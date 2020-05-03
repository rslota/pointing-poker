defmodule PointingPoker.Room do
  use GenServer

  alias PointingPoker.Room.Member

  def new_room(enabled_values) do
    room_id = Base.encode16(:crypto.strong_rand_bytes(18))
    {:ok, _pid} = DynamicSupervisor.start_child(PointingPoker.Room.Supervisor, {__MODULE__, [room_id, enabled_values]})

    {:ok, room_id}
  end

  def join(pid, username) do
    GenServer.call(pid, {:join, username, self()})
  end

  def vote(pid, user_id, value) do
    GenServer.cast(pid, {:vote, user_id, value})
  end

  def clear_votes(pid, user_id) do
    GenServer.cast(pid, {:clear_votes, user_id})
  end

  def show_votes(pid, user_id, show_votes) do
    GenServer.cast(pid, {:show_votes, user_id, show_votes})
  end

  def start_link([room_id, enabled_values]) do
    GenServer.start_link(__MODULE__, room_id, name: {:via, Registry, {Registry.Rooms, room_id, enabled_values}})
  end

  @impl GenServer
  def init(room_id) do
    {:ok, %{
      id: room_id,
      members: %{},
      show_votes: false,
      clear_time: DateTime.utc_now(),
      show_time: DateTime.utc_now(),
    }}
  end

  @impl GenServer
  def handle_call({:join, username, member_pid}, _from, state) do
    user_id = Base.encode64(:crypto.strong_rand_bytes(18))
    member = %Member{id: user_id, name: username, pid: member_pid}
    Process.monitor(member_pid)
    new_state = update_in(state.members, & Map.put(&1, user_id, member))
    bcast_room(new_state)
    {:reply, user_id, new_state}
  end

  @impl GenServer
  def handle_cast({:vote, user_id, value}, state) do
    new_state = update_in(state, [:members, user_id, :vote], fn _vote ->
      value
    end)
    bcast_room(new_state)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:show_votes, user_id, show_votes}, state) do
    new_state = %{state | show_votes: show_votes, show_time: DateTime.utc_now()}
    bcast_room(new_state)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:clear_votes, user_id}, state) do
    new_state =
      update_in(state.members, fn members ->
        members
        |> Enum.map(fn {id, member} -> {id, %Member{member | vote: nil}} end)
        |> Map.new()
      end)
    new_state = %{new_state | clear_time: DateTime.utc_now()}
    bcast_room(new_state)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    new_state = update_in(state.members, fn members ->
      members
      |> Enum.filter(fn {_, member} -> Process.alive?(member.pid) end)
      |> Map.new()
    end)
    bcast_room(new_state)
    {:noreply, new_state}
  end

  def bcast_room(state) do
    stats = gen_stats(state)
    Enum.each(state.members, fn {_, member} ->
      send(member.pid,
        %{
          members: Map.values(state.members),
          show_votes: state.show_votes,
          stats: stats
        })
    end)
  end

  def gen_stats(state) do
    integer_votes =
      state.members
      |> Map.values()
      |> Enum.map(& &1.vote || "")
      |> Enum.filter(fn vote ->
        case Integer.parse(vote, 10) do
          {int, ""} when is_integer(int) -> true
          _ -> false
        end
      end)
      |> Enum.map(& String.to_integer(&1))


    %{
      vote_count:
        state.members
        |> Map.values()
        |> Enum.map(& &1.vote)
        |> Enum.filter(& &1)
        |> Enum.frequencies(),
      time_taken: DateTime.diff(
        Map.get(state, :show_time, DateTime.utc_now()),
        Map.get(state, :clear_time, DateTime.utc_now())
      ),
      average_vote:
        if length(integer_votes) > 0 do
          Enum.sum(integer_votes) / length(integer_votes)
        else
          -1
        end
    }
  end
end
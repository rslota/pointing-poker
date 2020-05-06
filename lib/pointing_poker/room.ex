defmodule PointingPoker.Room do
  use GenServer

  alias PointingPoker.Room.{Member, Config}

  @shutdown_time 60 * 60 * 1000

  def new_room(enabled_values, manager_type) do
    room_id = Base.encode16(:crypto.strong_rand_bytes(6))

    {:ok, _pid} =
      DynamicSupervisor.start_child(
        PointingPoker.Room.Supervisor,
        {__MODULE__, [room_id, enabled_values, manager_type]}
      )

    {:ok, room_id}
  end

  def find_room(room_id) do
    case :syn.whereis(room_id) do
      :undefined ->
        {:error, :not_found}

      pid ->
        room_config = get_config(pid)
        {:ok, room_config}
    end
  end

  def join(pid, username, type) do
    GenServer.call(pid, {:join, username, type, self()})
  end

  def get_config(pid) do
    GenServer.call(pid, :get_config)
  end

  def vote(pid, user_id, value) do
    GenServer.cast(pid, {:vote, user_id, value})
  end

  def comment(pid, user_id, value) do
    GenServer.cast(pid, {:comment, user_id, value})
  end

  def clear_votes(pid, user_id) do
    GenServer.cast(pid, {:clear_votes, user_id})
  end

  def show_votes(pid, user_id, show_votes) do
    GenServer.cast(pid, {:show_votes, user_id, show_votes})
  end

  def start_link([room_id, enabled_values, manager_type]) do
    opts = %{
      room_id: room_id,
      enabled_values: enabled_values,
      manager_type: manager_type
    }

    GenServer.start_link(__MODULE__, opts, name: {:via, :syn, opts.room_id})
  end

  @impl GenServer
  def init(opts) do
    {:ok,
     %{
       config: %Config{
         id: opts.room_id,
         enabled_values: opts.enabled_values,
         manager_type: opts.manager_type,
         pid: self()
       },
       comment: "",
       members: %{},
       show_votes: false,
       clear_time: DateTime.utc_now(),
       show_time: DateTime.utc_now()
     }, @shutdown_time}
  end

  @impl GenServer
  def handle_call(:get_config, _from, state) do
    {:reply, state.config, state, @shutdown_time}
  end

  @impl GenServer
  def handle_call({:join, username, type, member_pid}, _from, state) do
    with user_id = Base.encode64(:crypto.strong_rand_bytes(18)),
         true <- Enum.member?([:voter, :observer], type),
         member = %Member{id: user_id, name: username, pid: member_pid, type: type} do
      Process.monitor(member_pid)
      new_state = update_in(state.members, &Map.put(&1, user_id, member))
      bcast_room(new_state)
      {:reply, member, new_state, @shutdown_time}
    else
      false -> {:reply, :error, state, @shutdown_time}
    end
  end

  @impl GenServer
  def handle_cast({:vote, user_id, value}, state) do
    new_state =
      update_in(state, [:members, user_id, :vote], fn _vote ->
        value
      end)

    bcast_room(new_state)
    {:noreply, new_state, @shutdown_time}
  end

  @impl GenServer
  def handle_cast({:comment, user_id, value}, state) do
    if state.config.manager_type == :voter || state.members[user_id].type == :observer do
      new_state = %{state | comment: value}
      bcast_room(new_state)
      {:noreply, new_state, @shutdown_time}
    else
      {:noreply, state, @shutdown_time}
    end
  end

  @impl GenServer
  def handle_cast({:show_votes, user_id, show_votes}, state) do
    if state.config.manager_type == :voter || state.members[user_id].type == :observer do
      new_state = %{state | show_votes: show_votes, show_time: DateTime.utc_now()}
      bcast_room(new_state)
      {:noreply, new_state, @shutdown_time}
    else
      {:noreply, state, @shutdown_time}
    end
  end

  @impl GenServer
  def handle_cast({:clear_votes, user_id}, state) do
    if state.config.manager_type == :voter || state.members[user_id].type == :observer do
      new_state =
        update_in(state.members, fn members ->
          members
          |> Enum.map(fn {id, member} -> {id, %Member{member | vote: nil}} end)
          |> Map.new()
        end)

      new_state = %{new_state | clear_time: DateTime.utc_now(), comment: ""}
      bcast_room(new_state)
      {:noreply, new_state, @shutdown_time}
    else
      {:noreply, state, @shutdown_time}
    end
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    case map_size(state.members) do
      0 ->
        {:stop, :shutdown, state}

      _ ->
        {:noreply, state, @shutdown_time}
    end
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    new_state =
      update_in(state.members, fn members ->
        members
        |> Enum.filter(fn {_, member} -> Process.alive?(member.pid) end)
        |> Map.new()
      end)

    bcast_room(new_state)
    {:noreply, new_state, @shutdown_time}
  end

  def bcast_room(state) do
    stats = gen_stats(state)

    Enum.each(state.members, fn {_, member} ->
      send(
        member.pid,
        %{
          members: Map.values(state.members),
          show_votes: state.show_votes,
          stats: stats,
          me: member,
          comment: state.comment
        }
      )
    end)
  end

  def gen_stats(state) do
    integer_votes =
      state.members
      |> Map.values()
      |> Enum.map(fn member ->
        PointingPoker.Room.Utils.to_number(member.vote || "")
      end)
      |> Enum.filter(&(&1 != :error))

    %{
      vote_count:
        state.members
        |> Map.values()
        |> Enum.map(& &1.vote)
        |> Enum.filter(& &1)
        |> Enum.frequencies(),
      time_taken:
        DateTime.diff(
          Map.get(state, :show_time, DateTime.utc_now()),
          Map.get(state, :clear_time, DateTime.utc_now())
        ),
      average_vote:
        if length(integer_votes) > 0 do
          Float.round(Enum.sum(integer_votes) / length(integer_votes), 2)
        else
          -1
        end
    }
  end
end

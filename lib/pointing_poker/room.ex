defmodule PointingPoker.Room do
  use GenServer

  alias PointingPoker.Room.Member

  def new_room() do
    room_id = Base.encode64(:crypto.strong_rand_bytes(18))
    {:ok, _pid} = DynamicSupervisor.start_child(PointingPoker.Room.Supervisor, {__MODULE__, room_id})

    {:ok, room_id}
  end

  def join(pid, username) do
    GenServer.call(pid, {:join, username, self()})
  end

  def start_link(room_id) do
    GenServer.start_link(__MODULE__, room_id, name: {:via, Registry, {Registry.Rooms, room_id, nil}})
  end

  @impl GenServer
  def init(room_id) do
    {:ok, %{
      id: room_id,
      members: []
    }}
  end

  @impl GenServer
  def handle_call({:join, username, member_pid}, _from, state) do
    user_id = Base.encode64(:crypto.strong_rand_bytes(18))
    member = %Member{id: user_id, name: username, pid: member_pid}
    Process.monitor(member_pid)
    new_state = update_in(state.members, & [member | &1])
    bcast_members(new_state)
    {:reply, user_id, new_state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    new_state = update_in(state.members, &Enum.filter(&1, fn member -> Process.alive?(member.pid) end))
    bcast_members(new_state)
    {:noreply, new_state}
  end

  def bcast_members(state) do
    Enum.each(state.members, fn member ->
      send(member.pid, {:members, state.members})
    end)
  end
end
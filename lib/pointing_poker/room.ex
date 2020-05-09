defmodule PointingPoker.Room do
  alias PointingPoker.Room.{Member, Config, Worker}

  @type id() :: String.t()

  @spec new([number()], Member.role()) :: PointingPoker.Error.maybe({:ok, Config.t()})
  def new(enabled_values, manager_type) do
    room_id = Base.encode16(:crypto.strong_rand_bytes(6))

    with {:ok, _pid} <-
           DynamicSupervisor.start_child(
             PointingPoker.Room.Supervisor,
             {Worker, [room_id, enabled_values, manager_type]}
           ) do
      {:ok, room_id}
    end
  end

  @spec find(id()) :: PointingPoker.Error.maybe({:ok, Config.t()})
  def find(room_id) do
    case :syn.whereis(room_id) do
      :undefined ->
        {:error,
         %PointingPoker.Error{
           category: :not_found,
           details: :room_process
         }}

      pid ->
        room_config = get_config(pid)
        {:ok, room_config}
    end
  end

  @spec join(pid(), String.t(), Member.role()) :: Member.t()
  def join(pid, username, role) do
    GenServer.call(pid, {:join, username, role, self()})
  end

  @spec get_config(pid()) :: Config.t()
  def get_config(pid) do
    GenServer.call(pid, :get_config)
  end

  @spec vote(pid(), Member.id(), number()) :: :ok
  def vote(pid, user_id, value) do
    GenServer.cast(pid, {:vote, user_id, value})
  end

  @spec comment(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def comment(pid, user_id, value) do
    GenServer.cast(pid, {:comment, user_id, value})
  end

  @spec clear_votes(pid(), Member.id()) :: :ok
  def clear_votes(pid, user_id) do
    GenServer.cast(pid, {:clear_votes, user_id})
  end

  @spec show_votes(pid(), Member.id(), boolean()) :: :ok
  def show_votes(pid, user_id, show_votes) do
    GenServer.cast(pid, {:show_votes, user_id, show_votes})
  end

  @spec trigger_update(pid()) :: :ok
  def trigger_update(pid) do
    GenServer.cast(pid, :trigger_update)
  end
end

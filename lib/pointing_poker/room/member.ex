defmodule PointingPoker.Room.Member do
  defstruct [:id, :name, :pid, :vote, :role]

  @type role() :: :voter | :observer
  @type id() :: String.t()

  def get_and_update(data, key, function) do
    Map.get_and_update(data, key, function)
  end
end

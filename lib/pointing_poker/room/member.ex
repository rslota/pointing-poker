defmodule PointingPoker.Room.Member do
  defstruct [:id, :name, :pid, :vote, :type]

  def get_and_update(data, key, function) do
    Map.get_and_update(data, key, function)
  end
end
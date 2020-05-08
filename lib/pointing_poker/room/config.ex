defmodule PointingPoker.Room.Config do
  defstruct [:id, :manager_type, :enabled_values, :pid]

  @type t() :: %__MODULE__{}
  @type manager_type() :: :voter | :observer

  def new(pid, room_id, enabled_values, manager_type) do
    %__MODULE__{
      id: room_id,
      enabled_values: parse_vote_values(enabled_values),
      pid: pid,
      manager_type: parse_manager_type(manager_type)
    }
  end

  defp parse_manager_type(:voter), do: :voter
  defp parse_manager_type(:observer), do: :observer

  defp parse_manager_type(_) do
    raise PointingPoker.Error,
      category: :invalid_argument,
      details: :manager_type
  end

  defp parse_vote_values(values) do
    values
    |> Enum.filter(&is_number/1)
    |> Enum.sort()
    |> Enum.uniq()
  end
end

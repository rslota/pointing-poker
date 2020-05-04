defmodule PointingPoker.Room.Utils do
  def to_number(value) when is_number(value), do: value

  def to_number(value) do
    case {Float.parse(value), Integer.parse(value)} do
      {_, {int, ""}} -> int
      {{float, ""}, _} -> float
      _ -> :error
    end
  end
end

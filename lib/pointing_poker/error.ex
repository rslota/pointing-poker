defmodule PointingPoker.Error do
  defexception [:category, :details]

  @type t() :: %__MODULE__{}
  @type maybe(ok_type) :: {:ok, ok_type} | {:error, PointingPoker.Error.t()}

  def message(e) do
    "#{e.category}: #{e.details}"
  end
end

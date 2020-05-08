defmodule PointingPoker.TestUtils.Room do
  alias PointingPoker.Room.Update

  @spec get_member(PointingPoker.Room.Update.t(), String.t()) ::
          PointingPoker.Room.Member.t() | nil
  def get_member(update, id) do
    update.members
    |> Enum.map(&{&1.id, &1})
    |> Map.new()
    |> Map.get(id)
  end

  @spec flush(non_neg_integer()) :: :ok | :timeout
  def flush(0), do: :ok

  def flush(n) do
    receive do
      %Update{} ->
        flush(n - 1)
    after
      1000 ->
        :timeout
    end
  end
end

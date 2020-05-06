defmodule PointingPokerWeb.HomeView do
  use PointingPokerWeb, :view

  @vote_form_fields_count 3

  def vote_form_fields(current_values, col_count) do
    elems = rem(length(current_values), col_count) + 1
    filler_count = col_count - elems
    fillers = Enum.map(1..filler_count, fn _ -> :noop end)

    current_values ++ [:add] ++ fillers
  end

  def format_vote_form_fields(current_values) do
    current_values
    |> vote_form_fields(@vote_form_fields_count)
    |> Enum.with_index()
    |> Enum.chunk_every(@vote_form_fields_count)
  end
end

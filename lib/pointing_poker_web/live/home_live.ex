defmodule PointingPokerWeb.HomeLive do
  use PointingPokerWeb, :live_view

  @default_values ["1", "2", "3", "5", "8", "11", "19", "30"]

  @impl true
  def mount(params, session, socket) do
    {:ok, assign(socket,
      enabled_values: @default_values,
    )}
  end

  def render(assigns) do
    Phoenix.View.render(PointingPokerWeb.RoomView, "create.html", assigns)
  end

  @impl true
  def handle_event("add_value", data, socket) do
    {:noreply, assign(socket, enabled_values: socket.assigns[:enabled_values] ++ [""])}
  end

  @impl true
  def handle_event("del", data, socket) do
    index = String.to_integer(data["value"])
    {_, new_enabled_values} = List.pop_at(socket.assigns[:enabled_values], index)
    {:noreply, assign(socket, enabled_values: new_enabled_values)}
  end

  def handle_event("change", data, socket) do
    enabled_values =
      data
      |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "value_") end)
      |> Enum.sort_by(fn {"value_" <> key, _} -> String.to_integer(key) end)
      |> Enum.reduce([], fn {key, value}, acc ->
        [value | acc]
      end)
    IO.inspect(Enum.reverse(enabled_values))
    {:noreply, assign(socket, enabled_values: Enum.reverse(enabled_values))}
  end

  def handle_event(_event, _data, socket) do
    IO.inspect({_event, _data})
    {:noreply, socket}
  end
end

defmodule PointingPokerWeb.HomeLive do
  use PointingPokerWeb, :live_view

  @default_values ["0", "0.5", "1", "2", "3", "5", "8", "13", "19"]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, enabled_values: @default_values)}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(PointingPokerWeb.HomeView, "create.html", assigns)
  end

  @impl true
  def handle_event("add_value", _data, socket) do
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
      |> Enum.reduce([], fn {_key, value}, acc ->
        [value | acc]
      end)

    {:noreply, assign(socket, enabled_values: Enum.reverse(enabled_values))}
  end

  def handle_event("join", data, socket) do
    room_id = data["room_id"]

    case PointingPoker.Room.find(room_id) do
      {:error, %PointingPoker.Error{category: :not_found}} ->
        {:noreply, put_flash(socket, :error, "Session '#{room_id}' does not exist!")}

      {:ok, config} ->
        {:noreply, redirect(socket, to: "/room/#{config.id}")}
    end
  end

  def handle_event(_event, _data, socket) do
    {:noreply, socket}
  end
end

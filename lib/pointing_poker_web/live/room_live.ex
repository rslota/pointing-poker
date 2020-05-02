defmodule PointingPokerWeb.RoomLive do
  use PointingPokerWeb, :live_view

  @enabled_values ["1", "2", "3", "5", "8", "11", "19", "30", "?"]

  @impl true
  def mount(params = %{"room_id" => room_id}, _session, socket) do
    # Check if room exists
    {:ok, assign(socket, room_id: room_id, enabled_values: @enabled_values, members: [])}
  end

  @impl true
  def handle_event(_event, _data, socket) do
    IO.inspect({_event, _data})
    {:noreply, socket}
  end
end

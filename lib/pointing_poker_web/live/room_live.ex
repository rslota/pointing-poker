defmodule PointingPokerWeb.RoomLive do
  use PointingPokerWeb, :live_view

  @enabled_values ["1", "2", "3", "5", "8", "11", "19", "30", "?"]

  @impl true
  def mount(params, session, socket) do
    # Check if room exists
    room_id = Map.get(params, "room_id")
    case Registry.lookup(Registry.Rooms, room_id) do
      [] ->
        {:ok, assign(socket, room_id: nil)}
      [{pid, _}] ->
        {:ok, assign(socket,
          room_id: room_id,
          enabled_values: @enabled_values,
          members: [],
          room_pid: pid,
          user_id: nil
        )}
    end
  end

  def render(%{room_id: nil} = assigns) do
    ~L"""
    Room not found!
    """
  end

  def render(%{user_id: nil} = assigns) do
    Phoenix.View.render(PointingPokerWeb.RoomView, "join.html", assigns)
  end

  def render(assigns) do
    Phoenix.View.render(PointingPokerWeb.RoomView, "show.html", assigns)
  end

  @impl true
  def handle_event("join", %{"username" => username}, socket) do
    user_id = PointingPoker.Room.join(Map.get(socket.assigns, :room_pid), username)
    {:noreply, assign(socket, user_id: user_id)}
  end

  def handle_event(_event, _data, socket) do
    IO.inspect({_event, _data})
    {:noreply, socket}
  end

  def handle_info({:members, members}, socket) do
    {:noreply, assign(socket, members: members)}
  end
end
defmodule PointingPokerWeb.RoomLive do
  use PointingPokerWeb, :live_view
  use Timex

  @enabled_values ["1", "2", "3", "5", "8", "11", "19", "30", "?"]

  @impl true
  def mount(params, session, socket) do
    # Check if room exists
    room_id = Map.get(params, "room_id")
    case Registry.lookup(Registry.Rooms, room_id) do
      [] ->
        {:ok, assign(socket, room_id: nil)}
      [{pid, enabled_values}] ->
        {:ok, assign(socket,
          room_id: room_id,
          enabled_values: enabled_values ++ ["?"],
          members: [],
          room_pid: pid,
          user_id: nil,
          show_votes: false
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
    room_pid = Map.get(socket.assigns, :room_pid)
    user_id = PointingPoker.Room.join(room_pid, username)
    {:noreply, assign(socket, user_id: user_id, username: username)}
  end

  def handle_event("vote", %{"value" => value}, socket) do
    room_pid = Map.get(socket.assigns, :room_pid)
    user_id = Map.get(socket.assigns, :user_id)
    :ok = PointingPoker.Room.vote(room_pid, user_id, value)
    {:noreply, socket}
  end

  def handle_event("clear", %{}, socket) do
    room_pid = Map.get(socket.assigns, :room_pid)
    user_id = Map.get(socket.assigns, :user_id)
    :ok = PointingPoker.Room.clear_votes(room_pid, user_id)
    :ok = PointingPoker.Room.show_votes(room_pid, user_id, false)
    {:noreply, socket}
  end

  def handle_event("show", %{}, socket) do
    room_pid = Map.get(socket.assigns, :room_pid)
    user_id = Map.get(socket.assigns, :user_id)
    :ok = PointingPoker.Room.show_votes(room_pid, user_id, true)
    {:noreply, socket}
  end

  def handle_event("hide", %{}, socket) do
    room_pid = Map.get(socket.assigns, :room_pid)
    user_id = Map.get(socket.assigns, :user_id)
    :ok = PointingPoker.Room.show_votes(room_pid, user_id, false)
    {:noreply, socket}
  end

  def handle_event(_event, _data, socket) do
    IO.inspect({_event, _data})
    {:noreply, socket}
  end

  def handle_info(%{members: members, show_votes: show_votes, stats: stats}, socket) do
    {:noreply, assign(socket,
      members: members,
      show_votes: show_votes,
      stats: %{
        vote_count: stats.vote_count,
        time_taken:
          stats.time_taken
          |> Duration.from_seconds()
          |> Timex.format_duration(:humanized),
        average_vote:
          if stats.average_vote >= 0 do
            stats.average_vote
          else
            ":("
          end
      }
    )}
  end
end

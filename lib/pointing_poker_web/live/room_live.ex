defmodule PointingPokerWeb.RoomLive do
  use PointingPokerWeb, :live_view
  use Timex

  alias PointingPoker.Room.Utils

  @impl true
  def mount(params, _session, socket) do
    # Check if room exists
    room_id = Map.get(params, "room_id")

    case PointingPoker.Room.find(room_id) do
      {:error, %PointingPoker.Error{category: :not_found}} ->
        {:ok, assign(socket, room_config: nil)}

      {:ok, room_config} ->
        Process.monitor(room_config.pid)

        {:ok,
         assign(socket,
           room_config: room_config,
           members: [],
           show_votes?: false,
           me: nil,
           comment: ""
         )}
    end
  end

  @impl true
  def render(%{room_config: nil} = assigns) do
    ~L"""
    Room not found! <a href="/">Go back</a>
    """
  end

  def render(%{me: nil} = assigns) do
    Phoenix.View.render(PointingPokerWeb.RoomView, "join.html", assigns)
  end

  def render(assigns) do
    Phoenix.View.render(PointingPokerWeb.RoomView, "show.html", assigns)
  end

  @impl true
  def handle_event("join", %{"username" => username, "type" => type} = _data, socket) do
    username = String.trim(username)

    case String.length(username) > 0 do
      true ->
        room_pid = socket.assigns[:room_config].pid
        member = PointingPoker.Room.join(room_pid, username, String.to_existing_atom(type))
        {:noreply, clear_flash(assign(socket, me: member))}

      false ->
        {:noreply, put_flash(socket, :error, "Please enter a name!")}
    end
  end

  def handle_event("vote", %{"value" => value}, socket) do
    room_pid = socket.assigns[:room_config].pid
    user_id = socket.assigns[:me].id

    :ok = PointingPoker.Room.vote(room_pid, user_id, Utils.to_number(value))
    {:noreply, socket}
  end

  def handle_event("comment", data, socket) do
    room_pid = socket.assigns[:room_config].pid
    user_id = socket.assigns[:me].id
    :ok = PointingPoker.Room.comment(room_pid, user_id, data["comment"])
    {:noreply, socket}
  end

  def handle_event("clear", %{}, socket) do
    room_pid = socket.assigns[:room_config].pid
    user_id = socket.assigns[:me].id
    :ok = PointingPoker.Room.clear_votes(room_pid, user_id)
    :ok = PointingPoker.Room.show_votes(room_pid, user_id, false)
    {:noreply, socket}
  end

  def handle_event("show", %{}, socket) do
    room_pid = socket.assigns[:room_config].pid
    user_id = socket.assigns[:me].id
    :ok = PointingPoker.Room.show_votes(room_pid, user_id, true)
    {:noreply, socket}
  end

  def handle_event("hide", %{}, socket) do
    room_pid = socket.assigns[:room_config].pid
    user_id = socket.assigns[:me].id
    :ok = PointingPoker.Room.show_votes(room_pid, user_id, false)
    {:noreply, socket}
  end

  def handle_event(_event, _data, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket) do
    case pid == socket.assigns.room_config.pid do
      true ->
        {:noreply, assign(socket, room_config: nil)}

      false ->
        {:noreply, socket}
    end
  end

  def handle_info(
        %{comment: comment, members: members, show_votes?: show_votes, stats: stats, me: me},
        socket
      ) do
    {:noreply,
     assign(socket,
       members: members,
       show_votes?: show_votes,
       me: me,
       comment: comment,
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

defmodule PointingPokerWeb.RoomController do
  use PointingPokerWeb, :controller
  import Phoenix.LiveView.Controller

  def create(conn, _params) do
    {:ok, room_id} = PointingPoker.Room.new_room()
    # Create the room
    redirect(conn, to: "/room/#{room_id}")
  end
end
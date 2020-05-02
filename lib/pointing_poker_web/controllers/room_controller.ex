defmodule PointingPokerWeb.RoomController do
  use PointingPokerWeb, :controller

  def create(conn, _params) do
    room_id = Base.encode64(:crypto.strong_rand_bytes(18))
    # Create the room
    redirect(conn, to: "/room/#{room_id}")
  end
end
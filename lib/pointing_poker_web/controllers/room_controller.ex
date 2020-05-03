defmodule PointingPokerWeb.RoomController do
  use PointingPokerWeb, :controller
  import Phoenix.LiveView.Controller

  def create(conn, params) do
    enabled_values =
      params
      |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "value_") end)
      |> Enum.filter(fn {_key, value} ->
        case Integer.parse(value, 10) do
          {_, ""} -> true
          _ -> false
        end
      end)
      |> Enum.map(fn {_key, value} -> value end)
      |> Enum.uniq()

    {:ok, room_id} = PointingPoker.Room.new_room(enabled_values)
    # Create the room
    redirect(conn, to: "/room/#{room_id}")
  end
end
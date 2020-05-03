defmodule PointingPokerWeb.RoomController do
  use PointingPokerWeb, :controller
  import Phoenix.LiveView.Controller

  def create(conn, params) do
    enabled_values =
      params
      |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "value_") end)
      |> Enum.map(fn {_key, value} ->
        PointingPoker.Room.Utils.to_number(value)
      end)
      |> Enum.filter(& &1 != :error)
      |> Enum.sort()
      |> Enum.uniq()

    manager_type = String.to_existing_atom(params["manager_type"])
    {:ok, room_id} = PointingPoker.Room.new_room(enabled_values, manager_type)
    # Create the room
    redirect(conn, to: "/room/#{room_id}")
  end
end
defmodule PointingPokerWeb.RoomControllerTest do
  use PointingPokerWeb.ConnCase

  alias PointingPoker.Room

  test "room can be created with correct params with voter as manager", %{conn: conn} do
    conn =
      post(conn, "/room",
        manager_type: "voter",
        value_1: "1.0",
        value_2: 5,
        value_3: "random",
        value_4: "0.5",
        value_5: 1.8,
        value_6: "39",
        value_8: "6",
        value_11: "40234230.31"
      )

    assert redirected_to(conn) =~ ~r"/room/[A-Z0-9]+"

    "/room/" <> room_id = redirected_to(conn)
    assert {:ok, room_config} = Room.find(room_id)
    assert room_config.manager_type == :voter
    assert room_config.enabled_values == [0.5, 1.0, 1.8, 5, 6, 39, 40_234_230.31]
  end

  test "room can be created with correct params with observer as manager", %{conn: conn} do
    conn =
      post(conn, "/room",
        manager_type: "observer",
        value_1: "1.0",
        value_2: 5,
        value_3: "random",
        value_4: "0.5",
        value_5: 1.8,
        value_6: "39",
        value_8: "6",
        value_11: "40234230.31"
      )

    assert redirected_to(conn) =~ ~r"/room/[A-Z0-9]+"

    "/room/" <> room_id = redirected_to(conn)
    assert {:ok, room_config} = Room.find(room_id)
    assert room_config.manager_type == :observer
    assert room_config.enabled_values == [0.5, 1.0, 1.8, 5, 6, 39, 40_234_230.31]
  end
end

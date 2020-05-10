defmodule PointingPokerWeb.EmptyRoomLiveTest do
  use PointingPokerWeb.ConnCase
  use AssertEventually
  alias PointingPoker.Room

  import Phoenix.LiveViewTest

  describe "in non-existing room" do
    test "user get not found error", %{conn: conn} do
      {:ok, page_live, _disconnected_html} = live(conn, "/room/12345")
      assert page_live |> element("a[href='/'", "Go back") |> render() =~ "Go back"
    end
  end

  describe "in room with observer as manager" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, 10], :observer)
      {:ok, room} = Room.find(room_id)
      %{room: room}
    end

    test "voters can see comment section", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "voter"
      })

      assert element(page_live, "form[phx-change=comment] textarea[name=comment][readonly]")
             |> has_element?()
    end

    test "observers can see comment section", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "observer"
      })

      refute element(page_live, "form[phx-change=comment] textarea[name=comment][readonly]")
             |> has_element?()

      assert element(page_live, "form[phx-change=comment] textarea[name=comment]")
             |> has_element?()
    end

    test "voters can't see clear/show buttons", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "voter"
      })

      refute element(page_live, "button[phx-click=show]", "Show votes") |> has_element?()
      refute element(page_live, "button[phx-click=clear]", "Clear votes") |> has_element?()
    end

    test "obeservers see clear/show buttons", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "observer"
      })

      assert element(page_live, "button[phx-click=show]", "Show votes") |> has_element?()
      assert element(page_live, "button[phx-click=clear]", "Clear votes") |> has_element?()
    end
  end

  describe "in room with voter as manager" do
    setup do
      {:ok, room_id} = Room.new([1, 5, 80.1, 2.5, 3, 3, 10], :voter)
      {:ok, room} = Room.find(room_id)
      %{room: room}
    end

    test "voters can see comment section", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "voter"
      })

      refute element(page_live, "form[phx-change=comment] textarea[name=comment][readonly]")
             |> has_element?()

      assert element(page_live, "form[phx-change=comment] textarea[name=comment]")
             |> has_element?()
    end

    test "observers can see comment section", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "observer"
      })

      refute element(page_live, "form[phx-change=comment] textarea[name=comment][readonly]")
             |> has_element?()

      assert element(page_live, "form[phx-change=comment] textarea[name=comment]")
             |> has_element?()
    end

    test "users can see join form", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      assert page_live
             |> element("form[phx-submit=join] input[name=username][type=text]")
             |> has_element?()

      assert page_live
             |> element("form[phx-submit=join] select[name=role] option[value=voter]")
             |> has_element?()

      assert page_live
             |> element("form[phx-submit=join] select[name=role] option[value=observer]")
             |> has_element?()

      assert page_live
             |> element("form[phx-submit=join] button[type=submit]", "Join")
             |> has_element?()
    end

    test "users cannot join the room without name", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "",
        "role" => "voter"
      })

      assert element(page_live, "p[phx-value-key=error]", "Please enter a name") |> has_element?()
    end

    test "users cannot join the room with invalid role", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "something"
      })

      assert element(page_live, "p[phx-value-key=error]", "Please enter a valid role")
             |> has_element?()
    end

    test "voters see voting buttons", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "voter"
      })

      assert element(page_live, "button[phx-click=vote][value=1]", "1") |> has_element?()
      assert element(page_live, "button[phx-click=vote][value='2.5']", "2.5") |> has_element?()
      assert element(page_live, "button[phx-click=vote][value=3]", "3") |> has_element?()
      assert element(page_live, "button[phx-click=vote][value=5]", "5") |> has_element?()
      assert element(page_live, "button[phx-click=vote][value=10]", "10") |> has_element?()
      assert element(page_live, "button[phx-click=vote][value='80.1']", "80.1") |> has_element?()
      assert element(page_live, "button[phx-click=vote][value='?']", "?") |> has_element?()
    end

    test "voters see clear/show buttons", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "voter"
      })

      assert element(page_live, "button[phx-click=show]", "Show votes") |> has_element?()
      assert element(page_live, "button[phx-click=clear]", "Clear votes") |> has_element?()
    end

    test "obeservers see clear/show buttons", %{room: room, conn: conn} do
      {:ok, page_live, _disconnected_html1} = live(conn, "/room/#{room.id}")

      render_submit(page_live, "join", %{
        "username" => "my name",
        "role" => "observer"
      })

      assert element(page_live, "button[phx-click=show]", "Show votes") |> has_element?()
      assert element(page_live, "button[phx-click=clear]", "Clear votes") |> has_element?()
    end

    test "users can join the room and see all others but observers", %{
      room: room,
      conn1: conn1,
      conn2: conn2,
      conn3: conn3
    } do
      {:ok, page_live1, _disconnected_html1} = live(conn1, "/room/#{room.id}")
      {:ok, page_live2, _disconnected_html1} = live(conn2, "/room/#{room.id}")
      {:ok, page_live3, _disconnected_html1} = live(conn3, "/room/#{room.id}")

      # Voter 1 joins
      render_submit(page_live1, "join", %{
        "username" => "Voter 1",
        "role" => "voter"
      })

      eventually(assert element(page_live1, "tr td b", "Voter 1") |> has_element?())

      # Voter 2 joins
      render_submit(page_live2, "join", %{
        "username" => "Voter 2",
        "role" => "voter"
      })

      eventually(assert element(page_live1, "tr td", "Voter 2") |> has_element?())
      eventually(assert element(page_live2, "tr td", "Voter 1") |> has_element?())
      eventually(assert element(page_live2, "tr td b", "Voter 2") |> has_element?())

      # Observer joins
      render_submit(page_live3, "join", %{
        "username" => "Observer",
        "role" => "observer"
      })

      eventually(assert element(page_live3, "tr td", "Voter 2") |> has_element?())
      eventually(assert element(page_live3, "tr td", "Voter 1") |> has_element?())

      eventually(refute element(page_live1, "tr td", "Observer") |> has_element?())
      eventually(refute element(page_live2, "tr td", "Observer") |> has_element?())
      eventually(refute element(page_live2, "tr td", "Observer") |> has_element?())
    end
  end
end

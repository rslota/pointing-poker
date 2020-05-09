defmodule PointingPokerWeb.PageLiveTest do
  use PointingPokerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")

    assert disconnected_html =~ "PointingPoker"
    assert disconnected_html =~ "Create new session!"
    assert disconnected_html =~ "Join the session!"

    assert render(page_live) =~ "PointingPoker"
    assert render(page_live) =~ "Create new session!"
    assert render(page_live) =~ "Join the session!"
  end
end

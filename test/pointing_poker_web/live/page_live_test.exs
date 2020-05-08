defmodule PointingPokerWeb.PageLiveTest do
  use PointingPokerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "PointingPoker"
    assert render(page_live) =~ "PointingPoker"
  end
end

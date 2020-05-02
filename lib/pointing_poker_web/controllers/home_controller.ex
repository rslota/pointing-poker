defmodule PointingPokerWeb.HomeController do
  use PointingPokerWeb, :controller

  def index(conn, _params) do
    # render(PointingPokerWeb.LayoutView, "index.html", [])
    render(conn, :index)
  end
end
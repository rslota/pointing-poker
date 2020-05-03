defmodule PointingPokerWeb.HomeController do
  use PointingPokerWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
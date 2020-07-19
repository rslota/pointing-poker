defmodule PointingPokerWeb.SettingsController do
  use PointingPokerWeb, :controller

  def set(conn, params) do
    if params["theme"] in ["dark", "light"] do
      conn
      |> put_session(:theme, params["theme"])
      |> redirect_to_referer()
    else
      render(conn, PointingPokerWeb.ErrorView, "400.html")
    end
  end

  defp redirect_to_referer(conn) do
    case get_req_header(conn, "referer") do
      [url] ->
        redirect(conn, external: url)

      _ ->
        redirect(conn, to: "/")
    end
  end
end

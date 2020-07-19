defmodule PointingPokerWeb.Router do
  use PointingPokerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PointingPokerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug BasicAuth, use_config: {:pointing_poker, BasicAuth}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PointingPokerWeb do
    pipe_through :browser

    live "/", HomeLive
    post "/room", RoomController, :create
    live "/room/:room_id", RoomLive

    get "/settings", SettingsController, :set
  end

  # Other scopes may use custom stacks.
  # scope "/api", PointingPokerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through [:browser, :admin]
    live_dashboard "/dashboard", metrics: PointingPokerWeb.Telemetry
  end
end

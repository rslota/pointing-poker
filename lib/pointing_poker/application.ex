defmodule PointingPoker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # PointingPoker.Repo,
      # Start the Telemetry supervisor
      PointingPokerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PointingPoker.PubSub},
      # Start the Endpoint (http/https)
      PointingPokerWeb.Endpoint,
      PointingPoker.Room.Supervisor,
      {Registry, keys: :unique, name: Registry.Rooms},
      # Start a worker by calling: PointingPoker.Worker.start_link(arg)
      # {PointingPoker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PointingPoker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PointingPokerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

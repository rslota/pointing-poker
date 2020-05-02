defmodule PointingPoker.Repo do
  use Ecto.Repo,
    otp_app: :pointing_poker,
    adapter: Ecto.Adapters.Postgres
end

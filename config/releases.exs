import Config

config :pointing_poker, PointingPokerWeb.Endpoint,
  url: [host: System.get_env("HOST"), port: String.to_integer(System.get_env("PORT"))],
  http: [port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  code_reloader: false,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

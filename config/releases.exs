import Config

config :pointing_poker, PointingPokerWeb.Endpoint,
  url: [host: System.get_env("HOST"), port: String.to_integer(System.get_env("PORT"))],
  http: [port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  code_reloader: false,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :pointing_poker, BasicAuth,
  username: System.get_env("POINTINGPOKER_ADMIN_USER") || "admin",
  password:
    System.get_env("POINTINGPOKER_ADMIN_PASSWORD") || Base.encode16(:crypto.strong_rand_bytes(16)),
  realm: "Admin Area"

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id]

# Do not print debug messages in production
config :logger, level: :info

config :libcluster,
  debug: false

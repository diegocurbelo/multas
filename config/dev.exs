use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :multas, Multas.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []


# Watch static and templates for browser reloading.
config :multas, Multas.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :multas, Multas.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "multas_dev",
  hostname: "localhost",
  pool_size: 10,
  loggers: [Multas.Metrics.RepoInstrumenter]

# Facebook
config :multas, :facebook,
  app_id: "149447142211748",
  app_secret: "faa573023e34ee4b734faea6a95591be",
  page_access_token: "EAACH69ZCTAKQBAJMGp41HaTBOSIRFyy5YOkxs9zzCcveeSB58TYZCje0NJrVAOS6eM6P4vOkc3g6iuvFnOGGb5W51uZCT114H9UCE7KRAWk5gePZC8ArmU0Bl9ImVootQsLzZAlKojgewyIKVNQq9n3yqGeBrIvtPIpSOJzhamAZDZD"
  # graph_url: "https://graph.facebook.com/v2.8",
  # redirect_uri: "http://localhost:3000/login"

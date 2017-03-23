# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :multas,
  ecto_repos: [Multas.Repo]

# Configures the endpoint
config :multas, Multas.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "G/aaM2LD0I16jwiTh+GHnqPXgQfWkY0Zqla9uc9P78qfXV3WcnkfsbhUAnA9nwt2",
  render_errors: [view: Multas.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Multas.PubSub,
           adapter: Phoenix.PubSub.PG2],
  instrumenters: [Multas.Metrics.PhoenixInstrumenter]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :prometheus, Multas.Metrics.PhoenixInstrumenter,  
  controller_call_labels: [:controller, :action],
  duration_buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000,
                     10_000, 25_000, 50_000, 100_000, 250_000, 500_000,
                     1_000_000, 2_500_000, 5_000_000, 10_000_000],
  registry: :default,
  duration_unit: :microseconds

config :prometheus, Multas.Metrics.PipelineInstrumenter,  
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [10, 100, 1_000, 10_000, 100_000,
                     300_000, 500_000, 750_000, 1_000_000,
                     1_500_000, 2_000_000, 3_000_000],
  registry: :default,
  duration_unit: :microseconds

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

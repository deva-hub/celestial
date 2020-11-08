# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :celestial,
  ecto_repos: [Celestial.Repo]

config :celestial_web,
  ecto_repos: [Celestial.Repo],
  generators: [context_app: :celestial]

# Configures the endpoint
config :celestial_web, CelestialWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SnbttDD+34FXLe8ZVbbsl2Nhj4s3volMmtLV+oblFi3vLG/Bld/OlymgifoMa44Q",
  render_errors: [view: CelestialWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Celestial.PubSub,
  live_view: [signing_salt: "IDE+hU6q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

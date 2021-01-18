# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :celestial,
  ecto_repos: [Celestial.Repo]

config :celestial_web,
  ecto_repos: [Celestial.Repo],
  generators: [context_app: :celestial]

# Configures the endpoint
config :celestial_web, CelestialWeb.Endpoint,
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

case config_env() do
  :dev ->
    # Configure the database
    config :celestial, Celestial.Repo,
      show_sensitive_data_on_connection_error: true,
      pool_size: 10

    # For development, we disable any cache and enable
    # debugging and code reloading.
    #
    # The watchers configuration can be used to run external
    # watchers to your application. For example, we use it
    # with webpack to recompile .js and .css sources.
    config :celestial_web, CelestialWeb.Endpoint,
      debug_errors: true,
      code_reloader: true,
      check_origin: false,
      server: true

    # Do not include metadata nor timestamps in development logs
    config :logger, :console, format: "[$level] $message\n"

    # Initialize plugs at runtime for faster development compilation
    config :phoenix, :plug_init_mode, :runtime

    # Set a higher stacktrace during development. Avoid configuring such
    # in production as building large stacktraces may be expensive.
    config :phoenix, :stacktrace_depth, 20

  :test ->
    # We don't run a server during test. If one is required,
    # you can enable the server option below.
    config :celestial_web, CelestialWeb.Endpoint, server: false

    # Print only warnings and errors during test
    config :logger, level: :warn

  :prod ->
    # Do not print debug messages in production
    config :logger, level: :info
end

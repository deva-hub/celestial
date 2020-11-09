use Mix.Config

# Configure mailing service
config :celestial_web, CelestialWeb.Mailer, adapter: Swoosh.Adapters.Local

config :celestial_web,
  recovery_url: "http://example.com/recovery",
  email_url: "http://example.com/email",
  confirmation_url: "http://example.com/confirmation"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :celestial, Celestial.Repo,
  username: "postgres",
  password: "postgres",
  database: "celestial_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :celestial_web, CelestialWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

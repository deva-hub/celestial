import Config

# Configure the database
config :celestial, Celestial.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost")

# Configure Celestial channel node port
config :celestial_world,
  gateway_port: System.get_env("CELESTIAL_CHANNEL_PORT", "4123") |> String.to_integer(),
  channel_port: System.get_env("CELESTIAL_CHANNEL_PORT", "4124") |> String.to_integer()

# Configure email redirection
app_url = System.get_env("CELESTIAL_APP_URL", "http://localhost:3000")

config :celestial_web,
  recovery_url: "#{app_url}/recovery",
  email_url: "#{app_url}/email",
  confirmation_url: "#{app_url}/confirmation"

# Don't forget to configure the url hostto something
# meaningful, Phoenix uses this information when
# generating URLs.
config :celestial_web, CelestialWeb.Endpoint,
  url: [
    host: System.get_env("HOST", "0.0.0.0"),
    port: System.get_env("PORT", "4000") |> String.to_integer()
  ]

case config_env() do
  :dev ->
    # Configure the database
    config :celestial, Celestial.Repo, database: System.get_env("POSTGRES_DB", "celestial_dev")

  :test ->
    # The MIX_TEST_PARTITION environment variable can be used
    # to provide built-in test partitioning in CI environment.
    # Run `mix help test` for more information.
    config :celestial, Celestial.Repo,
      database:
        System.get_env("POSTGRES_DB", "celestial_test#{System.get_env("MIX_TEST_PARTITION")}"),
      pool: Ecto.Adapters.SQL.Sandbox

  :prod ->
    # Configure Celestial gateway client version requirement
    client_version =
      System.get_env("CELESTIAL_CLIENT_VERSION") ||
        raise """
        environment variable CELESTIAL_CLIENT_VERSION is missing.
        Enforce a compatible and stable client version
        """

    config :celestial_world, client_version: client_version

    # Configures the endpoint
    secret_key_base =
      System.get_env("CELESTIAL_SECRET_KEY_BASE") ||
        raise """
        environment variable CELESTIAL_SECRET_KEY_BASE is missing.
        You can generate one by calling: mix phx.gen.secret
        """

    config :celestial_web, CelestialWeb.Endpoint,
      http: [transport_options: [socket_opts: [:inet6]]],
      secret_key_base: secret_key_base,
      server: true

    # Configures the database
    config :celestial, Celestial.Repo,
      database: System.get_env("POSTGRES_DB", "celestial"),
      pool_size: System.get_env("POOL_SIZE", "10") |> String.to_integer()

    # Configure the distribution protocol port
    dist_port = System.get_env("CELESTIAL_DIST_PORT", "49300") |> String.to_integer()

    config :kernel,
      inet_dist_listen_min: dist_port,
      inet_dist_listen_max: dist_port
end

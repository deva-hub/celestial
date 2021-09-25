defmodule Celestial.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Celestial.Repo,
      # Start the Telemetry supervisor
      CelestialWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Celestial.PubSub},
      # Start the Endpoint (http/https)
      CelestialWeb.Endpoint,
      # Start the Nostale Gateway
      :ranch.child_spec(
        CelestiaNetwork.Gateway.TCP,
        :ranch_tcp,
        [port: 4123],
        CelestiaNetwork.Gateway,
        []
      )
      # Start a worker by calling: Celestial.Worker.start_link(arg)
      # {Celestial.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Celestial.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CelestialWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule CelestialWorld.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias CelestialWorld.{Gateway, Channel}

  def start(_type, _args) do
    gateway_port =
      Application.get_env(:celestial_world, :gateway_port) ||
        raise ":gateway_port not set in :celestial_world application"

    channel_port =
      Application.get_env(:celestial_world, :channel_port) ||
        raise ":channel_port not set in :celestial_world application"

    children = [
      # Start the Gateway TCP Server
      {Nostalex.Endpoint, [port: gateway_port, handler: Gateway, protocol_opts: [connect_info: [:peer_data]]]},
      # Start the Channel TCP Server
      {Nostalex.Endpoint, [port: channel_port, handler: Channel, protocol_opts: [connect_info: [:peer_data]]]}
      # Start a worker by calling: CelestialWorld.Worker.start_link(arg)
      # {CelestialWorld.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialWorld.Supervisor)
  end
end

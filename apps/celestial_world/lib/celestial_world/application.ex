defmodule CelestialWorld.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    gateway_endpoint_opts = [
      port: 4123,
      handler: CelestialWorld.Gateway,
      protocol_opts: [connect_info: [:peer_data]]
    ]

    channel_enpdoint_opts = [
      port: 4124,
      handler: CelestialWorld.Channel,
      protocol_opts: [connect_info: [:peer_data, :handoff_key, :packet_id, :current_identity]]
    ]

    children = [
      # Start the TCP Server
      {Nostalex.Endpoint, gateway_endpoint_opts},
      {Nostalex.Endpoint, channel_enpdoint_opts}
      # Start a worker by calling: CelestialWorld.Worker.start_link(arg)
      # {CelestialWorld.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialWorld.Supervisor)
  end
end

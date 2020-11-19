defmodule CelestialChannel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port =
      Application.get_env(:celestial_channel, :port) ||
        raise ":port not set in :celestial_channel application"

    hostname =
      Application.get_env(:celestial_channel, :hostname) ||
        raise ":hostname not set in :celestial_channel application"

    name =
      Application.get_env(:celestial_channel, :name) ||
        raise ":name not set in :celestial_channel application"

    children = [
      # Start the Presence server
      {CelestialChannel.Presence, []},
      # Start the Channel manager
      {CelestialChannel.Manager,
       [
         id: 1,
         world_id: 1,
         world_name: name,
         hostname: hostname,
         port: port
       ]},
      # Start the TCP Server
      {Nostalex.Endpoint,
       [
         port: port,
         handler: CelestialChannel.Socket,
         handler_opts: [connect_info: [:peer_data]]
       ]}
      # Start a worker by calling: CelestialChannel.Worker.start_link(arg)
      # {CelestialChannel.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialChannel.Supervisor)
  end
end

defmodule CelestialPortal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    name =
      Application.get_env(:celestial_world, :name) ||
        raise ":name not set in :celestial_world application"

    id =
      Application.get_env(:celestial_world, :id) ||
        raise ":name not set in :celestial_world application"

    channel_id =
      Application.get_env(:celestial_world, :channel_id) ||
        raise ":name not set in :celestial_world application"

    port =
      Application.get_env(:celestial_portal, :port) ||
        raise ":port not set in :celestial_portal application"

    hostname =
      Application.get_env(:celestial_portal, :hostname) ||
        raise ":hostname not set in :celestial_portal application"

    children = [
      # Start the Presence server
      {CelestialPortal.Presence, []},
      # Start the Channel manager
      {CelestialPortal.Manager,
       [
         id: id,
         channel_id: channel_id,
         world_name: name,
         hostname: hostname,
         port: port
       ]},
      # Start the TCP Server
      {Nostalex.Endpoint,
       [
         port: port,
         handler: CelestialPortal.Socket,
         handler_opts: [
           serializer: CelestialPortal.Serializer,
           connect_info: [:peer_data]
         ]
       ]}
      # Start a worker by calling: CelestialPortal.Worker.start_link(arg)
      # {CelestialPortal.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialPortal.Supervisor)
  end
end

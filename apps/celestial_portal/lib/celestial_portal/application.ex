defmodule CelestialPortal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    id =
      Application.get_env(:celestial_portal, :world) ||
        raise ":name not set in :celestial_portal application"

    channel_id =
      Application.get_env(:celestial_portal, :channel) ||
        raise ":name not set in :celestial_portal application"

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
      {CelestialPortal.Oracle,
       [
         id: id,
         channel_id: channel_id,
         world_name: "Celestial",
         hostname: hostname,
         port: port
       ]},
      # Start the TCP Server
      {Nostalex.Endpoint,
       [
         port: port,
         handler: CelestialPortal.Socket,
         handler_opts: [
           pubsub_server: Celestial.PubSub,
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

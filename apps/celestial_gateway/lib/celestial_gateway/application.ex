defmodule CelestialGateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port =
      Application.get_env(:celestial_gateway, :port) ||
        raise ":port not set in :celestial_gateway application"

    children = [
      # Start the TCP Server
      {Nostalex.Endpoint, port: port, handler: CelestialGateway.Socket, handler_opts: [connect_info: [:peer_data]]}
      # Start a worker by calling: CelestialGateway.Worker.start_link(arg)
      # {CelestialGateway.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialGateway.Supervisor)
  end
end

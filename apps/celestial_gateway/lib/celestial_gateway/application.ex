defmodule CelestialGateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the TCP Server
      {Nostalex.Endpoint, scheme: :tcp, port: 4123, handler: CelestialGateway.Handler, protocol_opts: [connect_info: [:peer_data]]}
      # Start a worker by calling: CelestialGateway.Worker.start_link(arg)
      # {CelestialGateway.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialGateway.Supervisor)
  end
end

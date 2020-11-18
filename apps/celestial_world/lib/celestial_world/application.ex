defmodule CelestialWorld.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port =
      Application.get_env(:celestial_world, :port) ||
        raise ":port not set in :celestial_world application"

    children = [
      # Start the TCP Server
      {Nostalex.Endpoint, [port: port, handler: CelestialWorld.Socket, handler_opts: [connect_info: [:peer_data]]]}
      # Start a worker by calling: CelestialWorld.Worker.start_link(arg)
      # {CelestialWorld.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialWorld.Supervisor)
  end
end

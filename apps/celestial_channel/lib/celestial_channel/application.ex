defmodule CelestialChannel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the TCP Server
      {CelestialChannel.Server, []}
      # Start a worker by calling: CelestialChannel.Worker.start_link(arg)
      # {CelestialChannel.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialChannel.Supervisor)
  end
end

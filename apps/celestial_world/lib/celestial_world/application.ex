defmodule CelestialWorld.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Presence server
      {CelestialWorld.Presence, []},
      # Start the Entity registry
      {Registry, keys: :unique, name: CelestialWorld.Registry},
      # Start Character entity supervisor
      {Nostalex.EntitySupervisor, []}
      # Start a worker by calling: CelestialWorld.Worker.start_link(arg)
      # {CelestialWorld.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CelestialWorld.Supervisor)
  end
end

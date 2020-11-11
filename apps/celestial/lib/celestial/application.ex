defmodule Celestial.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Celestial.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Celestial.PubSub}
      # Start a worker by calling: Celestial.Worker.start_link(arg)
      # {Celestial.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Celestial.Supervisor)
  end
end

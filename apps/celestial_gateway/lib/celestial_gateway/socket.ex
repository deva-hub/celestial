defmodule CelestialGateway.Socket do
  @moduledoc false
  use Nostalex.Gateway

  require Logger
  alias Celestial.Accounts
  alias CelestialPortal.Presence

  @impl true
  def connect(params, socket) do
    if identity = Accounts.get_identity_by_username_and_password(params.username, params.password) do
      {:ok, assign(socket, :current_identity, identity)}
    else
      :error
    end
  end

  @impl true
  def key(socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    Accounts.generate_identity_otk(address, socket.assigns.current_identity)
  end

  @impl true
  def portals(_socket) do
    for {id, %{metas: [meta]}} <- Presence.list("portals") do
      %{
        id: id,
        world_id: meta.world_id,
        world_name: meta.world_name,
        hostname: meta.hostname,
        port: meta.port,
        population: meta.population,
        capacity: meta.capacity
      }
    end
  end
end

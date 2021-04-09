defmodule CelestialGateway.Socket do
  @moduledoc false

  use CelestialNetwork.Gateway
  alias Celestial.Accounts
  alias CelestialPortal.Presence

  @impl true
  def connect(params, socket, connect_info) do
    address = connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    if identity = Accounts.get_identity_by_username_and_hashed_password(params.username, params.hashed_password) do
      {:ok, assign(socket, %{current_identity: identity, address: address})}
    else
      :error
    end
  end

  @impl true
  def portals(_socket) do
    for {id, %{metas: [meta]}} <- Presence.list("portals") do
      %{
        id: id,
        channel_id: meta.channel_id,
        world_name: meta.world_name,
        hostname: meta.hostname,
        port: meta.port,
        population: meta.population,
        capacity: meta.capacity
      }
    end
  end

  @impl true
  def key(socket) do
    Accounts.generate_identity_key(socket.assigns.address, socket.assigns.current_identity)
  end
end

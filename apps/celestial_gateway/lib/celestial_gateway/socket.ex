defmodule CelestialGateway.Socket do
  @moduledoc false

  use CelestialNetwork.Gateway
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
  def id(socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    user_id = Accounts.generate_identity_key(address, socket.assigns.current_identity)
    "users:#{user_id}"
  end
end

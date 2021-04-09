defmodule CelestialPortal.Socket do
  @moduledoc false

  use CelestialNetwork.Portal
  alias Celestial.Accounts

  entity "accounts:*", CelestialPortal.IdentityEntity
  entity "entity:*", CelestialPortal.CharacterEntity

  @impl true
  def connect(params, socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    user_id = String.split(params.user_id, ":") |> List.last()
    password_hash = :crypto.hash(:sha512, params.password) |> Base.encode16()

    case Accounts.consume_identity_key(address, user_id, password_hash) do
      {:ok, identity} ->
        socket = assign(socket, :current_identity, identity)
        {:ok, socket}

      :error ->
        :error
    end
  end

  @impl true
  def id(socket) do
    "users:#{socket.assigns.current_identity.id}"
  end
end

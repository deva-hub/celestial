defmodule CelestialPortal.Socket do
  @moduledoc false

  use CelestialNetwork.Portal
  alias Celestial.Accounts

  entity "accounts:*", CelestialPortal.IdentityEntity
  entity "entity:*", CelestialPortal.CharacterEntity

  @impl true
  def connect(params, socket, connect_info) do
    address = connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    case Accounts.get_identity_by_key_and_password(address, params.key, params.password) do
      {:ok, identity} ->
        {:ok, assign(socket, :current_identity, identity)}

      :error ->
        :error
    end
  end
end

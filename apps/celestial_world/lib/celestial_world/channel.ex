defmodule CelestialWorld.Channel do
  @moduledoc false
  use Nostalex.Channel

  require Logger
  alias Celestial.Accounts

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_packet({:handoff, packet_id, handoff_key}, state) do
    {:ok, Map.update!(state, :info, &%{&1 | packet_id: packet_id, handoff_key: handoff_key})}
  end

  def handle_packet({:credentials, packet_id, email, password}, state) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      %{id: id} = identity
      address = state.info.peer_data.address |> :inet.ntoa() |> to_string()

      if %{id: ^id} = Accounts.confirm_handoff(address, state.info.handoff_key) do
        {:ok, Map.update!(state, :info, &%{&1 | current_identity: identity, packet_id: packet_id})}
      else
        {:reply, :error, {:failc, :cant_authenticate}}
      end
    else
      {:reply, :error, {:failc, :unvalid_credentials}}
    end
  end

  def handle_packet({:ping, packet_id}, state) do
    Logger.debug(["PING ", packet_id])
    {:ok, put_in(state.info.packet_id, packet_id)}
  end

  def handle_packet(data, state) do
    IO.inspect(data)
    {:ok, state}
  end
end

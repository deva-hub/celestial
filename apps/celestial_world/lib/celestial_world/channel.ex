defmodule CelestialWorld.Channel do
  @moduledoc false
  use Nostalex.Channel

  require Logger
  alias Celestial.Accounts

  @impl true
  def init(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_packet({:upgrade, id}, socket) do
    {:ok, assign(socket, :id, id)}
  end

  def handle_packet({:dynamic, [_, email, packet_id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

      case Accounts.confirm_one_time_key(address, socket.key) do
        %{id: id} when id == identity.id ->
          {:ok, assign(socket, %{current_identity: identity, packet_id: packet_id})}

        _ ->
          {:reply, :error, {:failc, :cant_authenticate}}
      end
    else
      {:reply, :error, {:failc, :unvalid_credentials}}
    end
  end

  def handle_packet({:ping, packet_id}, socket) do
    Logger.debug(["PING ", packet_id])
    {:ok, assign(socket, :packet_id, packet_id)}
  end

  def handle_packet(data, socket) do
    Logger.debug(["GARBAGE ", inspect(data)])
    {:ok, socket}
  end
end
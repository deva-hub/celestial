defmodule CelestialWorld.Channel do
  @moduledoc false
  use Nostalex.Channel

  require Logger
  alias Celestial.{Accounts, World}

  @impl true
  def init(socket) do
    {:ok, assign(socket, %{current_identity: nil, packet_id: nil})}
  end

  @impl true
  def handle_packet({:upgrade, id}, socket) do
    {:ok, assign(socket, :id, id)}
  end

  def handle_packet({:dynamic, [_, email, packet_id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with {:ok, identity} <- get_identity_by_email_and_password(email, password),
         :ok <- consume_identity_one_time_key(identity, address, socket.key) do
      heroes = World.list_identity_heroes(identity)
      socket = assign(socket, %{current_identity: identity, packet_id: packet_id})
      {:reply, :ok, {:clist, heroes}, socket}
    else
      :error ->
        {:stop, :normal, socket}
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

  defp get_identity_by_email_and_password(email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, identity}
    else
      :error
    end
  end

  defp consume_identity_one_time_key(identity, address, key) do
    case Accounts.consume_identity_one_time_key(address, key) do
      {:ok, %{id: id}} when id == identity.id ->
        :ok

      {:error, _} ->
        :error
    end
  end
end

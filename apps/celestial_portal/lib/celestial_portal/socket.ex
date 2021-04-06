defmodule CelestialPortal.Socket do
  @moduledoc false
  @behaviour CelestialNetwork.Socket.Transport

  require Logger
  import CelestialNetwork.Socket
  alias CelestialNetwork.Socket.Message
  alias Celestial.{Accounts, Galaxy}

  @impl true
  def init(socket) do
    state = %{
      current_identity: nil,
      entity_pid: nil,
      last_message_id: nil,
      world_id: Application.fetch_env!(:celestial_portal, :world),
      channel_id: Application.fetch_env!(:celestial_portal, :channel)
    }

    {:ok, assign(socket, state)}
  end

  @impl true
  def handle_in({payload, opts}, %{key: nil} = socket) do
    handle_in(socket.serializer.decode!(payload, opts), socket)
  end

  def handle_in({payload, opts}, socket) do
    decode_opts = Keyword.put(opts, :key, socket.key)
    handle_in(socket.serializer.decode!(payload, decode_opts), socket)
  end

  def handle_in(%Message{id: id}, %{key: nil} = socket) do
    {:ok, %{assign(socket, :last_message_id, id) | key: 0}}
  end

  def handle_in(%Message{payload: [_, key, id, password]}, %{assigns: %{current_identity: nil}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    password_hash = :crypto.hash(:sha512, password) |> Base.encode16()

    case Accounts.consume_identity_key(address, key, password_hash) do
      {:ok, identity} ->
        push_slots(self(), Galaxy.list_slots(identity), socket.serializer)
        {:ok, assign(socket, %{current_identity: identity, id: id})}

      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%Message{event: "select", payload: payload, id: id}, socket) do
    slot = Galaxy.get_slot_by_index!(socket.assigns.current_identity, payload.index)
    topic = "worlds:#{socket.assigns.world_id}:channels:#{socket.assigns.channel_id}"
    {:ok, entity_pid} = CelestialNetwork.EntitySupervisor.start_character(%{socket | topic: topic}, slot.character)
    {:ok, assign(%{socket | entity_pid: entity_pid}, %{last_message_id: id})}
  end

  def handle_in(%Message{event: "Char_NEW", payload: payload}, socket) do
    %{current_identity: current_identity} = socket.assigns

    case Galaxy.create_slot(current_identity, payload) do
      {:ok, _} ->
        push_slots(self(), Galaxy.list_slots(current_identity), socket.serializer)

      {:error, _} ->
        push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
    end

    {:ok, socket}
  end

  def handle_in(%Message{event: "Char_DEL", payload: payload}, socket) do
    %{current_identity: current_identity} = socket.assigns

    if identity = Accounts.get_identity_by_username_and_password(current_identity.username, payload.password) do
      case Galaxy.get_slot_by_index!(current_identity, payload.index) |> Galaxy.delete_slot() do
        {:ok, _} ->
          :ok

        {:error, _} ->
          push(self(), "failc", %{error: :unexpected_error}, socket.serializer)
      end

      push_slots(self(), Galaxy.list_slots(current_identity), socket.serializer)

      {:ok, assign(socket, :current_identity, identity)}
    else
      push(self(), "failc", %{error: :unvalid_credentials}, socket.serializer)
      {:ok, socket}
    end
  end

  def handle_in(%Message{event: "0", id: id}, socket) do
    {:ok, assign(socket, :last_message_id, id)}
  end

  def handle_in(%Message{id: id, event: "walk"} = message, socket) do
    send(socket.entity_pid, message)
    {:ok, assign(socket, :last_message_id, id)}
  end

  def handle_in(%Message{id: id} = message, socket) do
    Logger.debug("GARBAGE id=\"#{message.id}\" event=\"#{message.event}\"\n#{inspect(message.payload)}")
    {:ok, assign(socket, :last_message_id, id)}
  end

  @impl true
  def handle_info({:socket_push, opcode, payload}, socket) do
    {:push, {opcode, payload}, socket}
  end

  def handle_info(_, socket) do
    {:ok, socket}
  end

  @impl true
  def terminate(_, _) do
    :ok
  end

  defp push_slots(pid, slots, serializer) do
    push(pid, "clist_start", %{length: length(slots)}, serializer)
    for slot <- slots, do: push(pid, "clist", slot, serializer)
    push(pid, "clist_end", %{}, serializer)
    :ok
  end

  defp push(pid, event, payload, serializer) do
    message = %Message{event: event, payload: payload}
    send(pid, serializer.encode!(message))
    :ok
  end
end

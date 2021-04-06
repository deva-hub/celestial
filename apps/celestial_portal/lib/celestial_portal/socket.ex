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
      step: :authentication,
      world_id: Application.fetch_env!(:celestial_portal, :world),
      channel_id: Application.fetch_env!(:celestial_portal, :channel)
    }

    {:ok, assign(socket, state)}
  end

  @impl true
  def handle_in({payload, opts}, %{assigns: %{step: :authentication}} = socket) do
    handle_in(socket.serializer.decode!(payload, opts), socket)
  end

  def handle_in({payload, opts}, %{assigns: %{step: :authorization}} = socket) do
    decode_opts = Keyword.put(opts, :key, 0)
    %{payload: [_, user_id, id, password]} = socket.serializer.decode!(payload, decode_opts)
    password_hash = :crypto.hash(:sha512, password) |> Base.encode16()
    handle_in(%Message{event: "", payload: %{user_id: user_id, password_hash: password_hash}, id: id}, socket)
  end

  def handle_in({payload, opts}, socket) do
    decode_opts = Keyword.put(opts, :key, 0)
    handle_in(socket.serializer.decode!(payload, decode_opts), socket)
  end

  def handle_in(%Message{event: "0", payload: %{}, id: id}, %{assigns: %{step: :authentication}} = socket) do
    {:ok, assign(socket, %{step: :authorization, last_message_id: id})}
  end

  def handle_in(%Message{event: "", payload: payload, id: id}, %{assigns: %{step: :authorization}} = socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    user_id = String.split(payload.user_id, ":") |> List.last()

    case Accounts.consume_identity_key(address, user_id, payload.password_hash) do
      {:ok, identity} ->
        socket = %{socket | id: user_id}
        slots = Galaxy.list_slots(identity)
        send_message(socket, "clists", %{slots: slots})
        {:ok, assign(socket, %{step: nil, current_identity: identity, last_message_id: id})}

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

  def handle_in(%Message{event: "Char_NEW", payload: payload, id: id}, socket) do
    %{current_identity: current_identity} = socket.assigns

    case Galaxy.create_slot(current_identity, payload) do
      {:ok, _} ->
        slots = Galaxy.list_slots(current_identity)
        send_message(socket, "clists", %{slots: slots})

      {:error, _} ->
        send_message(socket, "failc", %{error: :unexpected_error})
    end

    {:ok, assign(socket, %{last_message_id: id})}
  end

  def handle_in(%Message{event: "Char_DEL", payload: payload, id: id}, socket) do
    %{current_identity: current_identity} = socket.assigns

    if identity = Accounts.get_identity_by_username_and_password(current_identity.username, payload.password) do
      case Galaxy.get_slot_by_index!(current_identity, payload.index) |> Galaxy.delete_slot() do
        {:ok, _} ->
          :ok

        {:error, _} ->
          send_message(socket, "failc", %{error: :unexpected_error})
      end

      slots = Galaxy.list_slots(current_identity)
      send_message(socket, "clists", %{slots: slots})

      {:ok, assign(socket, %{current_identity: identity, last_message_id: id})}
    else
      send_message(socket, "failc", %{error: :unvalid_credentials})
      {:ok, assign(socket, %{last_message_id: id})}
    end
  end

  def handle_in(%Message{event: "0", id: id}, socket) do
    {:ok, assign(socket, :last_message_id, id)}
  end

  def handle_in(%Message{event: "walk", id: id} = message, socket) do
    send(socket.entity_pid, message)
    {:ok, assign(socket, :last_message_id, id)}
  end

  def handle_in(%Message{event: event, payload: payload, id: id}, socket) do
    Logger.debug("GARBAGE id=\"#{id}\" event=\"#{event}\"\n#{inspect(payload)}")
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

  defp send_message(socket, "clists", payload) do
    send_message(socket, "clist_start", %{length: length(payload.slots)})
    for slot <- payload.slots, do: send_message(socket, "clist", slot)
    send_message(socket, "clist_end", %{})
    :ok
  end

  defp send_message(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    send(socket.transport_pid, socket.serializer.encode!(message))
    :ok
  end
end

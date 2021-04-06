defmodule CelestialPortal.Socket do
  @moduledoc false
  @behaviour CelestialNetwork.Socket.Transport

  require Logger
  alias CelestialNetwork.Socket.Message
  alias Celestial.{Accounts, Galaxy}

  @impl true
  def init(socket) do
    state = %{
      entities: %{},
      entities_inverse: %{},
      current_identity: nil,
      last_message_id: nil,
      step: :authentication,
      world_id: Application.fetch_env!(:celestial_portal, :world),
      channel_id: Application.fetch_env!(:celestial_portal, :channel)
    }

    {:ok, {socket, state}}
  end

  @impl true
  def handle_in({payload, opts}, {socket, state})
      when state.step == :authentication do
    handle_in(socket.serializer.decode!(payload, opts), {socket, state})
  end

  def handle_in({payload, opts}, {socket, state})
      when state.step == :authorization do
    decode_opts = Keyword.put(opts, :key, 0)
    %{payload: [_, user_id, id, password]} = socket.serializer.decode!(payload, decode_opts)
    password_hash = :crypto.hash(:sha512, password) |> Base.encode16()
    message = %Message{event: "", payload: %{user_id: user_id, password_hash: password_hash}, id: id}
    handle_in(message, {socket, state})
  end

  def handle_in({payload, opts}, {socket, state}) do
    decode_opts = Keyword.put(opts, :key, 0)
    handle_in(socket.serializer.decode!(payload, decode_opts), {socket, state})
  end

  def handle_in(%Message{event: "0", payload: %{}, id: id}, {socket, state})
      when state.step == :authentication do
    state = %{state | step: :authorization, last_message_id: id}
    {:ok, {socket, state}}
  end

  def handle_in(%Message{event: "", payload: payload, id: id}, {socket, state})
      when state.step == :authorization do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    user_id = String.split(payload.user_id, ":") |> List.last()

    case Accounts.consume_identity_key(address, user_id, payload.password_hash) do
      {:ok, identity} ->
        slots = Galaxy.list_slots(identity)
        send_message(socket, "clists", %{slots: slots})
        socket = %{socket | id: user_id}
        state = %{state | step: nil, current_identity: identity, last_message_id: id}
        {:ok, {socket, state}}

      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%Message{event: "Char_NEW", payload: payload, id: id}, {socket, state}) do
    case Galaxy.create_slot(state.current_identity, payload) do
      {:ok, _} ->
        slots = Galaxy.list_slots(state.current_identity)
        send_message(socket, "clists", %{slots: slots})

      {:error, _} ->
        send_message(socket, "failc", %{error: :unexpected_error})
    end

    {:ok, {socket, %{state | last_message_id: id}}}
  end

  def handle_in(%Message{event: "Char_DEL", payload: payload, id: id}, {socket, state}) do
    if Accounts.get_identity_by_username_and_password(state.current_identity.username, payload.password) do
      case Galaxy.get_slot_by_index!(state.current_identity, payload.index) |> Galaxy.delete_slot() do
        {:ok, _} ->
          :ok

        {:error, _} ->
          send_message(socket, "failc", %{error: :unexpected_error})
      end

      slots = Galaxy.list_slots(state.current_identity)
      send_message(socket, "clists", %{slots: slots})
      state = %{state | last_message_id: id}
      {:ok, {socket, state}}
    else
      send_message(socket, "failc", %{error: :unvalid_credentials})
      {:ok, {socket, %{state | last_message_id: id}}}
    end
  end

  def handle_in(%Message{event: "0", id: id}, {socket, state}) do
    {:ok, {socket, %{state | last_message_id: id}}}
  end

  def handle_in(%Message{event: event} = message, {socket, state}) do
    handle_in(Map.get(state.entities, event), message, {socket, state})
  end

  def handle_in(nil, %Message{event: event, payload: payload, id: id}, {socket, state}) do
    case __entities__(event) do
      {CelestialWorld.CharacterEntity, _} ->
        slot = Galaxy.get_slot_by_index!(state.current_identity, payload.index)
        topic = "worlds:#{state.world_id}:channels:#{state.channel_id}"
        {:ok, pid} = CelestialNetwork.EntitySupervisor.start_character(%{socket | topic: topic}, slot.character)
        state = put_character_entity(%{state | last_message_id: id}, pid, make_ref())
        {:ok, {socket, state}}

      _ ->
        Logger.debug("GARBAGE id=\"#{id}\" event=\"#{event}\"\n#{inspect(payload)}")
        {:ok, {socket, %{state | last_message_id: id}}}
    end
  end

  def handle_in({pid, _ref}, %Message{id: id} = message, {socket, state}) do
    send(pid, message)
    {:ok, {socket, %{state | last_message_id: id}}}
  end

  @impl true
  def handle_info({:socket_push, opcode, payload}, {socket, state}) do
    {:push, {opcode, payload}, {socket, state}}
  end

  def handle_info(_, {socket, state}) do
    {:ok, {socket, state}}
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

  defp put_character_entity(state, pid, join_ref) do
    for event <- ["walk", "select"], reduce: state do
      acc -> put_entity(acc, pid, event, join_ref)
    end
  end

  defp put_entity(state, pid, event, join_ref) do
    %{entities: entities, entities_inverse: entities_inverse} = state
    monitor_ref = Process.monitor(pid)

    %{
      state
      | entities: Map.put(entities, event, {pid, monitor_ref}),
        entities_inverse: Map.put(entities_inverse, pid, {event, join_ref})
    }
  end

  def __entities__("walk") do
    {CelestialWorld.CharacterEntity, []}
  end

  def __entities__("select") do
    {CelestialWorld.CharacterEntity, []}
  end

  def __entities__(_) do
    nil
  end
end

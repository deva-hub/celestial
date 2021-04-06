defmodule CelestialPortal.Socket do
  @moduledoc false
  @behaviour CelestialNetwork.Socket.Transport

  require Logger
  import CelestialNetwork.Socket
  alias CelestialNetwork.Socket.Message
  alias Celestial.Accounts

  @impl true
  def init(socket) do
    state = %{
      entities: %{},
      entities_inverse: %{},
      last_message_id: nil,
      step: :authentication
    }

    {:ok, {socket, state}}
  end

  @impl true
  def handle_in({payload, opts}, {socket, %{step: :authentication} = state}) do
    handle_in(socket.serializer.decode!(payload, opts), {socket, state})
  end

  def handle_in({payload, opts}, {socket, %{step: :authorization} = state}) do
    decode_opts = Keyword.put(opts, :key, 0)
    %{payload: [_, user_id, id, password]} = socket.serializer.decode!(payload, decode_opts)
    password_hash = :crypto.hash(:sha512, password) |> Base.encode16()
    payload = %{user_id: user_id, password_hash: password_hash}
    message = %Message{event: "connect", payload: payload, id: id}
    handle_in(message, {socket, state})
  end

  def handle_in({payload, opts}, {socket, state}) do
    decode_opts = Keyword.put(opts, :key, 0)
    handle_in(socket.serializer.decode!(payload, decode_opts), {socket, state})
  end

  def handle_in(%{event: "0"} = message, {socket, %{step: :authentication} = state}) do
    state = %{state | step: :authorization, last_message_id: message.id}
    {:ok, {socket, state}}
  end

  def handle_in(%{event: "connect"} = message, {socket, state})
      when state.step == :authorization do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()
    user_id = String.split(message.payload.user_id, ":") |> List.last()

    case Accounts.consume_identity_key(address, user_id, message.payload.password_hash) do
      {:ok, identity} ->
        socket = assign(%{socket | id: user_id}, :current_identity, identity)
        state = %{state | step: nil}
        handle_in(nil, message, {socket, state})

      :error ->
        {:stop, :normal, socket}
    end
  end

  def handle_in(%{event: "0"} = message, {socket, state}) do
    {:ok, {socket, %{state | last_message_id: message.id}}}
  end

  def handle_in(%{event: event} = message, {socket, state}) do
    handle_in(Map.get(state.entities, event), message, {socket, state})
  end

  def handle_in(nil, message, {socket, state}) do
    case __entities__(message.event) do
      {CelestialWorld.IdentityEntity, _} ->
        {:ok, pid} = CelestialNetwork.EntitySupervisor.start_identity(message.event, message.payload, socket)
        state = put_identity_entity(%{state | last_message_id: message.id}, pid, make_ref())
        {:ok, {socket, state}}

      {CelestialWorld.CharacterEntity, _} ->
        {:ok, pid} = CelestialNetwork.EntitySupervisor.start_character(message.event, message.payload, socket)
        state = put_character_entity(%{state | last_message_id: message.id}, pid, make_ref())
        {:ok, {socket, state}}

      _ ->
        Logger.debug("GARBAGE id=\"#{message.id}\" event=\"#{message.event}\"\n#{inspect(message.payload)}")
        {:ok, {socket, %{state | last_message_id: message.id}}}
    end
  end

  def handle_in({pid, _ref}, message, {socket, state}) do
    IO.inspect(message)
    send(pid, message)
    {:ok, {socket, %{state | last_message_id: message.id}}}
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

  defp put_identity_entity(state, pid, join_ref) do
    put_entity(state, pid, "user", join_ref)
  end

  defp put_character_entity(state, pid, join_ref) do
    for event <- ["walk", "select"], reduce: state do
      acc -> put_entity(acc, pid, event, join_ref)
    end
  end

  defp put_entity(state, pid, event, join_ref) do
    monitor_ref = Process.monitor(pid)

    %{
      state
      | entities: Map.put(state.entities, event, {pid, monitor_ref}),
        entities_inverse: Map.put(state.entities_inverse, pid, {event, join_ref})
    }
  end

  def __entities__("connect") do
    {CelestialWorld.IdentityEntity, []}
  end

  def __entities__("select") do
    {CelestialWorld.CharacterEntity, []}
  end

  def __entities__("walk") do
    {CelestialWorld.CharacterEntity, []}
  end

  def __entities__(_) do
    nil
  end
end

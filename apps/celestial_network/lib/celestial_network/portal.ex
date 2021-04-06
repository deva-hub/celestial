defmodule CelestialNetwork.Portal do
  @moduledoc false

  require Logger
  alias CelestialNetwork.Socket
  alias CelestialNetwork.Socket.Message

  @callback connect(params :: map, Socket.t()) :: {:ok, Socket.t()} | :error

  @callback id(Socket.t()) :: binary() | nil

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour CelestialNetwork.Portal
      @behaviour CelestialNetwork.Socket.Transport

      import CelestialNetwork.Socket

      @celestial_gateway_options unquote(opts)

      @impl true
      @doc false
      def init(state) do
        CelestialNetwork.Portal.__init__(state)
      end

      @impl true
      @doc false
      def handle_in(message, state) do
        CelestialNetwork.Portal.__in__(__MODULE__, message, state)
      end

      @impl true
      @doc false
      def handle_info(message, state) do
        CelestialNetwork.Portal.__info__(message, state)
      end

      @impl true
      @doc false
      def terminate(reason, state) do
        CelestialNetwork.Portal.__terminate__(reason, state)
      end
    end
  end

  def __init__(socket) do
    state = %{
      entities: %{},
      entities_inverse: %{},
      last_message_id: nil,
      step: :authentication
    }

    {:ok, {socket, state}}
  end

  def __in__(portal, {payload, opts}, {socket, %{step: :authentication} = state}) do
    __in__(portal, socket.serializer.decode!(payload, opts), {socket, state})
  end

  def __in__(portal, {payload, opts}, {socket, %{step: :authorization} = state}) do
    decode_opts = Keyword.put(opts, :key, 0)
    %{payload: [_, user_id, id, password]} = socket.serializer.decode!(payload, decode_opts)
    password_hash = :crypto.hash(:sha512, password) |> Base.encode16()
    payload = %{user_id: user_id, password_hash: password_hash}
    message = %Message{event: "connect", payload: payload, id: id}
    __in__(portal, message, {socket, state})
  end

  def __in__(portal, {payload, opts}, {socket, state}) do
    decode_opts = Keyword.put(opts, :key, 0)
    __in__(portal, socket.serializer.decode!(payload, decode_opts), {socket, state})
  end

  def __in__(_, %{event: "0"} = message, {socket, %{step: :authentication} = state}) do
    state = %{state | step: :authorization, last_message_id: message.id}
    {:ok, {socket, state}}
  end

  def __in__(portal, %{event: "connect"} = message, {socket, %{step: :authorization} = state}) do
    case portal.connect(message.payload, socket) do
      {:ok, socket} ->
        socket = %{socket | id: portal.id(socket)}
        state = %{state | step: nil}
        __in__(portal, nil, message, {socket, state})

      :error ->
        {:stop, :normal, socket}
    end
  end

  def __in__(_, %{event: "0"} = message, {socket, state}) do
    {:ok, {socket, %{state | last_message_id: message.id}}}
  end

  def __in__(portal, %{event: event} = message, {socket, state}) do
    __in__(portal, Map.get(state.entities, event), message, {socket, state})
  end

  def __in__(_, nil, message, {socket, state}) do
    case __entities__(message.event) do
      {CelestialWorld.IdentityEntity, _} ->
        {:ok, pid} =
          CelestialNetwork.EntitySupervisor.start_identity(message.event, message.payload, socket)

        state = put_identity_entity(%{state | last_message_id: message.id}, pid, make_ref())
        {:ok, {socket, state}}

      {CelestialWorld.CharacterEntity, _} ->
        {:ok, pid} =
          CelestialNetwork.EntitySupervisor.start_character(
            message.event,
            message.payload,
            socket
          )

        state = put_character_entity(%{state | last_message_id: message.id}, pid, make_ref())
        {:ok, {socket, state}}

      _ ->
        Logger.debug(
          "GARBAGE id=\"#{message.id}\" event=\"#{message.event}\"\n#{inspect(message.payload)}"
        )

        {:ok, {socket, %{state | last_message_id: message.id}}}
    end
  end

  def __in__(_, {pid, _ref}, message, {socket, state}) do
    send(pid, message)
    {:ok, {socket, %{state | last_message_id: message.id}}}
  end

  def __info__({:socket_push, opcode, payload}, socket) do
    {:push, {opcode, payload}, socket}
  end

  def __info__(_, socket) do
    {:ok, socket}
  end

  def __terminate__(_reason, _state_socket) do
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

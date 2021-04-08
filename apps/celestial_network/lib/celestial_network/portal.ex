defmodule CelestialNetwork.Portal do
  @moduledoc false

  require Logger
  alias CelestialNetwork.Socket
  alias CelestialNetwork.Socket.{PoolSupervisor, Message}

  @callback connect(params :: map, Socket.t()) :: {:ok, Socket.t()} | :error

  @callback id(Socket.t()) :: binary() | nil

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour CelestialNetwork.Portal
      @behaviour CelestialNetwork.Socket.Transport
      @before_compile CelestialNetwork.Portal

      Module.register_attribute(__MODULE__, :celestial_entities, accumulate: true)

      import CelestialNetwork.Portal
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
      step: :announce
    }

    {:ok, {socket, state}}
  end

  def __in__(portal, {payload, opts}, {socket, state}) when state.step == :announce do
    message = socket.serializer.decode!(payload, opts)
    __in__(portal, message, {socket, state})
  end

  def __in__(portal, {payload, opts}, {socket, state}) when state.step == :authorization do
    decode_opts = Keyword.put(opts, :key, 0)
    message = socket.serializer.decode!(payload, decode_opts)
    message = normalize_handoff_message(message)
    __in__(portal, message, {socket, state})
  end

  def __in__(portal, {payload, opts}, {socket, state}) do
    decode_opts = Keyword.put(opts, :key, 0)
    message = socket.serializer.decode!(payload, decode_opts)
    __in__(portal, message, {socket, state})
  end

  def __in__(_, _, {socket, state}) when state.step == :announce do
    {:ok, {socket, %{state | step: :authorization}}}
  end

  def __in__(portal, message, {socket, state}) when state.step == :authorization do
    case portal.connect(message.payload, socket) do
      {:ok, socket} ->
        socket = %{socket | id: portal.id(socket)}
        state = %{state | step: nil}
        __in__(portal, nil, message, {socket, state})

      :error ->
        {:stop, :normal, socket}
    end
  end

  def __in__(_, %{topic: "celestial", event: "heartbeat"}, {socket, state}) do
    {:ok, {socket, state}}
  end

  def __in__(portal, message, {socket, state}) do
    __in__(portal, Map.get(state.entities, message.topic), message, {socket, state})
  end

  def __in__(portal, nil, message, {socket, state}) do
    case portal.__entity__(message.topic) do
      {entity, opts} ->
        {:ok, pid} = PoolSupervisor.start_child(entity, message, socket, opts)
        state = put_entity(state, pid, message.topic, make_ref())
        {:ok, {socket, state}}

      _ ->
        Logger.debug(
          "GARBAGE topic=\"#{message.topic}\" event=\"#{message.event}\"\n#{
            inspect(message.payload)
          }"
        )

        {:ok, {socket, state}}
    end
  end

  def __in__(_, {pid, _ref}, message, {socket, state}) do
    send(pid, message)
    {:ok, {socket, state}}
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

  defmacro entity(topic_pattern, module, opts \\ []) do
    # Tear the alias to simply store the root in the AST.
    # This will make Elixir unable to track the dependency between
    # endpoint <-> socket and avoid recompiling the endpoint
    # (alongside the whole project) whenever the socket changes.
    module = tear_alias(module)

    quote do
      @celestial_entities {unquote(topic_pattern), unquote(module), unquote(opts)}
    end
  end

  defp tear_alias({:__aliases__, meta, [h | t]}) do
    alias = {:__aliases__, meta, [h]}

    quote do
      Module.concat([unquote(alias) | unquote(t)])
    end
  end

  defp tear_alias(other), do: other

  defmacro __before_compile__(env) do
    entitys = Module.get_attribute(env.module, :celestial_entities)

    entity_defs =
      for {topic_pattern, module, opts} <- entitys do
        topic_pattern
        |> to_topic_match()
        |> defentity(module, opts)
      end

    quote do
      unquote(entity_defs)
      def __entity__(_topic), do: nil
    end
  end

  defp to_topic_match(topic_pattern) do
    case String.split(topic_pattern, "*") do
      [prefix, ""] -> quote do: <<unquote(prefix) <> _rest>>
      [bare_topic] -> bare_topic
      _ -> raise ArgumentError, "entitys using splat patterns must end with *"
    end
  end

  defp defentity(topic_match, entity_module, opts) do
    quote do
      def __entity__(unquote(topic_match)), do: unquote({entity_module, Macro.escape(opts)})
    end
  end

  defp put_entity(state, pid, topic, join_ref) do
    monitor_ref = Process.monitor(pid)

    %{
      state
      | entities: Map.put(state.entities, topic, {pid, monitor_ref}),
        entities_inverse: Map.put(state.entities_inverse, pid, {topic, join_ref})
    }
  end

  defp normalize_handoff_message(%{payload: [_, user_id, ref, password]}) do
    password_hash = :crypto.hash(:sha512, password) |> Base.encode16()
    payload = %{user_id: user_id, password_hash: password_hash}
    %Message{topic: "celestial:lobby", event: "connect", payload: payload, ref: ref}
  end
end

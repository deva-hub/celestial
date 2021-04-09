defmodule CelestialNetwork.Gateway do
  @moduledoc false

  require Logger
  alias CelestialNetwork.Socket
  alias CelestialNetwork.Socket.{Broadcast, Message}

  @version_requirement "~> 0.9.3"

  @callback connect(params :: map, Socket.t()) :: {:ok, Socket.t()} | :error
  @callback connect(params :: map, Socket.t(), connect_info :: map) ::
              {:ok, Socket.t()} | {:error, term} | :error

  @optional_callbacks connect: 2, connect: 3

  @callback portals(Socket.t()) :: list(map)

  @callback key(Socket.t()) :: binary() | nil

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour CelestialNetwork.Gateway
      @behaviour CelestialNetwork.Socket.Transport

      import CelestialNetwork.Socket

      @celestial_gateway_options unquote(opts)

      @impl true
      @doc false
      def init(state) do
        CelestialNetwork.Gateway.__init__(state)
      end

      @impl true
      @doc false
      def connect(map) do
        CelestialNetwork.Gateway.__connect__(__MODULE__, map)
      end

      @impl true
      @doc false
      def handle_in(message, state) do
        CelestialNetwork.Gateway.__in__(__MODULE__, message, state)
      end

      @impl true
      @doc false
      def handle_info(message, state) do
        CelestialNetwork.Gateway.__info__(message, state)
      end

      @impl true
      @doc false
      def terminate(reason, state) do
        CelestialNetwork.Gateway.__terminate__(reason, state)
      end
    end
  end

  def __init__(socket) do
    {:ok, socket}
  end

  def __connect__(portal, map) do
    socket = %Socket{
      handler: portal,
      pubsub_server: map.pubsub_server,
      serializer: map.serializer,
      transport: map.transport,
      transport_pid: self()
    }

    if Version.match?(map.params.version, @version_requirement) do
      authenticate(portal, map.params, socket, map.connect_info)
    else
      send_message(socket, "failc", %{error: :outdated_client})
      {:ok, socket}
    end
  end

  def __in__(_, message, socket) do
    Logger.debug(
      "GARBAGE topic=\"#{message.topic}\" event=\"#{message.event}\"\n#{inspect(message.payload)}"
    )

    {:ok, socket}
  end

  def __info__(%Broadcast{event: "disconnect"}, state) do
    {:stop, {:shutdown, :disconnected}, state}
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

  defp authenticate(gateway, params, socket, connect_info) do
    case user_connect(gateway, params, socket, connect_info) do
      {:ok, socket} ->
        case {gateway.portals(socket), gateway.key(socket)} do
          {[], _} ->
            send_message(socket, "failc", %{error: :maintenance})

          {_, nil} ->
            send_message(socket, "failc", %{error: :session_already_used})

          {portals, key} ->
            send_message(socket, "NsTeST", %{
              username: params.username,
              key: key,
              portals: portals
            })
        end

        {:ok, socket}

      :error ->
        send_message(socket, "failc", %{error: :unvalid_credentials})
        {:ok, socket}

      {:error, _reason} = err ->
        err
    end
  end

  defp user_connect(gateway, params, socket, connect_info) do
    if function_exported?(gateway, :connect, 3) do
      gateway.connect(params, socket, connect_info)
    else
      gateway.connect(params, socket)
    end
  end

  defp send_message(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    send(socket.transport_pid, socket.serializer.encode!(message))
    :ok
  end
end

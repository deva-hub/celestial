defmodule CelestialNetwork.Gateway do
  @moduledoc false

  require Logger
  alias CelestialNetwork.Socket
  alias CelestialNetwork.Socket.Message

  @version_requirement "~> 0.9.3"

  @callback connect(params :: map, Socket.t()) :: {:ok, Socket.t()} | :error

  @callback portals(Socket.t()) :: list(map)

  @callback id(Socket.t()) :: binary() | nil

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

  def __in__(gateway, {payload, opts}, socket) do
    __in__(gateway, socket.serializer.decode!(payload, opts), socket)
  end

  def __in__(gateway, %{topic: "accounts:lobby", event: "NoS0575", payload: payload}, socket) do
    if Version.match?(payload.version, @version_requirement) do
      authenticate(gateway, payload, socket)
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

  def __info__({:socket_push, opcode, payload}, socket) do
    {:push, {opcode, payload}, socket}
  end

  def __info__(_, socket) do
    {:ok, socket}
  end

  def __terminate__(_reason, _state_socket) do
    :ok
  end

  defp authenticate(gateway, payload, socket) do
    case gateway.connect(payload, socket) do
      {:ok, socket} ->
        case {gateway.portals(socket), gateway.id(socket)} do
          {[], _} ->
            send_message(socket, "failc", %{error: :maintenance})

          {_, nil} ->
            send_message(socket, "failc", %{error: :session_already_used})

          {portals, user_id} ->
            send_message(socket, "NsTeST", %{
              username: payload.username,
              user_id: user_id,
              portals: portals
            })
        end

        {:ok, socket}

      :error ->
        send_message(socket, "failc", %{error: :unvalid_credentials})
        {:ok, socket}
    end
  end

  defp send_message(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    send(socket.transport_pid, socket.serializer.encode!(message))
    :ok
  end
end

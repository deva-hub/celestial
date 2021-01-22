defmodule Nostalex.Gateway do
  @moduledoc false

  require Logger
  alias Nostalex.Socket
  alias Nostalex.Socket.Message

  @version_requirement "~> 0.9.3"

  @callback connect(params :: map, Socket.t()) :: {:ok, Socket.t()} | :error

  @callback key(Socket.t()) :: non_neg_integer() | nil

  @callback portals(Socket.t()) :: list(map)

  defmacro __using__(opts) do
    quote location: :keep do
      @behaviour Nostalex.Gateway
      @behaviour Nostalex.Socket.Transport

      import Nostalex.Socket

      @nostalex_gateway_options unquote(opts)

      @impl true
      @doc false
      def init(state), do: Nostalex.Gateway.__init__(state)

      @impl true
      @doc false
      def handle_in(message, state), do: Nostalex.Gateway.__in__(__MODULE__, message, state)

      @impl true
      @doc false
      def handle_info(message, state), do: Nostalex.Gateway.__info__(message, state)

      @impl true
      @doc false
      def terminate(reason, state), do: Nostalex.Gateway.__terminate__(reason, state)
    end
  end

  def __init__(socket) do
    {:ok, socket}
  end

  def __in__(gateway, {payload, opts}, socket) do
    __in__(gateway, socket.serializer.decode!(payload, opts), socket)
  end

  def __in__(gateway, %{event: "NoS0575", payload: payload}, socket) do
    if Version.match?(payload.version, @version_requirement) do
      authenticate(gateway, payload, socket)
    else
      send_error(socket, :outdated_client)
      {:ok, socket}
    end
  end

  defp authenticate(gateway, payload, socket) do
    case gateway.connect(payload, socket) do
      {:ok, socket} ->
        case {gateway.portals(socket), gateway.key(socket)} do
          {[], _} ->
            send_error(socket, :maintenance)

          {_, nil} ->
            send_error(socket, :session_already_used)

          {portals, key} ->
            send_nstest(socket, payload.username, key, portals)
        end

        {:ok, socket}

      :error ->
        send_error(socket, :unvalid_credentials)
        {:ok, socket}
    end
  end

  def __in__(data, socket) do
    Logger.debug("GARBAGE id=\"#{data.id}\" event=\"#{data.event}\"\n#{inspect(data.payload)}")
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

  defp send_nstest(socket, username, key, portals) do
    send_message(socket, "NsTeST", %{username: username, key: key, portals: portals})
  end

  defp send_error(socket, reason) do
    send_message(socket, "failc", %{error: reason})
  end

  defp send_message(socket, event, payload) do
    message = %Message{event: event, payload: payload}
    send(socket.transport_pid, socket.serializer.encode!(message))
    :ok
  end
end

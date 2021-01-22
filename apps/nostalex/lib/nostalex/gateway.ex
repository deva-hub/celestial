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
    quote do
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

  def __in__(mod, {payload, opts}, socket) do
    __in__(mod, socket.serializer.decode!(payload, opts), socket)
  end

  def __in__(mod, %{event: "NoS0575", payload: payload}, socket) do
    if Version.match?(payload.version, @version_requirement) do
      authenticate(mod, payload, socket)
    else
      {:push, encode_error(socket, :outdated_client), socket}
    end
  end

  defp authenticate(mod, payload, socket) do
    case mod.connect(payload, socket) do
      {:ok, socket} ->
        case {mod.portals(socket), mod.key(socket)} do
          {[], _} ->
            {:push, encode_error(socket, :maintenance), socket}

          {_, nil} ->
            {:push, encode_error(socket, :session_already_used), socket}

          {portals, key} ->
            {:push, encode_nstest(socket, payload.username, key, portals), socket}
        end

      :error ->
        {:push, encode_error(socket, :unvalid_credentials), socket}
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

  defp encode_nstest(socket, username, key, portals) do
    message = %Message{
      event: "NsTeST",
      payload: %{key: key, username: username, portals: portals}
    }

    encode_reply(socket, message)
  end

  defp encode_error(socket, reason) do
    message = %Message{event: "failc", payload: %{error: reason}}
    encode_reply(socket, message)
  end

  defp encode_reply(socket, data) do
    {:socket_push, opcode, payload} = socket.serializer.encode!(data)
    {opcode, payload}
  end
end

defmodule Nostalex.Channel do
  @moduledoc false

  alias Nostalex.Socket
  alias Nostalex.Protocol
  alias Nostalex.Channel.Crypto

  @doc """
  Handles incoming decoded socket packet.

  It must return one of:

    * `{:ok, socket}` - continues the socket with no reply
    * `{:reply, status, reply, socket}` - continues the socket with reply
    * `{:stop, reason, socket}` - stops the socket

  The `reply` is a tuple contain an `opcode` atom and a message that can
  be any term. The built-in websocket transport supports both `:text` and
  `:binary` opcode and the message must be always iodata. Long polling only
  supports text opcode.
  """
  @callback handle_packet(message :: term, Socket.t()) ::
              {:ok, Socket.t()}
              | {:reply, :ok | :error, {opcode :: atom, message :: term}, Socket.t()}
              | {:stop, reason :: term, Socket.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Nostalex.Channel
      @behaviour Nostalex.Transport

      import Nostalex.Socket

      @impl true
      def handle_in({data, options}, socket) do
        Nostalex.Channel.__handle_in__(__MODULE__, {data, options}, socket)
      end

      @impl true
      def handle_info(data, socket) do
        Nostalex.Channel.__handle_info__(data, socket)
      end

      @impl true
      def terminate(reason, socket) do
        Nostalex.Channel.__terminate__(reason, socket)
      end

      defoverridable handle_info: 2, terminate: 2
    end
  end

  def __handle_in__(mod, {data, _}, %{key: nil} = socket) do
    data = Crypto.decrypt(data)

    case Protocol.parse(data) do
      {:dynamic, [packet_id, key]} ->
        packet = {:upgrade, String.to_integer(packet_id)}
        socket = put_key(socket, String.to_integer(key))
        mod.handle_packet(packet, socket) |> handle_reply()

      _ ->
        {:stop, :garbage, socket}
    end
  end

  def __handle_in__(mod, {data, _}, socket) do
    data
    |> Crypto.decrypt(socket.key)
    |> Protocol.parse()
    |> mod.handle_packet(socket)
    |> handle_reply()
  end

  defp handle_reply({:ok, socket}) do
    {:ok, socket}
  end

  defp handle_reply({:push, {opcode, data}, socket}) do
    data =
      Protocol.pack(opcode, data)
      |> Enum.join()
      |> Crypto.encrypt()

    {:push, {opcode, data}, socket}
  end

  defp handle_reply({:reply, status, {opcode, data}, socket}) do
    data =
      Protocol.pack(opcode, data)
      |> Enum.join()
      |> Crypto.encrypt()

    {:reply, status, {opcode, data}, socket}
  end

  defp handle_reply({:stop, reason, socket}) do
    {:stop, reason, socket}
  end

  def __handle_info__(_, socket) do
    {:ok, socket}
  end

  def __terminate__(_, _) do
    :ok
  end

  defp put_key(socket, key) do
    %{socket | key: key}
  end
end

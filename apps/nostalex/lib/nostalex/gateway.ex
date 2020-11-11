defmodule Nostalex.Gateway do
  @moduledoc false

  require Logger

  alias Nostalex.Protocol
  alias Nostalex.Gateway.Crypto

  @type state :: term()

  @doc """
  Handles incoming decoded socket packet.

  It must return one of:

    * `{:ok, state}` - continues the socket with no reply
    * `{:reply, status, reply, state}` - continues the socket with reply
    * `{:stop, reason, state}` - stops the socket

  The `reply` is a tuple contain an `opcode` atom and a message that can
  be any term. The built-in websocket transport supports both `:text` and
  `:binary` opcode and the message must be always iodata. Long polling only
  supports text opcode.
  """
  @callback handle_packet(message :: term, state) ::
              {:ok, state}
              | {:reply, :ok | :error, {opcode :: atom, message :: term}, state}
              | {:stop, reason :: term, state}

  defmacro __using__(_opts) do
    quote do
      @behaviour Nostalex.Gateway
      @behaviour Nostalex.Transport

      import Nostalex.Socket

      @impl true
      def handle_in({data, options}, state) do
        Nostalex.Gateway.__handle_in__(__MODULE__, {data, options}, state)
      end

      @impl true
      def handle_info(data, state) do
        Nostalex.Gateway.__handle_info__(data, state)
      end

      @impl true
      def terminate(reason, state) do
        Nostalex.Gateway.__terminate__(reason, state)
      end

      defoverridable handle_info: 2, terminate: 2
    end
  end

  def __handle_in__(mod, {data, _}, state) do
    data = Crypto.decrypt(data)
    Logger.info(["PACKET ", data])
    data |> Protocol.parse() |> mod.handle_packet(state) |> handle_reply()
  end

  defp handle_reply({:ok, state}) do
    {:ok, state}
  end

  defp handle_reply({:push, {opcode, data}, state}) do
    data =
      Protocol.pack(opcode, data)
      |> Enum.join()
      |> Crypto.encrypt()

    {:push, {opcode, data}, state}
  end

  defp handle_reply({:reply, status, {opcode, data}, state}) do
    data =
      Protocol.pack(opcode, data)
      |> Enum.join()
      |> Crypto.encrypt()

    {:reply, status, {opcode, data}, state}
  end

  defp handle_reply({:stop, reason, state}) do
    {:stop, reason, state}
  end

  def __handle_info__(_, state) do
    {:ok, state}
  end

  def __terminate__(_, _) do
    :ok
  end
end

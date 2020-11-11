defmodule Nostalex.Channel do
  @moduledoc false

  require Logger

  alias Nostalex.Protocol
  alias Nostalex.Channel.Crypto

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
      @behaviour Nostalex.Channel
      @behaviour Nostalex.Transport

      @impl true
      def handle_in({data, options}, state) do
        Nostalex.Channel.__handle_in__(__MODULE__, {data, options}, state)
      end

      @impl true
      def handle_info(data, state) do
        Nostalex.Channel.__handle_info__(data, state)
      end

      @impl true
      def terminate(reason, state) do
        Nostalex.Channel.__terminate__(reason, state)
      end

      defoverridable handle_info: 2, terminate: 2
    end
  end

  def __handle_in__(mod, {data, _}, %{info: %{handoff_key: nil}} = state) do
    data = Crypto.decrypt(data)

    case Protocol.parse(data) do
      {:dynamic, [packet_id, handoff_key]} ->
        {:handoff, String.to_integer(packet_id), String.to_integer(handoff_key)}
        |> mod.handle_packet(state)
        |> handle_reply()

      _ ->
        {:stop, :garbage, state}
    end
  end

  def __handle_in__(mod, {data, _}, %{info: %{credentials: nil}} = state) do
    data = Crypto.decrypt(data, state.info.handoff_key)

    case Protocol.parse(data) do
      {:dynamic, [_, email, packet_id, password]} ->
        {:credentials, packet_id, email, password}
        |> mod.handle_packet(state)
        |> handle_reply()

      _ ->
        {:stop, :garbage, state}
    end
  end

  def __handle_in__(mod, {data, _}, state) do
    data = Crypto.decrypt(data, state.info.handoff_key)
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

defmodule Ruisseau.Protocol do
  @moduledoc false
  @behaviour :ranch_protocol

  @impl true
  def start_link(ref, _, transport, opts) do
    start_link(ref, transport, opts)
  end

  def start_link(ref, transport, opts \\ []) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :connection_process, [{self(), ref, transport, opts}])}
  end

  def connection_process({parent, ref, transport, opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    init(parent, socket, transport, opts)
  end

  defp init(parent, socket, transport, opts) do
    handler = Keyword.fetch!(opts, :handler)
    connect_info = Keyword.get(opts, :connect_info, [])
    peer_data = get_connect_info(connect_info, socket, transport)

    state = %{
      socket: socket,
      transport: transport,
      transport_pid: parent,
      peer_data: peer_data
    }

    {:ok, state} = handler.init(state)

    loop({handler, state})
  end

  defp loop({handler, %{socket: socket} = state}) do
    :ok = state.transport.setopts(state.socket, active: :once)
    {ok, closed, error} = state.transport.messages()

    receive do
      {^ok, ^socket, data} ->
        handle_reply(handler, handler.handle_in({data, []}, state))

      {^error, ^socket, reason} ->
        terminate(reason, {handler, state})

      {^closed, ^socket} ->
        terminate(:close, {handler, state})

      message ->
        handle_reply(handler, handler.handle_info(message, state))
        loop({handler, state})
    end
  rescue
    e ->
      terminate({e, __STACKTRACE__}, {handler, state})
      reraise e, __STACKTRACE__
  end

  defp handle_reply(handler, {:ok, state}) do
    loop({handler, state})
  end

  defp handle_reply(handler, {:push, data, state}) do
    state.transport.send(state.socket, data)
    loop({handler, state})
  end

  defp handle_reply(handler, {:reply, _status, {_, data}, state}) do
    state.transport.send(state.socket, data)
    loop({handler, state})
  end

  defp handle_reply(handler, {:stop, reason, state}) do
    terminate(reason, {handler, state})
  end

  defp terminate(:closed, {handler, state}) do
    handler.terminate(:closed, state)
    exit({:shutdown, :normal})
  end

  defp terminate(reason, {handler, state}) do
    handler.terminate(reason, state)
    exit({:shutdown, reason})
  end

  defp get_connect_info(connect_info, socket, transport) do
    Enum.reduce(connect_info, %{}, fn
      :peer_data, acc ->
        {:ok, {address, port}} = transport.peername(socket)

        acc
        |> Map.put(:address, address)
        |> Map.put(:port, port)

      _, acc ->
        acc
    end)
  end
end

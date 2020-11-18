defmodule Nostalex.Endpoint.Protocol do
  @moduledoc false
  @behaviour :ranch_protocol

  alias Nostalex.Socket

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
    serializer = Keyword.fetch!(opts, :serializer)
    connect_info = get_connect_info(opts, socket, transport)

    state = %Socket{
      transport: transport,
      transport_pid: parent,
      connect_info: connect_info,
      serializer: serializer
    }

    {:ok, state} = handler.init(state)

    loop({handler, state, socket})
  end

  defp loop({handler, state, socket}) do
    :ok = state.transport.setopts(socket, active: :once)
    {ok, closed, error} = state.transport.messages()

    receive do
      {^ok, ^socket, data} ->
        handler.handle_in({data, []}, state) |> handle_reply({handler, socket})

      {^error, ^socket, reason} ->
        terminate(reason, {handler, state, socket})

      {^closed, ^socket} ->
        terminate(:close, {handler, state, socket})

      message ->
        handler.handle_info(message, state) |> handle_reply({handler, socket})
    end
  rescue
    e ->
      handler.terminate({e, __STACKTRACE__}, state)
      reraise e, __STACKTRACE__
  end

  defp handle_reply({:ok, state}, {handler, socket}) do
    loop({handler, state, socket})
  end

  defp handle_reply({:push, msg, state}, {handler, socket}) do
    handle_message({msg, state}, socket)
    loop({handler, state, socket})
  end

  defp handle_reply({:reply, _status, msg, state}, {handler, socket}) do
    handle_message({msg, state}, socket)
    loop({handler, state, socket})
  end

  defp handle_reply({:stop, reason, state}, {handler, socket}) do
    terminate(reason, {handler, state, socket})
  end

  defp terminate(:closed, {handler, state, _}) do
    handler.terminate(:closed, state)
    exit({:shutdown, :normal})
  end

  defp terminate(reason, {handler, state, _}) do
    handler.terminate(reason, state)
    exit({:shutdown, reason})
  end

  defp handle_message({{:chunked, chunks}, state}, socket) do
    Enum.each(chunks, &handle_message({{:plain, &1}, state}, socket))
  end

  defp handle_message({{:plain, data}, state}, socket) do
    state.transport.send(socket, data)
  end

  defp get_connect_info(opts, socket, transport) do
    opts
    |> Keyword.get(:connect_info, [])
    |> Enum.reduce(%{}, fn
      :peer_data, acc ->
        Map.put(acc, :peer_data, get_peer_data(socket, transport))

      :socket_data, acc ->
        Map.put(acc, :socket_data, get_socket_data(socket, transport))

      _, acc ->
        acc
    end)
  end

  defp get_peer_data(socket, transport) do
    case transport.peername(socket) do
      {:ok, {address, port}} ->
        %{address: address, port: port}

      _ ->
        nil
    end
  end

  defp get_socket_data(socket, transport) do
    case transport.sockname(socket) do
      {:ok, {address, port}} ->
        %{address: address, port: port}

      _ ->
        nil
    end
  end
end

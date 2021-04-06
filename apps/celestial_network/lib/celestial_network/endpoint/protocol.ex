defmodule CelestialNetwork.Endpoint.Protocol do
  @moduledoc false
  @behaviour :ranch_protocol

  alias CelestialNetwork.Socket

  @impl true
  def start_link(ref, _, transport, opts) do
    start_link(ref, transport, opts)
  end

  def start_link(ref, transport, opts \\ []) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :connection_process, [{ref, transport, opts}])}
  end

  def connection_process({ref, transport, opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    init(socket, transport, opts)
  end

  defp init(socket, transport, opts) do
    Process.flag(:trap_exit, true)

    handler = Keyword.fetch!(opts, :handler)
    pubsub_server = Keyword.fetch!(opts, :pubsub_server)
    serializer = Keyword.fetch!(opts, :serializer)
    connect_info = get_connect_info(opts, socket, transport)

    state = %Socket{
      transport: handler,
      transport_pid: self(),
      pubsub_server: pubsub_server,
      connect_info: connect_info,
      serializer: serializer
    }

    {:ok, state} = handler.init(state)

    loop({handler, state, socket, transport})
  end

  defp loop({handler, state, socket, transport}) do
    :ok = transport.setopts(socket, active: :once)
    {ok, closed, error} = transport.messages()

    receive do
      {^ok, ^socket, data} ->
        handler.handle_in({data, []}, state) |> handle_reply({handler, socket, transport})

      {^error, ^socket, reason} ->
        terminate(reason, {handler, state, socket, transport})

      {^closed, ^socket} ->
        terminate(:close, {handler, state, socket, transport})

      {:EXIT, _, _} ->
        loop({handler, state, socket, transport})

      message ->
        handler.handle_info(message, state) |> handle_reply({handler, socket, transport})
    end
  rescue
    e ->
      handler.terminate({e, __STACKTRACE__}, state)
      reraise e, __STACKTRACE__
  end

  defp handle_reply({:ok, state}, {handler, socket, transport}) do
    loop({handler, state, socket, transport})
  end

  defp handle_reply({:push, message, state}, {handler, socket, transport}) do
    send_message(message, socket, transport)
    loop({handler, state, socket, transport})
  end

  defp handle_reply({:stop, reason, state}, {handler, socket, transport}) do
    terminate(reason, {handler, state, socket, transport})
  end

  defp terminate(:closed, {handler, state, _, _}) do
    handler.terminate(:closed, state)
    exit({:shutdown, :normal})
  end

  defp terminate(reason, {handler, state, _, _}) do
    handler.terminate(reason, state)
    exit({:shutdown, reason})
  end

  defp send_message({:chunked, chunks}, socket, transport) do
    Enum.each(chunks, &send_message({:plain, &1}, socket, transport))
  end

  defp send_message({:plain, data}, socket, transport) do
    transport.send(socket, data)
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

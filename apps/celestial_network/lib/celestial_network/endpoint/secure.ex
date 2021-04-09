defmodule CelestialNetwork.Endpoint.Secure do
  @moduledoc false
  @behaviour :ranch_protocol

  alias CelestialNetwork.Endpoint.Conn

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

    conn = %Conn{
      transport: transport,
      transport_pid: socket,
      serializer: serializer
    }

    handshake_loop(handler, :auth, pubsub_server, opts, [conn])
  end

  defp handshake_loop(handler, step, pubsub_server, opts, [conn | state]) do
    socket = conn.transport_pid
    :ok = conn.transport.setopts(socket, active: :once)
    {ok, closed, error} = conn.transport.messages()

    receive do
      {^ok, ^socket, data} ->
        handle_handshake(handler, step, data, pubsub_server, opts, [conn | state])

      {^error, ^socket, reason} ->
        terminate(handler, reason, [conn | state])

      {^closed, ^socket} ->
        terminate(handler, :close, [conn | state])

      _ ->
        handshake_loop(handler, step, pubsub_server, opts, [conn | state])
    end
  rescue
    e ->
      handler.terminate({e, __STACKTRACE__}, conn)
      reraise e, __STACKTRACE__
  end

  defp loop(handler, [conn | state]) do
    socket = conn.transport_pid
    :ok = conn.transport.setopts(socket, active: :once)
    {ok, closed, error} = conn.transport.messages()

    receive do
      {^ok, ^socket, data} ->
        handle_in(handler, data, [conn | state])

      {^error, ^socket, reason} ->
        terminate(handler, reason, [conn | state])

      {^closed, ^socket} ->
        terminate(handler, :closed, [conn | state])

      {:EXIT, _, _} ->
        loop(handler, [conn | state])

      message ->
        handle_info(handler, message, [conn | state])
    end
  rescue
    e ->
      handler.terminate({e, __STACKTRACE__}, conn)
      reraise e, __STACKTRACE__
  end

  defp handle_handshake(handler, :auth, data, pubsub_server, opts, [conn | state]) do
    message = conn.serializer.decode!(data, [])
    conn = %{conn | key: message.payload.code}
    handshake_loop(handler, :connect, pubsub_server, opts, [conn | state])
  end

  defp handle_handshake(handler, :connect, data, pubsub_server, opts, [conn | _]) do
    message = conn.serializer.decode!(data, key: conn.key)
    connect_info = Conn.get_connect_info(conn, opts)

    config = %{
      serializer: conn.serializer,
      params: message.payload,
      pubsub_server: pubsub_server,
      transport: :tcp,
      connect_info: connect_info,
      key: conn.key
    }

    case handler.connect(config) do
      {:ok, state} ->
        {:ok, state} = handler.init(state)
        handle_in(handler, data, [conn | state])

      :error ->
        exit(:normal)
    end
  end

  defp handle_in(handler, data, [conn | state]) do
    handle_reply(handler, handler.handle_in({data, []}, state), [conn | state])
  end

  defp handle_info(handler, message, [conn | state]) do
    handle_reply(handler, handler.handle_info(message, state), [conn | state])
  end

  defp handle_reply(handler, {:ok, state}, [conn | _]) do
    loop(handler, [conn | state])
  end

  defp handle_reply(handler, {:push, message, state}, [conn | _]) do
    Conn.send_message(conn, message)
    loop(handler, [conn | state])
  end

  defp handle_reply(handler, {:stop, reason, state}, [conn | _]) do
    terminate(handler, reason, [conn | state])
  end

  defp terminate(handler, :closed, [conn | _]) do
    handler.terminate(:closed, conn)
    exit(:normal)
  end

  defp terminate(_, :normal, _) do
    exit(:normal)
  end

  defp terminate(handler, reason, [conn | _]) do
    handler.terminate(reason, conn)
    exit({:shutdown, reason})
  end
end

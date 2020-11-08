defmodule CelestialGateWay.Server.SE do
  @moduledoc false
  @behaviour :ranch_protocol

  require Logger

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

  defp init(_parent, socket, transport, _opts) do
    loop(%{socket: socket, transport: transport})
  end

  defp loop(state) do
    :ok = state.transport.setopts(state.socket, active: :once)
    {ok, closed, error} = state.transport.messages()

    %{socket: socket} = state

    receive do
      {^ok, ^socket, ciphertext} ->
        Logger.warn(NosCrypto.Gateway.decrypt(ciphertext))
        loop(state)

      {^error, ^socket, reason} ->
        terminate({:socket_error, reason})

      {^closed, ^socket} ->
        terminate({:socket_error, :closed})
    end
  end

  defp terminate(reason) do
    exit({:shutdown, reason})
  end
end

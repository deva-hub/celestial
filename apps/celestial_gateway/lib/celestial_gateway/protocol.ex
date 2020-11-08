defmodule CelestialGateWay.Protocol do
  @behaviour :ranch_protocol

  @impl true
  def start_link(ref, _, transport, opts \\ []) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, transport, opts}])}
  end

  def init({ref, transport, _opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    before_loop(%{socket: socket, transport: transport})
  end

  defp before_loop(state) do
    :ok = state.transport.setopts(state.socket, active: :once)
    loop(state)
  end

  defp loop(state) do
    %{socket: socket} = state
    {ok, closed, error} = state.transport.messages()

    receive do
      {^ok, ^socket, data} ->
        Logger.warn(Noscrypto.Gateway.decrypt_packet(data))
        before_loop(state)

      {^error, ^socket, reason} ->
        exit({:socket_error, reason})

      {^closed, ^socket} ->
        exit({:socket_error, :closed})
    end
  end
end

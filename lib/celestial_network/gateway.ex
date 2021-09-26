defmodule CelestiaNetwork.Gateway do
  @behaviour :ranch_protocol

  defstruct transport: nil,
            socket: nil

  @impl true
  def start_link(ref, _, transport, opts) do
    start_link(ref, transport, opts)
  end

  def start_link(ref, transport, opts \\ []) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, transport, opts}])}
  end

  def init({ref, transport, opts}) do
    with {:ok, socket} <- :ranch.handshake(ref),
         state <- %__MODULE__{transport: transport, socket: socket},
         {:ok, conn} <- Noscore.Portal.initiate(transport, socket, opts) do
      loop({conn, state})
    else
      {:error, reason} ->
        exit(reason)
    end
  end

  defp loop({conn, state}) do
    %{transport: transport, socket: socket} = state
    {ok, closed, error} = transport.messages()

    receive do
      {^ok, ^socket, data} ->
        handle_data(data, {conn, state})

      {^error, ^socket, reason} ->
        exit(reason)

      {^closed, ^socket} ->
        exit(:closed)
    end
  rescue
    _ ->
      Noscore.Portal.send(
        conn,
        Noscore.Event.Client.failc_event(%{
          error: :unexpected_error
        })
      )
  end

  defp handle_data(data, {conn, state}) do
    case Noscore.Gateway.stream(conn, data) do
      {:ok, conn, _} ->
        loop({conn, state})

      {:error, conn, _, _} ->
        Noscore.Gateway.send(
          conn,
          Noscore.Event.Client.failc_event(%{
            error: :bad_case
          })
        )

        exit(:normal)
    end
  end
end

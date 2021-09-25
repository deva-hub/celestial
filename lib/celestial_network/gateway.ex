defmodule CelestiaNetwork.Gateway do
  @behaviour :ranch_protocol

  defstruct transport: nil,
            socket: nil

  @impl true
  def start_link(ref, _, transport, opts) do
    start_link(ref, transport, opts)
  end

  def start_link(ref, transport, opts \\ []) do
    {:ok,
     :proc_lib.spawn_link(
       __MODULE__,
       :connection_process,
       [{ref, transport, opts}]
     )}
  end

  def connection_process({ref, transport, opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    init(transport, socket, opts)
  end

  defp init(transport, socket, opts) do
    state = %__MODULE__{
      transport: transport,
      socket: socket
    }

    case Noscore.Gateway.initiate(transport, socket, opts) do
      {:ok, conn} ->
        loop({conn, state})

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
  end

  defp handle_data(data, {conn, state}) do
    case Noscore.Gateway.stream(conn, data) do
      {:ok, conn, responses} ->
        handle_sign_in(responses, {conn, state})

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

  defp handle_sign_in([], {conn, state}) do
    loop({conn, state})
  end

  defp handle_sign_in([response | rest], {conn, state}) do
    case response do
      {:event, ["nos0575", _username, _password, _version]} ->
        Noscore.Gateway.send(
          conn,
          Noscore.Event.Gateway.nstest_event(%{
            key: conn.key,
            portals: [
              %{
                hostname: "localhost",
                port: "4002",
                population: 0,
                capacity: 10,
                world_id: 0,
                world_name: "Dev",
                channel_id: 0
              }
            ]
          })
        )

        handle_sign_in(rest, {conn, state})

      _ ->
        Noscore.Gateway.send(
          conn,
          Noscore.Event.Client.failc_event(%{
            error: :cant_authenticate
          })
        )

        exit(:normal)
    end
  end
end
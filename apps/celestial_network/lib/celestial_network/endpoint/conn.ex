defmodule CelestialNetwork.Endpoint.Conn do
  @moduledoc false

  defstruct transport: nil,
            transport_pid: nil,
            serializer: nil,
            key: nil

  def get_connect_info(conn, opts) do
    opts
    |> Keyword.get(:connect_info, [])
    |> Enum.reduce(%{}, fn
      :peer_data, acc ->
        Map.put(acc, :peer_data, get_peer_data(conn))

      :socket_data, acc ->
        Map.put(acc, :socket_data, get_socket_data(conn))

      _, acc ->
        acc
    end)
  end

  def get_peer_data(conn) do
    case conn.transport.peername(conn.transport_pid) do
      {:ok, {address, port}} ->
        %{address: address, port: port}

      _ ->
        nil
    end
  end

  def get_socket_data(conn) do
    case conn.transport.sockname(conn.transport_pid) do
      {:ok, {address, port}} ->
        %{address: address, port: port}

      _ ->
        nil
    end
  end

  def send_message(conn, {:chunked, chunks}) do
    Enum.each(chunks, &send_message(conn, {:plain, &1}))
  end

  def send_message(conn, {:plain, data}) do
    conn.transport.send(conn.transport_pid, data)
  end
end

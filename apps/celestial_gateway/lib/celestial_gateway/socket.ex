defmodule CelestialGateway.Socket do
  @moduledoc false
  @behaviour Nostalex.Socket.Transport

  require Logger
  alias Celestial.Accounts
  alias CelestialChannel.Presence
  alias CelestialGateway.Crypto
  alias Nostalex.Socket.Message

  @impl true
  def init(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in({payload, opts}, socket) do
    msg = payload |> Crypto.decrypt() |> socket.serializer.decode!(opts)
    handle_in(msg, socket)
  end

  def handle_in(%{event: "NoS0575", payload: payload}, %{connect_info: %{peer_data: peer_data}} = socket) do
    with :ok <- validate_client_version(payload.version),
         {:ok, key} <- generate_otk(peer_data.address, payload.email, payload.password) do
      channels = list_online_channel()
      {:reply, :ok, encode_nstest(socket, key, channels), socket}
    else
      {:error, :outdated_client} ->
        {:reply, :error, encode_error(socket, :outdated_client), socket}

      {:error, :unvalid_credentials} ->
        {:reply, :error, encode_error(socket, :unvalid_credentials), socket}
    end
  end

  def handle_in(data, socket) do
    Logger.debug("GARBAGE #{data.id} #{inspect(data.payload)}")
    {:ok, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:ok, socket}
  end

  @impl true
  def terminate(_, _) do
    :ok
  end

  defp encode_nstest(socket, key, channels) do
    message = %Message{event: "NsTeST", payload: %{key: key, channels: channels}}
    encode_reply(socket, message)
  end

  defp encode_error(socket, reason) do
    message = %Message{event: "failc", payload: %{error: reason}}
    encode_reply(socket, message)
  end

  defp encode_reply(socket, data) do
    {:socket_push, opcode, payload} = socket.serializer.encode!(data)
    {opcode, payload |> Enum.join() |> Crypto.encrypt()}
  end

  defp validate_client_version(version) do
    case Application.get_env(:celestial_gateway, :client_version) do
      nil ->
        :ok

      requirement ->
        validate_client_verion_requirement(version, requirement)
    end
  end

  defp validate_client_verion_requirement(version, requirement) do
    if Version.match?(version, requirement) do
      :ok
    else
      {:error, :outdated_client}
    end
  end

  defp generate_otk(address, email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, Accounts.generate_identity_otk(address |> :inet.ntoa() |> to_string(), identity)}
    else
      {:error, :unvalid_credentials}
    end
  end

  defp list_online_channel do
    Presence.list("channels")
    |> Enum.map(fn {id, %{metas: [meta]}} ->
      %{
        id: id,
        world_id: meta.world_id,
        world_name: meta.world_name,
        hostname: meta.hostname,
        port: meta.port,
        population: meta.population,
        capacity: meta.capacity
      }
    end)
  end
end

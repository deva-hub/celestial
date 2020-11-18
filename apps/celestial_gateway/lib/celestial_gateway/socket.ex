defmodule CelestialGateway.Socket do
  @moduledoc false
  @behaviour Nostalex.Socket.Transport

  require Logger
  alias Celestial.Accounts
  alias CelestialWorld.Oracle
  alias CelestialGateway.Crypto
  alias Nostalex.Socket.{Message}

  @impl true
  def init(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in({payload, opts}, socket) do
    msg = payload |> Crypto.decrypt() |> socket.serializer.decode!(opts)
    handle_in(msg, socket)
  end

  def handle_in(%{event: "NoS0575", payload: payload}, socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with :ok <- validate_client_version(payload.version),
         {:ok, key} <- generate_otk_by_email_and_password(address, payload.email, payload.password) do
      channels = Oracle.list_channels()
      message = %Message{event: "NsTeST", payload: %{key: key, channels: channels}}
      {:reply, :ok, encode_reply(socket, message), socket}
    else
      {:error, :outdated_client} ->
        message = %Message{event: "failc", payload: %{error: :outdated_client}}
        {:reply, :error, encode_reply(socket, message), socket}

      {:error, :unvalid_credentials} ->
        message = %Message{event: "failc", payload: %{error: :unvalid_credentials}}
        {:reply, :error, encode_reply(socket, message), socket}
    end
  end

  def handle_in(data, socket) do
    Logger.debug("GARBAGE #{data}")
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

  defp generate_otk_by_email_and_password(ip, email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, Accounts.generate_identity_otk(ip, identity)}
    else
      {:error, :unvalid_credentials}
    end
  end
end

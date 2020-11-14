defmodule CelestialGateway.Socket do
  @moduledoc false
  @behaviour Ruisseau.Transport

  require Logger
  alias Celestial.Accounts
  alias CelestialWorld.Oracle
  alias CelestialGateway.Crypto

  @impl true
  def init(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in({data, _}, state) do
    data
    |> Crypto.decrypt()
    |> Nostalex.parse()
    |> handle_packet(state)
  end

  @impl true
  def handle_info(_, state) do
    {:ok, state}
  end

  @impl true
  def terminate(_, _) do
    :ok
  end

  def handle_packet({:nos0575, email, password, client_version}, socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with :ok <- validate_client_version(client_version),
         {:ok, key} <- generate_otk_by_email_and_password(address, email, password) do
      channels = Oracle.list_channels()
      {:reply, :ok, encode_packet(:nstest, %{key: key, channels: channels}), socket}
    else
      {:error, :outdated_client} ->
        {:reply, :error, encode_packet(:failc, %{error: :outdated_client}), socket}

      {:error, :unvalid_credentials} ->
        {:reply, :error, encode_packet(:failc, %{error: :unvalid_credentials}), socket}
    end
  end

  def handle_packet(data, socket) do
    Logger.debug(["GARBAGE ", inspect(data)])
    {:ok, socket}
  end

  defp encode_packet(opcode, data) do
    {:plain, Nostalex.pack(opcode, data) |> Enum.join() |> Crypto.encrypt()}
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

defmodule CelestialGateway.Handler do
  @moduledoc false
  @behaviour Ruisseau.Handler

  require Logger
  alias Celestial.Accounts

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_in({data, _}, state) do
    data = NostalexCrypto.Gateway.decrypt(data)

    Logger.info(["PACKET ", data])

    case data |> Nostalex.parse() |> handle_packet(state) do
      {:reply, status, {opcode, msg}, state} ->
        msg = msg |> Enum.join() |> NostalexCrypto.Gateway.encrypt()
        {:reply, status, {opcode, msg}, state}
    end
  end

  defp handle_packet({:nos0575, email, cipher_password, client_version}, state) do
    password = NostalexCrypto.Gateway.decrypt_password(cipher_password)
    address = state.peer_data.address |> :inet.ntoa() |> to_string()

    with :ok <- validate_client_version(client_version),
         {:ok, uid} <- generate_uid_by_email_and_password(address, email, password) do
      send(self(), :authenticated)
      {:reply, :ok, {:nstest, Nostalex.Gateway.pack_nstest(%{uid: uid, channels: []})}, state}
    else
      {:error, :outdated_client} ->
        {:reply, :error, {:failc, Nostalex.Client.pack_failc(%{reason: :outdated_client})}, state}

      {:error, :unvalid_credentials} ->
        {:reply, :error, {:failc, Nostalex.Client.pack_failc(%{reason: :unvalid_credentials})}, state}
    end
  end

  defp validate_client_version(version) do
    case Application.get_env(:gateway, :client_requirement) do
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

  defp generate_uid_by_email_and_password(ip, email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, Accounts.generate_identity_uid_token(ip, identity)}
    else
      {:error, :unvalid_credentials}
    end
  end

  @impl true
  def handle_info(:authenticated, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(_, _) do
    :ok
  end
end

defmodule CelestialWorld.Gateway do
  @moduledoc false
  use Nostalex.Gateway

  require Logger
  alias Celestial.Accounts
  alias CelestialWorld.Oracle

  @impl true
  def init(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_packet({:nos0575, email, password, client_version}, socket) do
    address = socket.connect_info.peer_data.address |> :inet.ntoa() |> to_string()

    with :ok <- validate_client_version(client_version),
         {:ok, key} <- generate_one_time_key_by_email_and_password(address, email, password) do
      {:reply, :ok, {:nstest, %{key: key, channels: Oracle.list_channels()}}, socket}
    else
      {:error, :outdated_client} ->
        {:reply, :error, {:failc, %{error: :outdated_client}}, socket}

      {:error, :unvalid_credentials} ->
        {:reply, :error, {:failc, %{error: :unvalid_credentials}}, socket}
    end
  end

  def handle_packet(data, socket) do
    Logger.debug(["GARBAGE ", inspect(data)])
    {:ok, socket}
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

  defp generate_one_time_key_by_email_and_password(ip, email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, Accounts.generate_identity_one_time_key(ip, identity)}
    else
      {:error, :unvalid_credentials}
    end
  end
end

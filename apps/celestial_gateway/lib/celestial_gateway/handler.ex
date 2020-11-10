defmodule CelestialGateway.Handler do
  @moduledoc false
  use Nostalex.Gateway

  alias Celestial.Accounts

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_packet({:nos0575, email, password, client_version}, state) do
    address = state.peer_data.address |> :inet.ntoa() |> to_string()

    with :ok <- validate_client_version(client_version),
         {:ok, uid} <- generate_uid_by_email_and_password(address, email, password) do
      send(self(), :authenticated)
      {:reply, :ok, {:nstest, %{uid: uid, channels: []}}, state}
    else
      {:error, :outdated_client} ->
        {:reply, :error, {:failc, %{reason: :outdated_client}}, state}

      {:error, :unvalid_credentials} ->
        {:reply, :error, {:failc, %{reason: :unvalid_credentials}}, state}
    end
  end

  def handle_packet(_, state) do
    {:ok, state}
  end

  @impl true
  def handle_info(:authenticated, state) do
    {:stop, :normal, state}
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
end

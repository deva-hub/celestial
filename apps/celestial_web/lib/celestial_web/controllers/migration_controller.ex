defmodule CelestialWeb.MigrationController do
  use CelestialWeb, :controller

  alias Celestial.Accounts
  alias CelestialWeb.{Mailer, MigrationEmail}

  action_fallback CelestialWeb.FallbackController

  def edit(conn, params) do
    url = Application.get_env(:celestial_web, :email_url)
    qs = %URI{query: URI.encode_query(params)}
    redirect(conn, external: URI.merge(url, qs) |> to_string())
  end

  def create(conn, %{"current_password" => password, "identity" => identity_params}) do
    identity = conn.assigns.current_identity

    with {:ok, applied_identity} <- Accounts.apply_identity_email(identity, password, identity_params) do
      with {:ok, encoded_token} <- Accounts.prepare_update_email_token(applied_identity, identity.email) do
        url = Routes.identity_migration_path(conn, :edit, identity.id, encoded_token)

        identity
        |> MigrationEmail.new(url)
        |> Mailer.deliver()
      end

      send_resp(conn, :created, "")
    end
  end

  def update(conn, %{"token" => token}) do
    case Accounts.update_identity_email(conn.assigns.current_identity, token) do
      {:ok, _} ->
        send_resp(conn, :accepted, "")

      :error ->
        send_resp(conn, :unauthorized, "")
    end
  end
end

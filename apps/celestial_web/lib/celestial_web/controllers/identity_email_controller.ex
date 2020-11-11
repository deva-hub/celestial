defmodule CelestialWeb.IdentityEmailController do
  use CelestialWeb, :controller

  alias Celestial.Accounts
  alias CelestialWeb.{Mailer, IdentityEmailEmail}

  action_fallback CelestialWeb.FallbackController

  def edit(conn, params) do
    url = Application.get_env(:celestial_web, :email_url)
    qs = %URI{query: URI.encode_query(params)}
    redirect(conn, external: URI.merge(url, qs) |> to_string())
  end

  def update(conn, %{"current_password" => password, "identity" => identity_params}) do
    identity = conn.assigns.current_identity

    with {:ok, applied_identity} <- Accounts.apply_identity_email(identity, password, identity_params) do
      with {:ok, encoded_token} <- Accounts.prepare_update_email_token(applied_identity, identity.email) do
        url = Routes.identity_identity_email_path(conn, :edit, identity.id, encoded_token)

        identity
        |> IdentityEmailEmail.new(url)
        |> Mailer.deliver()
      end

      send_resp(conn, :created, "")
    end
  end

  def confirm(conn, %{"token" => token}) do
    with {:ok, _} <- Accounts.update_identity_email(conn.assigns.current_identity, token) do
      send_resp(conn, :accepted, "")
    else
      :error ->
        send_resp(conn, :unauthorized, "")
    end
  end
end

defmodule CelestialWeb.IdentityRecoveryController do
  use CelestialWeb, :controller

  alias Celestial.Accounts
  alias CelestialWeb.{Mailer, IdentityRecoveryEmail}

  action_fallback CelestialWeb.FallbackController

  def edit(conn, params) do
    url = Application.get_env(:celestial_web, :recovery_url)
    qs = %URI{query: URI.encode_query(params)}
    redirect(conn, external: URI.merge(url, qs) |> to_string())
  end

  def create(conn, %{"identity" => %{"email" => email}}) do
    if identity = Accounts.get_identity_by_email(email) do
      with {:ok, encoded_token} <- Accounts.prepare_identity_recovery_token(identity) do
        url = Routes.identity_recovery_url(conn, :edit, encoded_token)

        identity
        |> IdentityRecoveryEmail.new(url)
        |> Mailer.deliver()
      end
    end

    send_resp(conn, :created, "")
  end

  def update(conn, %{"identity" => identity_params, "token" => token}) do
    if identity = Accounts.get_identity_by_recovery_token(token) do
      with {:ok, _} <- Accounts.recover_identity_password(identity, identity_params) do
        send_resp(conn, :accepted, "")
      end
    else
      send_resp(conn, :unauthorized, "")
    end
  end
end

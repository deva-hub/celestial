defmodule CelestialWeb.ConfirmationController do
  use CelestialWeb, :controller

  alias Celestial.Accounts
  alias CelestialWeb.{Mailer, ConfirmationEmail}

  def create(conn, %{"identity" => %{"email" => email}}) do
    if identity = Accounts.get_identity_by_email(email) do
      with {:ok, encoded_token} <- Accounts.prepare_identity_confirmation_token(identity) do
        url = Routes.confirmation_url(conn, :update, encoded_token)

        identity
        |> ConfirmationEmail.new(url)
        |> Mailer.deliver()
      end
    end

    send_resp(conn, :created, "")
  end

  def edit(conn, params) do
    url = Application.get_env(:celestial_web, :confirmation_url)
    qs = %URI{query: URI.encode_query(params)}
    redirect(conn, external: URI.merge(url, qs) |> to_string())
  end

  def update(conn, %{"token" => token}) do
    case Accounts.confirm_identity(token) do
      {:ok, _} ->
        send_resp(conn, :accepted, "")

      :error ->
        send_resp(conn, :unauthorized, "")
    end
  end
end

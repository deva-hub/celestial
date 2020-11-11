defmodule CelestialWeb.AccessController do
  use CelestialWeb, :controller

  alias Celestial.Accounts

  def create(conn, %{"identity" => %{"email" => email, "password" => password}}) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      token = Accounts.generate_identity_access_token(identity)

      conn
      |> put_status(:created)
      |> render("show.json", access: %{token: token})
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def delete(conn, %{"token" => token}) do
    with :ok <- Accounts.delete_access_token(token) do
      send_resp(conn, :no_content, "")
    end
  end
end

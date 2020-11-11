defmodule CelestialWeb.IdentityController do
  use CelestialWeb, :controller

  alias Celestial.Accounts
  alias CelestialWeb.{Mailer, ConfirmationEmail}

  action_fallback CelestialWeb.FallbackController

  def index(conn, _params) do
    identities = Accounts.list_identities()
    render(conn, "index.json", identities: identities)
  end

  def show(conn, %{"id" => id}) do
    identity = Accounts.get_identity!(id)
    render(conn, "show.json", identity: identity)
  end

  def create(conn, %{"identity" => identity_params}) do
    with {:ok, identity} <- Accounts.register_identity(identity_params) do
      with {:ok, encoded_token} <- Accounts.prepare_identity_confirmation_token(identity) do
        url = Routes.confirmation_url(conn, :update, encoded_token)

        identity
        |> ConfirmationEmail.new(url)
        |> Mailer.deliver()
      end

      conn
      |> put_status(:created)
      |> render("show.json", identity: identity)
    end
  end
end

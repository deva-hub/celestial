defmodule CelestialWeb.IdentityController do
  use CelestialWeb, :controller

  alias Celestial.Accounts
  alias Celestial.Accounts.Identity

  action_fallback CelestialWeb.FallbackController

  def index(conn, _params) do
    identities = Accounts.list_identities()
    render(conn, "index.json", identities: identities)
  end

  def create(conn, %{"identity" => identity_params}) do
    with {:ok, %Identity{} = identity} <- Accounts.create_identity(identity_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.identity_path(conn, :show, identity))
      |> render("show.json", identity: identity)
    end
  end

  def show(conn, %{"id" => id}) do
    identity = Accounts.get_identity!(id)
    render(conn, "show.json", identity: identity)
  end

  def update(conn, %{"id" => id, "identity" => identity_params}) do
    identity = Accounts.get_identity!(id)

    with {:ok, %Identity{} = identity} <- Accounts.update_identity(identity, identity_params) do
      render(conn, "show.json", identity: identity)
    end
  end

  def delete(conn, %{"id" => id}) do
    identity = Accounts.get_identity!(id)

    with {:ok, %Identity{}} <- Accounts.delete_identity(identity) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule CelestialWeb.IdentityPasswordController do
  use CelestialWeb, :controller

  alias Celestial.Accounts

  action_fallback CelestialWeb.FallbackController

  def update(conn, %{"current_password" => password, "identity" => identity_params}) do
    identity = conn.assigns.current_identity

    with {:ok, _} <- Accounts.update_identity_password(identity, password, identity_params) do
      send_resp(conn, :accepted, "")
    end
  end
end

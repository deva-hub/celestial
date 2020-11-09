defmodule CelestialWeb.IdentityAuth do
  import Plug.Conn

  alias Celestial.Accounts

  @doc """
  Authenticates the identity by looking for identity using
  the bearer access token.
  """
  def fetch_current_identity(conn, _opts) do
    identity_token = get_authorization_header(conn)
    identity = identity_token && Accounts.get_identity_by_access_token(identity_token)
    assign(conn, :current_identity, identity)
  end

  defp get_authorization_header(conn) do
    case get_req_header(conn, "authorization") do
      [] ->
        nil

      ["Bearer " <> identity_token] ->
        identity_token
    end
  end

  @doc """
  Used for routes that require the identity to be authenticated.

  If you want to enforce the identity email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_identity(conn, _opts) do
    if conn.assigns[:current_identity] do
      conn
    else
      conn
      |> send_resp(:unauthorized, "")
      |> halt()
    end
  end
end

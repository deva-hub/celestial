defmodule CelestialWeb.IdentityAuthTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  alias CelestialWeb.IdentityAuth
  import Celestial.AccountsFixtures

  setup %{conn: conn} do
    secret_key_base = CelestialWeb.Endpoint.config(:secret_key_base)
    conn = Map.replace!(conn, :secret_key_base, secret_key_base)
    %{identity: identity_fixture(), conn: conn}
  end

  describe "fetch current identity" do
    test "authenticates identity from authorization bearer", %{conn: conn, identity: identity} do
      identity_token = Accounts.generate_identity_access_token(identity)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{identity_token}")
        |> IdentityAuth.fetch_current_identity([])

      assert conn.assigns.current_identity.id == identity.id
    end

    test "does not authenticate if data is missing", %{conn: conn, identity: identity} do
      _ = Accounts.generate_identity_access_token(identity)
      conn = IdentityAuth.fetch_current_identity(conn, [])
      refute conn.assigns.current_identity
    end
  end

  describe "require authenticated identity" do
    test "renders error when is not authenticated", %{conn: conn} do
      conn = IdentityAuth.require_authenticated_identity(conn, [])
      assert response(conn, 401)
    end

    test "renders route when identity is authenticated", %{conn: conn, identity: identity} do
      conn =
        conn
        |> assign(:current_identity, identity)
        |> IdentityAuth.require_authenticated_identity([])

      refute conn.halted
      refute conn.status
    end
  end
end

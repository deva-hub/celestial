defmodule CelestialWeb.IdentityTokenControllerTest do
  use CelestialWeb.ConnCase, async: true

  import Celestial.AccountsFixtures
  alias Celestial.Accounts

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), identity: identity_fixture()}
  end

  describe "create token" do
    test "renders token when credentials are valid", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_access_path(conn, :create), %{
          "identity" => %{"email" => identity.email, "password" => valid_identity_password()}
        })

      assert json_response(conn, 201)["data"]
    end

    test "renders errors when credentials are invalid", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_access_path(conn, :create), %{
          "identity" => %{"email" => identity.email, "password" => "invalid_password"}
        })

      assert response(conn, 401)
    end
  end

  describe "delete token" do
    test "deletes chosen token", %{conn: conn, identity: identity} do
      identity_token = Accounts.generate_identity_access_token(identity)
      conn = put_req_header(conn, "authorization", "Bearer #{identity_token}")
      conn = delete(conn, Routes.identity_access_path(conn, :delete, identity_token))
      assert response(conn, 204)

      conn = get(conn, Routes.identity_path(conn, :show, identity.id))
      assert response(conn, 401)
    end
  end
end

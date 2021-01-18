defmodule CelestialWeb.IdentityControllerTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  import Celestial.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create identity" do
    test "renders identity when data is valid", %{conn: conn} do
      username = unique_identity_username()

      conn =
        post(conn, Routes.identity_path(conn, :create), %{
          "identity" => %{
            "username" => username,
            "password" => valid_identity_password()
          }
        })

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert id == Accounts.get_identity_by_username(username).id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.identity_path(conn, :create), %{
          "identity" => %{"username" => "with spaces", "password" => "too short"}
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

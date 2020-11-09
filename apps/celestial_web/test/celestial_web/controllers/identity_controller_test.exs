defmodule CelestialWeb.IdentityControllerTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  import Celestial.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create identity" do
    test "renders identity when data is valid", %{conn: conn} do
      email = unique_identity_email()

      conn =
        post(conn, Routes.identity_path(conn, :create), %{
          "identity" => %{
            "email" => email,
            "password" => valid_identity_password()
          }
        })

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert id == Accounts.get_identity_by_email(email).id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.identity_path(conn, :create), %{
          "identity" => %{"email" => "with spaces", "password" => "too short"}
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

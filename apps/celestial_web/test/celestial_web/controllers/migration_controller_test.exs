defmodule CelestialWeb.MigrationControllerTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  import Celestial.AccountsFixtures

  setup :register_and_sign_in_identity

  describe "update email" do
    test "updates the identity email", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_migration_path(conn, :create, "@me"), %{
          "current_password" => valid_identity_password(),
          "identity" => %{"email" => unique_identity_email()}
        })

      assert response(conn, 201)
      assert Accounts.get_identity_by_email(identity.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.identity_migration_path(conn, :create, "@me"), %{
          "current_password" => "invalid",
          "identity" => %{"email" => "with spaces"}
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update email confimation" do
    setup %{identity: identity} do
      email = unique_identity_email()
      {:ok, token} = Accounts.prepare_update_email_token(%{identity | email: email}, identity.email)
      %{token: token, email: email}
    end

    test "redirect to confirmation url", %{conn: conn, token: token} do
      conn = get(conn, Routes.identity_migration_path(conn, :edit, "@me", token))
      base_url = Application.get_env(:celestial_web, :email_url)
      url = URI.merge(base_url, %URI{query: URI.encode_query(%{identity_id: "@me", token: token})})
      assert redirected_to(conn) == url |> to_string()
    end

    test "updates the identity email once", %{
      conn: conn,
      identity: identity,
      token: token,
      email: email
    } do
      conn = put(conn, Routes.identity_migration_path(conn, :update, "@me", token))
      assert response(conn, 202)
      refute Accounts.get_identity_by_email(identity.email)
      assert Accounts.get_identity_by_email(email)

      conn = put(conn, Routes.identity_migration_path(conn, :update, "@me", token))
      assert response(conn, 401)
    end
  end
end

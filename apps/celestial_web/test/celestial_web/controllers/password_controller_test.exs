defmodule CelestialWeb.PasswordControllerTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  import Celestial.AccountsFixtures

  setup :register_and_sign_in_identity

  describe "PUT /identities/settings/update_password" do
    test "updates the identity password and resets tokens", %{conn: conn, identity: identity} do
      conn =
        put(conn, Routes.identity_password_path(conn, :update, identity.id), %{
          "current_password" => valid_identity_password(),
          "identity" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert response(conn, 202)
      assert Accounts.get_identity_by_email_and_password(identity.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn, identity: identity} do
      conn =
        put(conn, Routes.identity_password_path(conn, :update, identity.id), %{
          "current_password" => "invalid",
          "identity" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

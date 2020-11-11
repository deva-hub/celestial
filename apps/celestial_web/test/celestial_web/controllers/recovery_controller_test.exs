defmodule CelestialWeb.RecoveryControllerTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  alias Celestial.Repo
  import Celestial.AccountsFixtures

  setup do
    %{identity: identity_fixture()}
  end

  describe "create recovery" do
    test "sends a new recovery password token", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.recovery_path(conn, :create), %{
          "identity" => %{"email" => identity.email}
        })

      assert response(conn, 201)
      assert Repo.get_by!(Accounts.IdentityToken, identity_id: identity.id).context == "recovery"
    end

    test "does not send recovery password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.recovery_path(conn, :create), %{
          "identity" => %{"email" => "unknown@example.com"}
        })

      assert response(conn, 201)
      assert Repo.all(Accounts.IdentityToken) == []
    end
  end

  describe "show recovery token page" do
    setup %{identity: identity} do
      {:ok, token} = Accounts.prepare_identity_recovery_token(identity)
      %{token: token}
    end

    test "redirect to the recovery page", %{conn: conn, token: token} do
      conn = get(conn, Routes.recovery_path(conn, :edit, token))
      base_url = Application.get_env(:celestial_web, :recovery_url)
      url = URI.merge(base_url, %URI{query: URI.encode_query(%{token: token})})
      assert redirected_to(conn) == url |> to_string()
    end
  end

  describe "consume recovery token" do
    setup %{identity: identity} do
      {:ok, token} = Accounts.prepare_identity_recovery_token(identity)
      %{token: token}
    end

    test "recover password once", %{conn: conn, identity: identity, token: token} do
      conn =
        put(conn, Routes.recovery_path(conn, :update, token), %{
          "identity" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert response(conn, 202)
      assert Accounts.get_identity_by_email_and_password(identity.email, "new valid password")
    end

    test "does not recovery password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.recovery_path(conn, :update, token), %{
          "identity" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "does not recovery password with invalid token", %{conn: conn} do
      conn =
        put(conn, Routes.recovery_path(conn, :update, "oops"), %{
          "identity" => %{}
        })

      assert response(conn, 401)
    end
  end
end

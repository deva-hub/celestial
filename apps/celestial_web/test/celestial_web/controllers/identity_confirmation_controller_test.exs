defmodule CelestialWeb.IdentityConfirmationControllerTest do
  use CelestialWeb.ConnCase, async: true

  alias Celestial.Accounts
  alias Celestial.Repo
  import Celestial.AccountsFixtures

  setup do
    %{identity: identity_fixture()}
  end

  describe "create confirmation" do
    test "sends a new confirmation token", %{conn: conn, identity: identity} do
      conn =
        post(conn, Routes.identity_confirmation_path(conn, :create), %{
          "identity" => %{"email" => identity.email}
        })

      assert response(conn, 201)
      assert Repo.get_by!(Accounts.IdentityToken, identity_id: identity.id).context == "confirm"
    end

    test "does not send confirmation token if account is confirmed", %{
      conn: conn,
      identity: identity
    } do
      Repo.update!(Accounts.Identity.confirm_changeset(identity))

      conn =
        post(conn, Routes.identity_path(conn, :create), %{
          "identity" => %{"email" => identity.email}
        })

      assert json_response(conn, 422)["errors"] != %{}
      refute Repo.get_by(Accounts.IdentityToken, identity_id: identity.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.identity_path(conn, :create), %{
          "identity" => %{"email" => "unknown@example.com"}
        })

      assert json_response(conn, 422)["errors"] != %{}
      assert Repo.all(Accounts.IdentityToken) == []
    end
  end

  describe "edit confirmation token" do
    setup %{identity: identity} do
      {:ok, token} = Accounts.prepare_identity_confirmation_token(identity)
      %{token: token}
    end

    test "redirect to the confirmation page", %{conn: conn, token: token} do
      conn = get(conn, Routes.identity_confirmation_path(conn, :edit, token))
      base_url = Application.get_env(:celestial_web, :confirmation_url)
      url = URI.merge(base_url, %URI{query: URI.encode_query(%{token: token})})
      assert redirected_to(conn) == url |> to_string()
    end
  end

  describe "update confirmatio token" do
    test "confirms the given token once", %{conn: conn, identity: identity} do
      {:ok, token} = Accounts.prepare_identity_confirmation_token(identity)
      conn = put(conn, Routes.identity_confirmation_path(conn, :update, token))
      assert response(conn, 202)
      assert Accounts.get_identity!(identity.id).confirmed_at
      assert Repo.all(Accounts.IdentityToken) == []

      conn = put(conn, Routes.identity_confirmation_path(conn, :update, token))
      assert response(conn, 401)
    end

    test "does not confirm email with invalid token", %{conn: conn, identity: identity} do
      conn = put(conn, Routes.identity_confirmation_path(conn, :update, "oops"))
      assert response(conn, 401)
      refute Accounts.get_identity!(identity.id).confirmed_at
    end
  end
end

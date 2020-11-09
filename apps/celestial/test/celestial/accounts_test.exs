defmodule Celestial.AccountsTest do
  use Celestial.DataCase

  alias Celestial.Accounts
  import Celestial.AccountsFixtures
  alias Celestial.Accounts.{Identity, IdentityToken}

  describe "get_identity_by_email/1" do
    test "does not return the identity if the email does not exist" do
      refute Accounts.get_identity_by_email("unknown@example.com")
    end

    test "returns the identity if the email exists" do
      %{id: id} = identity = identity_fixture()
      assert %Identity{id: ^id} = Accounts.get_identity_by_email(identity.email)
    end
  end

  describe "get_identity_by_email_and_password/2" do
    test "does not return the identity if the email does not exist" do
      refute Accounts.get_identity_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the identity if the password is not valid" do
      identity = identity_fixture()
      refute Accounts.get_identity_by_email_and_password(identity.email, "invalid")
    end

    test "returns the identity if the email and password are valid" do
      %{id: id} = identity = identity_fixture()

      assert %Identity{id: ^id} =
               Accounts.get_identity_by_email_and_password(
                 identity.email,
                 valid_identity_password()
               )
    end
  end

  describe "get_identity!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_identity!(-1)
      end
    end

    test "returns the identity with the given id" do
      %{id: id} = identity = identity_fixture()
      assert %Identity{id: ^id} = Accounts.get_identity!(identity.id)
    end
  end

  describe "register_identity/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_identity(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_identity(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_identity(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = identity_fixture()
      {:error, changeset} = Accounts.register_identity(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_identity(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers identities with a hashed password" do
      email = unique_identity_email()

      {:ok, identity} = Accounts.register_identity(%{email: email, password: valid_identity_password()})

      assert identity.email == email
      assert is_binary(identity.hashed_password)
      assert is_nil(identity.confirmed_at)
      assert is_nil(identity.password)
    end
  end

  describe "change_identity_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_identity_registration(%Identity{})
      assert changeset.required == [:password, :email]
    end
  end

  describe "change_identity_email/2" do
    test "returns a identity changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_identity_email(%Identity{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_identity_email/3" do
    setup do
      %{identity: identity_fixture()}
    end

    test "requires email to change", %{identity: identity} do
      {:error, changeset} = Accounts.apply_identity_email(identity, valid_identity_password(), %{})

      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{identity: identity} do
      {:error, changeset} = Accounts.apply_identity_email(identity, valid_identity_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{identity: identity} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} = Accounts.apply_identity_email(identity, valid_identity_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{identity: identity} do
      %{email: email} = identity_fixture()

      {:error, changeset} = Accounts.apply_identity_email(identity, valid_identity_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{identity: identity} do
      {:error, changeset} = Accounts.apply_identity_email(identity, "invalid", %{email: unique_identity_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{identity: identity} do
      email = unique_identity_email()

      {:ok, identity} = Accounts.apply_identity_email(identity, valid_identity_password(), %{email: email})

      assert identity.email == email
      assert Accounts.get_identity!(identity.id).email != email
    end
  end

  describe "prepare_update_email_token/3" do
    setup do
      %{identity: identity_fixture()}
    end

    test "sends token through notification", %{identity: identity} do
      {:ok, token} = Accounts.prepare_update_email_token(identity, "current@example.com")
      {:ok, token} = Base.url_decode64(token, padding: false)
      assert identity_token = Repo.get_by(IdentityToken, token: :crypto.hash(:sha256, token))
      assert identity_token.identity_id == identity.id
      assert identity_token.sent_to == identity.email
      assert identity_token.context == "change:current@example.com"
    end
  end

  describe "update_identity_email/2" do
    setup do
      identity = identity_fixture()
      email = unique_identity_email()
      {:ok, token} = Accounts.prepare_update_email_token(%{identity | email: email}, identity.email)
      %{identity: identity, token: token, email: email}
    end

    test "updates the email with a valid token", %{identity: identity, token: token, email: email} do
      assert Accounts.update_identity_email(identity, token)
      changed_identity = Repo.get!(Identity, identity.id)
      assert changed_identity.email != identity.email
      assert changed_identity.email == email
      assert changed_identity.confirmed_at
      assert changed_identity.confirmed_at != identity.confirmed_at
      refute Repo.get_by(IdentityToken, identity_id: identity.id)
    end

    test "does not update email with invalid token", %{identity: identity} do
      assert Accounts.update_identity_email(identity, "oops") == :error
      assert Repo.get!(Identity, identity.id).email == identity.email
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end

    test "does not update email if identity email changed", %{identity: identity, token: token} do
      assert Accounts.update_identity_email(%{identity | email: "current@example.com"}, token) ==
               :error

      assert Repo.get!(Identity, identity.id).email == identity.email
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end

    test "does not update email if token expired", %{identity: identity, token: token} do
      {1, nil} = Repo.update_all(IdentityToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_identity_email(identity, token) == :error
      assert Repo.get!(Identity, identity.id).email == identity.email
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end
  end

  describe "change_identity_password/2" do
    test "returns a identity changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_identity_password(%Identity{})
      assert changeset.required == [:password]
    end
  end

  describe "update_identity_password/3" do
    setup do
      %{identity: identity_fixture()}
    end

    test "validates password", %{identity: identity} do
      {:error, changeset} =
        Accounts.update_identity_password(identity, valid_identity_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{identity: identity} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_identity_password(identity, valid_identity_password(), %{
          password: too_long
        })

      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{identity: identity} do
      {:error, changeset} =
        Accounts.update_identity_password(identity, "invalid", %{
          password: valid_identity_password()
        })

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{identity: identity} do
      {:ok, identity} =
        Accounts.update_identity_password(identity, valid_identity_password(), %{
          password: "new valid password"
        })

      assert is_nil(identity.password)
      assert Accounts.get_identity_by_email_and_password(identity.email, "new valid password")
    end

    test "deletes all tokens for the given identity", %{identity: identity} do
      _ = Accounts.generate_identity_access_token(identity)

      {:ok, _} =
        Accounts.update_identity_password(identity, valid_identity_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(IdentityToken, identity_id: identity.id)
    end
  end

  describe "generate_identity_access_token/1" do
    setup do
      %{identity: identity_fixture()}
    end

    test "generates a token", %{identity: identity} do
      token = Accounts.generate_identity_access_token(identity)
      assert identity_token = Repo.get_by(IdentityToken, token: token)
      assert identity_token.context == "access"

      # Creating the same token for another identity should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%IdentityToken{
          token: identity_token.token,
          identity_id: identity_fixture().id,
          context: "access"
        })
      end
    end
  end

  describe "get_identity_by_access_token/1" do
    setup do
      identity = identity_fixture()
      token = Accounts.generate_identity_access_token(identity)
      %{identity: identity, token: token}
    end

    test "returns identity by token", %{identity: identity, token: token} do
      assert token_identity = Accounts.get_identity_by_access_token(token)
      assert token_identity.id == identity.id
    end

    test "does not return identity for invalid token" do
      refute Accounts.get_identity_by_access_token("oops")
    end

    test "does not return identity for expired token", %{token: token} do
      {1, nil} = Repo.update_all(IdentityToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_identity_by_access_token(token)
    end
  end

  describe "delete_access_token/1" do
    test "deletes the token" do
      identity = identity_fixture()
      token = Accounts.generate_identity_access_token(identity)
      assert Accounts.delete_access_token(token) == :ok
      refute Accounts.get_identity_by_access_token(token)
    end
  end

  describe "prepare_identity_confirmation_token/2" do
    setup do
      %{identity: identity_fixture()}
    end

    test "sends token through notification", %{identity: identity} do
      {:ok, token} = Accounts.prepare_identity_confirmation_token(identity)
      {:ok, token} = Base.url_decode64(token, padding: false)
      assert identity_token = Repo.get_by(IdentityToken, token: :crypto.hash(:sha256, token))
      assert identity_token.identity_id == identity.id
      assert identity_token.sent_to == identity.email
      assert identity_token.context == "confirm"
    end
  end

  describe "confirm_identity/2" do
    setup do
      identity = identity_fixture()
      {:ok, token} = Accounts.prepare_identity_confirmation_token(identity)
      %{identity: identity, token: token}
    end

    test "confirms the email with a valid token", %{identity: identity, token: token} do
      assert {:ok, confirmed_identity} = Accounts.confirm_identity(token)
      assert confirmed_identity.confirmed_at
      assert confirmed_identity.confirmed_at != identity.confirmed_at
      assert Repo.get!(Identity, identity.id).confirmed_at
      refute Repo.get_by(IdentityToken, identity_id: identity.id)
    end

    test "does not confirm with invalid token", %{identity: identity} do
      assert Accounts.confirm_identity("oops") == :error
      refute Repo.get!(Identity, identity.id).confirmed_at
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end

    test "does not confirm email if token expired", %{identity: identity, token: token} do
      {1, nil} = Repo.update_all(IdentityToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_identity(token) == :error
      refute Repo.get!(Identity, identity.id).confirmed_at
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end
  end

  describe "prepare_identity_recovery_token/2" do
    setup do
      %{identity: identity_fixture()}
    end

    test "sends token through notification", %{identity: identity} do
      {:ok, token} = Accounts.prepare_identity_recovery_token(identity)
      {:ok, token} = Base.url_decode64(token, padding: false)
      assert identity_token = Repo.get_by(IdentityToken, token: :crypto.hash(:sha256, token))
      assert identity_token.identity_id == identity.id
      assert identity_token.sent_to == identity.email
      assert identity_token.context == "recovery"
    end
  end

  describe "get_identity_by_recovery_token/1" do
    setup do
      identity = identity_fixture()
      {:ok, token} = Accounts.prepare_identity_recovery_token(identity)
      %{identity: identity, token: token}
    end

    test "returns the identity with valid token", %{identity: %{id: id}, token: token} do
      assert %Identity{id: ^id} = Accounts.get_identity_by_recovery_token(token)
      assert Repo.get_by(IdentityToken, identity_id: id)
    end

    test "does not return the identity with invalid token", %{identity: identity} do
      refute Accounts.get_identity_by_recovery_token("oops")
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end

    test "does not return the identity if token expired", %{identity: identity, token: token} do
      {1, nil} = Repo.update_all(IdentityToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_identity_by_recovery_token(token)
      assert Repo.get_by(IdentityToken, identity_id: identity.id)
    end
  end

  describe "recover_identity_password/2" do
    setup do
      %{identity: identity_fixture()}
    end

    test "validates password", %{identity: identity} do
      {:error, changeset} =
        Accounts.recover_identity_password(identity, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{identity: identity} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.recover_identity_password(identity, %{password: too_long})
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{identity: identity} do
      {:ok, updated_identity} = Accounts.recover_identity_password(identity, %{password: "new valid password"})

      assert is_nil(updated_identity.password)
      assert Accounts.get_identity_by_email_and_password(identity.email, "new valid password")
    end

    test "deletes all tokens for the given identity", %{identity: identity} do
      _ = Accounts.generate_identity_access_token(identity)
      {:ok, _} = Accounts.recover_identity_password(identity, %{password: "new valid password"})
      refute Repo.get_by(IdentityToken, identity_id: identity.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Identity{password: "123456"}) =~ "password: \"123456\""
    end
  end
end

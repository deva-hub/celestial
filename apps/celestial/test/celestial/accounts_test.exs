defmodule Celestial.AccountsTest do
  use Celestial.DataCase

  alias Celestial.Accounts
  import Celestial.AccountsFixtures
  alias Celestial.Accounts.{Identity, IdentityToken}

  describe "get_identity_by_username/1" do
    test "does not return the identity if the username does not exist" do
      refute Accounts.get_identity_by_username("unknown@example.com")
    end

    test "returns the identity if the username exists" do
      %{id: id} = identity = identity_fixture()
      assert %Identity{id: ^id} = Accounts.get_identity_by_username(identity.username)
    end
  end

  describe "get_identity_by_username_and_password/2" do
    test "does not return the identity if the username does not exist" do
      refute Accounts.get_identity_by_username_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the identity if the password is not valid" do
      identity = identity_fixture()
      refute Accounts.get_identity_by_username_and_password(identity.username, "invalid")
    end

    test "returns the identity if the username and password are valid" do
      %{id: id} = identity = identity_fixture()

      assert %Identity{id: ^id} =
               Accounts.get_identity_by_username_and_password(
                 identity.username,
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

  describe "create_identity/1" do
    test "requires username and password to be set" do
      {:error, changeset} = Accounts.create_identity(%{})

      assert %{
               password: ["can't be blank"],
               username: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates username and password when given" do
      {:error, changeset} = Accounts.create_identity(%{username: "not valid", password: "not valid"})

      assert %{
               username: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for username and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.create_identity(%{username: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).username
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates username uniqueness" do
      %{username: username} = identity_fixture()
      {:error, changeset} = Accounts.create_identity(%{username: username})
      assert "has already been taken" in errors_on(changeset).username

      # Now try with the upper cased username too, to check that username case is ignored.
      {:error, changeset} = Accounts.create_identity(%{username: String.upcase(username)})
      assert "has already been taken" in errors_on(changeset).username
    end

    test "registers identities with a hashed password" do
      username = unique_identity_username()

      {:ok, identity} = Accounts.create_identity(%{username: username, password: valid_identity_password()})

      assert identity.username == username
      assert is_binary(identity.hashed_password)
      assert is_nil(identity.password)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Identity{password: "123456"}) =~ "password: \"123456\""
    end
  end
end

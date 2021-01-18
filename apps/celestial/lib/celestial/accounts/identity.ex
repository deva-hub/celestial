defmodule Celestial.Accounts.Identity do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:password]}
  schema "identities" do
    field :username, :string
    field :password, :string, virtual: true
    field :hashed_password, :string

    timestamps()
  end

  @doc """
  A identity changeset for registration.

  It is important to validate the length of both username and password.
  Otherwise databases may truncate the username without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:username, :password])
    |> validate_username()
    |> validate_password()
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+/)
    |> validate_length(:username, max: 160)
    |> unsafe_validate_unique(:username, Celestial.Repo)
    |> unique_constraint(:username)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, max: 80)
    |> prepare_changes(&hash_password/1)
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    changeset
    |> put_change(:hashed_password, Argon2.hash_pwd_salt(password))
    |> delete_change(:password)
  end

  @doc """
  Verifies the password.

  If there is no identity or the identity doesn't have a password, we call
  `Argon2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Celestial.Accounts.Identity{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end

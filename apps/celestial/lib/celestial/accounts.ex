defmodule Celestial.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Celestial.Repo
  alias Celestial.Accounts.{Identity, IdentityToken}

  @doc """
  Returns the list of identities.

  ## Examples

      iex> list_identities()
      [%Identity{}, ...]

  """
  def list_identities do
    Repo.all(Identity)
  end

  @doc """
  Gets a identity by username.

  ## Examples

      iex> get_identity_by_username("foo@example.com")
      %Identity{}

      iex> get_identity_by_username("unknown@example.com")
      nil

  """
  def get_identity_by_username(username) when is_binary(username) do
    Repo.get_by(Identity, username: username)
  end

  @doc """
  Gets a identity by username and password.

  ## Examples

      iex> get_identity_by_username_and_password("foo@example.com", "correct_password")
      %Identity{}

      iex> get_identity_by_username_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_identity_by_username_and_password(username, password)
      when is_binary(username) and is_binary(password) do
    identity = Repo.get_by(Identity, username: username)
    if Identity.valid_password?(identity, password), do: identity
  end

  @doc """
  Gets a single identity.

  Raises `Ecto.NoResultsError` if the Identity does not exist.

  ## Examples

      iex> get_identity!(123)
      %Identity{}

      iex> get_identity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_identity!(id), do: Repo.get!(Identity, id)

  ## Identity registration

  @doc """
  Registers a identity.

  ## Examples

      iex> create_identity(%{field: value})
      {:ok, %Identity{}}

      iex> create_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_identity(attrs) do
    %Identity{}
    |> Identity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a identity.

  ## Examples

      iex> update_identity(identity, %{field: new_value})
      {:ok, %Identity{}}

      iex> update_identity(identity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_identity(%Identity{} = identity, attrs) do
    identity
    |> Identity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a identity.

  ## Examples

      iex> delete_identity(identity)
      {:ok, %Identity{}}

      iex> delete_identity(identity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_identity(%Identity{} = identity) do
    Repo.delete(identity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking identity changes.

  ## Examples

      iex> change_identity(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity(%Identity{} = identity, attrs \\ %{}) do
    Identity.changeset(identity, attrs)
  end

  ## Session

  @doc """
  Generates a one time key from a given address.
  """
  def generate_identity_key(address, identity) do
    {key, identity_token} = IdentityToken.build_key(address, identity)
    Repo.insert!(identity_token)
    key
  end

  @doc """
  Gets the identity with the given key and password.
  """
  def consume_identity_key(address, key, password) do
    case Repo.one(IdentityToken.verify_key_query(address, key)) do
      nil ->
        :error

      identity ->
        if Identity.valid_password?(identity, password) do
          Repo.delete_all(IdentityToken.identity_and_contexts_query(identity, ["key"]))
          {:ok, identity}
        else
          :error
        end
    end
  end
end

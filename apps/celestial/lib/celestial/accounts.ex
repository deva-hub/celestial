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
  Gets a identity by email.

  ## Examples

      iex> get_identity_by_email("foo@example.com")
      %Identity{}

      iex> get_identity_by_email("unknown@example.com")
      nil

  """
  def get_identity_by_email(email) when is_binary(email) do
    Repo.get_by(Identity, email: email)
  end

  @doc """
  Gets a identity by email and password.

  ## Examples

      iex> get_identity_by_email_and_password("foo@example.com", "correct_password")
      %Identity{}

      iex> get_identity_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_identity_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    identity = Repo.get_by(Identity, email: email)
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

      iex> register_identity(%{field: value})
      {:ok, %Identity{}}

      iex> register_identity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_identity(attrs) do
    %Identity{}
    |> Identity.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking identity changes.

  ## Examples

      iex> change_identity_registration(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity_registration(%Identity{} = identity, attrs \\ %{}) do
    Identity.registration_changeset(identity, attrs)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the identity email.

  ## Examples

      iex> change_identity_email(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity_email(identity, attrs \\ %{}) do
    Identity.email_changeset(identity, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_identity_email(identity, "valid password", %{email: ...})
      {:ok, %Identity{}}

      iex> apply_identity_email(identity, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_identity_email(identity, password, attrs) do
    identity
    |> Identity.email_changeset(attrs)
    |> Identity.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the identity email using the given token.

  If the token matches, the identity email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_identity_email(identity, token) do
    context = "change:#{identity.email}"

    with {:ok, query} <- IdentityToken.verify_change_email_token_query(token, context),
         %{sent_to: email} <- Repo.one(query) do
      case Repo.transaction(identity_email_multi(identity, email, context)) do
        {:ok, %{identity: identity}} -> {:ok, identity}
        {:error, :identity, changeset, _} -> {:error, changeset}
      end
    else
      _ -> :error
    end
  end

  defp identity_email_multi(identity, email, context) do
    changeset = identity |> Identity.email_changeset(%{email: email}) |> Identity.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      IdentityToken.identity_and_contexts_query(identity, [context])
    )
  end

  @doc """
  Delivers the update email instructions to the given identity.

  ## Examples

      iex> prepare_update_email_token(identity, current_email, &Routes.identity_update_email_url(conn, :edit, &1))
      {:ok, "rORVX6rTRrCRL0km4223weXbXRnyIxOPYNdc5qd5mSs"}

  """
  def prepare_update_email_token(%Identity{} = identity, current_email) do
    {encoded_token, identity_token} = IdentityToken.build_email_token(identity, "change:#{current_email}")

    with {:ok, _} <- Repo.insert(identity_token) do
      {:ok, encoded_token}
    else
      _ -> :error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the identity password.

  ## Examples

      iex> change_identity_password(identity)
      %Ecto.Changeset{data: %Identity{}}

  """
  def change_identity_password(identity, attrs \\ %{}) do
    Identity.password_changeset(identity, attrs)
  end

  @doc """
  Updates the identity password.

  ## Examples

      iex> update_identity_password(identity, "valid password", %{password: ...})
      {:ok, %Identity{}}

      iex> update_identity_password(identity, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_identity_password(identity, password, attrs) do
    changeset =
      identity
      |> Identity.password_changeset(attrs)
      |> Identity.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, changeset)
    |> Ecto.Multi.delete_all(:tokens, IdentityToken.identity_and_contexts_query(identity, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{identity: identity}} -> {:ok, identity}
      {:error, :identity, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a one time key from a given address.
  """
  def generate_identity_one_time_key(address, identity) do
    {key, identity_token} = IdentityToken.build_one_time_key(address, identity)
    Repo.insert!(identity_token)
    key
  end

  @doc """
  Generates a token.
  """
  def generate_identity_access_token(identity) do
    {token, identity_token} = IdentityToken.build_access_token(identity)
    Repo.insert!(identity_token)
    token
  end

  @doc """
  Gets the identity with the given signed key.
  """
  def consume_one_time_key(address, key) do
    with {:ok, query} = IdentityToken.verify_one_time_key_query(address, key),
         identity when not is_nil(identity) <- Repo.one(query) do
      case Repo.transaction(consume_one_time_key_multi(identity)) do
        {:ok, %{identity: identity}} -> {:ok, identity}
        {:error, :identity, changeset, _} -> {:error, changeset}
      end
    else
      _ -> :error
    end
  end

  defp consume_one_time_key_multi(identity) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, Identity.confirm_changeset(identity))
    |> Ecto.Multi.delete_all(
      :tokens,
      IdentityToken.identity_and_contexts_query(identity, ["otk"])
    )
  end

  @doc """
  Gets the identity with the given signed token.
  """
  def get_identity_by_access_token(token) do
    {:ok, query} = IdentityToken.verify_access_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_access_token(token) do
    Repo.delete_all(IdentityToken.token_and_context_query(token, "access"))
    :ok
  end

  ## IdentityConfirmation

  @doc """
  Delivers the confirmation email instructions to the given identity.

  ## Examples

      iex> prepare_identity_confirmation_token(identity)
      {:ok, "Z3zvZL-vWzlDQu4VQhMMvKNl6VHZwr3qEWooBW_a4mA"}

      iex> prepare_identity_confirmation_token(confirmed_identity)
      {:error, :already_confirmed}

  """
  def prepare_identity_confirmation_token(%Identity{} = identity) do
    if identity.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, identity_token} = IdentityToken.build_email_token(identity, "confirm")

      with {:ok, _} <- Repo.insert(identity_token) do
        {:ok, encoded_token}
      else
        _ -> :error
      end
    end
  end

  @doc """
  Confirms a identity by the given token.

  If the token matches, the identity account is marked as confirmed
  and the token is deleted.
  """
  def confirm_identity(token) do
    with {:ok, query} <- IdentityToken.verify_email_token_query(token, "confirm"),
         identity when not is_nil(identity) <- Repo.one(query) do
      case Repo.transaction(confirm_identity_multi(identity)) do
        {:ok, %{identity: identity}} -> {:ok, identity}
        {:error, :identity, changeset, _} -> {:error, changeset}
      end
    else
      _ -> :error
    end
  end

  defp confirm_identity_multi(identity) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, Identity.confirm_changeset(identity))
    |> Ecto.Multi.delete_all(
      :tokens,
      IdentityToken.identity_and_contexts_query(identity, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Delivers the recovery password email to the given identity.

  ## Examples

      iex> prepare_identity_recovery_token(identity)
      {:ok, "p8STyFNR_u7SiWTy60frr_sO6mvUGc7d226HUzQIS84"}

  """
  def prepare_identity_recovery_token(%Identity{} = identity) do
    {encoded_token, identity_token} = IdentityToken.build_email_token(identity, "recovery")

    with {:ok, _} <- Repo.insert(identity_token) do
      {:ok, encoded_token}
    else
      _ -> :error
    end
  end

  @doc """
  Gets the identity by recovery password token.

  ## Examples

      iex> get_identity_by_recovery_token("validtoken")
      %Identity{}

      iex> get_identity_by_recovery_token("invalidtoken")
      nil

  """
  def get_identity_by_recovery_token(token) do
    with {:ok, query} <- IdentityToken.verify_email_token_query(token, "recovery") do
      Repo.one(query)
    else
      _ -> nil
    end
  end

  @doc """
  Resets the identity password.

  ## Examples

      iex> recover_identity_password(identity, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Identity{}}

      iex> recover_identity_password(identity, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def recover_identity_password(identity, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:identity, Identity.password_changeset(identity, attrs))
    |> Ecto.Multi.delete_all(:tokens, IdentityToken.identity_and_contexts_query(identity, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{identity: identity}} -> {:ok, identity}
      {:error, :identity, changeset, _} -> {:error, changeset}
    end
  end
end

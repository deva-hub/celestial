defmodule Celestial.Accounts.IdentityToken do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @key_size 2_147_483_647

  # It is very important to keep the key token expiry short since
  # someone, with access to the username and the same public ip may
  # take over the account.
  @key_validity_in_minute 5

  schema "identities_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :identity, Celestial.Accounts.Identity

    timestamps(updated_at: false)
  end

  @doc """
  Generate a token that will be stored in the database.
  While a one time key is issued for identification.
  """
  def build_key(address, identity) do
    key = :rand.uniform(@key_size)
    hashed_key = :crypto.hash(@hash_algorithm, key |> to_string())

    {key,
     %Celestial.Accounts.IdentityToken{
       token: hashed_key,
       context: "key",
       sent_to: address,
       identity_id: identity.id
     }}
  end

  @doc """
  Checks if the token is from the same id and returns its underlying
  lookup query.

  The query returns the identity found by the user id.
  """
  def verify_key_query(address, token) do
    hashed_token = :crypto.hash(@hash_algorithm, token |> to_string())

    query =
      from token in token_and_context_query(hashed_token, "key"),
        join: identity in assoc(token, :identity),
        where: token.inserted_at > ago(@key_validity_in_minute, "minute") and token.sent_to == ^address,
        select: identity

    {:ok, query}
  end

  @doc """
  Returns the given token with the given context.
  """
  def token_and_context_query(token, context) do
    from Celestial.Accounts.IdentityToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given identity for the given contexts.
  """
  def identity_and_contexts_query(identity, :all) do
    from t in Celestial.Accounts.IdentityToken, where: t.identity_id == ^identity.id
  end

  def identity_and_contexts_query(identity, [_ | _] = contexts) do
    from t in Celestial.Accounts.IdentityToken,
      where: t.identity_id == ^identity.id and t.context in ^contexts
  end
end

defmodule Celestial.Accounts.IdentityToken do
  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32
  @uid_size 2_147_483_647

  # It is very important to keep the recovery password token expiry short,
  # since someone with access to the email may take over the account.
  @recovery_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @access_validity_in_days 60
  @handoff_validity_in_secondes 60

  schema "identities_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :identity, Celestial.Accounts.Identity

    timestamps(updated_at: false)
  end

  @doc """
  Generate a token that will be stored in the database.
  While a handoff is issued for identification.
  """
  def build_handoff_key(ip, identity) do
    handoff_key = :rand.uniform(@uid_size)
    hashed_handoff_key = :crypto.hash(@hash_algorithm, handoff_key |> to_string())

    {handoff_key,
     %Celestial.Accounts.IdentityToken{
       token: hashed_handoff_key,
       context: "handoff",
       sent_to: ip,
       identity_id: identity.id
     }}
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_access_token(identity) do
    token = :crypto.strong_rand_bytes(@rand_size) |> Base.url_encode64(padding: false)

    {token,
     %Celestial.Accounts.IdentityToken{
       token: token,
       context: "access",
       identity_id: identity.id
     }}
  end

  @doc """
  Checks if the token is from the same id and returns its underlying
  lookup query.

  The query returns the identity found by the user id.
  """
  def verify_handoff_key_query(ip, token) do
    query =
      from token in token_and_context_query(token |> to_string(), "handoff"),
        join: identity in assoc(token, :identity),
        where: token.inserted_at > ago(@handoff_validity_in_secondes, "second") and token.sent_to == ^ip,
        select: identity

    {:ok, query}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity found by the token.
  """
  def verify_access_token_query(token) do
    query =
      from token in token_and_context_query(token, "access"),
        join: identity in assoc(token, :identity),
        where: token.inserted_at > ago(@access_validity_in_days, "day"),
        select: identity

    {:ok, query}
  end

  @doc """
  Builds a token with a hashed counter part.

  The non-hashed token is sent to the identity email while the
  hashed part is stored in the database, to avoid reconstruction.
  The token is valid for a week as long as identitys don't change
  their email.
  """
  def build_email_token(identity, context) do
    build_hashed_token(identity, context, identity.email)
  end

  defp build_hashed_token(identity, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %Celestial.Accounts.IdentityToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       identity_id: identity.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity found by the token.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: identity in assoc(token, :identity),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == identity.email,
            select: identity

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("recovery"), do: @recovery_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the identity token record.
  """
  def verify_change_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
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

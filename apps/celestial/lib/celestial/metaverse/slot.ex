defmodule Celestial.Metaverse.Slot do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "slots" do
    field :index, :integer
    belongs_to :character, Celestial.Metaverse.Character
    belongs_to :identity, Celestial.Accounts.Identity

    timestamps()
  end

  @doc false
  def changeset(slot, attrs) do
    slot
    |> cast(attrs, [:index])
    |> validate_required([:index])
    |> validate_number(:index, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> cast_assoc(:character, with: &Celestial.Metaverse.Character.create_changeset/2)
    |> assoc_constraint(:character)
    |> unique_constraint([:index, :identity_id])
    |> unique_constraint([:index, :character_id])
    |> unique_constraint([:character_id, :identity_id])
  end

  @doc """
  Gets all characters for the given identity.
  """
  def identity_query(identity) do
    from(s in Celestial.Metaverse.Slot,
      join: h in assoc(s, :character),
      preload: [character: {h, [:position, :equipment, :pets]}],
      where: s.identity_id == ^identity.id
    )
  end

  @doc """
  Gets the character for the given identity and index.
  """
  def identity_and_index_query(identity, index) do
    from(s in identity_query(identity),
      preload: [character: [:position, :equipment, :pets]],
      where: s.index == ^index and s.identity_id == ^identity.id
    )
  end
end

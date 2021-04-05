defmodule Celestial.Galaxy.Slot do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "slots" do
    field :index, :integer
    belongs_to :hero, Celestial.Galaxy.Hero
    belongs_to :identity, Celestial.Accounts.Identity

    timestamps()
  end

  @doc false
  def changeset(slot, attrs) do
    slot
    |> cast(attrs, [:index])
    |> validate_required([:index])
    |> validate_number(:index, greater_than_or_equal_to: 0, less_than_or_equal_to: 4)
    |> cast_assoc(:hero, with: &Celestial.Galaxy.Hero.create_changeset/2)
    |> assoc_constraint(:hero)
    |> unique_constraint([:index, :identity_id])
    |> unique_constraint([:index, :hero_id])
    |> unique_constraint([:hero_id, :identity_id])
  end

  @doc """
  Gets all heroes for the given identity.
  """
  def identity_query(identity) do
    from(s in Celestial.Galaxy.Slot,
      join: h in assoc(s, :hero),
      preload: [hero: {h, [:position, :equipment, :pets]}],
      where: s.identity_id == ^identity.id
    )
  end

  @doc """
  Gets the heroe for the given identity and index.
  """
  def identity_and_index_query(identity, index) do
    from(s in identity_query(identity),
      preload: [hero: [:position, :equipment, :pets]],
      where: s.index == ^index and s.identity_id == ^identity.id
    )
  end
end

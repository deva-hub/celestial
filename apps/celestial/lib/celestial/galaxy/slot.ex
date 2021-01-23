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
    |> cast(attrs, [:index, :hero_id, :identity_id])
    |> validate_required([:index])
    |> validate_number(:index, greater_than_or_equal_to: 0, less_than_or_equal_to: 4)
    |> unique_constraint([:index, :identity_id])
    |> unique_constraint([:index, :hero_id])
    |> unique_constraint([:hero_id, :identity_id])
    |> cast_assoc(:hero, with: &Celestial.Galaxy.Hero.create_changeset/2)
    |> assoc_constraint(:hero)
    |> cast_assoc(:identity, with: &Celestial.Accounts.Identity.changeset/2)
    |> assoc_constraint(:identity)
  end

  @doc """
  Gets all heroes for the given identity.
  """
  def identity_query(identity) do
    from s in Celestial.Galaxy.Slot,
      join: h in assoc(s, :hero),
      preload: [hero: h],
      where: s.identity_id == ^identity.id
  end

  @doc """
  Gets the heroe for the given identity and slot index.
  """
  def identity_and_index_query(identity, slot_index) do
    from s in identity_query(identity), where: s.index == ^slot_index
  end
end

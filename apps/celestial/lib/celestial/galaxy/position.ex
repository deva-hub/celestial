defmodule Celestial.Galaxy.Position do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :x, :integer
    field :y, :integer
    belongs_to :hero, Celestial.Galaxy.Hero
    belongs_to :world, Celestial.Galaxy.World

    timestamps()
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:x, :y])
    |> validate_required([:x, :y])
    |> unique_constraint([:hero_id, :world_id])
    |> cast_assoc(:hero, with: &Celestial.Galaxy.Hero.create_changeset/2)
    |> assoc_constraint(:hero)
    |> cast_assoc(:world, with: &Celestial.Galaxy.World.changeset/2)
    |> assoc_constraint(:world)
  end
end

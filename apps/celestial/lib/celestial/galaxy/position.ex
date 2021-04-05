defmodule Celestial.Galaxy.Position do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :coordinate_x, :integer
    field :coordinate_y, :integer
    belongs_to :character, Celestial.Galaxy.Character
    belongs_to :world, Celestial.Galaxy.World

    timestamps()
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:coordinate_x, :coordinate_y, :character_id, :world_id])
    |> validate_required([:coordinate_x, :coordinate_y])
    |> unique_constraint([:character_id, :world_id])
    |> cast_assoc(:character, with: &Celestial.Galaxy.Character.create_changeset/2)
    |> assoc_constraint(:character)
    |> cast_assoc(:world, with: &Celestial.Galaxy.World.changeset/2)
    |> assoc_constraint(:world)
  end
end

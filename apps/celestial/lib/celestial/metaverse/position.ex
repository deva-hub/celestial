defmodule Celestial.Metaverse.Position do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "positions" do
    field :direction, Ecto.Enum,
      values: [
        :north,
        :south,
        :east,
        :west
      ],
      default: :south

    field :coordinate_x, :integer
    field :coordinate_y, :integer
    belongs_to :character, Celestial.Metaverse.Character
    belongs_to :world, Celestial.Metaverse.World

    timestamps()
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:direction, :coordinate_x, :coordinate_y, :character_id, :world_id])
    |> validate_required([:direction, :coordinate_x, :coordinate_y])
    |> unique_constraint([:character_id, :world_id])
    |> cast_assoc(:character, with: &Celestial.Metaverse.Character.create_changeset/2)
    |> assoc_constraint(:character)
    |> cast_assoc(:world, with: &Celestial.Metaverse.World.changeset/2)
    |> assoc_constraint(:world)
  end
end

defmodule Celestial.Galaxy.CharacterItem do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters_items" do
    belongs_to :character_equipment, Celestial.Galaxy.CharacterEquipment

    timestamps()
  end

  @doc false
  def changeset(character_item, attrs) do
    character_item
    |> cast(attrs, [])
  end
end

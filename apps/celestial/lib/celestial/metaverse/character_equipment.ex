defmodule Celestial.Metaverse.CharacterEquipment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_equipments" do
    has_one :hat, Celestial.Metaverse.CharacterItem
    has_one :armor, Celestial.Metaverse.CharacterItem
    has_one :weapon_skin, Celestial.Metaverse.CharacterItem
    has_one :main_weapon, Celestial.Metaverse.CharacterItem
    has_one :secondary_weapon, Celestial.Metaverse.CharacterItem
    has_one :mask, Celestial.Metaverse.CharacterItem
    has_one :fairy, Celestial.Metaverse.CharacterItem
    has_one :costume_suit, Celestial.Metaverse.CharacterItem
    has_one :costume_hat, Celestial.Metaverse.CharacterItem
    belongs_to :character, Celestial.Metaverse.Character

    timestamps()
  end

  @doc false
  def changeset(character_equipement, attrs) do
    character_equipement
    |> cast(attrs, [])
  end
end

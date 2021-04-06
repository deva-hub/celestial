defmodule Celestial.Galaxy.CharacterEquipment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_equipments" do
    has_one :hat, Celestial.Galaxy.CharacterItem
    has_one :armor, Celestial.Galaxy.CharacterItem
    has_one :weapon_skin, Celestial.Galaxy.CharacterItem
    has_one :main_weapon, Celestial.Galaxy.CharacterItem
    has_one :secondary_weapon, Celestial.Galaxy.CharacterItem
    has_one :mask, Celestial.Galaxy.CharacterItem
    has_one :fairy, Celestial.Galaxy.CharacterItem
    has_one :costume_suit, Celestial.Galaxy.CharacterItem
    has_one :costume_hat, Celestial.Galaxy.CharacterItem
    belongs_to :character, Celestial.Galaxy.Character

    timestamps()
  end

  @doc false
  def changeset(character_equipement, attrs) do
    character_equipement
    |> cast(attrs, [])
  end
end

defmodule Celestial.Galaxy.HeroEquipment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "heroes_equipments" do
    has_one :hat, Celestial.Galaxy.HeroItem
    has_one :armor, Celestial.Galaxy.HeroItem
    has_one :weapon_skin, Celestial.Galaxy.HeroItem
    has_one :main_weapon, Celestial.Galaxy.HeroItem
    has_one :secondary_weapon, Celestial.Galaxy.HeroItem
    has_one :mask, Celestial.Galaxy.HeroItem
    has_one :fairy, Celestial.Galaxy.HeroItem
    has_one :costume_suit, Celestial.Galaxy.HeroItem
    has_one :costume_hat, Celestial.Galaxy.HeroItem
    belongs_to :hero, Celestial.Galaxy.Hero

    timestamps()
  end

  @doc false
  def changeset(hero_equipement, attrs) do
    hero_equipement
    |> cast(attrs, [])
  end
end

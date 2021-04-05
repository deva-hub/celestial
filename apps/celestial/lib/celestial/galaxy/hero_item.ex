defmodule Celestial.Galaxy.HeroItem do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "hereos_items" do
    belongs_to :hero_equipment, Celestial.Galaxy.HeroEquipment

    timestamps()
  end

  @doc false
  def changeset(hero_item, attrs) do
    hero_item
    |> cast(attrs, [])
  end
end

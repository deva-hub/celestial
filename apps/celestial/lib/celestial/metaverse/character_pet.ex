defmodule Celestial.Metaverse.CharacterPet do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_pets" do
    has_one :skin, Celestial.Metaverse.CharacterPetSkin
    belongs_to :character, Celestial.Metaverse.Character

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [])
  end
end

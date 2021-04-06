defmodule Celestial.Galaxy.CharacterPetSkin do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_pet_skins" do
    belongs_to :character_pet, Celestial.Galaxy.CharacterPet

    timestamps()
  end

  @doc false
  def changeset(pet_skin, attrs) do
    pet_skin
    |> cast(attrs, [])
  end
end

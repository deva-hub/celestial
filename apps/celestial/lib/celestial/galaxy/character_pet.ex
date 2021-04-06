defmodule Celestial.Galaxy.CharacterPet do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_pets" do
    has_one :skin, Celestial.Galaxy.CharacterPetSkin
    belongs_to :character, Celestial.Galaxy.Character

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [])
  end
end

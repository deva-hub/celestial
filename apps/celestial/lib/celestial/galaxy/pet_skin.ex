defmodule Celestial.Galaxy.PetSkin do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets_skins" do
    belongs_to :pet, Celestial.Galaxy.Pet

    timestamps()
  end

  @doc false
  def changeset(pet_skin, attrs) do
    pet_skin
    |> cast(attrs, [])
  end
end

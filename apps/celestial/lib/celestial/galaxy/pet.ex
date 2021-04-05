defmodule Celestial.Galaxy.Pet do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    has_one :skin, Celestial.Galaxy.PetSkin
    belongs_to :character, Celestial.Galaxy.Character

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [])
  end
end

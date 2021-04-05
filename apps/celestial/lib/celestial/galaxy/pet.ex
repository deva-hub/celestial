defmodule Celestial.Galaxy.Pet do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    has_one :skin, Celestial.Galaxy.PetSkin
    belongs_to :hero, Celestial.Galaxy.Hero

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [])
  end
end

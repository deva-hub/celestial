defmodule Celestial.Metaverse.CharacterToken do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_wallets" do
    field :golds, :integer
    field :master_tickets, :integer
    belongs_to :character, Celestial.Metaverse.Character

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [])
  end
end

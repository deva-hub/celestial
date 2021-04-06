defmodule Celestial.Galaxy.CharacterMiniland do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "character_minilands" do
    field :state, Ecto.Enum,
      values: [
        :public,
        :private,
        :lock
      ],
      default: :public

    field :intro_message, :string
    field :make_points, :integer
    belongs_to :character, Celestial.Galaxy.Character

    timestamps()
  end

  @doc false
  def create_changeset(character, attrs) do
    character
    |> cast(attrs, [:state, :intro_message, :make_points])
  end
end

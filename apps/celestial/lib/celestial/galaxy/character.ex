defmodule Celestial.Galaxy.Character do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "characters" do
    field :class, Ecto.Enum,
      values: [
        :adventurer,
        :sorcerer,
        :archer,
        :swordsman,
        :martial_artist
      ],
      default: :adventurer

    field :sex, Ecto.Enum,
      values: [
        :male,
        :female
      ]

    field :hair_color, Ecto.Enum,
      values: [
        :mauve_taupe,
        :cerise,
        :san_marino,
        :affair,
        :dixie,
        :raven,
        :killarney,
        :nutmeg,
        :saddle,
        :red
      ]

    field :hair_style, Ecto.Enum,
      values: [
        :a,
        :b,
        :c,
        :d,
        :shave
      ]

    field :faction, Ecto.Enum,
      values: [
        :neutre,
        :angel,
        :demon
      ]

    field :reputation, :integer, default: :beginner
    field :dignity, :integer, default: :basic
    field :compliment, :integer, default: 0

    field :health_points, :integer, default: 100
    field :mana_points, :integer, default: 20

    field :name, :string

    field :hero_xp, :integer, default: 0
    field :hero_xp_max, :integer, default: 1_000
    field :hero_level, :integer, default: 1

    field :job_xp, :integer, default: 0
    field :job_xp_max, :integer, default: 1_000
    field :job_level, :integer, default: 1

    field :xp, :integer, default: 0
    field :xp_max, :integer, default: 1_000
    field :level, :integer, default: 1

    has_one :slot, Celestial.Galaxy.Slot
    has_one :position, Celestial.Galaxy.Position
    has_one :equipment, Celestial.Galaxy.CharacterEquipment
    has_many :pets, Celestial.Galaxy.Pet

    timestamps()
  end

  @doc false
  def create_changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :class, :sex, :hair_color, :hair_style])
    |> validate_required([:name, :class, :sex, :hair_color, :hair_style])
    |> validate_length(:name, min: 4, max: 14)
    |> put_position()
    |> put_equipment()
    |> cast_assoc(:slot, with: &Celestial.Galaxy.Slot.changeset/2)
    |> cast_assoc(:position, with: &Celestial.Galaxy.Position.changeset/2)
  end

  @doc false
  defp put_position(%Ecto.Changeset{valid?: true} = changeset) do
    change(changeset,
      position: %{
        coordinate_x: :rand.uniform(3) + 77,
        coordinate_y: :rand.uniform(4) + 11
      }
    )
  end

  @doc false
  defp put_equipment(%Ecto.Changeset{valid?: true} = changeset) do
    change(changeset, equipment: %{})
  end

  @doc false
  def update_changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :faction, :class, :sex, :hair_color, :hair_style, :level, :job_level, :hero_level, :xp, :job_xp, :hero_xp])
  end
end

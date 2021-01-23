defmodule Celestial.Galaxy.Hero do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "heroes" do
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

    field :hero_level, :integer, default: 1
    field :hero_xp, :integer, default: 0
    field :job_level, :integer, default: 1
    field :job_xp, :integer, default: 0
    field :level, :integer, default: 1
    field :name, :string
    field :xp, :integer, default: 0
    has_one :slot, Celestial.Galaxy.Slot
    has_one :position, Celestial.Galaxy.Position

    timestamps()
  end

  @doc false
  def create_changeset(hero, attrs) do
    hero
    |> cast(attrs, [:name, :class, :sex, :hair_color, :hair_style])
    |> validate_required([:name, :class, :sex, :hair_color, :hair_style])
    |> validate_length(:name, min: 4, max: 14)
    |> cast_assoc(:slot, with: &Celestial.Galaxy.Slot.changeset/2)
    |> cast_assoc(:position, with: &Celestial.Galaxy.Position.changeset/2)
  end

  @doc false
  def update_changeset(hero, attrs) do
    hero
    |> cast(attrs, [:name, :index, :class, :sex, :hair_color, :hair_style, :level, :job_level, :hero_level, :xp, :job_xp, :hero_xp])
  end
end

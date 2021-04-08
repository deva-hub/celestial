defmodule Celestial.Metaverse.Character do
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
        :neutral,
        :angel,
        :demon
      ],
      default: :neutral

    field :reputation, Ecto.Enum,
      values: [
        :stupid_minded,
        :useless,
        :not_qualified_for,
        :bluffed_name_only,
        :suspected,
        :neutral,
        :beginner,
        :trainee_g,
        :trainee_b,
        :trainee_r,
        :the_experienced_g,
        :the_experienced_b,
        :the_experienced_r,
        :battle_soldier_g,
        :battle_soldier_b,
        :battle_soldier_r,
        :expert_g,
        :expert_b,
        :expert_r,
        :leader_g,
        :leader_b,
        :leader_r,
        :master_g,
        :master_b,
        :master_r,
        :nos_g,
        :nos_b,
        :nos_r,
        :elite_g,
        :elite_b,
        :elite_r,
        :legend_g,
        :legend_b,
        :ancien_hero,
        :mysterious_hero,
        :legendary_hero
      ],
      default: :beginner

    field :dignity, Ecto.Enum,
      values: [
        :neutral,
        :suspected,
        :bluffed_name_only,
        :not_qualified_for,
        :useless,
        :stupid_minded
      ],
      default: :neutral

    field :compliment, :integer, default: 0

    field :health_points, :integer
    field :mana_points, :integer

    field :name, :string
    field :biography, :string, default: "Hi!"

    field :mate_max, :integer

    field :xp, :integer, default: 0
    field :xp_max, :integer, virtual: true
    field :level, :integer, default: 1

    field :hero_xp, :integer, default: 0
    field :hero_xp_max, :integer, virtual: true
    field :hero_level, :integer, default: 0

    field :job_xp, :integer, default: 0
    field :job_xp_max, :integer, virtual: true
    field :job_level, :integer, default: 1

    field :sp_points, :integer, default: 10_000
    field :sp_additional_points, :integer, default: 500_000
    field :rage_points, :integer, default: 0

    has_one :battle_achivement, Celestial.Metaverse.BattleAchivement

    has_one :token, Celestial.Metaverse.CharacterToken
    has_one :miniland, Celestial.Metaverse.CharacterMiniland
    has_one :slot, Celestial.Metaverse.Slot
    has_one :position, Celestial.Metaverse.Position
    has_one :equipment, Celestial.Metaverse.CharacterEquipment
    has_many :pets, Celestial.Metaverse.CharacterPet

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
    |> put_health()
    |> cast_assoc(:slot, with: &Celestial.Metaverse.Slot.changeset/2)
    |> cast_assoc(:position, with: &Celestial.Metaverse.Position.changeset/2)
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
  defp put_health(%Ecto.Changeset{valid?: true} = changeset) do
    change(changeset,
      health_points: 300,
      mana_points: 200
    )
  end

  @doc false
  def update_changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :faction, :class, :sex, :hair_color, :hair_style, :level, :job_level, :hero_level, :xp, :job_xp, :hero_xp])
  end
end

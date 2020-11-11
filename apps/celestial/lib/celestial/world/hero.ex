defmodule Celestial.World.Hero do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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

    field :gender, Ecto.Enum,
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
    field :slot, :integer
    field :xp, :integer, default: 0

    belongs_to :identity, Celestial.Accounts.Identity

    timestamps()
  end

  @doc false
  def create_changeset(hero, attrs) do
    hero
    |> cast(attrs, [:name, :slot, :class, :hair_color, :hair_style])
    |> validate_required([:name, :slot, :class, :hair_color, :hair_style])
  end

  @doc false
  def update_changeset(hero, attrs) do
    hero
    |> cast(attrs, [:name, :slot, :class, :hair_color, :hair_style, :level, :job_level, :hero_level, :xp, :job_xp, :hero_xp])
  end

  @doc """
  Gets all heroes for the given identity.
  """
  def identity_query(identity) do
    from h in Celestial.World.Hero, where: h.identity_id == ^identity.id
  end
end

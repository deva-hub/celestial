defmodule Celestial.Repo.Migrations.CreateHeroes do
  use Ecto.Migration

  def change do
    create table(:heroes) do
      add :name, :string
      add :index, :integer
      add :health_points, :integer
      add :mana_points, :integer
      add :class, :string
      add :sex, :string
      add :hair_color, :string
      add :hair_style, :string
      add :level, :integer
      add :job_level, :integer
      add :hero_level, :integer
      add :xp, :integer
      add :xp_max, :integer
      add :job_xp, :integer
      add :job_xp_max, :integer
      add :hero_xp, :integer
      add :hero_xp_max, :integer
      timestamps()
    end

    create table(:heroes_items) do
      timestamps()
    end

    create table(:heroes_equipments) do
      add :hat_id, references(:heroes_items)
      add :armor_id, references(:heroes_items)
      add :weapon_skin_id, references(:heroes_items)
      add :main_weapon_id, references(:heroes_items)
      add :secondary_weapon_id, references(:heroes_items)
      add :mask_id, references(:heroes_items)
      add :fairy_id, references(:heroes_items)
      add :costume_suit_id, references(:heroes_items)
      add :costume_hat_id, references(:heroes_items)
      add :hero_id, references(:heroes)
      timestamps()
    end

    create index(:heroes_equipments, [
      :hat_id,
      :armor_id,
      :weapon_skin_id,
      :main_weapon_id,
      :secondary_weapon_id,
      :mask_id,
      :fairy_id,
      :costume_suit_id,
      :costume_hat_id,
      :hero_id
    ])

    create table(:pets) do
      add :hero_id, references(:heroes)
      timestamps()
    end

    create index(:pets, [:hero_id])

    create table(:pets_skins) do
      add :pet_id, references(:pets)
      timestamps()
    end

    create index(:pets_skins, [:pet_id])

    create table(:slots) do
      add :index, :integer
      add :hero_id, references(:heroes)
      add :identity_id, references(:identities)
      timestamps()
    end

    create index(:slots, [:hero_id, :identity_id])
    create unique_index(:slots, [:index, :identity_id])
    create unique_index(:slots, [:index, :hero_id])
  end
end

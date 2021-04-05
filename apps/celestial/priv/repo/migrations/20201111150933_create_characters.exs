defmodule Celestial.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
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

    create table(:characters_items) do
      timestamps()
    end

    create table(:characters_equipments) do
      add :hat_id, references(:characters_items)
      add :armor_id, references(:characters_items)
      add :weapon_skin_id, references(:characters_items)
      add :main_weapon_id, references(:characters_items)
      add :secondary_weapon_id, references(:characters_items)
      add :mask_id, references(:characters_items)
      add :fairy_id, references(:characters_items)
      add :costume_suit_id, references(:characters_items)
      add :costume_hat_id, references(:characters_items)
      add :character_id, references(:characters)
      timestamps()
    end

    create index(:characters_equipments, [
      :hat_id,
      :armor_id,
      :weapon_skin_id,
      :main_weapon_id,
      :secondary_weapon_id,
      :mask_id,
      :fairy_id,
      :costume_suit_id,
      :costume_hat_id,
      :character_id
    ])

    create table(:pets) do
      add :character_id, references(:characters)
      timestamps()
    end

    create index(:pets, [:character_id])

    create table(:pets_skins) do
      add :pet_id, references(:pets)
      timestamps()
    end

    create index(:pets_skins, [:pet_id])

    create table(:slots) do
      add :index, :integer
      add :character_id, references(:characters)
      add :identity_id, references(:identities)
      timestamps()
    end

    create index(:slots, [:character_id, :identity_id])
    create unique_index(:slots, [:index, :identity_id])
    create unique_index(:slots, [:index, :character_id])
  end
end

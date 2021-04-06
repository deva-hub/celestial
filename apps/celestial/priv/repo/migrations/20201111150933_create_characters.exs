defmodule Celestial.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string
      add :biography, :string
      add :health_points, :integer
      add :mana_points, :integer
      add :class, :string
      add :sex, :string
      add :hair_color, :string
      add :hair_style, :string
      add :faction, :string
      add :reputation, :string
      add :dignity, :string
      add :compliment, :integer
      add :level, :integer
      add :job_level, :integer
      add :hero_level, :integer
      add :mate_max, :integer
      add :xp, :integer
      add :job_xp, :integer
      add :hero_xp, :integer
      add :sp_points, :integer
      add :sp_additional_points, :integer
      add :rage_points, :integer
      timestamps()
    end

    create table(:character_items) do
      timestamps()
    end

    create table(:character_equipments) do
      add :hat_id, references(:character_items)
      add :armor_id, references(:character_items)
      add :weapon_skin_id, references(:character_items)
      add :main_weapon_id, references(:character_items)
      add :secondary_weapon_id, references(:character_items)
      add :mask_id, references(:character_items)
      add :fairy_id, references(:character_items)
      add :costume_suit_id, references(:character_items)
      add :costume_hat_id, references(:character_items)
      add :character_id, references(:characters)
      timestamps()
    end

    create index(:character_equipments, [
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

    create table(:character_minilands) do
      add :intro_message, :string
      add :state, :string
      add :make_points, :integer
      add :character_id, references(:characters)
      timestamps()
    end

    create table(:character_pets) do
      add :character_id, references(:characters)
      timestamps()
    end

    create index(:character_pets, [:character_id])

    create table(:character_pet_skins) do
      add :character_pet_id, references(:character_pets)
      timestamps()
    end

    create index(:character_pet_skins, [:character_pet_id])

    create table(:slots) do
      add :index, :integer
      add :character_id, references(:characters)
      add :identity_id, references(:identities)
      timestamps()
    end

    create index(:slots, [:character_id, :identity_id])
    create unique_index(:slots, [:index, :identity_id])
    create unique_index(:slots, [:index, :character_id])

    create table(:character_wallets) do
      add :golds, :integer
      add :master_tickets, :integer
      add :character_id, references(:characters)
      timestamps()
    end
  end
end

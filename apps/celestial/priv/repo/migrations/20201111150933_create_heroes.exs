defmodule Celestial.Repo.Migrations.CreateHeroes do
  use Ecto.Migration

  def change do
    create table(:heroes) do
      add :name, :string
      add :index, :integer
      add :class, :string
      add :sex, :string
      add :hair_color, :string
      add :hair_style, :string
      add :level, :integer
      add :job_level, :integer
      add :hero_level, :integer
      add :xp, :integer
      add :job_xp, :integer
      add :hero_xp, :integer
      timestamps()
    end

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

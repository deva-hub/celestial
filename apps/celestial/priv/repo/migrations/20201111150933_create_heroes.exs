defmodule Celestial.Repo.Migrations.CreateHeroes do
  use Ecto.Migration

  def change do
    create table(:heroes) do
      add :name, :string
      add :slot, :integer
      add :class, :string
      add :gender, :string
      add :hair_color, :string
      add :hair_style, :string
      add :level, :integer
      add :job_level, :integer
      add :hero_level, :integer
      add :xp, :integer
      add :job_xp, :integer
      add :hero_xp, :integer
      add :identity_id, references(:identities, on_delete: :nothing)

      timestamps()
    end

    create index(:heroes, [:identity_id])
  end
end

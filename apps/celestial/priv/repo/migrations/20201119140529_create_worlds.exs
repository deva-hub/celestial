defmodule Celestial.Repo.Migrations.CreateWorlds do
  use Ecto.Migration

  def change do
    create table(:worlds) do
      add :name, :string
      timestamps()
    end

    create table(:positions) do
      add :coordinate_x, :integer
      add :coordinate_y, :integer
      add :hero_id, references(:heroes)
      add :world_id, references(:worlds)
      timestamps()
    end

    create index(:positions, [:hero_id, :world_id], unique: true)
  end
end

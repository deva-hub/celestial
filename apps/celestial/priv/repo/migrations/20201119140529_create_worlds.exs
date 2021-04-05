defmodule Celestial.Repo.Migrations.CreateWorlds do
  use Ecto.Migration

  def change do
    create table(:worlds) do
      add :name, :string
      timestamps()
    end

    create table(:positions) do
      add :direction, :string
      add :coordinate_x, :integer
      add :coordinate_y, :integer
      add :character_id, references(:characters)
      add :world_id, references(:worlds)
      timestamps()
    end

    create index(:positions, [:character_id, :world_id])
  end
end

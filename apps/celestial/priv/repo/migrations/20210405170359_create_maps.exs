defmodule Celestial.Repo.Migrations.CreateMaps do
  use Ecto.Migration

  def change do
    create table(:maps) do
      timestamps()
    end

    create table(:ambiances) do
      timestamps()
    end
  end
end

defmodule Celestial.Repo.Migrations.CreateMap do
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

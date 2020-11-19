defmodule Celestial.Repo.Migrations.CreateWorlds do
  use Ecto.Migration

  def change do
    create table(:worlds) do
      add :name, :string

      timestamps()
    end

  end
end

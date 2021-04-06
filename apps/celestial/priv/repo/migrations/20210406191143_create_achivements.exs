defmodule Celestial.Repo.Migrations.CreateAchivements do
  use Ecto.Migration

  def change do
    create table(:battle_achivements) do
      add :act4_dead_count, :integer
      add :act4_kill_count, :integer
      add :act4_points, :integer
      add :arena_winner, :boolean
      add :talent_win_count, :integer
      add :talent_lose_count, :integer
      add :talent_surrender_count, :integer
      add :master_points, :integer
      add :character_id, references(:characters)
      timestamps()
    end
  end
end

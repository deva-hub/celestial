defmodule Celestial.Metaverse.BattleAchivement do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "battle_achivements" do
    field :act4_dead_count, :integer
    field :act4_kill_count, :integer
    field :act4_points, :integer
    field :arena_winner, :boolean
    field :talent_win_count, :integer
    field :talent_lose_count, :integer
    field :talent_surrender_count, :integer
    field :master_points, :integer
    belongs_to :character, Celestial.Metaverse.Character

    timestamps()
  end

  @doc false
  def changeset(character_pvp_stats, attrs) do
    character_pvp_stats
    |> cast(attrs, [])
  end
end

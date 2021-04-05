defmodule Noslib.HUD do
  @moduledoc false
  import Noslib.Packet

  @name_colors BiMap.new(%{
                 white: encode_int(0),
                 # ???: encode_int(1),
                 purple: encode_int(2),
                 # ???: encode_int(3),
                 # ???: encode_int(4),
                 # ???: encode_int(5),
                 invisible: encode_int(6)
               })

  def decode_name_color(name_color) do
    BiMap.fetch_key!(@name_colors, name_color)
  end

  def encode_name_color(name_color) do
    BiMap.fetch!(@name_colors, name_color)
  end

  @dignity_icons %{
    basic: -100,
    suspected: -201,
    bluffed_name_only: -401,
    not_qualified_for: -601,
    useless: -801
  }

  def dignity_icon(dignity) do
    Enum.find_value(@dignity_icons, :stupid_minded, fn
      {icon, limit} -> if dignity < limit, do: icon
    end)
  end

  def encode_dignity_icon(dignity_icon) do
    BiMap.fetch!(@dignity_icons, dignity_icon)
  end

  @reputations %{
    stupid_minded: -800,
    useless: -600,
    not_qualified_for: -400,
    bluffed_name_only: -200,
    suspected: -99,
    basic: 0,
    beginner: 250,
    trainee_g: 500,
    trainee_b: 750,
    trainee_r: 1_000,
    the_experienced_g: 2_250,
    the_experienced_b: 3_500,
    the_experienced_r: 5_000,
    battle_soldier_g: 9_500,
    battle_soldier_b: 19_000,
    battle_soldier_r: 25_000,
    expert_g: 40_000,
    expert_b: 60_000,
    expert_r: 85_000,
    leader_g: 115_000,
    leader_b: 150_000,
    leader_r: 190_000,
    master_g: 235_000,
    master_b: 185_000,
    master_r: 350_000,
    nos_g: 500_000,
    nos_b: 1_500_000,
    nos_r: 2_500_000,
    elite_g: 3_750_000,
    elite_b: 5_000_000
  }

  def reputation(reputation) do
    Enum.find_value(@reputations, :elite_r, fn
      {icon, limit} -> if reputation < limit, do: icon
    end)
  end
end

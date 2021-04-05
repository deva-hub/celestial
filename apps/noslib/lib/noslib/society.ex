defmodule Noslib.Society do
  @moduledoc false

  import Noslib.Packet

  # TODO: Refactor reputation based on number
  @reputations BiMap.new(%{
                 stupid_minded: encode_int(-6),
                 useless: encode_int(-5),
                 not_qualified_for: encode_int(-4),
                 bluffed_name_only: encode_int(-3),
                 suspected: encode_int(-2),
                 basic: encode_int(-1),
                 beginner: encode_int(1),
                 # ???: encode_int(2),
                 # ???: encode_int(3),
                 trainee_g: encode_int(4),
                 trainee_b: encode_int(5),
                 trainee_r: encode_int(6),
                 the_experienced_g: encode_int(7),
                 the_experienced_b: encode_int(8),
                 the_experienced_r: encode_int(9),
                 battle_soldier_g: encode_int(10),
                 battle_soldier_b: encode_int(11),
                 battle_soldier_r: encode_int(12),
                 expert_g: encode_int(13),
                 expert_b: encode_int(14),
                 expert_r: encode_int(15),
                 leader_g: encode_int(16),
                 leader_b: encode_int(17),
                 leader_r: encode_int(18),
                 master_g: encode_int(19),
                 master_b: encode_int(20),
                 master_r: encode_int(21),
                 nos_g: encode_int(22),
                 nos_b: encode_int(23),
                 nos_r: encode_int(24),
                 elite_g: encode_int(25),
                 elite_b: encode_int(26),
                 elite_r: encode_int(27),
                 legend_g: encode_int(28),
                 legend_b: encode_int(29),
                 ancien_hero: encode_int(30),
                 mysterious_hero: encode_int(31),
                 legendary_hero: encode_int(32)
               })

  def decode_reputation(reputation) do
    BiMap.fetch_key!(@reputations, reputation)
  end

  def encode_reputation(reputation) do
    BiMap.fetch!(@reputations, reputation)
  end

  @dignities BiMap.new(%{
               basic: encode_int(1),
               suspected: encode_int(2),
               bluffed_name_only: encode_int(3),
               not_qualified_for: encode_int(4),
               useless: encode_int(5),
               stupid_minded: encode_int(6)
             })

  def decode_dignity(dignity) do
    BiMap.fetch_key!(@dignities, dignity)
  end

  def encode_dignity(dignity) do
    BiMap.fetch!(@dignities, dignity)
  end

  @factions BiMap.new(%{
              neutre: encode_int(0),
              angel: encode_int(1),
              demon: encode_int(2)
            })

  def decode_faction(faction) do
    BiMap.fetch_key!(@factions, faction)
  end

  def encode_faction(faction) do
    BiMap.fetch!(@factions, faction)
  end

  @minilands BiMap.new(%{
               open: encode_int(0),
               private: encode_int(1),
               lock: encode_int(2)
             })

  def decode_miniland(miniland) do
    BiMap.fetch_key!(@minilands, miniland)
  end

  def encode_miniland(miniland) do
    BiMap.fetch!(@minilands, miniland)
  end
end

defmodule Noslib.Society do
  @moduledoc false
  alias Noslib.Helpers

  @reputations BiMap.new(%{
                 stupid_minded: Helpers.encode_int(-6),
                 useless: Helpers.encode_int(-5),
                 not_qualified_for: Helpers.encode_int(-4),
                 bluffed_name_only: Helpers.encode_int(-3),
                 suspected: Helpers.encode_int(-2),
                 basic: Helpers.encode_int(-1),
                 beginner: Helpers.encode_int(1),
                 # ???: Helpers.encode_int(2),
                 # ???: Helpers.encode_int(3),
                 trainee_g: Helpers.encode_int(4),
                 trainee_b: Helpers.encode_int(5),
                 trainee_r: Helpers.encode_int(6),
                 the_experienced_g: Helpers.encode_int(7),
                 the_experienced_b: Helpers.encode_int(8),
                 the_experienced_r: Helpers.encode_int(9),
                 battle_soldier_g: Helpers.encode_int(10),
                 battle_soldier_b: Helpers.encode_int(11),
                 battle_soldier_r: Helpers.encode_int(12),
                 expert_g: Helpers.encode_int(13),
                 expert_b: Helpers.encode_int(14),
                 expert_r: Helpers.encode_int(15),
                 leader_g: Helpers.encode_int(16),
                 leader_b: Helpers.encode_int(17),
                 leader_r: Helpers.encode_int(18),
                 master_g: Helpers.encode_int(19),
                 master_b: Helpers.encode_int(20),
                 master_r: Helpers.encode_int(21),
                 nos_g: Helpers.encode_int(22),
                 nos_b: Helpers.encode_int(23),
                 nos_r: Helpers.encode_int(24),
                 elite_g: Helpers.encode_int(25),
                 elite_b: Helpers.encode_int(26),
                 elite_r: Helpers.encode_int(27),
                 legend_g: Helpers.encode_int(28),
                 legend_b: Helpers.encode_int(29),
                 ancien_heros: Helpers.encode_int(30),
                 mysterious_heros: Helpers.encode_int(31),
                 legendary_heros: Helpers.encode_int(32)
               })

  @spec decode_reputation(binary) :: atom
  def decode_reputation(reputation), do: BiMap.fetch_key!(@reputations, reputation)

  @spec encode_reputation(atom) :: iodata
  def encode_reputation(reputation), do: BiMap.fetch!(@reputations, reputation)

  @dignities BiMap.new(%{
               basic: Helpers.encode_int(1),
               suspected: Helpers.encode_int(2),
               bluffed_name_only: Helpers.encode_int(3),
               not_qualified_for: Helpers.encode_int(4),
               useless: Helpers.encode_int(5),
               stupid_minded: Helpers.encode_int(6)
             })

  @spec decode_dignity(binary) :: atom
  def decode_dignity(dignity), do: BiMap.fetch_key!(@dignities, dignity)

  @spec encode_dignity(atom) :: iodata
  def encode_dignity(dignity), do: BiMap.fetch!(@dignities, dignity)

  @factions BiMap.new(%{
              neutral: Helpers.encode_int(0),
              angel: Helpers.encode_int(1),
              demon: Helpers.encode_int(2)
            })

  @spec decode_faction(binary) :: atom
  def decode_faction(faction), do: BiMap.fetch_key!(@factions, faction)

  @spec encode_faction(atom) :: iodata
  def encode_faction(faction), do: BiMap.fetch!(@factions, faction)

  @minilands BiMap.new(%{
               open: Helpers.encode_int(0),
               private: Helpers.encode_int(1),
               lock: Helpers.encode_int(2)
             })

  @spec decode_miniland(binary) :: atom
  def decode_miniland(miniland), do: BiMap.fetch_key!(@minilands, miniland)

  @spec encode_miniland(atom) :: iodata
  def encode_miniland(miniland), do: BiMap.fetch!(@minilands, miniland)
end

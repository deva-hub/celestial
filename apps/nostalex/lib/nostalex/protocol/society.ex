defmodule Nostalex.Protocol.Society do
  alias Nostalex.Protocol.Helpers

  @reputations BiMap.new(%{
                 stupid_minded: Helpers.pack_int(-6),
                 useless: Helpers.pack_int(-5),
                 not_qualified_for: Helpers.pack_int(-4),
                 bluffed_name_only: Helpers.pack_int(-3),
                 suspected: Helpers.pack_int(-2),
                 basic: Helpers.pack_int(-1),
                 beginner: Helpers.pack_int(1),
                 # ???: Helpers.pack_int(2),
                 # ???: Helpers.pack_int(3),
                 trainee_g: Helpers.pack_int(4),
                 trainee_b: Helpers.pack_int(5),
                 trainee_r: Helpers.pack_int(6),
                 the_experienced_g: Helpers.pack_int(7),
                 the_experienced_b: Helpers.pack_int(8),
                 the_experienced_r: Helpers.pack_int(9),
                 battle_soldier_g: Helpers.pack_int(10),
                 battle_soldier_b: Helpers.pack_int(11),
                 battle_soldier_r: Helpers.pack_int(12),
                 expert_g: Helpers.pack_int(13),
                 expert_b: Helpers.pack_int(14),
                 expert_r: Helpers.pack_int(15),
                 leader_g: Helpers.pack_int(16),
                 leader_b: Helpers.pack_int(17),
                 leader_r: Helpers.pack_int(18),
                 master_g: Helpers.pack_int(19),
                 master_b: Helpers.pack_int(20),
                 master_r: Helpers.pack_int(21),
                 nos_g: Helpers.pack_int(22),
                 nos_b: Helpers.pack_int(23),
                 nos_r: Helpers.pack_int(24),
                 elite_g: Helpers.pack_int(25),
                 elite_b: Helpers.pack_int(26),
                 elite_r: Helpers.pack_int(27),
                 legend_g: Helpers.pack_int(28),
                 legend_b: Helpers.pack_int(29),
                 ancien_heros: Helpers.pack_int(30),
                 mysterious_heros: Helpers.pack_int(31),
                 legendary_heros: Helpers.pack_int(32)
               })

  @spec parse_reputation(binary) :: atom
  def parse_reputation(reputation), do: BiMap.get_key(@reputations, reputation)

  @spec pack_reputation(atom) :: iodata
  def pack_reputation(reputation), do: BiMap.get(@reputations, reputation)

  @dignities BiMap.new(%{
               basic: Helpers.pack_int(1),
               suspected: Helpers.pack_int(2),
               bluffed_name_only: Helpers.pack_int(3),
               not_qualified_for: Helpers.pack_int(4),
               useless: Helpers.pack_int(5),
               stupid_minded: Helpers.pack_int(6)
             })

  @spec parse_dignity(binary) :: atom
  def parse_dignity(dignity), do: BiMap.get_key(@dignities, dignity)

  @spec pack_dignity(atom) :: iodata
  def pack_dignity(dignity), do: BiMap.get(@dignities, dignity)

  @factions BiMap.new(%{
              neutral: Helpers.pack_int(0),
              angel: Helpers.pack_int(1),
              demon: Helpers.pack_int(2)
            })

  @spec parse_faction(binary) :: atom
  def parse_faction(faction), do: BiMap.get_key(@factions, faction)

  @spec pack_faction(atom) :: iodata
  def pack_faction(faction), do: BiMap.get(@factions, faction)

  @minilands BiMap.new(%{
               open: Helpers.pack_int(0),
               private: Helpers.pack_int(1),
               lock: Helpers.pack_int(2)
             })

  @spec parse_miniland(binary) :: atom
  def parse_miniland(miniland), do: BiMap.get_key(@minilands, miniland)

  @spec pack_miniland(atom) :: iodata
  def pack_miniland(miniland), do: BiMap.get(@minilands, miniland)
end

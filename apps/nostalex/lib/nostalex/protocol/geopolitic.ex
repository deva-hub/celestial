defmodule Nostalex.Protocol.Geopolitic do
  alias Nostalex.Protocol.Helpers

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

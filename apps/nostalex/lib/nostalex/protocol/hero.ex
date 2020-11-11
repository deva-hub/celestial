defmodule Nostalex.Protocol.Hero do
  @moduledoc false

  alias Nostalex.Protocol.Helpers

  @genders BiMap.new(%{
             male: Helpers.pack_int(0),
             female: Helpers.pack_int(1)
           })

  @spec parse_gender(binary) :: atom
  def parse_gender(gender), do: BiMap.get_key(@genders, gender)

  @spec pack_gender(atom) :: iodata
  def pack_gender(gender), do: BiMap.get(@genders, gender)

  @hair_styles BiMap.new(%{
                 a: Helpers.pack_int(0),
                 b: Helpers.pack_int(1),
                 c: Helpers.pack_int(2),
                 d: Helpers.pack_int(3),
                 shave: Helpers.pack_int(4)
               })

  @spec parse_hair_style(binary) :: atom
  def parse_hair_style(hair_style), do: BiMap.get_key(@hair_styles, hair_style)

  @spec pack_hair_style(atom) :: iodata
  def pack_hair_style(hair_style), do: BiMap.get(@hair_styles, hair_style)

  @hair_colors BiMap.new(%{
                 mauve_taupe: Helpers.pack_int(0),
                 cerise: Helpers.pack_int(1),
                 san_marino: Helpers.pack_int(2),
                 affair: Helpers.pack_int(3),
                 dixie: Helpers.pack_int(4),
                 raven: Helpers.pack_int(5),
                 killarney: Helpers.pack_int(6),
                 nutmeg: Helpers.pack_int(7),
                 saddle: Helpers.pack_int(8),
                 red: Helpers.pack_int(9)
               })

  @spec parse_hair_color(binary) :: atom
  def parse_hair_color(hair_color), do: BiMap.get_key(@hair_colors, hair_color)

  @spec pack_hair_color(atom) :: iodata
  def pack_hair_color(hair_color), do: BiMap.get(@hair_colors, hair_color)

  @classes BiMap.new(%{
             adventurer: Helpers.pack_int(0),
             sorcerer: Helpers.pack_int(1),
             archer: Helpers.pack_int(2),
             swordsman: Helpers.pack_int(3),
             martial_artist: Helpers.pack_int(4)
           })

  @spec parse_class(binary) :: atom
  def parse_class(class), do: BiMap.get_key(@classes, class)

  @spec pack_class(atom) :: iodata
  def pack_class(class), do: BiMap.get(@classes, class)
end

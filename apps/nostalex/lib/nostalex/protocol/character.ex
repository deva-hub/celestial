defmodule Nostalex.Protocol.Character do
  @moduledoc false

  alias Nostalex.Protocol.Helpers

  @spec parse_gender(binary) :: iodata
  def parse_gender("0"), do: :male
  def parse_gender("1"), do: :female

  @spec parse_hair_style(binary) :: iodata
  def parse_hair_style("0"), do: :a
  def parse_hair_style("1"), do: :b

  @spec parse_hair_color(binary) :: iodata
  def parse_hair_color("0"), do: :mauve_taupe
  def parse_hair_color("1"), do: :cerise
  def parse_hair_color("2"), do: :san_marino
  def parse_hair_color("3"), do: :affair
  def parse_hair_color("4"), do: :dixie
  def parse_hair_color("5"), do: :raven
  def parse_hair_color("6"), do: :killarney
  def parse_hair_color("7"), do: :nutmeg
  def parse_hair_color("8"), do: :saddle
  def parse_hair_color("9"), do: :red

  @spec pack_class(atom) :: iodata
  def pack_class(:adventurer), do: Helpers.pack_int(0)
  def pack_class(:sorcerer), do: Helpers.pack_int(1)
  def pack_class(:archer), do: Helpers.pack_int(2)
  def pack_class(:swordsman), do: Helpers.pack_int(3)
  def pack_class(:martial_artist), do: Helpers.pack_int(4)

  @spec pack_hair_style(binary) :: iodata
  def pack_hair_style(:a), do: Helpers.pack_int(0)
  def pack_hair_style(:b), do: Helpers.pack_int(1)

  @spec pack_hair_color(binary) :: iodata
  def pack_hair_color(:mauve_taupe), do: Helpers.pack_int(0)
  def pack_hair_color(:cerise), do: Helpers.pack_int(1)
  def pack_hair_color(:san_marino), do: Helpers.pack_int(2)
  def pack_hair_color(:affair), do: Helpers.pack_int(3)
  def pack_hair_color(:dixie), do: Helpers.pack_int(4)
  def pack_hair_color(:raven), do: Helpers.pack_int(5)
  def pack_hair_color(:killarney), do: Helpers.pack_int(6)
  def pack_hair_color(:nutmeg), do: Helpers.pack_int(7)
  def pack_hair_color(:saddle), do: Helpers.pack_int(8)
  def pack_hair_color(:red), do: Helpers.pack_int(9)

  @spec pack_gender(atom) :: iodata
  def pack_gender(:male), do: Helpers.pack_int(0)
  def pack_gender(:female), do: Helpers.pack_int(1)
end

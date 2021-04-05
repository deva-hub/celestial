defmodule Noslib.Lobby do
  @moduledoc """
  Responses from the world server to select a hero.
  """

  alias Noslib.Entity
  import Noslib.Packet

  def decode_char_new([name, index, sex, hair_style, hair_color]) do
    %{
      index: String.to_integer(index),
      hero: %{
        name: name,
        sex: Entity.decode_sex(sex),
        hair_style: Entity.decode_hair_style(hair_style),
        hair_color: Entity.decode_hair_color(hair_color)
      }
    }
  end

  def decode_select([index]) do
    %{index: String.to_integer(index)}
  end

  def decode_char_del([index, password]) do
    %{index: String.to_integer(index), password: password}
  end

  @pets_terminator "-1"

  def encode_clist_start(clists_start) do
    encode_list([clists_start.length])
  end

  def encode_clist(clist) do
    encode_list([
      encode_int(clist.index),
      clist.hero.name,
      encode_int(0),
      Entity.encode_sex(clist.hero.sex),
      Entity.encode_hair_style(clist.hero.hair_style),
      Entity.encode_hair_color(clist.hero.hair_color),
      encode_int(0),
      Entity.encode_class(clist.hero.class),
      encode_int(clist.hero.level),
      encode_int(clist.hero.hero_level),
      Entity.encode_equipments(clist.hero.equipment),
      encode_int(clist.hero.job_level),
      encode_int("1"),
      encode_int("1"),
      clist.hero.pets
      |> Enum.map(&encode_pet/1)
      |> encode_list(@pets_terminator),
      encode_int("0")
    ])
  end

  defp encode_pet(pet) do
    encode_struct([
      encode_int(pet.skin.id),
      encode_int(pet.id)
    ])
  end
end

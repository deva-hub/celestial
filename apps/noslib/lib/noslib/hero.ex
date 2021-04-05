defmodule Noslib.Hero do
  @moduledoc false

  alias Noslib.{Entity, HUD, Society}
  import Noslib.Packet

  @type c_info :: %{
          name: binary,
          group_id: pos_integer,
          family_id: pos_integer,
          family_name: binary,
          id: pos_integer,
          name_color: atom,
          sex: atom,
          hair_style: atom,
          hair_color: atom,
          class: atom,
          reputation: atom,
          compliment: pos_integer,
          morph: pos_integer,
          invisible?: boolean,
          family_level: pos_integer,
          morph_upgrade: non_neg_integer,
          arena_winner?: boolean
        }

  @type tit :: %{
          title: binary,
          name: binary
        }

  @type fd :: %{
          reputation: atom,
          dignity: atom
        }

  @type lev :: %{
          level: pos_integer,
          job_level: pos_integer,
          job_xp: pos_integer,
          xp_max: pos_integer,
          job_xp_max: pos_integer,
          reputation: atom,
          cp: pos_integer,
          hero_xp: pos_integer,
          hero_level: pos_integer,
          hero_xp_max: pos_integer
        }

  @type at :: %{
          id: pos_integer,
          map_id: pos_integer,
          coordinate_x: pos_integer,
          coordinate_y: pos_integer,
          music_id: pos_integer
        }

  @spec encode_c_info(c_info) :: iodata
  def encode_c_info(c_info) do
    encode_list([
      encode_string(c_info.name),
      encode_string(""),
      encode_int(c_info.group_id),
      encode_int(c_info.family_id),
      encode_string(c_info.family_name),
      encode_int(c_info.id),
      HUD.encode_name_color(c_info.name_color),
      Entity.encode_sex(c_info.sex),
      Entity.encode_hair_style(c_info.hair_style),
      Entity.encode_hair_color(c_info.hair_color),
      Entity.encode_class(c_info.class),
      Society.encode_reputation(c_info.reputation),
      encode_int(c_info.compliment),
      encode_int(c_info.morph),
      encode_bool(c_info.invisible?),
      encode_int(c_info.family_level),
      encode_int(c_info.morph_upgrade),
      encode_bool(c_info.arena_winner?)
    ])
  end

  @spec encode_tit(tit) :: iodata
  def encode_tit(tit) do
    encode_list([
      encode_string(tit.title),
      encode_string(tit.name)
    ])
  end

  @spec encode_fd(fd) :: iodata
  def encode_fd(fd) do
    encode_list([
      Society.encode_reputation(fd.reputation),
      encode_int(HUD.dignity_icon(fd.reputation)),
      Society.encode_dignity(fd.dignity),
      encode_int(HUD.reputation(fd.dignity))
    ])
  end

  @spec encode_lev(lev) :: iodata
  def encode_lev(lev) do
    encode_list([
      encode_int(lev.level),
      encode_int(lev.job_level),
      encode_int(lev.job_xp),
      encode_int(lev.xp_max),
      encode_int(lev.job_xp_max),
      Society.encode_reputation(lev.reputation),
      encode_int(lev.cp),
      encode_int(lev.hero_xp),
      encode_int(lev.hero_level),
      encode_int(lev.hero_xp_max)
    ])
  end

  @spec encode_at(at) :: iodata
  def encode_at(at) do
    encode_list([
      encode_int(at.id),
      encode_int(at.map_id),
      encode_int(at.coordinate_x),
      encode_int(at.coordinate_y),
      "2",
      encode_int("0"),
      encode_int(at.music_id),
      "-1"
    ])
  end
end

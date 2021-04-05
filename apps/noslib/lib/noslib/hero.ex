defmodule Noslib.Hero do
  @moduledoc false

  alias Noslib.{Entity, HUD, Society}
  import Noslib.Packet

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

  def encode_tit(tit) do
    encode_list([
      encode_string(tit.title),
      encode_string(tit.name)
    ])
  end

  def encode_fd(fd) do
    encode_list([
      Society.encode_reputation(fd.reputation),
      encode_int(HUD.dignity_icon(fd.reputation)),
      Society.encode_dignity(fd.dignity),
      encode_int(HUD.reputation(fd.dignity))
    ])
  end

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

  def encode_at(at) do
    encode_list([
      encode_int(at.id),
      encode_int(at.map_id),
      encode_int(at.position.coordinate_x),
      encode_int(at.position.coordinate_y),
      "2",
      encode_int("0"),
      encode_int(at.music_id),
      "-1"
    ])
  end
end

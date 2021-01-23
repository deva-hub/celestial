defmodule Noslib.Hero do
  @moduledoc false
  alias Noslib.{Helpers, Entity, HUD, Society}

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
    Helpers.encode_list([
      Helpers.encode_string(c_info.name),
      Helpers.encode_string(""),
      Helpers.encode_int(c_info.group_id),
      Helpers.encode_int(c_info.family_id),
      Helpers.encode_string(c_info.family_name),
      Helpers.encode_int(c_info.id),
      HUD.encode_name_color(c_info.name_color),
      Entity.encode_sex(c_info.sex),
      Entity.encode_hair_style(c_info.hair_style),
      Entity.encode_hair_color(c_info.hair_color),
      Entity.encode_class(c_info.class),
      Society.encode_reputation(c_info.reputation),
      Helpers.encode_int(c_info.compliment),
      Helpers.encode_int(c_info.morph),
      Helpers.encode_bool(c_info.invisible?),
      Helpers.encode_int(c_info.family_level),
      Helpers.encode_int(c_info.morph_upgrade),
      Helpers.encode_bool(c_info.arena_winner?)
    ])
  end

  @spec encode_tit(tit) :: iodata
  def encode_tit(tit) do
    Helpers.encode_list([
      Helpers.encode_string(tit.title),
      Helpers.encode_string(tit.name)
    ])
  end

  @spec encode_fd(fd) :: iodata
  def encode_fd(fd) do
    Helpers.encode_list([
      Society.encode_reputation(fd.reputation),
      Helpers.encode_int(HUD.dignity_icon(fd.reputation)),
      Society.encode_dignity(fd.dignity),
      Helpers.encode_int(HUD.reputation(fd.dignity))
    ])
  end

  @spec encode_lev(lev) :: iodata
  def encode_lev(lev) do
    Helpers.encode_list([
      Helpers.encode_int(lev.level),
      Helpers.encode_int(lev.job_level),
      Helpers.encode_int(lev.job_xp),
      Helpers.encode_int(lev.xp_max),
      Helpers.encode_int(lev.job_xp_max),
      Society.encode_reputation(lev.reputation),
      Helpers.encode_int(lev.cp),
      Helpers.encode_int(lev.hero_xp),
      Helpers.encode_int(lev.hero_level),
      Helpers.encode_int(lev.hero_xp_max)
    ])
  end

  @spec encode_at(at) :: iodata
  def encode_at(at) do
    Helpers.encode_list([
      Helpers.encode_int(at.id),
      Helpers.encode_int(at.map_id),
      Helpers.encode_int(at.coordinate_x),
      Helpers.encode_int(at.coordinate_y),
      "2",
      Helpers.encode_int("0"),
      Helpers.encode_int(at.music_id),
      "-1"
    ])
  end
end

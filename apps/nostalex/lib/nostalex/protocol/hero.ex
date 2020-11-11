defmodule Nostalex.Protocol.Hero do
  @moduledoc false
  alias Nostalex.Protocol.{Helpers, UI, Society}

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

  @type c_info :: %{
          name: binary,
          group_id: pos_integer,
          family_id: pos_integer,
          family_name: binary,
          id: pos_integer,
          name_color: atom,
          gender: atom,
          hair_style: atom,
          hair_color: atom,
          class: atom,
          reputation: atom,
          compliment: pos_integer,
          morph: pos_integer,
          invisible?: boolean,
          family_level: pos_integer,
          morph_upgrade?: boolean,
          arena_winner?: boolean
        }

  def pack_c_info(c_info) do
    Helpers.pack_list([
      "c_info",
      c_info.name,
      "-",
      Helpers.pack_int(c_info.group_id),
      Helpers.pack_int(c_info.family_id),
      c_info.family_name,
      Helpers.pack_int(c_info.id),
      UI.pack_name_color(c_info.name_color),
      pack_gender(c_info.gender),
      pack_hair_style(c_info.hair_style),
      pack_hair_color(c_info.hair_color),
      pack_class(c_info.class),
      Society.pack_reputation(c_info.reputation),
      Helpers.pack_int(c_info.compliment),
      Helpers.pack_int(c_info.morph),
      Helpers.pack_bool(c_info.invisible?),
      Helpers.pack_int(c_info.family_level),
      Helpers.pack_bool(c_info.morph_upgrade?),
      Helpers.pack_bool(c_info.arena_winner?)
    ])
  end

  @type tit :: %{
          class: atom,
          name: binary
        }

  def pack_tit(tit) do
    Helpers.pack_list([
      "tit",
      tit.class |> to_string |> String.capitalize(),
      tit.name
    ])
  end

  @type fd :: %{
          reputation: atom,
          dignity: atom
        }

  def pack_fd(fd) do
    Helpers.pack_list([
      "fd",
      Society.pack_reputation(fd.reputation),
      Helpers.pack_int(UI.dignity_icon(fd.reputation)),
      Society.pack_dignity(fd.dignity),
      Helpers.pack_int(UI.reputation_icon(fd.dignity))
    ])
  end

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

  def pack_lev(lev) do
    Helpers.pack_list([
      "lev",
      Helpers.pack_int(lev.level),
      Helpers.pack_int(lev.job_level),
      Helpers.pack_int(lev.job_xp),
      Helpers.pack_int(lev.xp_max),
      Helpers.pack_int(lev.job_xp_max),
      Society.pack_reputation(lev.reputation),
      Helpers.pack_int(lev.cp),
      Helpers.pack_int(lev.hero_xp),
      Helpers.pack_int(lev.hero_level),
      Helpers.pack_int(lev.hero_xp_max)
    ])
  end
end

defmodule Noslib.Entity do
  @moduledoc false
  alias Noslib.{Client, Society, Helpers}

  @type in_ :: %{
          type: atom,
          name: binary,
          id: non_neg_integer,
          positions: %{
            x: integer,
            y: integer
          },
          direction: atom,
          name_color: atom,
          sex: atom,
          hair_style: atom,
          hair_color: atom,
          class: atom,
          equipments: atom,
          hp_percent: non_neg_integer,
          mp_percent: non_neg_integer,
          sitting?: bool,
          group_id: pos_integer,
          fairy_movement: atom,
          fairy_element: atom,
          fairy_morph: non_neg_integer,
          morph: non_neg_integer,
          weapon_upgrade: non_neg_integer,
          armor_upgrade: non_neg_integer,
          family_id: pos_integer,
          family_name: binary,
          reputation: atom,
          invisible?: bool,
          morph_upgrade: non_neg_integer,
          faction: atom,
          morph_bonus: non_neg_integer,
          level: pos_integer,
          family_level: pos_integer,
          family_icons: binary,
          compliment: non_neg_integer,
          size: pos_integer
        }

  @type mv :: %{
          entity: %{
            type: atom,
            id: pos_integer
          },
          positions: %{
            x: integer,
            y: integer
          },
          speed: non_neg_integer
        }

  @types BiMap.new(%{
           hero: Helpers.encode_int(1),
           npc: Helpers.encode_int(2),
           monster: Helpers.encode_int(3),
           map_object: Helpers.encode_int(9),
           portal: Helpers.encode_int(1000)
         })

  @spec decode_type(binary) :: atom
  def decode_type(type) do
    BiMap.fetch_key!(@types, type)
  end

  @spec encode_type(atom) :: iodata
  def encode_type(type) do
    BiMap.fetch!(@types, type)
  end

  @fairy_elements BiMap.new(%{
                    neutre: Helpers.encode_int(1),
                    fire: Helpers.encode_int(2),
                    water: Helpers.encode_int(3),
                    light: Helpers.encode_int(4),
                    darkness: Helpers.encode_int(4)
                  })

  @spec decode_fairy_element(binary) :: atom
  def decode_fairy_element(fairy_element) do
    BiMap.fetch_key!(@fairy_elements, fairy_element)
  end

  @spec encode_fairy_element(atom) :: iodata
  def encode_fairy_element(fairy_element) do
    BiMap.fetch!(@fairy_elements, fairy_element)
  end

  @fairy_movements BiMap.new(%{
                     neutre: Helpers.encode_int(0),
                     god: Helpers.encode_int(1)
                   })

  @spec decode_fairy_movement(binary) :: atom
  def decode_fairy_movement(fairy_movement),
    do: BiMap.fetch_key!(@fairy_movements, fairy_movement)

  @spec encode_fairy_movement(atom) :: iodata
  def encode_fairy_movement(fairy_movement) do
    BiMap.fetch!(@fairy_movements, fairy_movement)
  end

  @directions BiMap.new(%{
                north: Helpers.encode_int(1),
                east: Helpers.encode_int(2),
                south: Helpers.encode_int(3),
                west: Helpers.encode_int(4),
                north_east: Helpers.encode_int(5),
                south_east: Helpers.encode_int(6),
                south_west: Helpers.encode_int(7),
                north_west: Helpers.encode_int(8)
              })

  @spec decode_direction(binary) :: atom
  def decode_direction(direction) do
    BiMap.fetch_key!(@directions, direction)
  end

  @spec encode_direction(atom) :: iodata
  def encode_direction(direction) do
    BiMap.fetch!(@directions, direction)
  end

  @sexs BiMap.new(%{
          male: Helpers.encode_int(0),
          female: Helpers.encode_int(1)
        })

  @spec decode_sex(binary) :: atom
  def decode_sex(sex) do
    BiMap.fetch_key!(@sexs, sex)
  end

  @spec encode_sex(atom) :: iodata
  def encode_sex(sex) do
    BiMap.fetch!(@sexs, sex)
  end

  @hair_styles BiMap.new(%{
                 a: Helpers.encode_int(0),
                 b: Helpers.encode_int(1),
                 c: Helpers.encode_int(2),
                 d: Helpers.encode_int(3),
                 shave: Helpers.encode_int(4)
               })

  @spec decode_hair_style(binary) :: atom
  def decode_hair_style(hair_style) do
    BiMap.fetch_key!(@hair_styles, hair_style)
  end

  @spec encode_hair_style(atom) :: iodata
  def encode_hair_style(hair_style) do
    BiMap.fetch!(@hair_styles, hair_style)
  end

  @hair_colors BiMap.new(%{
                 mauve_taupe: Helpers.encode_int(0),
                 cerise: Helpers.encode_int(1),
                 san_marino: Helpers.encode_int(2),
                 affair: Helpers.encode_int(3),
                 dixie: Helpers.encode_int(4),
                 raven: Helpers.encode_int(5),
                 killarney: Helpers.encode_int(6),
                 nutmeg: Helpers.encode_int(7),
                 saddle: Helpers.encode_int(8),
                 red: Helpers.encode_int(9)
               })

  @spec decode_hair_color(binary) :: atom
  def decode_hair_color(hair_color) do
    BiMap.fetch_key!(@hair_colors, hair_color)
  end

  @spec encode_hair_color(atom) :: iodata
  def encode_hair_color(hair_color) do
    BiMap.fetch!(@hair_colors, hair_color)
  end

  @classes BiMap.new(%{
             adventurer: Helpers.encode_int(0),
             sorcerer: Helpers.encode_int(1),
             archer: Helpers.encode_int(2),
             swordsman: Helpers.encode_int(3),
             martial_artist: Helpers.encode_int(4)
           })

  @spec decode_class(binary) :: atom
  def decode_class(class) do
    BiMap.fetch_key!(@classes, class)
  end

  @spec encode_class(atom) :: iodata
  def encode_class(class) do
    BiMap.fetch!(@classes, class)
  end

  @spec encode_in(in_) :: iodata
  def encode_in(in_) do
    Helpers.encode_list([
      encode_type(in_.type),
      Helpers.encode_string(in_.name),
      Helpers.encode_string(""),
      Helpers.encode_int(in_.id),
      Helpers.encode_int(in_.positions.x),
      Helpers.encode_int(in_.positions.y),
      encode_direction(in_.direction),
      Client.encode_name_color(in_.name_color),
      encode_sex(in_.sex),
      encode_hair_style(in_.hair_style),
      encode_hair_color(in_.hair_color),
      encode_class(in_.class),
      encode_equipments(in_.equipments),
      Helpers.encode_int(in_.hp_percent),
      Helpers.encode_int(in_.mp_percent),
      Helpers.encode_bool(in_.sitting?),
      Helpers.encode_int(in_.group_id),
      encode_fairy_movement(in_.fairy_movement),
      encode_fairy_element(in_.fairy_element),
      Helpers.encode_int(0),
      Helpers.encode_int(in_.fairy_morph),
      Helpers.encode_int(0),
      Helpers.encode_int(in_.morph),
      Helpers.encode_int(in_.weapon_upgrade),
      Helpers.encode_int(in_.armor_upgrade),
      Helpers.encode_int(in_.family_id),
      Helpers.encode_string(in_.family_name),
      Society.encode_reputation(in_.reputation),
      Helpers.encode_bool(in_.invisible?),
      Helpers.encode_int(in_.morph_upgrade),
      Society.encode_faction(in_.faction),
      Helpers.encode_int(in_.morph_bonus),
      Helpers.encode_int(in_.level),
      Helpers.encode_int(in_.family_level),
      Helpers.encode_string(in_.family_icons),
      Helpers.encode_int(in_.compliment),
      Helpers.encode_int(in_.size),
      Helpers.encode_int(0),
      Helpers.encode_int(0),
      Helpers.encode_int(0)
    ])
  end

  def encode_equipments(equipments) do
    Helpers.encode_struct([
      Map.get(equipments, :hat, -1) |> Helpers.encode_int(),
      Map.get(equipments, :armor, -1) |> Helpers.encode_int(),
      Map.get(equipments, :weapon_skin, -1) |> Helpers.encode_int(),
      Map.get(equipments, :main_weapon, -1) |> Helpers.encode_int(),
      Map.get(equipments, :secondary_weapon, -1) |> Helpers.encode_int(),
      Map.get(equipments, :mask, -1) |> Helpers.encode_int(),
      Map.get(equipments, :fairy, -1) |> Helpers.encode_int(),
      Map.get(equipments, :costume_suit, -1) |> Helpers.encode_int(),
      Map.get(equipments, :costume_hat, -1) |> Helpers.encode_int()
    ])
  end

  @spec decode_walk([binary]) :: map
  def decode_walk([pos_x, pos_y, checksum, speed]) do
    %{
      positions: %{
        x: String.to_integer(pos_x),
        y: String.to_integer(pos_y)
      },
      speed: String.to_integer(speed),
      checksum: checksum
    }
  end

  @spec encode_mv(mv) :: iodata
  def encode_mv(mv) do
    Helpers.encode_list([
      encode_type(mv.entity.type),
      Helpers.encode_int(mv.entity.id),
      Helpers.encode_int(mv.positions.x),
      Helpers.encode_int(mv.positions.y),
      Helpers.encode_int(mv.speed)
    ])
  end
end

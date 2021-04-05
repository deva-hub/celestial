defmodule Noslib.Entity do
  @moduledoc false

  alias Noslib.{Client, Society}
  import Noslib.Packet

  @type in_ :: %{
          type: atom,
          name: binary,
          id: non_neg_integer,
          coordinate_x: integer,
          coordinate_y: integer,
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
          entity_type: atom,
          entity_id: pos_integer,
          coordinate_x: integer,
          coordinate_y: integer,
          speed: non_neg_integer
        }

  @types BiMap.new(%{
           hero: encode_int(1),
           npc: encode_int(2),
           monster: encode_int(3),
           map_object: encode_int(9),
           portal: encode_int(1000)
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
                    neutre: encode_int(1),
                    fire: encode_int(2),
                    water: encode_int(3),
                    light: encode_int(4),
                    darkness: encode_int(4)
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
                     neutre: encode_int(0),
                     god: encode_int(1)
                   })

  @spec decode_fairy_movement(binary) :: atom
  def decode_fairy_movement(fairy_movement),
    do: BiMap.fetch_key!(@fairy_movements, fairy_movement)

  @spec encode_fairy_movement(atom) :: iodata
  def encode_fairy_movement(fairy_movement) do
    BiMap.fetch!(@fairy_movements, fairy_movement)
  end

  @directions BiMap.new(%{
                north: encode_int(1),
                east: encode_int(2),
                south: encode_int(3),
                west: encode_int(4),
                north_east: encode_int(5),
                south_east: encode_int(6),
                south_west: encode_int(7),
                north_west: encode_int(8)
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
          male: encode_int(0),
          female: encode_int(1)
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
                 a: encode_int(0),
                 b: encode_int(1),
                 c: encode_int(2),
                 d: encode_int(3),
                 shave: encode_int(4)
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
                 mauve_taupe: encode_int(0),
                 cerise: encode_int(1),
                 san_marino: encode_int(2),
                 affair: encode_int(3),
                 dixie: encode_int(4),
                 raven: encode_int(5),
                 killarney: encode_int(6),
                 nutmeg: encode_int(7),
                 saddle: encode_int(8),
                 red: encode_int(9)
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
             adventurer: encode_int(0),
             sorcerer: encode_int(1),
             archer: encode_int(2),
             swordsman: encode_int(3),
             martial_artist: encode_int(4)
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
    encode_list([
      encode_type(in_.type),
      encode_string(in_.name),
      encode_string(""),
      encode_int(in_.id),
      encode_int(in_.coordinate_x),
      encode_int(in_.coordinate_y),
      encode_direction(in_.direction),
      Client.encode_name_color(in_.name_color),
      encode_sex(in_.sex),
      encode_hair_style(in_.hair_style),
      encode_hair_color(in_.hair_color),
      encode_class(in_.class),
      encode_equipments(in_.equipments),
      encode_int(in_.hp_percent),
      encode_int(in_.mp_percent),
      encode_bool(in_.sitting?),
      encode_int(in_.group_id),
      encode_fairy_movement(in_.fairy_movement),
      encode_fairy_element(in_.fairy_element),
      encode_int(0),
      encode_int(in_.fairy_morph),
      encode_int(0),
      encode_int(in_.morph),
      encode_int(in_.weapon_upgrade),
      encode_int(in_.armor_upgrade),
      encode_int(in_.family_id),
      encode_string(in_.family_name),
      Society.encode_reputation(in_.reputation),
      encode_bool(in_.invisible?),
      encode_int(in_.morph_upgrade),
      Society.encode_faction(in_.faction),
      encode_int(in_.morph_bonus),
      encode_int(in_.level),
      encode_int(in_.family_level),
      encode_string(in_.family_icons),
      encode_int(in_.compliment),
      encode_int(in_.size),
      encode_int(0),
      encode_int(0),
      encode_int(0)
    ])
  end

  def encode_equipments(equipments) do
    encode_struct([
      Map.get(equipments, :hat, -1) |> encode_int(),
      Map.get(equipments, :armor, -1) |> encode_int(),
      Map.get(equipments, :weapon_skin, -1) |> encode_int(),
      Map.get(equipments, :main_weapon, -1) |> encode_int(),
      Map.get(equipments, :secondary_weapon, -1) |> encode_int(),
      Map.get(equipments, :mask, -1) |> encode_int(),
      Map.get(equipments, :fairy, -1) |> encode_int(),
      Map.get(equipments, :costume_suit, -1) |> encode_int(),
      Map.get(equipments, :costume_hat, -1) |> encode_int()
    ])
  end

  @spec decode_walk([binary]) :: map
  def decode_walk([pos_x, pos_y, checksum, speed]) do
    %{
      coordinate_x: String.to_integer(pos_x),
      coordinate_y: String.to_integer(pos_y),
      speed: String.to_integer(speed),
      checksum: checksum
    }
  end

  @spec encode_mv(mv) :: iodata
  def encode_mv(mv) do
    encode_list([
      encode_type(mv.entity_type),
      encode_int(mv.entity_id),
      encode_int(mv.coordinate_x),
      encode_int(mv.coordinate_y),
      encode_int(mv.speed)
    ])
  end
end

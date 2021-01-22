defmodule Noslib.Geolocation do
  @moduledoc false
  alias Noslib.{Client, Hero, Entity, Society, Helpers}

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
  def decode_direction(direction), do: BiMap.fetch_key!(@directions, direction)

  @spec encode_direction(atom) :: iodata
  def encode_direction(direction), do: BiMap.fetch!(@directions, direction)

  @type at :: %{
          id: pos_integer,
          map_id: pos_integer,
          coordinates: %{
            x: pos_integer,
            y: pos_integer
          },
          music_id: pos_integer
        }

  def encode_at(at) do
    Helpers.encode_list([
      Helpers.encode_int(at.id),
      Helpers.encode_int(at.map_id),
      Helpers.encode_int(at.coordinates.x),
      Helpers.encode_int(at.coordinates.y),
      "2",
      Helpers.encode_int("0"),
      Helpers.encode_int(at.music_id),
      "-1"
    ])
  end

  @type in_ :: %{
          type: atom,
          name: binary,
          id: non_neg_integer,
          coordinates: %{
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

  def encode_in(in_) do
    Helpers.encode_list([
      Entity.encode_type(in_.type),
      Helpers.encode_string(in_.name),
      Helpers.encode_string(""),
      Helpers.encode_int(in_.id),
      Helpers.encode_int(in_.coordinates.x),
      Helpers.encode_int(in_.coordinates.y),
      encode_direction(in_.direction),
      Client.encode_name_color(in_.name_color),
      Hero.encode_sex(in_.sex),
      Hero.encode_hair_style(in_.hair_style),
      Hero.encode_hair_color(in_.hair_color),
      Hero.encode_class(in_.class),
      Hero.encode_equipments(in_.equipments),
      Helpers.encode_int(in_.hp_percent),
      Helpers.encode_int(in_.mp_percent),
      Helpers.encode_bool(in_.sitting?),
      Helpers.encode_int(in_.group_id),
      Entity.encode_fairy_movement(in_.fairy_movement),
      Entity.encode_fairy_element(in_.fairy_element),
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

  def decode_walk([pos_x, pos_y, checksum, speed]) do
    %{
      coordinates: %{
        x: String.to_integer(pos_x),
        y: String.to_integer(pos_y)
      },
      speed: String.to_integer(speed),
      checksum: checksum
    }
  end
end

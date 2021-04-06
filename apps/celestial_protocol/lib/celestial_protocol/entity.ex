defmodule CelestialProtocol.Entity do
  @moduledoc false

  alias CelestialProtocol.{Client, Society, Entity, HUD, Society}
  import CelestialProtocol.Packet

  def encode_c_info(c_info) do
    encode_list([
      encode_string(c_info.entity.name),
      encode_string(""),
      encode_int(c_info.group_id),
      encode_int(c_info.family_id),
      encode_string(c_info.family_name),
      encode_int(c_info.entity.id),
      HUD.encode_name_color(c_info.name_color),
      Entity.encode_sex(c_info.entity.sex),
      Entity.encode_hair_style(c_info.entity.hair_style),
      Entity.encode_hair_color(c_info.entity.hair_color),
      Entity.encode_class(c_info.entity.class),
      Society.encode_reputation(c_info.entity.reputation),
      encode_int(c_info.entity.compliment),
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
      Society.encode_reputation(fd.entity.reputation),
      encode_int(HUD.dignity_icon(fd.entity.reputation)),
      Society.encode_dignity(fd.entity.dignity),
      encode_int(HUD.reputation(fd.entity.dignity))
    ])
  end

  def encode_lev(lev) do
    encode_list([
      encode_int(lev.entity.level),
      encode_int(lev.entity.job_level),
      encode_int(lev.entity.job_xp),
      encode_int(lev.entity.xp_max),
      encode_int(lev.entity.job_xp_max),
      Society.encode_reputation(lev.entity.reputation),
      encode_int(lev.cp),
      encode_int(lev.entity.hero_xp),
      encode_int(lev.entity.hero_level),
      encode_int(lev.entity.hero_xp_max)
    ])
  end

  def encode_at(at) do
    encode_list([
      encode_int(at.id),
      encode_int(at.map),
      encode_int(at.position.coordinate_x),
      encode_int(at.position.coordinate_y),
      "2",
      encode_int("0"),
      encode_int(at.ambiance),
      "-1"
    ])
  end

  @types BiMap.new(%{
           character: encode_int(1),
           npc: encode_int(2),
           monster: encode_int(3),
           map_object: encode_int(9),
           portal: encode_int(1000)
         })

  def decode_type(type) do
    BiMap.fetch_key!(@types, type)
  end

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

  def decode_fairy_element(fairy_element) do
    BiMap.fetch_key!(@fairy_elements, fairy_element)
  end

  def encode_fairy_element(fairy_element) do
    BiMap.fetch!(@fairy_elements, fairy_element)
  end

  @fairy_movements BiMap.new(%{
                     neutre: encode_int(0),
                     god: encode_int(1)
                   })

  def decode_fairy_movement(fairy_movement),
    do: BiMap.fetch_key!(@fairy_movements, fairy_movement)

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

  def decode_direction(direction) do
    BiMap.fetch_key!(@directions, direction)
  end

  def encode_direction(direction) do
    BiMap.fetch!(@directions, direction)
  end

  @sexs BiMap.new(%{
          male: encode_int(0),
          female: encode_int(1)
        })

  def decode_sex(sex) do
    BiMap.fetch_key!(@sexs, sex)
  end

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

  def decode_hair_style(hair_style) do
    BiMap.fetch_key!(@hair_styles, hair_style)
  end

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

  def decode_hair_color(hair_color) do
    BiMap.fetch_key!(@hair_colors, hair_color)
  end

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

  def decode_class(class) do
    BiMap.fetch_key!(@classes, class)
  end

  def encode_class(class) do
    BiMap.fetch!(@classes, class)
  end

  def encode_in(in_) do
    encode_list([
      encode_type(in_.type),
      encode_string(in_.entity.name),
      encode_string(""),
      encode_int(in_.id),
      encode_int(in_.entity.position.coordinate_x),
      encode_int(in_.entity.position.coordinate_y),
      encode_direction(in_.entity.position.direction),
      Client.encode_name_color(in_.name_color),
      encode_sex(in_.entity.sex),
      encode_hair_style(in_.entity.hair_style),
      encode_hair_color(in_.entity.hair_color),
      encode_class(in_.entity.class),
      encode_equipments(in_.entity.equipment),
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
      Society.encode_reputation(in_.entity.reputation),
      encode_bool(in_.invisible?),
      encode_int(in_.morph_upgrade),
      Society.encode_faction(in_.entity.faction),
      encode_int(in_.morph_bonus),
      encode_int(in_.entity.level),
      encode_int(in_.family_level),
      encode_string(in_.family_icons),
      encode_int(in_.entity.compliment),
      encode_int(in_.size),
      encode_int(0),
      encode_int(0),
      encode_int(0)
    ])
  end

  def encode_equipments(equipment) do
    encode_struct([
      Map.get(equipment.hat, :id, -1) |> encode_int(),
      Map.get(equipment.armor, :id, -1) |> encode_int(),
      Map.get(equipment.weapon_skin, :id, -1) |> encode_int(),
      Map.get(equipment.main_weapon, :id, -1) |> encode_int(),
      Map.get(equipment.secondary_weapon, :id, -1) |> encode_int(),
      Map.get(equipment.mask, :id, -1) |> encode_int(),
      Map.get(equipment.fairy, :id, -1) |> encode_int(),
      Map.get(equipment.costume_suit, :id, -1) |> encode_int(),
      Map.get(equipment.costume_hat, :id, -1) |> encode_int()
    ])
  end

  def decode_walk([pos_x, pos_y, checksum, speed]) do
    %{
      speed: String.to_integer(speed),
      checksum: checksum,
      position: %{
        coordinate_x: String.to_integer(pos_x),
        coordinate_y: String.to_integer(pos_y)
      }
    }
  end

  def encode_mv(mv) do
    encode_list([
      encode_type(mv.entity_type),
      encode_int(mv.entity.id),
      encode_int(mv.position.coordinate_x),
      encode_int(mv.position.coordinate_y),
      encode_int(mv.speed)
    ])
  end
end

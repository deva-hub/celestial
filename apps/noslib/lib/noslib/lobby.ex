defmodule Noslib.Lobby do
  @moduledoc """
  Responses from the world server to select a hero.
  """

  alias Noslib.Entity
  import Noslib.Packet

  @type equipments :: %{
          hat_id: pos_integer | nil,
          armor_id: pos_integer | nil,
          weapon_skin_id: pos_integer | nil,
          main_weapon_id: pos_integer | nil,
          secondary_weapon_id: pos_integer | nil,
          mask_id: pos_integer | nil,
          fairy_id: pos_integer | nil,
          costume_suit_id: pos_integer | nil,
          costume_hat_id: pos_integer | nil
        }

  @type pet :: %{
          id: pos_integer,
          skin_id: pos_integer
        }

  @type clist :: %{
          index: pos_integer,
          name: bitstring,
          sex: atom,
          hair_style: atom,
          hair_color: atom,
          class: atom,
          level: integer,
          hero_level: integer,
          job_level: integer,
          equipments: equipments,
          pets: [pet]
        }

  @type clists_start :: %{
          length: pos_integer
        }

  @type clists_end :: %{}

  @type family :: %{
          id: pos_integer,
          name: bitstring,
          level: pos_integer
        }

  def decode_char_new([name, index, sex, hair_style, hair_color]) do
    %{
      index: String.to_integer(index),
      name: name,
      sex: Entity.decode_sex(sex),
      hair_style: Entity.decode_hair_style(hair_style),
      hair_color: Entity.decode_hair_color(hair_color)
    }
  end

  def decode_select([index]) do
    %{index: String.to_integer(index)}
  end

  def decode_char_del([index, password]) do
    %{index: String.to_integer(index), password: password}
  end

  @pets_terminator "-1"

  @spec encode_clist_start(clists_start) :: iodata
  def encode_clist_start(clists_start) do
    encode_list([clists_start.length])
  end

  @spec encode_clist(clist) :: iodata
  def encode_clist(clist) do
    encode_list([
      encode_int(clist.index),
      clist.name,
      encode_int(0),
      Entity.encode_sex(clist.sex),
      Entity.encode_hair_style(clist.hair_style),
      Entity.encode_hair_color(clist.hair_color),
      encode_int(0),
      Entity.encode_class(clist.class),
      encode_int(clist.level),
      encode_int(clist.hero_level),
      Entity.encode_equipments(%{}),
      Entity.encode_equipments(clist.equipments),
      encode_int(clist.job_level),
      encode_int("1"),
      encode_int("1"),
      clist.pets
      |> Enum.map(&encode_pet/1)
      |> encode_list(@pets_terminator),
      encode_int("0")
    ])
  end

  defp encode_pet(pet) do
    encode_struct([
      encode_int(pet.skin_id),
      encode_int(pet.id)
    ])
  end
end

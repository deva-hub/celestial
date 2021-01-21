defmodule Noslib.Lobby do
  @moduledoc """
  Responses from the world server to select a hero.
  """
  alias Noslib.{Hero, Helpers}

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
          slot: pos_integer,
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

  def decode_char_new([name, slot, sex, hair_style, hair_color]) do
    %{
      slot: String.to_integer(slot),
      name: name,
      sex: Hero.decode_sex(sex),
      hair_style: Hero.decode_hair_style(hair_style),
      hair_color: Hero.decode_hair_color(hair_color)
    }
  end

  def decode_select([slot]) do
    %{slot: String.to_integer(slot)}
  end

  def decode_char_del([slot, password]) do
    %{slot: String.to_integer(slot), password: password}
  end

  @pets_terminator "-1"

  @spec encode_clist_start(clists_start) :: iodata
  def encode_clist_start(clists_start) do
    Helpers.encode_list([clists_start.length])
  end

  @spec encode_clist(clist) :: iodata
  def encode_clist(clist) do
    Helpers.encode_list([
      Helpers.encode_int(clist.slot),
      clist.name,
      Helpers.encode_int(0),
      Hero.encode_sex(clist.sex),
      Hero.encode_hair_style(clist.hair_style),
      Hero.encode_hair_color(clist.hair_color),
      Helpers.encode_int(0),
      Hero.encode_class(clist.class),
      Helpers.encode_int(clist.level),
      Helpers.encode_int(clist.hero_level),
      Hero.encode_equipments(%{}),
      Hero.encode_equipments(clist.equipments),
      Helpers.encode_int(clist.job_level),
      Helpers.encode_int("1"),
      Helpers.encode_int("1"),
      clist.pets
      |> Enum.map(&encode_pet/1)
      |> Helpers.encode_list(@pets_terminator),
      Helpers.encode_int("0")
    ])
  end

  defp encode_pet(pet) do
    Helpers.encode_struct([
      Helpers.encode_int(pet.skin_id),
      Helpers.encode_int(pet.id)
    ])
  end
end

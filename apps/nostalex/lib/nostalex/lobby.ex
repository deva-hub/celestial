defmodule Nostalex.Lobby do
  @moduledoc """
  Responses from the world server to select a hero.
  """
  alias Nostalex.{Hero, Helpers}

  @type equipment :: %{
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
          gender: Hero.gender(),
          hair_style: Hero.hair_style(),
          hair_color: Hero.hair_color(),
          class: Hero.class(),
          level: integer,
          hero_level: integer,
          job_level: integer,
          equipment: equipment,
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

  def parse_char_new([packet_id, name, slot, gender, hair_style, hair_color]) do
    slot = String.to_integer(slot)
    gender = Hero.parse_gender(gender)
    hair_style = Hero.parse_hair_style(hair_style)
    hair_color = Hero.parse_hair_color(hair_color)
    {:char_del, packet_id, slot, name, gender, hair_style, hair_color}
  end

  def parse_select([packet_id, slot]) do
    {:select, packet_id, String.to_integer(slot)}
  end

  def parse_char_del([packet_id, slot, name]) do
    {:char_del, packet_id, String.to_integer(slot), name}
  end

  @pets_terminator "-1"

  @spec pack_clist_start(clists_start) :: iodata
  def pack_clist_start(clists_start) do
    Helpers.pack_list(["clist_start", clists_start.length])
  end

  @spec pack_clist_end(clists_end) :: iodata
  def pack_clist_end(_) do
    Helpers.pack_list(["clist_end"])
  end

  @spec pack_clist(clist) :: iodata
  def pack_clist(clist) do
    Helpers.pack_list([
      "clist",
      Helpers.pack_int(clist.slot),
      clist.name,
      "0",
      Hero.pack_gender(clist.gender),
      Hero.pack_hair_style(clist.hair_style),
      Hero.pack_hair_color(clist.hair_color),
      "0",
      Hero.pack_class(clist.class),
      Helpers.pack_int(clist.level),
      Helpers.pack_int(clist.hero_level),
      pack_equipment(%{}),
      pack_equipment(clist.equipment),
      Helpers.pack_int(clist.job_level),
      "1",
      "1",
      clist.pets
      |> Enum.map(&pack_pet/1)
      |> Helpers.pack_list(@pets_terminator),
      "0"
    ])
  end

  defp pack_equipment(equipment) do
    Helpers.pack_struct([
      Map.get(equipment, :hat, "-1"),
      Map.get(equipment, :armor, "-1"),
      Map.get(equipment, :weapon_skin, "-1"),
      Map.get(equipment, :main_weapon, "-1"),
      Map.get(equipment, :secondary_weapon, "-1"),
      Map.get(equipment, :mask, "-1"),
      Map.get(equipment, :fairy, "-1"),
      Map.get(equipment, :costume_suit, "-1"),
      Map.get(equipment, :costume_hat, "-1")
    ])
  end

  defp pack_pet(pet) do
    Helpers.pack_struct([
      Helpers.pack_int(pet.skin_id),
      Helpers.pack_int(pet.id)
    ])
  end
end

defmodule Noslib.Entity do
  @moduledoc false
  alias Noslib.{Helpers}

  @types BiMap.new(%{
           hero: Helpers.encode_int(1),
           npc: Helpers.encode_int(2),
           monster: Helpers.encode_int(3),
           map_object: Helpers.encode_int(9),
           portal: Helpers.encode_int(1000)
         })

  @spec decode_type(binary) :: atom
  def decode_type(type), do: BiMap.fetch_key!(@types, type)

  @spec encode_type(atom) :: iodata
  def encode_type(type), do: BiMap.fetch!(@types, type)

  @fairy_elements BiMap.new(%{
                    neutre: Helpers.encode_int(1),
                    fire: Helpers.encode_int(2),
                    water: Helpers.encode_int(3),
                    light: Helpers.encode_int(4),
                    darkness: Helpers.encode_int(4)
                  })

  @spec decode_fairy_element(binary) :: atom
  def decode_fairy_element(fairy_element), do: BiMap.fetch_key!(@fairy_elements, fairy_element)

  @spec encode_fairy_element(atom) :: iodata
  def encode_fairy_element(fairy_element), do: BiMap.fetch!(@fairy_elements, fairy_element)

  @fairy_movements BiMap.new(%{
                     neutre: Helpers.encode_int(0),
                     god: Helpers.encode_int(1)
                   })

  @spec decode_fairy_movement(binary) :: atom
  def decode_fairy_movement(fairy_movement),
    do: BiMap.fetch_key!(@fairy_movements, fairy_movement)

  @spec encode_fairy_movement(atom) :: iodata
  def encode_fairy_movement(fairy_movement), do: BiMap.fetch!(@fairy_movements, fairy_movement)
end

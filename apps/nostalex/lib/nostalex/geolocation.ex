defmodule Nostalex.Geolocation do
  @moduledoc false
  alias Nostalex.Helpers

  @type at :: %{
          id: pos_integer,
          map_id: pos_integer,
          position_x: pos_integer,
          position_y: pos_integer,
          music_id: pos_integer
        }

  def pack_at(at) do
    Helpers.pack_list([
      "at",
      Helpers.pack_int(at.id),
      Helpers.pack_int(at.map_id),
      Helpers.pack_int(at.position_x),
      Helpers.pack_int(at.position_y),
      "2",
      "0",
      Helpers.pack_int(at.music_id),
      "-1"
    ])
  end

  @spec parse_walk([binary]) :: {:walk, String.t(), String.t(), String.t()}
  def parse_walk([packet_id, pos_x, pos_y, checksum, speed]) do
    pos_x = String.to_integer(pos_x)
    pos_y = String.to_integer(pos_y)
    speed = String.to_integer(speed)
    {:walk, packet_id, pos_x, pos_y, checksum, speed}
  end
end

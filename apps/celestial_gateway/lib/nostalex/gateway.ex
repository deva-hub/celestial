defmodule Nostalex.Gateway do
  @moduledoc """
  Authentification response serializer.
  """

  alias Nostalex.Helpers

  @type channel :: %{
          sid: pos_integer,
          world_sid: pos_integer,
          slot: pos_integer,
          ip: :inet.ip4_address(),
          port: :inet.port_number(),
          population: non_neg_integer,
          capacity: non_neg_integer
        }

  @type nstest :: %{
          uid: pos_integer,
          channels: [channel]
        }

  @channel_terminator "-1:-1:-1:10000.10000.1"

  @spec encode_nstest(nstest) :: iodata
  def encode_nstest(param) do
    channels = Helpers.encode_list(param.channels, @channel_terminator, &channel/1)
    Helpers.encode_packet(["NsTeST", to_string(param.uid) | channels])
  end

  defp channel(channel) do
    [
      ip_address(channel.ip),
      ":",
      to_string(channel.port),
      ":",
      channel_color(channel.population, channel.capacity),
      ":",
      to_string(channel.slot),
      ".",
      to_string(channel.world_sid),
      ".",
      to_string(channel.sid)
    ]
  end

  defp channel_color(population, capacity) do
    to_string(round(population / capacity * 20) + 1)
  end

  defp ip_address({d1, d2, d3, d4}) do
    [to_string(d1), ".", to_string(d2), ".", to_string(d3), ".", to_string(d4)]
  end
end

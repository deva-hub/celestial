defmodule Nostalex.Protocol.Gateway do
  @moduledoc """
  Authentification response serializer.
  """

  alias Nostalex.Protocol.Helpers

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

  @spec pack_nstest(nstest) :: iodata
  def pack_nstest(param) do
    channels =
      param.channels
      |> Enum.map(&pack_channel/1)
      |> Helpers.pack_list(@channel_terminator)

    Helpers.pack_list(["NsTeST", param.uid | channels])
  end

  def pack_channel(channel) do
    [
      pack_ip_address(channel.ip),
      ":",
      channel.port,
      ":",
      channel_color(channel.population, channel.capacity),
      ":",
      channel.slot,
      ".",
      channel.world_sid,
      ".",
      channel.sid
    ]
  end

  defp channel_color(population, capacity) do
    round(population / capacity * 20) + 1
  end

  def pack_ip_address({d1, d2, d3, d4}) do
    Enum.intersperse([d1, d2, d3, d4], ".")
  end

  @spec parse_nos0575([binary]) :: {:nos0575, String.t(), String.t(), String.t()}
  def parse_nos0575([_, email, cipher_password, _, client_version]) do
    password = decrypt_password(cipher_password)
    version = Helpers.normalize_version(client_version)
    {:nos0575, email, password, version}
  end

  def decrypt_password(password) do
    password
    |> slice_password_padding()
    |> String.codepoints()
    |> Enum.take_every(2)
    |> Enum.chunk_every(2)
    |> Enum.map(&(&1 |> Enum.join() |> String.to_integer(16)))
    |> to_string()
  end

  defp slice_password_padding(password) do
    case password |> String.length() |> rem(2) do
      0 -> String.slice(password, 3..-1)
      1 -> String.slice(password, 4..-1)
    end
  end
end

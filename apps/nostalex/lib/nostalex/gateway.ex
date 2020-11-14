defmodule Nostalex.Gateway do
  @moduledoc """
  Authentification response serializer.
  """

  alias Nostalex.Helpers

  @type channel :: %{
          id: pos_integer,
          world_id: pos_integer,
          slot: pos_integer,
          ip: :inet.ip4_address(),
          port: :inet.port_number(),
          population: non_neg_integer,
          capacity: non_neg_integer
        }

  @type nstest :: %{
          key: pos_integer,
          channels: [channel]
        }

  @channel_terminator "-1:-1:-1:10000.10000.1"

  @spec pack_nstest(nstest) :: iodata
  def pack_nstest(nstest) do
    Helpers.pack_list([
      "NsTeST",
      Helpers.pack_int(nstest.key),
      nstest.channels
      |> Enum.map(&pack_channel/1)
      |> Helpers.pack_list(@channel_terminator)
    ])
  end

  def pack_channel(channel) do
    Helpers.pack_tuple([
      pack_ip_address(channel.ip),
      Helpers.pack_int(channel.port),
      Helpers.pack_int(channel_color(channel.population, channel.capacity)),
      Helpers.pack_struct([
        Helpers.pack_int(channel.slot),
        Helpers.pack_int(channel.world_id),
        Helpers.pack_int(channel.id)
      ])
    ])
  end

  defp channel_color(population, capacity) do
    round(population / capacity * 20) + 1
  end

  def pack_ip_address({d1, d2, d3, d4}) do
    Helpers.pack_struct([
      Helpers.pack_int(d1),
      Helpers.pack_int(d2),
      Helpers.pack_int(d3),
      Helpers.pack_int(d4)
    ])
  end

  @spec parse_nos0575([binary]) :: {:nos0575, String.t(), String.t(), String.t()}
  def parse_nos0575([_, email, cipher_password, _, client_version]) do
    password = decrypt_password(cipher_password)
    version = Helpers.normalize_version(client_version)
    {:nos0575, email, password, version}
  end

  defp decrypt_password(password) do
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

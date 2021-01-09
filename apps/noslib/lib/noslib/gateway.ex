defmodule Noslib.Gateway do
  @moduledoc """
  Authentification response serializer.
  """

  alias Noslib.Helpers

  @type channel :: %{
          id: pos_integer,
          world_id: pos_integer,
          world_name: pos_integer,
          hostname: :inet.ip4_address(),
          port: :inet.port_number(),
          population: non_neg_integer,
          capacity: non_neg_integer
        }

  @type nstest :: %{
          key: pos_integer,
          channels: [channel]
        }

  @channel_terminator "-1:-1:-1:10000.10000.1"

  @spec encode_nstest(nstest) :: iodata
  def encode_nstest(nstest) do
    Helpers.encode_list([
      Helpers.encode_int(nstest.key),
      nstest.channels
      |> Enum.map(&encode_channel/1)
      |> Helpers.encode_list(@channel_terminator)
    ])
  end

  def encode_channel(channel) do
    Helpers.encode_tuple([
      encode_ip_address(channel.hostname),
      Helpers.encode_int(channel.port),
      Helpers.encode_int(channel_color(channel.population, channel.capacity)),
      Helpers.encode_struct([
        Helpers.encode_int(channel.world_id),
        channel.world_name,
        Helpers.encode_int(channel.id)
      ])
    ])
  end

  defp channel_color(population, capacity) do
    round(population / capacity * 20) + 1
  end

  def encode_ip_address({d1, d2, d3, d4}) do
    Helpers.encode_struct([
      Helpers.encode_int(d1),
      Helpers.encode_int(d2),
      Helpers.encode_int(d3),
      Helpers.encode_int(d4)
    ])
  end

  @spec decode_nos0575([binary]) :: map
  def decode_nos0575([_, email, cipher_password, _, client_version]) do
    %{
      email: email,
      password: decrypt_password(cipher_password),
      version: Helpers.normalize_version(client_version)
    }
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
defmodule CelestialProtocol.Gateway do
  @moduledoc """
  Authentification response serializer.
  """

  import CelestialProtocol.Packet

  @type portal :: %{
          id: pos_integer,
          channel_id: pos_integer,
          world_name: pos_integer,
          hostname: :inet.ip4_address(),
          port: :inet.port_number(),
          population: non_neg_integer,
          capacity: non_neg_integer
        }

  @type nstest :: %{
          user_id: pos_integer,
          username: binary,
          portals: [portal]
        }

  @portal_terminator "-1:-1:-1:10000.10000.1"

  @spec encode_nstest(nstest) :: iodata
  def encode_nstest(%{username: username} = nstest) do
    encode_list([
      encode_int(nstest.user_id),
      encode_string(username),
      nstest.portals
      |> Enum.map(&encode_portal/1)
      |> encode_list(@portal_terminator)
    ])
  end

  def encode_nstest(nstest) do
    encode_list([
      encode_int(nstest.id),
      nstest.portals
      |> Enum.map(&encode_portal/1)
      |> encode_list(@portal_terminator)
    ])
  end

  def encode_portal(portal) do
    encode_tuple([
      encode_ip_address(portal.hostname),
      encode_int(portal.port),
      encode_int(portal_color(portal.population, portal.capacity)),
      encode_struct([
        encode_int(portal.id),
        encode_string(portal.world_name),
        encode_int(portal.channel_id)
      ])
    ])
  end

  defp portal_color(population, capacity) do
    round(population / capacity * 20) + 1
  end

  def encode_ip_address({d1, d2, d3, d4}) do
    encode_struct([
      encode_int(d1),
      encode_int(d2),
      encode_int(d3),
      encode_int(d4)
    ])
  end

  def decode_nos0575([_, username, cipher_password, _, version]) do
    %{
      username: username,
      password: :crypto.hash(:sha512, decrypt_password(cipher_password)),
      version: normalize_version(version)
    }
  end

  def decode_nos0575([_, username, password, _, _, version, _, checksum]) do
    decode_nos0575([username, password, version, checksum])
  end

  def decode_nos0575([_, username, password, _, version, _, checksum]) do
    decode_nos0575([username, password, version, checksum])
  end

  def decode_nos0575([username, password, version, checksum]) do
    %{
      username: username,
      password: password,
      version: normalize_version(version),
      checksum: checksum
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

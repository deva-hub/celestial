defmodule CelestialPortal.Crypto do
  @moduledoc """
  NosTale Channel cryptography suite
  """
  use Bitwise, only_operators: true

  @permutation_matrix ["\0", " ", "-", ".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "\n", "\0"]

  @doc """
  Encrypts a given binary
  """
  @spec encrypt(binary) :: binary
  def encrypt(plaintext) do
    <<encrypt_chunk(plaintext)::binary, 0xFF::size(8)>>
  end

  defp encrypt_chunk(ciphertext) do
    bytes = ciphertext |> to_charlist |> Enum.with_index()
    length = length(bytes)

    for {b, i} <- bytes, into: <<>> do
      if rem(i, 0x7E) != 0 do
        <<(~~~b)>>
      else
        rest = if length - i > 0x7E, do: 0x7E, else: length - i
        <<rest::size(8), ~~~b::size(8)>>
      end
    end
  end

  @doc """
  Decrypts the given binary
  """
  @spec decrypt(binary, keyword) :: binary
  def decrypt(plaintext, opts \\ []) do
    if key = Keyword.get(opts, :key) do
      decryption_type = key >>> 6 &&& 3
      offset = key &&& 0xFF
      unpack(for <<c <- plaintext>>, into: "", do: decrypt_byte(c, offset, decryption_type))
    else
      unpack(for <<c <- plaintext>>, into: "", do: decrypt_byte(c, -1, -1))
    end
  end

  defp decrypt_byte(char, offset, 0), do: <<char - offset - 0x40 &&& 0xFF>>
  defp decrypt_byte(char, offset, 1), do: <<char + offset + 0x40 &&& 0xFF>>
  defp decrypt_byte(char, offset, 2), do: <<Bitwise.bxor(char - offset - 0x40, 0xC3) &&& 0xFF>>
  defp decrypt_byte(char, offset, 3), do: <<Bitwise.bxor(char + offset + 0x40, 0xC3) &&& 0xFF>>
  defp decrypt_byte(char, _, _), do: <<char - 0x0F &&& 0xFF>>

  defp unpack(binary) do
    binary
    |> :binary.split(<<0xFF>>, [:global, :trim_all])
    |> Enum.map(&unpack_bytes(&1))
    |> Enum.join(" ")
  end

  defp unpack_bytes(data, result \\ [])

  defp unpack_bytes("", result) do
    result
    |> Enum.reverse()
    |> Enum.join()
  end

  defp unpack_bytes(<<byte::size(8), rest::binary>>, result) do
    packed? = (byte &&& 0x80) > 0
    len = byte &&& 0x7F
    len = if packed?, do: ceil(len / 2), else: len

    <<pack::bytes-size(len), rest::binary>> = rest

    pack =
      if packed? do
        for <<h::size(4), l::size(4) <- pack>>, into: "" do
          left_byte = Enum.at(@permutation_matrix, h)
          right_byte = Enum.at(@permutation_matrix, l)
          if l != 0, do: left_byte <> right_byte, else: left_byte
        end
      else
        for <<c <- pack>>, into: "", do: <<Bitwise.bxor(c, 0xFF)>>
      end

    unpack_bytes(rest, [pack | result])
  end
end

defmodule CelestialWorld.Crypto do
  @moduledoc """
  NosTale Channel cryptography suite
  """
  use Bitwise, only_operators: true

  @permutation_matrix [" ", "-", ".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "n"]

  @doc """
  Encrypts a given binary
  """
  @spec encrypt(binary) :: binary
  def encrypt(plaintext) do
    <<encrypt_data(plaintext)::binary, 0xFF::size(8)>>
  end

  defp encrypt_data(ciphertext) do
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
  @spec decrypt(binary) :: String.t()
  def decrypt(ciphertext) do
    case ciphertext do
      <<_::size(8), payload::binary>> ->
        payload
        |> decrypt_key_bytes()
        |> Enum.reverse()
        |> Enum.join()

      _ ->
        ""
    end
  end

  def decrypt(ciphertext, key) do
    uid_key = key &&& 0xFF
    offset = uid_key + 0x40 &&& 0xFF
    switch = key >>> 6 &&& 0x03

    ciphertext
    |> decrypt_user_data(switch, offset)
    |> :binary.split(<<0xFF>>, [:global, :trim_all])
    |> Enum.map(&decrypt_subpacket/1)
    |> Enum.join(" ")
  end

  defp decrypt_user_data(data, switch, offset) do
    for <<b <- data>>, into: <<>> do
      <<decrypt_user_byte(b, switch, offset)::size(8)>>
    end
  end

  defp decrypt_user_byte(byte, switch, offset) do
    case switch do
      0 -> byte - offset
      1 -> byte + offset
      2 -> (byte - offset) ^^^ 0xC3
      3 -> (byte + offset) ^^^ 0xC3
    end
  end

  defp decrypt_subpacket(data, result \\ [])

  defp decrypt_subpacket(<<>>, result) do
    result
    |> Enum.reverse()
    |> Enum.join()
  end

  defp decrypt_subpacket(<<byte::size(8), rest::binary>>, result) do
    if byte <= 0x7A do
      len = min(byte, byte_size(rest))
      {fst, snd} = String.split_at(rest, len)
      res = for <<b <- fst>>, into: "", do: <<b ^^^ 0xFF>>
      decrypt_subpacket(snd, [res | result])
    else
      len = byte &&& 0x7F
      {fst, snd} = decrypt_partial_subpacket(rest, len)
      decrypt_subpacket(snd, [fst | result])
    end
  end

  defp decrypt_partial_subpacket(data, len, i \\ 0, result \\ "")

  defp decrypt_partial_subpacket(<<>>, _, _, result) do
    {result, ""}
  end

  defp decrypt_partial_subpacket(data, len, i, result) do
    if i >= len do
      {result, data}
    else
      <<h::size(4), l::size(4), rest::binary>> = data
      res = permutate_hl_pair(h, l)

      if h != 0 and h != 0xF do
        decrypt_partial_subpacket(rest, len, i + 2, result <> res)
      else
        decrypt_partial_subpacket(rest, len, i + 1, result <> res)
      end
    end
  end

  defp permutate_hl_pair(h, l)
       when h != 0 and h != 0xF and (l == 0 or l == 0xF) do
    Enum.at(@permutation_matrix, h - 1)
  end

  defp permutate_hl_pair(h, l)
       when l != 0 and l != 0xF and (h == 0 or h == 0xF) do
    Enum.at(@permutation_matrix, l - 1)
  end

  defp permutate_hl_pair(h, l)
       when h != 0 and h != 0xF and l != 0 and l != 0xF do
    Enum.at(@permutation_matrix, h - 1) <> Enum.at(@permutation_matrix, l - 1)
  end

  defp permutate_hl_pair(_, _) do
    ""
  end

  defp decrypt_key_bytes(data, result \\ []) do
    case data do
      <<>> ->
        result

      <<0xE::size(8), _::binary>> ->
        result

      <<b::size(8), rest::binary>> ->
        {fst, snd} = decrypt_key_byte_pair(b)
        decrypt_key_bytes(rest, [snd, fst | result])
    end
  end

  defp decrypt_key_byte_pair(byte) do
    fst_b = byte - 0xF
    snd_b = fst_b &&& 0xF0
    fst = decrypt_key_second_key(snd_b >>> 0x4)
    snd = decrypt_key_first_key(fst_b - snd_b)
    {fst, snd}
  end

  defp decrypt_key_second_key(0), do: " "
  defp decrypt_key_second_key(1), do: " "
  defp decrypt_key_second_key(2), do: "-"
  defp decrypt_key_second_key(3), do: "."
  defp decrypt_key_second_key(key), do: <<0x2C + key::utf8>>

  defp decrypt_key_first_key(0), do: " "
  defp decrypt_key_first_key(1), do: " "
  defp decrypt_key_first_key(2), do: "-"
  defp decrypt_key_first_key(3), do: "."
  defp decrypt_key_first_key(key), do: <<0x2C + key::utf8>>
end

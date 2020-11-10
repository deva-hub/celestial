defmodule Nostalex.Gateway.Crypto do
  @moduledoc """
  NosTale Gateway cryptography suite
  """
  use Bitwise, only_operators: true

  @doc """
  Encrypts a given binary
  """
  @spec encrypt(binary) :: binary
  def encrypt(plaintext) do
    <<encrypt_data(plaintext)::binary, 0x19::size(8)>>
  end

  defp encrypt_data(data) do
    for <<b <- data>>, into: <<>> do
      <<b + 15 &&& 0xFF::size(8)>>
    end
  end

  @doc """
  Decrypts the given binary
  """
  @spec decrypt(binary) :: binary
  def decrypt(ciphertext) do
    for <<b <- ciphertext>>, into: "" do
      if b > 14 do
        <<(b - 15) ^^^ 195::utf8>>
      else
        <<(256 - (15 - b)) ^^^ 195::utf8>>
      end
    end
  end
end

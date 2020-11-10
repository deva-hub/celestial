defmodule Nostalex do
  @moduledoc """
  This module provides functions to work with the NostaleSE Protocol.
  """

  alias Nostalex.Helpers

  def parse(binary) when is_binary(binary) do
    binary |> String.split() |> parse()
  end

  def parse(["NoS0575" | rest]), do: parse_nos0575(rest)

  def parse_nos0575([_, email, cipher_password, _, client_version]) do
    {:nos0575, email, cipher_password, Helpers.normalize_version(client_version)}
  end
end

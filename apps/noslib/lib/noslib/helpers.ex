defmodule Noslib.Helpers do
  @moduledoc false
  def encode_list(list, terminator) do
    [terminator]
    |> Enum.concat(Enum.reverse(list))
    |> Enum.reverse()
    |> encode_list()
  end

  def encode_list(list) do
    Enum.intersperse(list, " ")
  end

  def encode_tuple(tuple) do
    Enum.intersperse(tuple, ":")
  end

  def encode_struct(struct) do
    Enum.intersperse(struct, ".")
  end

  def encode_int(number) do
    number |> to_string
  end

  def encode_bool(true), do: encode_int(1)
  def encode_bool(false), do: encode_int(0)

  @nostale_semver_regex ~r/(\d*)\.(\d*)\.(\d*)\.(\d*)/

  def normalize_version(version) do
    IO.inspect(version)
    Regex.replace(@nostale_semver_regex, version, "\\1.\\2.\\3+\\4")
  end
end

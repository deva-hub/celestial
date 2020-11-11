defmodule Nostalex.Protocol.Helpers do
  def pack_list(list, terminator) do
    [terminator]
    |> Enum.concat(Enum.reverse(list))
    |> Enum.reverse()
    |> pack_list()
  end

  def pack_list(list) do
    Enum.intersperse(list, " ")
  end

  def pack_tuple(tuple) do
    Enum.intersperse(tuple, ":")
  end

  def pack_struct(struct) do
    Enum.intersperse(struct, ".")
  end

  def pack_int(number) do
    number |> to_string
  end

  @nostale_semver_regex ~r/(\d*)\.(\d*)\.(\d*)\.(\d*)/

  def normalize_version(version) do
    Regex.replace(@nostale_semver_regex, version, "\\1.\\2.\\3-\\4")
  end
end

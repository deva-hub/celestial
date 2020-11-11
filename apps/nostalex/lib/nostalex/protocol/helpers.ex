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

  def pack_number(number) do
    number |> to_string
  end

  @nostale_semver_regex ~r/(\d*)\.(\d*)\.(\d*)\.(\d*)/

  def normalize_version(version) do
    Regex.replace(@nostale_semver_regex, version, "\\1.\\2.\\3-\\4")
  end
end

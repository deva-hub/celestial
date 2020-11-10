defmodule Nostalex.Protocol.Helpers do
  def pack_list(list, terminator) when is_list(list) do
    [terminator]
    |> Enum.concat(Enum.reverse(list))
    |> Enum.reverse()
    |> pack_list()
  end

  def pack_list(list) when is_list(list) do
    list
    |> Enum.map(&to_string/1)
    |> Enum.intersperse(" ")
  end

  @nostale_semver_regex ~r/(\d*)\.(\d*)\.(\d*)\.(\d*)/

  def normalize_version(version) do
    Regex.replace(@nostale_semver_regex, version, "\\1.\\2.\\3-\\4")
  end
end

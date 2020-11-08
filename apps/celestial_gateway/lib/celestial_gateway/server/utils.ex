defmodule CelestialGateway.Helpers do
  @nostale_semver_regex ~r/(\d*)\.(\d*)\.(\d*)\.(\d*)/

  def nostale_version_to_semver(version) do
    Regex.replace(@nostale_semver_regex, version, "\\1.\\2.\\3-\\4")
  end
end

defmodule Nostalex.Client do
  @moduledoc """
  Client specific response.
  """

  alias Nostalex.Helpers

  @type error :: %{error: atom}

  @type info :: %{message: binary}

  @spec pack_failc(error) :: iodata
  def pack_failc(failc) do
    Helpers.pack_list(["failc", pack_error(failc.error)])
  end

  @spec pack_info(info) :: iodata
  def pack_info(info) do
    Helpers.pack_list(["info", info.message])
  end

  @errors BiMap.new(%{
            outdated_client: Helpers.pack_int(1),
            unexpected_error: Helpers.pack_int(2),
            maintenance: Helpers.pack_int(3),
            session_already_used: Helpers.pack_int(4),
            unvalid_credentials: Helpers.pack_int(5),
            cant_authenticate: Helpers.pack_int(6),
            citizen_blacklisted: Helpers.pack_int(7),
            country_blacklisted: Helpers.pack_int(8),
            bad_case: Helpers.pack_int(9)
          })

  @spec parse_error(binary) :: atom
  def parse_error(error), do: BiMap.get_key(@errors, error)

  @spec pack_error(atom) :: iodata
  def pack_error(error), do: BiMap.get(@errors, error)

  @languages BiMap.new(%{
               kr: Helpers.pack_int(0),
               en: Helpers.pack_int(1)
             })

  @spec parse_language(binary) :: atom
  def parse_language(language), do: BiMap.get_key(@languages, language)

  @spec pack_language(atom) :: iodata
  def pack_language(language), do: BiMap.get(@languages, language)
end

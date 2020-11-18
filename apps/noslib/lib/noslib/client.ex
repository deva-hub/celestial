defmodule Noslib.Client do
  @moduledoc """
  Client specific response.
  """

  alias Noslib.Helpers

  @type error :: %{error: atom}

  @type info :: %{message: binary}

  @spec encode_failc(error) :: iodata
  def encode_failc(failc) do
    Helpers.encode_list(["failc", encode_error(failc.error)])
  end

  @spec encode_info(info) :: iodata
  def encode_info(info) do
    Helpers.encode_list(["info", info.message])
  end

  @errors BiMap.new(%{
            outdated_client: Helpers.encode_int(1),
            unexpected_error: Helpers.encode_int(2),
            maintenance: Helpers.encode_int(3),
            session_already_used: Helpers.encode_int(4),
            unvalid_credentials: Helpers.encode_int(5),
            cant_authenticate: Helpers.encode_int(6),
            citizen_blacklisted: Helpers.encode_int(7),
            country_blacklisted: Helpers.encode_int(8),
            bad_case: Helpers.encode_int(9)
          })

  @spec decode_error(binary) :: atom
  def decode_error(error), do: BiMap.get_key(@errors, error)

  @spec encode_error(atom) :: iodata
  def encode_error(error), do: BiMap.get(@errors, error)

  @languages BiMap.new(%{
               kr: Helpers.encode_int(0),
               en: Helpers.encode_int(1)
             })

  @spec decode_language(binary) :: atom
  def decode_language(language), do: BiMap.get_key(@languages, language)

  @spec encode_language(atom) :: iodata
  def encode_language(language), do: BiMap.get(@languages, language)
end

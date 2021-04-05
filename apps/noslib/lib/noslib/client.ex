defmodule Noslib.Client do
  @moduledoc """
  Client specific response.
  """

  import Noslib.Packet

  def encode_failc(failc) do
    encode_error(failc.error)
  end

  def encode_info(info) do
    encode_string(info.message)
  end

  @errors BiMap.new(%{
            outdated_client: encode_int(1),
            unexpected_error: encode_int(2),
            maintenance: encode_int(3),
            session_already_used: encode_int(4),
            unvalid_credentials: encode_int(5),
            cant_authenticate: encode_int(6),
            citizen_blacklisted: encode_int(7),
            country_blacklisted: encode_int(8),
            bad_case: encode_int(9)
          })

  def decode_error(error) do
    BiMap.fetch_key!(@errors, error)
  end

  def encode_error(error) do
    BiMap.fetch!(@errors, error)
  end

  @languages BiMap.new(%{
               kr: encode_int(0),
               en: encode_int(1)
             })

  def decode_language(language) do
    BiMap.fetch_key!(@languages, language)
  end

  def encode_language(language) do
    BiMap.fetch!(@languages, language)
  end

  @name_colors BiMap.new(%{
                 white: encode_int(0),
                 violet: encode_int(2),
                 invisible: encode_int(6)
               })

  def decode_name_color(name_color) do
    BiMap.fetch_key!(@name_colors, name_color)
  end

  def encode_name_color(name_color) do
    BiMap.fetch!(@name_colors, name_color)
  end
end

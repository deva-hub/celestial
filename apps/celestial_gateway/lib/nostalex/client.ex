defmodule Nostalex.Client do
  @moduledoc """
  Client specific response.
  """

  alias Nostalex.Helpers

  @type reason ::
          :outdated_client
          | :unexpected_error
          | :maintenance
          | :session_already_used
          | :unvalid_credentials
          | :cant_authenticate
          | :citizen_blacklisted
          | :country_blacklisted
          | :bad_case
  @type error :: %{reason: reason()}
  @type info :: %{message: bitstring}

  @spec encode_failc(error) :: iodata
  def encode_failc(param) do
    Helpers.encode_packet(["failc", reason(param.reason)])
  end

  @spec encode_info(info) :: iodata
  def encode_info(param) do
    Helpers.encode_packet(["info", param.message])
  end

  @spec reason(reason) :: iodata
  defp reason(:outdated_client), do: "1"
  defp reason(:unexpected_error), do: "2"
  defp reason(:maintenance), do: "3"
  defp reason(:session_already_used), do: "4"
  defp reason(:unvalid_credentials), do: "5"
  defp reason(:cant_authenticate), do: "6"
  defp reason(:citizen_blacklisted), do: "7"
  defp reason(:country_blacklisted), do: "8"
  defp reason(:bad_case), do: "9"
end

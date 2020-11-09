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

  @spec pack_failc(error) :: iodata
  def pack_failc(param) do
    Helpers.pack_list(["failc", pack_reason(param.reason)])
  end

  @spec pack_info(info) :: iodata
  def pack_info(param) do
    Helpers.pack_list(["info", param.message])
  end

  @spec pack_reason(reason) :: iodata
  defp pack_reason(:outdated_client), do: "1"
  defp pack_reason(:unexpected_error), do: "2"
  defp pack_reason(:maintenance), do: "3"
  defp pack_reason(:session_already_used), do: "4"
  defp pack_reason(:unvalid_credentials), do: "5"
  defp pack_reason(:cant_authenticate), do: "6"
  defp pack_reason(:citizen_blacklisted), do: "7"
  defp pack_reason(:country_blacklisted), do: "8"
  defp pack_reason(:bad_case), do: "9"
end

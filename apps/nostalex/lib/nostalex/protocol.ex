defmodule Nostalex.Protocol do
  @moduledoc """
  This module provides functions to work with the NostaleSE Protocol.
  """

  alias Nostalex.Protocol.{Client, HeroSelection, Gateway}

  def parse(data) when is_binary(data) do
    data |> String.split() |> parse()
  end

  def parse(["NoS0575" | rest]), do: Gateway.parse_nos0575(rest)
  def parse([packet_id, "0"]), do: {:ping, packet_id}
  def parse(data), do: {:dynamic, data}

  def pack(:clist_start, data), do: HeroSelection.pack_clist_start(data)
  def pack(:clist_end, data), do: HeroSelection.pack_clist_end(data)
  def pack(:clist, data), do: HeroSelection.pack_clist(data)
  def pack(:failc, data), do: Client.pack_failc(data)
  def pack(:nstest, data), do: Gateway.pack_nstest(data)
end

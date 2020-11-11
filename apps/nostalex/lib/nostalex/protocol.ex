defmodule Nostalex.Protocol do
  @moduledoc """
  This module provides functions to work with the NostaleSE Protocol.
  """

  alias Nostalex.Protocol.{Client, Lobby, Gateway, Hero, Geolocation}

  def parse(data) when is_binary(data) do
    data |> String.split() |> parse()
  end

  def parse(["NoS0575" | rest]), do: Gateway.parse_nos0575(rest)
  def parse([packet_id, "select" | rest]), do: Lobby.parse_select([packet_id | rest])
  def parse([packet_id, "char_del" | rest]), do: Lobby.parse_char_del([packet_id | rest])
  def parse([packet_id, "char_new" | rest]), do: Lobby.parse_char_new([packet_id | rest])
  def parse([packet_id, "0"]), do: {:heartbeat, packet_id}
  def parse(data), do: {:dynamic, data}

  def pack(:clist_start, data), do: Lobby.pack_clist_start(data)
  def pack(:clist_end, data), do: Lobby.pack_clist_end(data)
  def pack(:clist, data), do: Lobby.pack_clist(data)
  def pack(:c_info, data), do: Hero.pack_c_info(data)
  def pack(:failc, data), do: Client.pack_failc(data)
  def pack(:fd, data), do: Hero.pack_fd(data)
  def pack(:tit, data), do: Hero.pack_tit(data)
  def pack(:lev, data), do: Hero.pack_lev(data)
  def pack(:nstest, data), do: Gateway.pack_nstest(data)
  def pack(:at, data), do: Geolocation.pack_at(data)
end

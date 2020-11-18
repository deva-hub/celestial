defmodule Noslib do
  @moduledoc """
  This module provides functions to work with the NostaleSE Noslib.
  """

  alias Noslib.{Client, Lobby, Gateway, Hero, Geolocation, Helpers}

  def decode(payload) when is_binary(payload) do
    payload |> String.split() |> decode()
  end

  def decode(["NoS0575" | payload]) do
    [0, "NoS0575", Gateway.decode_nos0575(payload)]
  end

  def decode([id, "select" | payload]) do
    [String.to_integer(id), "select", Lobby.decode_select(payload)]
  end

  def decode([id, "char_del" | payload]) do
    [String.to_integer(id), "char_del", Lobby.decode_char_del(payload)]
  end

  def decode([id, "char_new" | payload]) do
    [String.to_integer(id), "char_new", Lobby.decode_char_new(payload)]
  end

  def decode([id, "0"]) do
    [String.to_integer(id), "0", %{}]
  end

  def decode([id, "walk" | payload]) do
    [String.to_integer(id), "walk", Geolocation.decode_walk(payload)]
  end

  def decode(payload) do
    [0, "", payload]
  end

  def encode(["clist_start", payload]) do
    Helpers.encode_list(["clist_start" | Lobby.encode_clist_start(payload)])
  end

  def encode(["clist_end", _]) do
    Helpers.encode_list(["clist_end"])
  end

  def encode(["clist", payload]) do
    Helpers.encode_list(["clist" | Lobby.encode_clist(payload)])
  end

  def encode(["c_info", payload]) do
    Helpers.encode_list(["c_info" | Hero.encode_c_info(payload)])
  end

  def encode(["failc", payload]) do
    Helpers.encode_list(["failc" | Client.encode_failc(payload)])
  end

  def encode(["fd", payload]) do
    Helpers.encode_list(["fd" | Hero.encode_fd(payload)])
  end

  def encode(["tit", payload]) do
    Helpers.encode_list(["tit" | Hero.encode_tit(payload)])
  end

  def encode(["lev", payload]) do
    Helpers.encode_list(["lev" | Hero.encode_lev(payload)])
  end

  def encode(["NsTeST", payload]) do
    Helpers.encode_list(["NsTeST" | Gateway.encode_nstest(payload)])
  end

  def encode(["at", payload]) do
    Helpers.encode_list(["at" | Geolocation.encode_at(payload)])
  end
end

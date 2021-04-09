defmodule CelestialProtocol do
  @moduledoc """
  This module provides functions to work with the NostaleSE CelestialProtocol.
  """

  alias CelestialProtocol.{Client, Lobby, Gateway, Entity}
  import CelestialProtocol.Packet

  def decode(payload) when is_binary(payload) do
    payload |> String.split() |> decode()
  end

  def decode(["NoS0575" | payload]) do
    [0, "accounts:lobby", "NoS0575", Gateway.decode_nos0575(payload)]
  end

  def decode([ref, "select" | payload]) do
    [String.to_integer(ref), "entity:lobby", "select", Lobby.decode_select(payload)]
  end

  def decode([ref, "Char_DEL" | payload]) do
    [String.to_integer(ref), "entity:lobby", "char_DEL", Lobby.decode_char_del(payload)]
  end

  def decode([ref, "Char_NEW" | payload]) do
    [String.to_integer(ref), "entity:lobby", "char_NEW", Lobby.decode_char_new(payload)]
  end

  def decode([ref, "walk" | payload]) do
    [String.to_integer(ref), "entity:lobby", "walk", Entity.decode_walk(payload)]
  end

  def decode(payload) do
    if msg = maybe_decode(payload) do
      msg
    else
      [0, "", "", payload]
    end
  end

  defp maybe_decode([ref1, user_id, ref2, password]) do
    case {Integer.parse(ref1), Integer.parse(ref2)} do
      {{ref1, ""}, {ref2, ""}} when ref1 + 1 == ref2 ->
        [ref2, "accounts:lobby", "handoff", %{user_id: user_id, password: password}]

      _ ->
        nil
    end
  end

  defp maybe_decode([ref, code]) do
    case Integer.parse(code) do
      {code, ""} ->
        [String.to_integer(ref), "celestial", "heartbeat", %{code: code}]

      _ ->
        nil
    end
  end

  defp maybe_decode(_) do
    nil
  end

  def encode(["in", payload]) do
    encode_list(["in", Entity.encode_in(payload)])
  end

  def encode(["clist_start", payload]) do
    encode_list(["clist_start", Lobby.encode_clist_start(payload)])
  end

  def encode(["clist_end", _]) do
    encode_list(["clist_end"])
  end

  def encode(["clist", payload]) do
    encode_list(["clist", Lobby.encode_clist(payload)])
  end

  def encode(["c_info", payload]) do
    encode_list(["c_info", Entity.encode_c_info(payload)])
  end

  def encode(["failc", payload]) do
    encode_list(["failc", Client.encode_failc(payload)])
  end

  def encode(["fd", payload]) do
    encode_list(["fd", Entity.encode_fd(payload)])
  end

  def encode(["tit", payload]) do
    encode_list(["tit", Entity.encode_tit(payload)])
  end

  def encode(["lev", payload]) do
    encode_list(["lev", Entity.encode_lev(payload)])
  end

  def encode(["NsTeST", payload]) do
    encode_list(["NsTeST", Gateway.encode_nstest(payload)])
  end

  def encode(["at", payload]) do
    encode_list(["at", Entity.encode_at(payload)])
  end

  def encode(["mv", payload]) do
    encode_list(["mv", Entity.encode_mv(payload)])
  end
end

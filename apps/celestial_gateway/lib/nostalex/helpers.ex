defmodule Nostalex.Helpers do
  def encode_list(list, terminator, fun) when is_list(list) and is_function(fun) do
    list
    |> Enum.reduce([terminator], &[fun.(&1) | &2])
    |> Enum.intersperse(" ")
  end

  def encode_packet(list) when is_list(list) do
    Enum.intersperse(list, " ")
  end
end

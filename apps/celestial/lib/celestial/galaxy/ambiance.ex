defmodule Celestial.Galaxy.Map do
  use Ecto.Schema
  import Ecto.Changeset

  schema "maps" do
    timestamps()
  end

  @doc false
  def changeset(map, attrs) do
    map
    |> cast(attrs, [])
  end
end

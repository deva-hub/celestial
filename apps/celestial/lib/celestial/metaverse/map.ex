defmodule Celestial.Metaverse.Ambiance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ambiances" do
    timestamps()
  end

  @doc false
  def changeset(ambiance, attrs) do
    ambiance
    |> cast(attrs, [])
  end
end

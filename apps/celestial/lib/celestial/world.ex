defmodule Celestial.World do
  @moduledoc """
  The World context.
  """

  import Ecto.Query, warn: false
  alias Celestial.Repo

  alias Celestial.World.Hero

  @doc """
  Returns the list of heroes.

  ## Examples

      iex> list_heroes()
      [%Hero{}, ...]

  """
  def list_heroes do
    Repo.all(Hero)
  end

  @doc """
  Returns the identity list of heroes.

  ## Examples

      iex> list_identity_heroes()
      [%Hero{}, ...]

  """
  def list_identity_heroes(identity) do
    Repo.all(Hero.identity_query(identity))
  end

  @doc """
  Gets a single hero.

  Raises `Ecto.NoResultsError` if the Hero does not exist.

  ## Examples

      iex> get_hero!(123)
      %Hero{}

      iex> get_hero!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hero!(id), do: Repo.get!(Hero, id)

  @doc """
  Creates a hero.

  ## Examples

      iex> create_hero(%Identity{}, %{field: value})
      {:ok, %Hero{}}

      iex> create_hero(%Identity{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hero(identity, attrs \\ %{}) do
    %Hero{identity_id: identity.id}
    |> Hero.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hero.

  ## Examples

      iex> update_hero(hero, %{field: new_value})
      {:ok, %Hero{}}

      iex> update_hero(hero, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hero(%Hero{} = hero, attrs) do
    hero
    |> Hero.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hero.

  ## Examples

      iex> delete_hero(hero)
      {:ok, %Hero{}}

      iex> delete_hero(hero)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hero(%Hero{} = hero) do
    Repo.delete(hero)
  end
end

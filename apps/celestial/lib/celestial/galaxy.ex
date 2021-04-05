defmodule Celestial.Galaxy do
  @moduledoc """
  The Galaxy context.
  """

  import Ecto.Query, warn: false
  alias Celestial.Repo

  alias Celestial.Galaxy.{Slot, Hero}

  @doc """
  Returns the list of slots.

  ## Examples

      iex> list_slots()
      [%Hero{}, ...]

  """
  def list_slots(identity) do
    Repo.all(Slot.identity_query(identity))
  end

  @doc """
  Gets a single hero by slot.

  Raises `Ecto.NoResultsError` if the Hero does not exist.

  ## Examples

      iex> get_slot_by_index!(%Identity{}, 123)
      %Hero{}

      iex> get_slot_by_index!(%Identity{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_slot_by_index!(identity, slot_index) do
    Repo.one!(Slot.identity_and_index_query(identity, slot_index))
  end

  @doc """
  Creates a slot.

  ## Examples

      iex> create_slot(%{field: value})
      {:ok, %Slot{}}

      iex> create_slot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_slot(identity, attrs \\ %{}) do
    identity
    |> Ecto.build_assoc(:slot)
    |> Slot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a slot.

  ## Examples

      iex> delete_slot(slot)
      {:ok, %Slot{}}

      iex> delete_slot(slot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_slot(%Slot{} = slot) do
    Repo.delete(slot)
  end

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
  Gets a single hero.

  Raises `Ecto.NoResultsError` if the Hero does not exist.

  ## Examples

      iex> get_hero!(123)
      %Hero{}

      iex> get_hero!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hero!(id) do
    Repo.get!(Hero, id)
  end

  def get_hero!(identity, id) do
    Repo.get_by!(Hero, identity_id: identity.id, id: id)
  end

  @doc """
  Creates a hero.

  ## Examples

      iex> create_hero(%{field: value})
      {:ok, %Hero{}}

      iex> create_hero(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hero(attrs \\ %{}) do
    %Hero{}
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

  alias Celestial.Galaxy.World

  @doc """
  Returns the list of worlds.

  ## Examples

      iex> list_worlds()
      [%World{}, ...]

  """
  def list_worlds do
    Repo.all(World)
  end

  @doc """
  Gets a single world.

  Raises `Ecto.NoResultsError` if the World does not exist.

  ## Examples

      iex> get_world!(123)
      %World{}

      iex> get_world!(456)
      ** (Ecto.NoResultsError)

  """
  def get_world!(id), do: Repo.get!(World, id)

  @doc """
  Creates a world.

  ## Examples

      iex> create_world(%{field: value})
      {:ok, %World{}}

      iex> create_world(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_world(attrs \\ %{}) do
    %World{}
    |> World.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a world.

  ## Examples

      iex> update_world(world, %{field: new_value})
      {:ok, %World{}}

      iex> update_world(world, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_world(%World{} = world, attrs) do
    world
    |> World.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a world.

  ## Examples

      iex> delete_world(world)
      {:ok, %World{}}

      iex> delete_world(world)
      {:error, %Ecto.Changeset{}}

  """
  def delete_world(%World{} = world) do
    Repo.delete(world)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking world changes.

  ## Examples

      iex> change_world(world)
      %Ecto.Changeset{data: %World{}}

  """
  def change_world(%World{} = world, attrs \\ %{}) do
    World.changeset(world, attrs)
  end
end

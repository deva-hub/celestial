defmodule Celestial.Metaverse do
  @moduledoc """
  The Metaverse context.
  """

  import Ecto.Query, warn: false
  alias Celestial.Repo

  alias Celestial.Metaverse.{Slot, Character}

  @doc """
  Returns the list of slots.

  ## Examples

      iex> list_slots()
      [%Character{}, ...]

  """
  def list_slots(identity) do
    Repo.all(Slot.identity_query(identity))
  end

  @doc """
  Gets a single character by slot.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_slot_by_index!(%Identity{}, 123)
      %Character{}

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
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      [%Character{}, ...]

  """
  def list_characters do
    Repo.all(Character)
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!(123)
      %Character{}

      iex> get_character!(456)
      ** (Ecto.NoResultsError)

  """
  def get_character!(id) do
    Repo.get!(Character, id)
  end

  def get_character!(identity, id) do
    Repo.get_by!(Character, identity_id: identity.id, id: id)
  end

  @doc """
  Creates a character.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  alias Celestial.Metaverse.World

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

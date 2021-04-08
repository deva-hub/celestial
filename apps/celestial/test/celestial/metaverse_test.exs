defmodule Celestial.WorldTest do
  use Celestial.DataCase

  alias Celestial.Metaverse

  describe "characters" do
    alias Celestial.Metaverse.Character

    @valid_attrs %{
      class: "some class",
      hair_color: "some hair_color",
      hair_style: "some hair_style",
      hero_level: 42,
      hero_xp: 42,
      job_level: 42,
      job_xp: 42,
      level: 42,
      name: "some name",
      index: 42,
      xp: 42
    }
    @update_attrs %{
      class: "some updated class",
      hair_color: "some updated hair_color",
      hair_style: "some updated hair_style",
      hero_level: 43,
      hero_xp: 43,
      job_level: 43,
      job_xp: 43,
      level: 43,
      name: "some updated name",
      index: 43,
      xp: 43
    }
    @invalid_attrs %{class: nil, hair_color: nil, hair_style: nil, hero_level: nil, hero_xp: nil, job_level: nil, job_xp: nil, level: nil, name: nil, index: nil, xp: nil}

    def character_fixture(attrs \\ %{}) do
      {:ok, character} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Metaverse.create_character()

      character
    end

    test "list_characters/0 returns all characters" do
      character = character_fixture()
      assert Metaverse.list_characters() == [character]
    end

    test "get_character!/1 returns the character with given id" do
      character = character_fixture()
      assert Metaverse.get_character!(character.id) == character
    end

    test "create_character/1 with valid data creates a character" do
      assert {:ok, %Character{} = character} = Metaverse.create_character(@valid_attrs)
      assert character.class == "some class"
      assert character.hair_color == "some hair_color"
      assert character.hair_style == "some hair_style"
      assert character.hero_level == 42
      assert character.hero_xp == 42
      assert character.job_level == 42
      assert character.job_xp == 42
      assert character.level == 42
      assert character.name == "some name"
      assert character.xp == 42
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metaverse.create_character(@invalid_attrs)
    end

    test "update_character/2 with valid data updates the character" do
      character = character_fixture()
      assert {:ok, %Character{} = character} = Metaverse.update_character(character, @update_attrs)
      assert character.class == "some updated class"
      assert character.hair_color == "some updated hair_color"
      assert character.hair_style == "some updated hair_style"
      assert character.hero_level == 43
      assert character.hero_xp == 43
      assert character.job_level == 43
      assert character.job_xp == 43
      assert character.level == 43
      assert character.name == "some updated name"
      assert character.xp == 43
    end

    test "update_character/2 with invalid data returns error changeset" do
      character = character_fixture()
      assert {:error, %Ecto.Changeset{}} = Metaverse.update_character(character, @invalid_attrs)
      assert character == Metaverse.get_character!(character.id)
    end

    test "delete_character/1 deletes the character" do
      character = character_fixture()
      assert {:ok, %Character{}} = Metaverse.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Metaverse.get_character!(character.id) end
    end

    test "change_character/1 returns a character changeset" do
      character = character_fixture()
      assert %Ecto.Changeset{} = Metaverse.change_character(character)
    end
  end

  describe "worlds" do
    alias Celestial.Metaverse.World

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def world_fixture(attrs \\ %{}) do
      {:ok, world} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Metaverse.create_world()

      world
    end

    test "list_worlds/0 returns all worlds" do
      world = world_fixture()
      assert Metaverse.list_worlds() == [world]
    end

    test "get_world!/1 returns the world with given id" do
      world = world_fixture()
      assert Metaverse.get_world!(world.id) == world
    end

    test "create_world/1 with valid data creates a world" do
      assert {:ok, %World{} = world} = Metaverse.create_world(@valid_attrs)
      assert world.name == "some name"
    end

    test "create_world/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metaverse.create_world(@invalid_attrs)
    end

    test "update_world/2 with valid data updates the world" do
      world = world_fixture()
      assert {:ok, %World{} = world} = Metaverse.update_world(world, @update_attrs)
      assert world.name == "some updated name"
    end

    test "update_world/2 with invalid data returns error changeset" do
      world = world_fixture()
      assert {:error, %Ecto.Changeset{}} = Metaverse.update_world(world, @invalid_attrs)
      assert world == Metaverse.get_world!(world.id)
    end

    test "delete_world/1 deletes the world" do
      world = world_fixture()
      assert {:ok, %World{}} = Metaverse.delete_world(world)
      assert_raise Ecto.NoResultsError, fn -> Metaverse.get_world!(world.id) end
    end

    test "change_world/1 returns a world changeset" do
      world = world_fixture()
      assert %Ecto.Changeset{} = Metaverse.change_world(world)
    end
  end
end

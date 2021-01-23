defmodule Celestial.WorldTest do
  use Celestial.DataCase

  alias Celestial.Galaxy

  describe "heroes" do
    alias Celestial.Galaxy.Hero

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

    def hero_fixture(attrs \\ %{}) do
      {:ok, hero} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Galaxy.create_hero()

      hero
    end

    test "list_heroes/0 returns all heroes" do
      hero = hero_fixture()
      assert Galaxy.list_heroes() == [hero]
    end

    test "get_hero!/1 returns the hero with given id" do
      hero = hero_fixture()
      assert Galaxy.get_hero!(hero.id) == hero
    end

    test "create_hero/1 with valid data creates a hero" do
      assert {:ok, %Hero{} = hero} = Galaxy.create_hero(@valid_attrs)
      assert hero.class == "some class"
      assert hero.hair_color == "some hair_color"
      assert hero.hair_style == "some hair_style"
      assert hero.hero_level == 42
      assert hero.hero_xp == 42
      assert hero.job_level == 42
      assert hero.job_xp == 42
      assert hero.level == 42
      assert hero.name == "some name"
      assert hero.xp == 42
    end

    test "create_hero/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Galaxy.create_hero(@invalid_attrs)
    end

    test "update_hero/2 with valid data updates the hero" do
      hero = hero_fixture()
      assert {:ok, %Hero{} = hero} = Galaxy.update_hero(hero, @update_attrs)
      assert hero.class == "some updated class"
      assert hero.hair_color == "some updated hair_color"
      assert hero.hair_style == "some updated hair_style"
      assert hero.hero_level == 43
      assert hero.hero_xp == 43
      assert hero.job_level == 43
      assert hero.job_xp == 43
      assert hero.level == 43
      assert hero.name == "some updated name"
      assert hero.xp == 43
    end

    test "update_hero/2 with invalid data returns error changeset" do
      hero = hero_fixture()
      assert {:error, %Ecto.Changeset{}} = Galaxy.update_hero(hero, @invalid_attrs)
      assert hero == Galaxy.get_hero!(hero.id)
    end

    test "delete_hero/1 deletes the hero" do
      hero = hero_fixture()
      assert {:ok, %Hero{}} = Galaxy.delete_hero(hero)
      assert_raise Ecto.NoResultsError, fn -> Galaxy.get_hero!(hero.id) end
    end

    test "change_hero/1 returns a hero changeset" do
      hero = hero_fixture()
      assert %Ecto.Changeset{} = Galaxy.change_hero(hero)
    end
  end

  describe "worlds" do
    alias Celestial.Galaxy.World

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def world_fixture(attrs \\ %{}) do
      {:ok, world} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Galaxy.create_world()

      world
    end

    test "list_worlds/0 returns all worlds" do
      world = world_fixture()
      assert Galaxy.list_worlds() == [world]
    end

    test "get_world!/1 returns the world with given id" do
      world = world_fixture()
      assert Galaxy.get_world!(world.id) == world
    end

    test "create_world/1 with valid data creates a world" do
      assert {:ok, %World{} = world} = Galaxy.create_world(@valid_attrs)
      assert world.name == "some name"
    end

    test "create_world/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Galaxy.create_world(@invalid_attrs)
    end

    test "update_world/2 with valid data updates the world" do
      world = world_fixture()
      assert {:ok, %World{} = world} = Galaxy.update_world(world, @update_attrs)
      assert world.name == "some updated name"
    end

    test "update_world/2 with invalid data returns error changeset" do
      world = world_fixture()
      assert {:error, %Ecto.Changeset{}} = Galaxy.update_world(world, @invalid_attrs)
      assert world == Galaxy.get_world!(world.id)
    end

    test "delete_world/1 deletes the world" do
      world = world_fixture()
      assert {:ok, %World{}} = Galaxy.delete_world(world)
      assert_raise Ecto.NoResultsError, fn -> Galaxy.get_world!(world.id) end
    end

    test "change_world/1 returns a world changeset" do
      world = world_fixture()
      assert %Ecto.Changeset{} = Galaxy.change_world(world)
    end
  end
end

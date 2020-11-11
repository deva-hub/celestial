defmodule Celestial.WorldTest do
  use Celestial.DataCase

  alias Celestial.World

  describe "heroes" do
    alias Celestial.World.Hero

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
      slot: 42,
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
      slot: 43,
      xp: 43
    }
    @invalid_attrs %{class: nil, hair_color: nil, hair_style: nil, hero_level: nil, hero_xp: nil, job_level: nil, job_xp: nil, level: nil, name: nil, slot: nil, xp: nil}

    def hero_fixture(attrs \\ %{}) do
      {:ok, hero} =
        attrs
        |> Enum.into(@valid_attrs)
        |> World.create_hero()

      hero
    end

    test "list_heroes/0 returns all heroes" do
      hero = hero_fixture()
      assert World.list_heroes() == [hero]
    end

    test "get_hero!/1 returns the hero with given id" do
      hero = hero_fixture()
      assert World.get_hero!(hero.id) == hero
    end

    test "create_hero/1 with valid data creates a hero" do
      assert {:ok, %Hero{} = hero} = World.create_hero(@valid_attrs)
      assert hero.class == "some class"
      assert hero.hair_color == "some hair_color"
      assert hero.hair_style == "some hair_style"
      assert hero.hero_level == 42
      assert hero.hero_xp == 42
      assert hero.job_level == 42
      assert hero.job_xp == 42
      assert hero.level == 42
      assert hero.name == "some name"
      assert hero.slot == 42
      assert hero.xp == 42
    end

    test "create_hero/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = World.create_hero(@invalid_attrs)
    end

    test "update_hero/2 with valid data updates the hero" do
      hero = hero_fixture()
      assert {:ok, %Hero{} = hero} = World.update_hero(hero, @update_attrs)
      assert hero.class == "some updated class"
      assert hero.hair_color == "some updated hair_color"
      assert hero.hair_style == "some updated hair_style"
      assert hero.hero_level == 43
      assert hero.hero_xp == 43
      assert hero.job_level == 43
      assert hero.job_xp == 43
      assert hero.level == 43
      assert hero.name == "some updated name"
      assert hero.slot == 43
      assert hero.xp == 43
    end

    test "update_hero/2 with invalid data returns error changeset" do
      hero = hero_fixture()
      assert {:error, %Ecto.Changeset{}} = World.update_hero(hero, @invalid_attrs)
      assert hero == World.get_hero!(hero.id)
    end

    test "delete_hero/1 deletes the hero" do
      hero = hero_fixture()
      assert {:ok, %Hero{}} = World.delete_hero(hero)
      assert_raise Ecto.NoResultsError, fn -> World.get_hero!(hero.id) end
    end

    test "change_hero/1 returns a hero changeset" do
      hero = hero_fixture()
      assert %Ecto.Changeset{} = World.change_hero(hero)
    end
  end
end

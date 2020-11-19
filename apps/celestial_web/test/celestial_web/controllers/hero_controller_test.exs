defmodule CelestialWeb.HeroControllerTest do
  use CelestialWeb.ConnCase

  alias Celestial.Universe
  alias Celestial.Universe.Hero

  @create_attrs %{
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

  def fixture(:hero) do
    {:ok, hero} = Universe.create_hero(@create_attrs)
    hero
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all heroes", %{conn: conn} do
      conn = get(conn, Routes.hero_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create hero" do
    test "renders hero when data is valid", %{conn: conn} do
      conn = post(conn, Routes.hero_path(conn, :create), hero: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.hero_path(conn, :show, id))

      assert %{
               "id" => id,
               "class" => "some class",
               "hair_color" => "some hair_color",
               "hair_style" => "some hair_style",
               "hero_level" => 42,
               "hero_xp" => 42,
               "job_level" => 42,
               "job_xp" => 42,
               "level" => 42,
               "name" => "some name",
               "slot" => 42,
               "xp" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.hero_path(conn, :create), hero: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update hero" do
    setup [:create_hero]

    test "renders hero when data is valid", %{conn: conn, hero: %Hero{id: id} = hero} do
      conn = put(conn, Routes.hero_path(conn, :update, hero), hero: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.hero_path(conn, :show, id))

      assert %{
               "id" => id,
               "class" => "some updated class",
               "hair_color" => "some updated hair_color",
               "hair_style" => "some updated hair_style",
               "hero_level" => 43,
               "hero_xp" => 43,
               "job_level" => 43,
               "job_xp" => 43,
               "level" => 43,
               "name" => "some updated name",
               "slot" => 43,
               "xp" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, hero: hero} do
      conn = put(conn, Routes.hero_path(conn, :update, hero), hero: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete hero" do
    setup [:create_hero]

    test "deletes chosen hero", %{conn: conn, hero: hero} do
      conn = delete(conn, Routes.hero_path(conn, :delete, hero))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.hero_path(conn, :show, hero))
      end
    end
  end

  defp create_hero(_) do
    hero = fixture(:hero)
    %{hero: hero}
  end
end

defmodule CelestialWeb.CharacterControllerTest do
  use CelestialWeb.ConnCase

  alias Celestial.Metaverse
  alias Celestial.Metaverse.Character

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

  def fixture(:character) do
    {:ok, character} = Metaverse.create_character(@create_attrs)
    character
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all characters", %{conn: conn} do
      conn = get(conn, Routes.character_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create character" do
    test "renders character when data is valid", %{conn: conn} do
      conn = post(conn, Routes.character_path(conn, :create), character: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.character_path(conn, :show, id))

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
               "index" => 42,
               "xp" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.character_path(conn, :create), character: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update character" do
    setup [:create_character]

    test "renders character when data is valid", %{conn: conn, character: %Character{id: id} = character} do
      conn = put(conn, Routes.character_path(conn, :update, character), character: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.character_path(conn, :show, id))

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
               "index" => 43,
               "xp" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, character: character} do
      conn = put(conn, Routes.character_path(conn, :update, character), character: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete character" do
    setup [:create_character]

    test "deletes chosen character", %{conn: conn, character: character} do
      conn = delete(conn, Routes.character_path(conn, :delete, character))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.character_path(conn, :show, character))
      end
    end
  end

  defp create_character(_) do
    character = fixture(:character)
    %{character: character}
  end
end

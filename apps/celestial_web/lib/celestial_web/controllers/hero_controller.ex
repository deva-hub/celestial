defmodule CelestialWeb.HeroController do
  use CelestialWeb, :controller

  alias Celestial.World
  alias Celestial.World.Hero

  action_fallback CelestialWeb.FallbackController

  def index(conn, _params) do
    heroes = World.list_heroes()
    render(conn, "index.json", heroes: heroes)
  end

  def create(conn, %{"hero" => hero_params}) do
    with {:ok, %Hero{} = hero} <- World.create_hero(hero_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.hero_path(conn, :show, hero))
      |> render("show.json", hero: hero)
    end
  end

  def show(conn, %{"id" => id}) do
    hero = World.get_hero!(id)
    render(conn, "show.json", hero: hero)
  end

  def update(conn, %{"id" => id, "hero" => hero_params}) do
    hero = World.get_hero!(id)

    with {:ok, %Hero{} = hero} <- World.update_hero(hero, hero_params) do
      render(conn, "show.json", hero: hero)
    end
  end

  def delete(conn, %{"id" => id}) do
    hero = World.get_hero!(id)

    with {:ok, %Hero{}} <- World.delete_hero(hero) do
      send_resp(conn, :no_content, "")
    end
  end
end

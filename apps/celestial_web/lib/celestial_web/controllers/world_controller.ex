defmodule CelestialWeb.WorldController do
  use CelestialWeb, :controller

  alias Celestial.Universe
  alias Celestial.Universe.World

  action_fallback CelestialWeb.FallbackController

  def index(conn, _params) do
    worlds = Universe.list_worlds()
    render(conn, "index.json", worlds: worlds)
  end

  def create(conn, %{"world" => world_params}) do
    with {:ok, %World{} = world} <- Universe.create_world(world_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.world_path(conn, :show, world))
      |> render("show.json", world: world)
    end
  end

  def show(conn, %{"id" => id}) do
    world = Universe.get_world!(id)
    render(conn, "show.json", world: world)
  end

  def update(conn, %{"id" => id, "world" => world_params}) do
    world = Universe.get_world!(id)

    with {:ok, %World{} = world} <- Universe.update_world(world, world_params) do
      render(conn, "show.json", world: world)
    end
  end

  def delete(conn, %{"id" => id}) do
    world = Universe.get_world!(id)

    with {:ok, %World{}} <- Universe.delete_world(world) do
      send_resp(conn, :no_content, "")
    end
  end
end

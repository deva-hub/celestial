defmodule CelestialWeb.AccessView do
  use CelestialWeb, :view
  alias CelestialWeb.AccessView

  def render("index.json", %{accesses: accesses}) do
    %{data: render_many(accesses, AccessView, "access.json")}
  end

  def render("show.json", %{access: access}) do
    %{data: render_one(access, AccessView, "access.json")}
  end

  def render("access.json", %{access: access}) do
    %{token: access.token}
  end
end

defmodule CelestialWeb.IdentityView do
  use CelestialWeb, :view
  alias CelestialWeb.IdentityView

  def render("index.json", %{identitys: identitys}) do
    %{data: render_many(identitys, IdentityView, "identity.json")}
  end

  def render("show.json", %{identity: identity}) do
    %{data: render_one(identity, IdentityView, "identity.json")}
  end

  def render("identity.json", %{identity: identity}) do
    %{id: identity.id}
  end
end

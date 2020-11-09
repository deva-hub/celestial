defmodule CelestialWeb.IdentityAccessView do
  use CelestialWeb, :view
  alias CelestialWeb.IdentityAccessView

  def render("index.json", %{identity_accesses: identity_accesses}) do
    %{data: render_many(identity_accesses, IdentityAccessView, "identity_access.json")}
  end

  def render("show.json", %{identity_access: identity_access}) do
    %{data: render_one(identity_access, IdentityAccessView, "identity_access.json")}
  end

  def render("identity_access.json", %{identity_access: identity_access}) do
    %{token: identity_access.token}
  end
end

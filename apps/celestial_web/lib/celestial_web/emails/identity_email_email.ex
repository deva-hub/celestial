defmodule CelestialWeb.IdentityEmailEmail do
  use Phoenix.Swoosh,
    view: CelestialWeb.IdentityEmailView,
    layout: {CelestialWeb.LayoutView, :email}

  alias CelestialWeb.Endpoint

  def new(identity, url) do
    new()
    |> to(identity.email)
    |> from({"Celestial", Enum.join(["noreply@", Endpoint.url()])})
    |> subject("Email change request")
    |> render_body("email.html", %{identity: identity, url: url})
  end
end

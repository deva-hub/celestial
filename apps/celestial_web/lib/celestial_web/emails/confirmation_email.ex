defmodule CelestialWeb.ConfirmationEmail do
  use Phoenix.Swoosh,
    view: CelestialWeb.ConfirmationView,
    layout: {CelestialWeb.LayoutView, :email}

  alias CelestialWeb.Endpoint

  def new(identity, url) do
    new()
    |> to(identity.email)
    |> from({"Celestial", Enum.join(["noreply@", Endpoint.url()])})
    |> subject("Welcome to Nowver!")
    |> render_body("email.html", %{identity: identity, url: url})
  end
end

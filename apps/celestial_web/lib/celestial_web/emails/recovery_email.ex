defmodule CelestialWeb.RecoveryEmail do
  @moduledoc false
  use Phoenix.Swoosh,
    view: CelestialWeb.RecoveryView,
    layout: {CelestialWeb.LayoutView, :email}

  alias CelestialWeb.Endpoint

  def new(identity, url) do
    new()
    |> to(identity.email)
    |> from({"Celestial", Enum.join(["noreply@", Endpoint.url()])})
    |> subject("Password reset request")
    |> render_body("email.html", %{identity: identity, url: url})
  end
end

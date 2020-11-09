defmodule CelestialWeb.Router do
  use CelestialWeb, :router

  import CelestialWeb.IdentityAuth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_identity
  end

  scope "/api", CelestialWeb do
    pipe_through :api
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: CelestialWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", CelestialWeb do
    pipe_through [:api]

    post "/accesses", IdentityAccessController, :create
    post "/identities", IdentityController, :create
    post "/confirmations", IdentityConfirmationController, :create
    get "/confirmations/:token", IdentityConfirmationController, :edit
    put "/confirmations/:token", IdentityConfirmationController, :update
    post "/recoveries", IdentityRecoveryController, :create
    get "/recoveries/:token", IdentityRecoveryController, :edit
    put "/recoveries/:token", IdentityRecoveryController, :update
  end

  scope "/", CelestialWeb do
    pipe_through [:api, :require_authenticated_identity]

    delete "/accesses/:token", IdentityAccessController, :delete
    get "/identities", IdentityController, :index
    get "/identities/:id", IdentityController, :show
    put "/identities/:id/password", IdentityPasswordController, :update
    post "/identities/:id/email", IdentityEmailController, :create
    get "/identities/:id/email/:token", IdentityEmailController, :edit
    put "/identities/:id/email/:token", IdentityEmailController, :update
  end
end

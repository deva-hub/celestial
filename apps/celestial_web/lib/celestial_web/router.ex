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

    resources "/accesses", AccessController, only: [:create]
    resources "/identities", IdentityController, only: [:create]
    resources "/confirmations", ConfirmationController, only: [:create]
    get "/confirmations/:token", ConfirmationController, :edit
    put "/confirmations/:token", ConfirmationController, :update
    patch "/confirmations/:token", ConfirmationController, :update
    resources "/recoveries", RecoveryController, only: [:create]
    get "/recoveries/:token", RecoveryController, :edit
    put "/recoveries/:token", RecoveryController, :update
    patch "/recoveries/:token", RecoveryController, :update
  end

  scope "/", CelestialWeb do
    pipe_through [:api, :require_authenticated_identity]

    delete "/accesses/:token", AccessController, :delete

    resources "/identities", IdentityController, only: [:index, :show] do
      put "/password", PasswordController, :update
      patch "/password", PasswordController, :update
      post "/migration", MigrationController, :create
      get "/migration/:token", MigrationController, :edit
      put "/migration/:token", MigrationController, :update
      patch "/migration/:token", MigrationController, :update
    end

    resources "/heroes", HeroController, except: [:new, :edit]
    resources "/worlds", WorldController, except: [:new, :edit]
  end
end

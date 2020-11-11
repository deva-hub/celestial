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

    resources "/accesses", IdentityAccessController, only: [:create]
    resources "/identities", IdentityController, only: [:create]
    resources "/confirmations", IdentityConfirmationController, only: [:create]
    get "/confirmations/:token", IdentityConfirmationController, :edit
    put "/confirmations/:token", IdentityConfirmationController, :update
    patch "/confirmations/:token", IdentityConfirmationController, :update
    resources "/recoveries", IdentityRecoveryController, only: [:create]
    get "/recoveries/:token", IdentityRecoveryController, :edit
    put "/recoveries/:token", IdentityRecoveryController, :update
    patch "/recoveries/:token", IdentityRecoveryController, :update
  end

  scope "/", CelestialWeb do
    pipe_through [:api, :require_authenticated_identity]

    delete "/accesses/:token", IdentityAccessController, :delete

    resources "/identities", IdentityController, only: [:index, :show] do
      put "/password", IdentityPasswordController, :update
      patch "/password", IdentityPasswordController, :update
      put "/email", IdentityEmailController, :update
      patch "/email", IdentityEmailController, :update
      get "/email/:token", IdentityEmailController, :edit
      put "/email/:token", IdentityEmailController, :confirm
      patch "/email/:token", IdentityEmailController, :confirm
    end
  end
end

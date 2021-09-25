defmodule Celestial.Repo do
  use Ecto.Repo,
    otp_app: :celestial,
    adapter: Ecto.Adapters.Postgres
end

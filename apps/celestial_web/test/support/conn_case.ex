defmodule CelestialWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use CelestialWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import CelestialWeb.ConnCase

      alias CelestialWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint CelestialWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Celestial.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Celestial.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in identities.

      setup :register_and_sign_in_identity

  It stores an updated connection and a registered identity in the
  test context.
  """
  def register_and_sign_in_identity(%{conn: conn}) do
    identity = Celestial.AccountsFixtures.identity_fixture()
    %{conn: sign_in_identity(conn, identity), identity: identity}
  end

  @doc """
  Logs the given `identity` into the `conn`.

  It returns an updated `conn`.
  """
  def sign_in_identity(conn, identity) do
    identity_token = Celestial.Accounts.generate_identity_access_token(identity)
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{identity_token}")
  end
end

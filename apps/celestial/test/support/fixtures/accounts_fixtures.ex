defmodule Celestial.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Celestial.Accounts` context.
  """

  def unique_identity_email, do: "identity#{System.unique_integer()}@example.com"
  def valid_identity_password, do: "hello world!"

  def identity_fixture(attrs \\ %{}) do
    {:ok, identity} =
      attrs
      |> Enum.into(%{
        email: unique_identity_email(),
        password: valid_identity_password()
      })
      |> Celestial.Accounts.register_identity()

    identity
  end
end

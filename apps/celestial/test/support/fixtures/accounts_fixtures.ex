defmodule Celestial.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Celestial.Accounts` context.
  """

  def unique_identity_username, do: "identity#{System.unique_integer()}"
  def valid_identity_password, do: "hello world!"

  def identity_fixture(attrs \\ %{}) do
    {:ok, identity} =
      attrs
      |> Enum.into(%{
        username: unique_identity_username(),
        password: valid_identity_password()
      })
      |> Celestial.Accounts.create_identity()

    identity
  end
end

defmodule Celestial.Repo.Migrations.CreateIdentitiesAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:identities) do
      add :username, :citext, null: false
      add :hashed_password, :string, null: false
      timestamps()
    end

    create unique_index(:identities, [:username])

    create table(:identities_tokens) do
      add :identity_id, references(:identities, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:identities_tokens, [:identity_id])
    create unique_index(:identities_tokens, [:context, :token])
  end
end

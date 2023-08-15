defmodule PhxSolid.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    create_if_not_exists table("users") do
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:users, [:email])

    create_if_not_exists table("users_tokens") do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    create_if_not_exists table("counter") do
      add(:count, :integer)
      add :logs, :integer, default: 1
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end
  end
end

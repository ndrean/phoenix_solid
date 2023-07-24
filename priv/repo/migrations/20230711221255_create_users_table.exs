defmodule PhxSolid.Repo.Migrations.CreateSocialUsersTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table("social_users") do
      add :email, :string
      add :name, :string
      add :logs, :integer, default: 1
      add :user_token, :string

      timestamps()
    end

    create unique_index("social_users", [:email])
  end
end

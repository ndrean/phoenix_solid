defmodule PhxSolid.Repo.Migrations.CreateCounterTable do
  use Ecto.Migration

  def change do
    create table(:counter) do
      add(:count, :integer)
      timestamps()
    end
  end
end

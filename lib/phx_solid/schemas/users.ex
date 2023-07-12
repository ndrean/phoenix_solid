defmodule PhxSolid.User do
  use Ecto.Schema
  # import Ecto.Changeset
  alias PhxSolid.{Repo, User}

  schema "users" do
    field :email, :string
    field :name, :string
    field(:logs, :integer)
    timestamps()
  end

  # def changeset(%User{} = user, attrs \\ %{}) do
  #   user
  #   |> Ecto.Changeset.cast(attrs, [:email, :name])
  #   |> validate_required([:email, :name])
  #   |> unique_constraint(:email)
  # end

  def create(%{email: email, name: name}) do
    Repo.insert!(
      %User{email: email, name: name, logs: 1},
      conflict_target: [:email],
      on_conflict: [
        inc: [logs: 1],
        set: [updated_at: DateTime.utc_now()]
      ]
    )
  end
end

defmodule PhxSolid.Counter do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias PhxSolid.{Repo, Counter, Accounts.User}

  @moduledoc """
  Ecto wrapper for the table "counter"
  """

  schema "counter" do
    field :count, :integer
    belongs_to :user, PhxSolid.Accounts.User

    timestamps()
  end

  def changeset(%Counter{} = count, params \\ %{}) do
    count
    |> Ecto.Changeset.cast(params, [:count, :user_id])
    |> validate_required([:count, :user_id])
  end

  def update_counter_by_one(user_id) do
    user = Repo.get!(User, user_id)

    counter =
      from(c in Counter, where: c.user_id == ^user_id)
      |> Repo.one()

    case counter do
      nil ->
        %Counter{}
        |> Counter.changeset(%{count: 1, user_id: user.id})
        |> Repo.insert!()

      _ ->
        counter
        |> Counter.changeset(%{count: counter.count + 1})
        |> Repo.update!()
    end

    counter.count
  end
end

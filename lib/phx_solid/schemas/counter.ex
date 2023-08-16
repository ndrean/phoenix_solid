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
    Repo.transaction(fn ->
      user = get_user(user_id)
      update_counter(user)
    end)
  end

  defp get_user(user_id) do
    Repo.get!(User, user_id)
  end

  defp update_counter(user) do
    counter =
      from(c in Counter, where: c.user_id == ^user.id)
      |> Repo.one()

    new_counter_data =
      case counter do
        nil ->
          %{count: 1, user_id: user.id}

        _ ->
          %{count: counter.count + 1}
      end

    counter
    |> Counter.changeset(new_counter_data)
    |> Repo.insert_or_update!()
    |> Map.get(:count)
  end
end

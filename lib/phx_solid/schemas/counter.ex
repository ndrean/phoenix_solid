defmodule PhxSolid.Counter do
  use Ecto.Schema
  alias PhxSolid.{Repo, Counter}

  @moduledoc """
  Ecto wrapper for "users"
  """

  schema "counter" do
    field :count, :integer
    timestamps()
  end

  def changeset(%Counter{} = count, params) do
    Ecto.Changeset.cast(count, params, [:count])
  end

  def update() do
    {:ok, %{count: count}} =
      case Repo.one(Counter) do
        nil -> {%Counter{}, 0}
        c -> {c, c.count}
      end
      |> then(fn {count, val} ->
        count
        |> changeset(%{count: val + 1})
        |> Repo.insert_or_update()
      end)

    count
  end

  def get() do
    Repo
  end
end

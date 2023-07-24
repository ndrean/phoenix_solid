defmodule PhxSolid.Counter do
  use Ecto.Schema
  alias PhxSolid.{Repo, Counter}

  @moduledoc """
  Ecto wrapper for the singleton table "counter"
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
        nil ->
          %Counter{}
          |> changeset(%{count: 1})
          |> Repo.insert_or_update()

        counter ->
          counter
          |> changeset(%{count: counter.count + 1})
          |> Repo.insert_or_update()
      end

    count
  end
end

defmodule PhxSolid.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias PhxSolid.{Repo, User}

  @moduledoc """
  Ecto wrapper for "users"
  """

  schema "users" do
    field :email, :string
    field :name, :string
    field(:logs, :integer)
    field(:user_token, :string)
    timestamps()
  end

  @doc """
  validate user has both :email and :name and than :email is unique
  """
  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:email, :name, :user_token])
    |> Ecto.Changeset.validate_required([:email, :name])
    |> unique_constraint(:email)
  end

  @doc """
  ## Example

      iex> PhxSolid.User.create(%{email: "toto", name: "toto})
      {:ok, %User{}} || {:error, changeset.errors}
  """
  def create(params) do
    changeset = changeset(%User{}, params)

    case Repo.insert(changeset,
           conflict_target: [:email],
           on_conflict: [
             inc: [logs: 1],
             set: [updated_at: DateTime.utc_now()]
           ]
         ) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end

  @doc """
  Using a changeset is **mandatory** for _update_.
  ## Example

      iex> PhsSlid.update_token(%{id: 1, user_token: "aze"})
      {:ok, user} || {error, changeset.error}
  """
  def update_token(%{id: id, user_token: token}) do
    case Repo.get_by(User, id: id) do
      nil ->
        {:error, :not_found}

      user ->
        changeset = PhxSolid.User.changeset(user, %{user_token: token})

        case Repo.update(changeset) do
          {:ok, user} -> {:ok, user}
          {:error, changeset} -> {:error, changeset.errors}
        end
    end
  end

  @doc """
  Check that the database contains a value
  ## Example

      iex> PhxSolid.get(:token, "toto_token", :email)
      {:ok, "toto"} || {:error, "no entry"}
  """
  def check(key1, val, key2) do
    user = Repo.get_by(User, %{key1 => val})

    case user do
      nil ->
        {:error, :not_found}

      user ->
        case Map.get(user, key2, nil) do
          nil -> {:error, :not_found}
          _ -> {:ok, user}
        end
    end
  end
end

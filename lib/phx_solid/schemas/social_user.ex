defmodule PhxSolid.SocialUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias PhxSolid.{Repo, SocialUser}

  @moduledoc """
  Ecto wrapper for "social_users"
  """

  schema "social_users" do
    field :email, :string
    field :name, :string
    field(:logs, :integer)
    field(:user_token, :string)
    timestamps()
  end

  @doc """
  validate user has both :email and :name and than :email is unique
  """
  def changeset(%SocialUser{} = social_user, params \\ %{}) do
    social_user
    |> Ecto.Changeset.cast(params, [:email, :name, :user_token])
    |> Ecto.Changeset.validate_required([:email, :name, :user_token])
    |> unique_constraint(:email)
  end

  @doc """
  ## Example

      iex> PhxSolid.User.create(%{email: "toto", name: "toto})
      {:ok, %User{}} || {:error, changeset.errors}
  """
  def create(params) do
    changeset = changeset(%SocialUser{}, params)

    case Repo.insert(changeset,
           conflict_target: [:email],
           on_conflict: [
             inc: [logs: 1],
             set: [updated_at: DateTime.utc_now()]
           ]
         ) do
      {:ok, social_user} -> {:ok, social_user}
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
    case Repo.get_by(SocialUser, id: id) do
      nil ->
        {:error, :not_found}

      social_user ->
        changeset = PhxSolid.SocialUser.changeset(social_user, %{user_token: token})

        case Repo.update(changeset) do
          {:ok, social_user} -> {:ok, social_user}
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
    social_user = Repo.get_by(SocialUser, %{key1 => val})

    case social_user do
      nil ->
        {:error, :not_found}

      social_user ->
        case Map.get(social_user, key2, nil) do
          nil -> {:error, :not_found}
          _ -> {:ok, social_user}
        end
    end
  end
end

defmodule PhxSolid.Repo do
  use Ecto.Repo,
    otp_app: :phx_solid,
    # adapter: Ecto.Adapters.SQLite3
    adapter: Ecto.Adapters.Postgres
end

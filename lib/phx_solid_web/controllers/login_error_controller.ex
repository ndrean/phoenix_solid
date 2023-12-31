defmodule PhxSolidWeb.LoginErrorController do
  # use Phoenix.Controller
  use PhxSolidWeb, :controller
  require Logger
  # don't "use Phoenix.Controller" if you want to use "Routes" helpers

  def call(conn, params) do
    Logger.warning("Got error during login #{inspect(params)}")

    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_flash(:error, inspect(params))
    |> redirect(to: ~p"/")
    |> halt()
  end
end

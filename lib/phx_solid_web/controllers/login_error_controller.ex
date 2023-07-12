defmodule PhxSolidWeb.LoginErrorController do
  # use Phoenix.Controller
  use PhxSolidWeb, :controller
  require Logger
  # don't "use Phoenix.Controller" if you want to use "Routes" helpers

  def call(conn, {:error, message}) do
    Logger.warning("Got error during login #{inspect(message)}")

    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_flash(:error, inspect(message))
    # |> put_view(PhxSolidWeb.PageView)
    |> redirect(to: ~p"/")
    |> halt()
  end
end

defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  def home(conn, _params) do
    IO.inspect(System.get_env("GOOGLE_CLIENT_ID"), label: "client_id")
    # The home page is often custom made, so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def welcome(conn, _) do
    profile = get_session(conn, :profile)
    user_token = get_session(conn, :user_token)

    conn
    |> assign(:user_token, user_token)
    |> render(:welcome, profile: profile)
  end
end

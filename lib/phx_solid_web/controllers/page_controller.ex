defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def welcome(conn, _) do
    profile = get_session(conn, :profile)
    user_token = get_session(conn, :user_token)

    process_info =
      %{
        node: node(),
        pid: inspect(self()),
        memory: div(:erlang.memory(:total), 1_000_000)
      }

    PhxSolidWeb.Endpoint.broadcast!("main_info", "update", %{process_info: process_info})

    conn
    |> assign(:user_token, user_token)
    |> render(:welcome, profile: profile)
  end
end

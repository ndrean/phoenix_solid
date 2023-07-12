defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  # def welcome(conn, _) do
  #   profile = get_session(conn, :profile)
  #   user_token = get_session(conn, :user_token)

  #   conn
  #   |> assign(:user_token, user_token)
  #   |> render(:welcome, profile: profile)
  # end
end

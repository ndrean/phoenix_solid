defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  @moduledoc """
  The landing page displays Google One Tap and Facebook connect to authenticate the user.
  We pass in the Google and Facebook credentials to the view ot execute the associated Javascript.
  """
  def home(conn, _params) do
    fb_app_id = System.get_env("FACEBOOK_APP_ID")
    g_client_id = System.get_env("GOOGLE_CLIENT_ID")

    conn
    |> assign(:fb_app_id, fb_app_id)
    |> assign(:g_client_id, g_client_id)
    |> render(:home)
  end
end

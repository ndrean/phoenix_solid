defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  @moduledoc """
  The landing page displays Google One Tap and Facebook connect to authenticate the user.
  We pass in the Google and Facebook credentials to the view ot execute the associated Javascript.
  """

  def home(conn, _params) do
    # for One Tap
    g_nonce = PhxSolid.gen_secret()
    # for SignIn
    g_state = PhxSolid.gen_secret()

    g_oauth_url =
      ElixirGoogleAuth.generate_oauth_url(PhxSolid.g_oauth_redirect_url(), g_state, %{hl: "fr"})

    conn
    |> fetch_session()
    |> put_session(:g_state, g_state)
    |> put_session(:g_nonce, g_nonce)
    |> assign(:fb_app_id, System.get_env("FACEBOOK_APP_ID"))
    |> assign(:g_client_id, System.get_env("GOOGLE_CLIENT_ID"))
    |> assign(:g_oauth_url, g_oauth_url)
    |> assign(:g_src_nonce, g_nonce)
    |> render(:home)
  end
end

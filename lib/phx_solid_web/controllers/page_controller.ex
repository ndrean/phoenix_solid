defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  @moduledoc """
  The landing page displays Google One Tap and Facebook connect to authenticate the user.
  We pass in the Google and Facebook credentials to the view ot execute the associated Javascript.
  """

  def home(conn, _params) do
    hostname =
      PhxSolidWeb.Endpoint.url()

    # for One Tap
    g_nonce = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

    # URL for One Tap
    location =
      Path.join(
        hostname,
        Application.get_application(__MODULE__) |> Application.get_env(:g_cb_uri)
      )

    # for SignIn
    g_state = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

    # URL for SignIn
    g_oauth_redirect_url =
      Path.join(
        hostname,
        Application.get_application(__MODULE__) |> Application.get_env(:g_auth_uri)
      )

    # redirect URL
    g_oauth_url =
      ElixirGoogleAuth.generate_oauth_url(g_oauth_redirect_url, g_state, %{hl: "it"})

    conn
    |> dbg()
    |> fetch_session()
    |> put_session(:g_state, g_state)
    |> put_session(:g_oauth_redirect_url, g_oauth_redirect_url)
    |> put_session(:g_nonce, g_nonce)
    |> assign(:fb_app_id, System.get_env("FACEBOOK_APP_ID"))
    |> assign(:g_client_id, System.get_env("GOOGLE_CLIENT_ID"))
    |> assign(:g_oauth_url, g_oauth_url)
    |> assign(:g_scr_nonce, g_nonce)
    |> assign(:location, location)
    |> render(:home)
  end
end

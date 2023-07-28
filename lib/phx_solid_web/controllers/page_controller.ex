defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  @moduledoc """
  The landing page displays Google One Tap and Facebook connect to authenticate the user.
  We pass in the Google and Facebook credentials to the view ot execute the associated Javascript.
  """

  def home(conn, _params) do
    cb_url_one_tap =
      Path.join(
        PhxSolidWeb.Endpoint.url(),
        Application.get_application(__MODULE__) |> Application.get_env(:g_certs_cb_path)
      )

    g_state = Base.url_encode64(:crypto.strong_rand_bytes(32))
    g_oauth_url = ElixirGoogleAuth.generate_oauth_url(g_state)

    conn
    |> fetch_session()
    |> put_session(:g_state, g_state)
    |> assign(:fb_app_id, System.get_env("FACEBOOK_APP_ID"))
    |> assign(:g_client_id, System.get_env("GOOGLE_CLIENT_ID"))
    |> assign(:g_oauth_url, g_oauth_url)
    |> assign(:location, cb_url_one_tap)
    |> render(:home)
  end
end

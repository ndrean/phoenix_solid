defmodule PhxSolidWeb.OneTapController do
  use PhxSolidWeb, :controller
  action_fallback PhxSolidWeb.LoginErrorController
  require Logger

  def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
    with {:ok, profile} <- ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token) do
      %{email: email, name: _name, google_id: _sub, picture: _pic} = profile
      user_token = Phoenix.Token.sign(PhxSolidWeb.Endpoint, "user token", email)

      conn
      |> fetch_session()
      # |> fetch_flash()
      |> put_session(:user_token, user_token)
      # |> put_session(:user_id, user.id)
      |> put_session(:profile, profile)
      |> put_session(:origin, "google_sdk")
      # |> put_view(LiveMapWeb.WelcomeView)
      |> redirect(to: ~p"/welcome")
      |> halt()
    end
  end
end

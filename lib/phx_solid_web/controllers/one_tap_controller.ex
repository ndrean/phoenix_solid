defmodule PhxSolidWeb.OneTapController do
  use PhxSolidWeb, :controller
  action_fallback PhxSolidWeb.LoginErrorController
  require Logger

  def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
    with {:ok, profile} <-
           ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token, PhxSolid.Finch) do
      %{email: email, name: name} = profile

      %{id: id} = PhxSolid.User.create(%{email: email, name: name})

      user_token = PhxSolid.Token.user_generate(email)

      conn
      |> fetch_session()
      |> put_session(:user_token, user_token)
      # |> put_session(:user_id, user.id)
      |> put_session(:profile, profile)
      |> put_session(:origin, "google_sdk")
      |> redirect(to: ~p"/welcome")
    end
  end
end

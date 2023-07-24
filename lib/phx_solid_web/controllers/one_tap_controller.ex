defmodule PhxSolidWeb.OneTapController do
  use PhxSolidWeb, :controller
  action_fallback PhxSolidWeb.LoginErrorController
  alias PhxSolid.SocialUser
  require Logger

  def handle(conn, %{"credential" => jwt, "g_csrf_token" => g_csrf_token}) do
    with {:ok, %{email: email, name: name} = profile} <-
           ElixirGoogleCerts.verified_identity(conn, jwt, g_csrf_token, PhxSolid.Finch) do
      token = PhxSolid.Token.user_generate(email)

      case SocialUser.create(%{email: email, name: name}) do
        {:error, errors} ->
          conn
          |> fetch_session()
          |> fetch_flash()
          |> put_flash(:error, inspect(errors))
          |> redirect(to: ~p"/")

        {:ok, user} ->
          {:ok, u} = SocialUser.update_token(%{id: user.id, user_token: token})

          conn
          |> fetch_session()
          |> put_session(:user_token, token)
          |> put_session(:profile, profile)
          |> put_session(:logs, u.logs)
          |> put_session(:origin, "google_one_tap")
          |> redirect(to: ~p"/welcome")
      end
    end
  end
end

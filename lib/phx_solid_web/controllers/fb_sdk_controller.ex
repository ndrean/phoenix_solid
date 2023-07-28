defmodule PhxSolidWeb.FbSdkController do
  use PhxSolidWeb, :controller
  alias PhxSolid.SocialUser

  def login(conn, params) do
    %{"email" => email, "name" => name, "picture" => picture} = params

    case SocialUser.create(%{email: email, name: name, user_token: "0"}) do
      {:error, errors} ->
        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(:error, inspect(errors))
        |> redirect(to: ~p"/")

      {:ok, user} ->
        token = PhxSolid.Token.user_generate(email)
        profile = %{email: email, name: name, picture: picture}
        {:ok, u} = SocialUser.update_token(%{id: user.id, user_token: token})

        conn
        |> fetch_session()
        |> put_session(:user_token, token)
        |> put_session(:profile, profile)
        |> put_session(:logs, u.logs)
        |> put_session(:origin, "fb_sdk")
        |> redirect(to: ~p"/welcome")
    end
  end
end

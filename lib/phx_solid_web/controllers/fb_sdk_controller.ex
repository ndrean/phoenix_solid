defmodule PhxSolidWeb.FbSdkController do
  use PhxSolidWeb, :controller
  alias PhxSolid.{Accounts, Accounts.User}
  alias PhxSolidWeb.UserAuth

  # alias PhxSolid.SocialUser
  require Logger
  # action_fallback PhxSolidWeb.LoginErrorController

  def login(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      nil ->
        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(
          :info,
          "If we find your account, you will be logged in"
        )
        |> redirect(to: ~p"/")

      user = %User{} ->
        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(:info, "Welcome back!")
        |> put_session(:origin, "facebook")
        |> UserAuth.log_in_user(user)

        # case SocialUser.create(%{email: email, name: name, user_token: "0"}) do
        #   {:error, errors} ->
        #     conn
        #     |> fetch_session()
        #     |> fetch_flash()
        #     |> put_flash(:error, inspect(errors))
        #     |> redirect(to: ~p"/")
        #     |> halt()

        #   {:ok, user} ->
        #     token = PhxSolid.Token.user_generate(email)
        #     profile = %{email: email, name: name}
        #     {:ok, u} = SocialUser.update_token(%{id: user.id, user_token: token})

        #     conn
        #     |> fetch_session()
        #     |> put_session(:user_token, token)
        #     |> put_session(:profile, profile)
        #     |> put_session(:logs, u.logs)
        #     |> put_session(:origin, "fb_sdk")
        #     |> redirect(to: ~p"/welcome")
        # end
    end
  end

  def login(conn, %{"error" => error}) do
    Logger.warning("failed: #{inspect(error)})")
    halt(conn)
  end
end

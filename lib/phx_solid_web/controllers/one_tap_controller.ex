defmodule PhxSolidWeb.OneTapController do
  use PhxSolidWeb, :controller
  alias PhxSolid.{Accounts, Accounts.User}
  alias PhxSolidWeb.UserAuth
  # alias PhxSolid.SocialUser
  require Logger

  def check_csrf(conn, _opts) do
    csrf_key = "g_csrf_token"

    g_csrf_cookies = Map.get(conn.req_cookies, csrf_key)
    g_csrf_params = Map.get(conn.params, csrf_key)

    if g_csrf_cookies !== g_csrf_params do
      conn
      |> put_flash(:error, "CSRF token mismatch")
      |> redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end

  plug :check_csrf

  def handle(conn, %{"credential" => jwt}) do
    g_nonce = fetch_session(conn) |> get_session(:g_nonce)

    with {:ok, %{email: email} = _profile} <-
           ElixirGoogleCerts.verified_identity(%{
             g_nonce: g_nonce,
             jwt: jwt
           }),
         user = %User{} <- Accounts.get_user_by_email(email) do
      conn
      |> fetch_session()
      |> fetch_flash()
      |> put_flash(:info, "Welcome back!")
      |> put_session(:origin, "google_one_tap")
      |> UserAuth.log_in_user(user)

      #    {:ok, user} <- SocialUser.create(%{email: email, name: name, user_token: "0"}) do
      # token = PhxSolid.Token.user_generate(email)
      # {:ok, u} = SocialUser.update_token(%{id: user.id, user_token: token})

      # conn
      # |> fetch_session()
      # |> put_session(:user_token, token)
      # |> put_session(:profile, profile)
      # |> put_session(:logs, u.logs)
      # |> put_session(:origin, "google_one_tap")
      # |> redirect(to: ~p"/welcome")
    else
      nil ->
        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(
          :info,
          "If we find your account, you will be logged in"
        )
        |> redirect(to: ~p"/")

      {:error, errors} ->
        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(:error, inspect(errors))
        |> redirect(to: ~p"/")
    end
  end

  def handle(conn, msg) do
    Logger.warning("OneTap error: #{inspect(msg)}")
    redirect(conn, to: ~p"/")
  end
end

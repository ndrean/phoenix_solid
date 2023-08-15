defmodule PhxSolidWeb.UserLiveAuth do
  # import Phoenix.Component
  import Phoenix.LiveView
  import Phoenix.Component
  require Logger

  @moduledoc """
  Following <https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations>
  """
  defp path_in_socket(_p, url, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_path, URI.parse(url).path)}
  end

  def on_mount(:default, _p, %{"user_token" => user_token} = session, socket) do
    Logger.info("On mount check, #{inspect(user_token)},...#{inspect(session)}")

    case PhxSolid.Accounts.get_user_by_session_token(user_token) do
      # end
      # case PhxSolid.SocialUser.check(:user_token, user_token, :id) do
      nil ->
        Logger.warning("not found on mount")
        # put_flash(socket, :error, "invalid credentials, please login again")
        {:halt, redirect(socket, to: "/")}

      user ->
        user_phx_token = PhxSolid.Token.user_generate(user.id)

        socket =
          assign_new(socket, :current_user, fn -> user end)
          |> assign(:user_phx_token, user_phx_token)

        {:cont,
         Phoenix.LiveView.attach_hook(
           socket,
           :put_path_in_socket,
           :handle_params,
           &path_in_socket/3
         )}
    end
  end
end

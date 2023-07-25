defmodule PhxSolidWeb.UserLiveAuth do
  # import Phoenix.Component
  import Phoenix.LiveView
  require Logger

  @moduledoc """
  Following <https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations>
  """
  defp path_in_socket(_p, url, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_path, URI.parse(url).path)}
  end

  def on_mount(:default, _p, %{"user_token" => user_token} = _session, socket) do
    Logger.info("On mount check")

    case PhxSolid.SocialUser.check(:user_token, user_token, :id) do
      {:ok, _user} ->
        {:cont,
         Phoenix.LiveView.attach_hook(
           socket,
           :put_path_in_socket,
           :handle_params,
           &path_in_socket/3
         )}

      {:error, :not_found} ->
        # put_flash(socket, :error, "invalid credentials, please login again")
        {:halt, redirect(socket, to: "/")}
    end
  end
end

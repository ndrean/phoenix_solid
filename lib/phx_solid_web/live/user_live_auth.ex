defmodule PhxSolidWeb.UserLiveAuth do
  # import Phoenix.Component
  import Phoenix.LiveView
  require Logger

  @moduledoc """
  Following <https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations>
  """
  def on_mount(:default, _p, %{"user_token" => user_token} = _session, socket) do
    Logger.info("on mount_____________")

    case PhxSolid.User.check(:user_token, user_token, :id) do
      {:ok, _user} ->
        {:cont, socket}

      {:error, reason} ->
        Logger.warning(reason)
        {:halt, redirect(socket, to: "/")}
    end
  end
end

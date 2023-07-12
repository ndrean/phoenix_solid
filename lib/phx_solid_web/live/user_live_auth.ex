defmodule PhxSolidWeb.UserLiveAuth do
  # import Phoenix.Component
  import Phoenix.LiveView
  require Logger

  @moduledoc """
  Following <https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations>
  """
  def on_mount(:default, _p, %{"user_token" => user_token} = _session, socket) do
    checked = user_token
    Logger.info("on mount_____________")

    if checked do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/")}
    end
  end
end

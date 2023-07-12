defmodule PhxSolidWeb.WelcomeLive do
  use PhxSolidWeb, :live_view
  on_mount PhxSolidWeb.UserLiveAuth

  alias PhxSolidWeb.{SolidApp, UserProfile}
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <UserProfile.show :if={!@display} profile={@profile} />
    <.live_component :if={@display} module={SolidApp} id="solidap" user_token={@user_token} />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    %{"user_token" => user_token, "profile" => profile} = session

    if connected?(socket) do
      Logger.info("LV Connected #{inspect(self())}")
      :ok = PhxSolidWeb.Endpoint.subscribe("check_user")
    end

    {:ok,
     assign(socket,
       user_token: user_token,
       profile: profile,
       page_title: "liveview"
     )}
  end

  # authorization check callback for the channel "info"
  @impl true
  def handle_info(%{topic: "check_user", event: "check_token", payload: response}, socket) do
    IO.inspect(
      "LV handle_info: -----------------------------#{inspect(socket.assigns.user_token)}"
    )

    if response["user_token"] === socket.assigns.user_token do
      PhxSolidWeb.Endpoint.broadcast!("user_checked", "authorized", %{verified: :ok})
    else
      PhxSolidWeb.Endpoint.broadcast!("user_checked", "authorized", %{
        verified: :unauthorized
      })
    end

    {:noreply, socket}
  end

  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    value = Map.get(unsigned_params, "display", false)
    {:noreply, assign(socket, display: value)}
  end
end

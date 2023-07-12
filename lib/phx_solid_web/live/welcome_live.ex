defmodule PhxSolidWeb.WelcomeLive do
  use PhxSolidWeb, :live_view
  on_mount PhxSolidWeb.UserLiveAuth

  alias PhxSolidWeb.{SolidApp, UserProfile}
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <UserProfile.show :if={!@display} profile={@profile} logs={@logs} />
    <SolidApp.render :if={@display} />
    """
  end

  # <.live_component :if={@display} module={SolidApp} id="solidap" />
  # user_token={@user_token}
  # main_pid={@main_pid}

  @impl true
  def mount(_params, session, socket) do
    %{"user_token" => user_token, "profile" => profile, "logs" => logs} = session

    if connected?(socket) do
      Logger.info("LV Connected ******}")
      # :ok = PhxSolidWeb.Endpoint.subscribe("check_user")
    end

    {:ok,
     assign(socket,
       user_token: user_token,
       profile: profile,
       logs: logs
     )}
  end

  # authorization check callback for the channel "info"
  # def handle_info(%{topic: "check_user", event: "check_token", payload: response}, socket) do
  #   if response["user_token"] === socket.assigns.user_token do
  #     PhxSolidWeb.Endpoint.broadcast!("user_checked", "authorized", %{verified: :ok})
  #   else
  #     PhxSolidWeb.Endpoint.broadcast!("user_checked", "authorized", %{
  #       verified: :unauthorized
  #     })
  #   end

  #   {:noreply, socket}
  # end

  # the event of changing the url is captured with handle_params
  @impl true
  def handle_params(unsigned_params, _uri, socket) do
    value = Map.get(unsigned_params, "display", false)

    active =
      ["flex items-center border rounded-md p-2 mr-2", value && "bg-[bisque] text-[midnightblue]"]

    {:noreply, assign(socket, display: value, active: active)}
  end
end

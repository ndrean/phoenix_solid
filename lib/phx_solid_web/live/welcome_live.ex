defmodule PhxSolidWeb.WelcomeLive do
  use PhxSolidWeb, :live_view
  on_mount PhxSolidWeb.UserLiveAuth

  alias PhxSolidWeb.{SolidApp, UserProfile, Nav}
  require Logger

  @nav_elts ["#solid", "#profile"]

  @impl true
  def render(assigns) do
    ~H"""
    <Nav.render active={@active} display={@display} />
    <SolidApp.render />
    <UserProfile.render profile={@profile} logs={@logs} />
    """
  end

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
  def handle_params(qstring, _uri, socket) do
    base = "flex items-center border rounded-md p-2 mr-2"
    styled = "bg-[bisque] text-[midnightblue]"

    view =
      case map_size(qstring) do
        0 -> "#profile"
        _ -> Map.get(qstring, "display")
      end

    active = fn current -> [base, current === view && styled] end

    display = fn view ->
      @nav_elts
      |> Enum.filter(&(&1 !== view))
      |> Enum.reduce(%JS{}, fn elt, acc ->
        acc |> JS.hide(to: elt)
      end)
      |> JS.show(to: view)
    end

    {:noreply, assign(socket, active: active, display: display)}
  end
end
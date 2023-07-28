defmodule PhxSolidWeb.Router do
  import Phoenix.LiveView.Router
  use PhxSolidWeb, :router
  # import Plug.Conn

  import PhxSolidWeb.UserAuth

  # https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid#content_security_policy
  # https://csp-evaluator.withgoogle.com/
  # @csp "script-src https://accounts.google.com/gsi/client;" <>
  #        "frame-src https://accounts.google.com/gsi/;" <>
  #        "connect-src https://accounts.google.com/gsi/;"

  # @csp "script-src https://accounts.google.com/gsi/client; frame-src https://accounts.google.com/gsi/; connect-src https://accounts.google.com/gsi/;"

  @csp ""

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhxSolidWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :default_assigns

    plug :put_secure_browser_headers

    plug :fetch_current_user
    plug :g_login

    plug(
      :put_secure_browser_headers,
      %{"content-security-policy-report-only" => @csp}
    )
  end

  pipeline :api do
    plug :accepts, ["json"]
    post("/users/one_tap", PhxSolidWeb.OneTapController, :handle)
  end

  scope "/", PhxSolidWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/fb_login", FbSdkController, :login
    get "/users/oauth", GController, :login
    get "/spa", SPAController, :index
    live "/welcome", WelcomeLive, :new
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxSolidWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  # if Application.compile_env(:phx_solid, :dev_routes) do
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/dev" do
    pipe_through :browser

    live_dashboard "/dashboard", metrics: PhxSolidWeb.Telemetry
    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end

  ## Authentication routes

  scope "/", PhxSolidWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{PhxSolidWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
    get "/users/log_in/:token", UserSessionController, :create
  end

  scope "/", PhxSolidWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PhxSolidWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", PhxSolidWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{PhxSolidWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  def default_assigns(conn, _opts) do
    conn
    |> assign(:meta_attrs, [])
    |> assign(:manifest, nil)
  end

  def g_login(conn, _) do
    Plug.Conn.put_resp_header(
      conn,
      "cross-origin-opener-policy",
      "same-origin-allow-popups"
    )
  end
end

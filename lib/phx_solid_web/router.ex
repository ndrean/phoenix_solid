defmodule PhxSolidWeb.Router do
  import Phoenix.LiveView.Router
  use PhxSolidWeb, :router

  import PhxSolidWeb.UserAuth

  # https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid#content_security_policy
  # https://csp-evaluator.withgoogle.com/

  # @hostname PhxSolid.hostname()

  # @report_to PhxSolid.report_to()

  # @csp (case Mix.env() do
  #         :prod ->
  #           "script-src 'nonce-123456789' 'nonce-f35697c2-bf93-418e-a119-8158c69a2b3a' 'nonce-0bce0d28-93ad-4f3e-9f3f-c1057b0e71b3' https://accounts.google.com/gsi/ https://connect.facebook.net/ 'self' https:#{@hostname};frame-src https://accounts.google.com/gsi/ 'self';connect-src https://accounts.google.com/gsi/   https://www.facebook.com/ 'self' wss:#{@hostname} http:#{@hostname};report-uri #{@report_to};report-to #{@report_to}"

  #         _ ->
  #           "script-src 'nonce-123456789' 'nonce-baad31ae-1280-4cef-a026-2e5f5fa13006' 'nonce-842fa7d9-8610-4180-9af1-e6ee3c47f1e7' 'nonce-123456' 'nonce-f35697c2-bf93-418e-a119-8158c69a2b3a' 'nonce-0bce0d28-93ad-4f3e-9f3f-c1057b0e71b3' https://accounts.google.com/ https://connect.facebook.net/ 'self' http:#{@hostname}/assets http:#{@hostname}/spa ;frame-src http:#{@hostname} https://accounts.google.com/gsi/ https://www.facebook.com 'self';connect-src http:#{@hostname} https:#{@hostname} https://accounts.google.com/gsi/   https://www.facebook.com/ https://graph.facebook.com/'self' ws:#{@hostname};report-uri #{@report_to};report-to #{@report_to}; object-src 'none';base-uri 'self';"
  #       end)

  # PhxSolid.csp() |> dbg()

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhxSolidWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :default_assigns
    plug :fetch_current_user

    plug(
      :put_secure_browser_headers,
      %{
        # "content-security-policy-report-only" => @csp,
        "cross-origin-opener-policy" => "same-origin-allow-popups"
      }
    )
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug :put_secure_browser_headers, %{
      # "content-security-policy" => @csp,
      "cross-origin-opener-policy" => "same-origin-allow-popups"
    }

    post("/users/one_tap", PhxSolidWeb.OneTapController, :handle)
    post "/csp-reports", PhxSolidWeb.CspReport, :display
    get "/users/log_in/:token", PhxSolidWeb.UserSessionController, :create
  end

  scope "/", PhxSolidWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/fb_login", FbSdkController, :login
    get "/users/oauth", GController, :login
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
    # get "/users/log_in/:token", UserSessionController, :create
  end

  scope "/", PhxSolidWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PhxSolidWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/welcome", WelcomeLive, :new
    end

    get "/spa", SPAController, :index
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

  # def redirect_path(conn, _) do
  #   redir_url =
  #     %URI{
  #       scheme: conn.scheme |> Atom.to_string(),
  #       port: conn.port,
  #       host: :inet.ntoa(conn.remote_ip) |> IO.iodata_to_binary(),
  #       path: Application.get_env(Application.get_application(__MODULE__), :g_certs_cb_path)
  #     }
  #     |> URI.to_string()

  #   assign(conn, :redir_url, redir_url)
  # end
end

defmodule PhxSolidWeb.Router do
  import Phoenix.LiveView.Router
  use PhxSolidWeb, :router

  # https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid#content_security_policy
  # https://csp-evaluator.withgoogle.com/
  # @csp "script-src https://accounts.google.com/gsi/client;" <>
  #        "frame-src https://accounts.google.com/gsi/;" <>
  #        "connect-src https://accounts.google.com/gsi/;"

  # @csp "script-src https://accounts.google.com/gsi/client; frame-src https://accounts.google.com/gsi/; connect-src https://accounts.google.com/gsi/;"

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhxSolidWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers
    # plug(
    #   :put_secure_browser_headers,
    #   %{"content-security-policy-report-only" => @csp}
    # )
  end

  pipeline :api do
    plug :accepts, ["json"]
    post("/auth/one_tap", PhxSolidWeb.OneTapController, :handle)
  end

  scope "/", PhxSolidWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/welcome", WelcomeLive
    get "/spa", SPAController, :index
    get "/fb_login", FbSdkController, :login
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
    # forward "/mailbox", Plug.Swoosh.MailboxPreview
    # end
  end
end

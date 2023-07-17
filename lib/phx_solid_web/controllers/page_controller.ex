defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller
  @moduledoc false
  def home(conn, _params) do
    fb_app_id = System.fetch_env!("FACEBOOK_APP_ID")
    conn = assign(conn, :app_id, fb_app_id)
    render(conn, :home)
  end
end

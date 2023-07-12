defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

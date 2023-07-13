defmodule PhxSolidWeb.PageController do
  use PhxSolidWeb, :controller
  @moduledoc false
  def home(conn, _params) do
    render(conn, :home)
  end
end

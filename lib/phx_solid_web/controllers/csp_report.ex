defmodule PhxSolidWeb.CspReport do
  use PhxSolidWeb, :controller
  require Logger

  def display(conn, report) do
    Logger.debug("#{inspect(report)}")
    render(conn, %{err: inspect(report)})
  end
end

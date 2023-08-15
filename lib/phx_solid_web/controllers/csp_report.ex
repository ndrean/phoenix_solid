defmodule PhxSolidWeb.CspReport do
  use PhxSolidWeb, :controller
  require Logger

  def display(conn, report) do
    Logger.warning("#{inspect(report)}")
    json(conn, %{err: inspect(report)})
  end
end

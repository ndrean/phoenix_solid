defmodule PhxSolidWeb.CounterChannel do
  use PhxSolidWeb, :channel

  @impl true
  def join("counter", payload, socket) do
    # if authorized?(payload) do
    IO.inspect(payload, label: "join channel payload")

    {:ok, socket}
    # else
    # {:error, %{reason: "unauthorized"}}
    # end
  end

  @impl true
  def handle_in("inc", payload, socket) do
    IO.inspect(payload, label: "received counter inc")
    broadcast(socket, "inc", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end

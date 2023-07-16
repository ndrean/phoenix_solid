defmodule PhxSolidWeb.CounterChannel do
  use PhxSolidWeb, :channel

  @impl true
  def join("counter", _payload, socket) do
    # IO.inspect(payload)
    {:ok, socket}
  end

  @impl true
  def handle_in("inc", payload, socket) do
    broadcast(socket, "inc", payload)
    {:noreply, socket}
  end
end

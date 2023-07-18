defmodule PhxSolidWeb.CounterChannel do
  use PhxSolidWeb, :channel
  alias PhxSolid.Counter

  @impl true
  def join("counter:visits", _payload, socket) do
    init_count = Counter.update()
    send(self(), {:init, init_count})
    {:ok, socket}
  end

  @impl true
  def handle_info({:init, init_count}, socket) do
    broadcast!(socket, "init_count", %{count: init_count})
    # push(socket, "init_count", %{count: init_count})
    {:noreply, socket}
  end
end

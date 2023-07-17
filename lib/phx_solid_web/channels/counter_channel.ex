defmodule PhxSolidWeb.CounterChannel do
  use PhxSolidWeb, :channel
  alias PhxSolid.{Counter}

  @impl true
  def join("counter", _payload, socket) do
    init_count = Counter.update()
    send(self(), {:init, init_count})
    {:ok, socket}
  end

  @impl true
  def handle_info({:init, init_count}, socket) do
    push(socket, "init_count", %{count: init_count})
    {:noreply, socket}
  end

  # @impl true
  # def handle_in("inc", %{}, socket) do
  #   broadcast(socket, "inc", %{count: count})
  #   {:noreply, socket}
  # end
end

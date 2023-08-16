defmodule PhxSolidWeb.CounterChannel do
  use PhxSolidWeb, :channel
  alias PhxSolid.Counter
  require Logger

  @moduledoc """
  Channel to broadcast the total number of visits
  """

  @impl true
  def join("counter:visits", _payload, socket) do
    case Counter.update_counter_by_one(socket.assigns.id) do
      {:ok, count} ->
        send(self(), {:init, count})
        {:ok, socket}

      {:error, err} ->
        Logger.error("#{__MODULE__}: error: #{inspect(err)}")
        # define an error handler in the websocket configuration
        # (https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
        :error
    end
  end

  @impl true
  def handle_info({:init, count}, socket) do
    broadcast!(socket, "init_count", %{count: count})
    # push(socket, "init_count", %{count: init_count})
    {:noreply, socket}
  end
end

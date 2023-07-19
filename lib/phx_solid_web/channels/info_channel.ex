defmodule PhxSolidWeb.InfoChannel do
  use PhxSolidWeb, :channel
  require Logger

  @moduledoc """
  Channel to provide general info on home page of SPA
  """

  @impl true
  def join("info", _payload, socket) do
    :ok = PhxSolidWeb.Endpoint.subscribe("nodes")
    send(self(), :join_info)
    {:ok, socket}
  end

  @impl true
  def handle_info(:join_info, socket) do
    process_info =
      %{
        curr_node: node(),
        user: socket.assigns.name,
        connected_nodes: Node.list(),
        memory: div(:erlang.memory(:total), 1_000_000)
      }

    broadcast!(socket, "get_info", process_info)
    # push(socket, "get_info", process_info)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{"topic" => "nodes", "event" => "down", payload: node}, socket) do
    Logger.debug("#{inspect(node)} down")
    broadcast!(socket, "nodes_event", %{down: node})
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{"topic" => "nodes", "event" => "up", payload: node}, socket) do
    Logger.debug("#{inspect(node)} up")
    broadcast!(socket, "nodes_event", %{up: node})
    {:noreply, socket}
  end
end

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
    # broadcast!(socket, "get_info", get_info(socket.assigns.name))
    push(socket, "get_info", get_info(socket.assigns.name))
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "nodes", event: "down", payload: node}, socket) do
    # broadcast!(socket, "get_info", get_info(socket.assigns.name))
    broadcast!(socket, "nodes_event", %{down: node, list: Node.list(:connected)})
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "nodes", event: "up", payload: node}, socket) do
    # broadcast!(socket, "get_info", get_info(socket.assigns.name))
    broadcast!(socket, "nodes_event", %{up: node, list: Node.list(:connected)})
    {:noreply, socket}
  end

  defp get_info(name) do
    %{
      curr_node: node(),
      cookie: Node.get_cookie(),
      user: name,
      connected_nodes: Node.list(:connected),
      memory: div(:erlang.memory(:total), 1_000_000)
    }
  end
end

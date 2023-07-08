defmodule PhxSolidWeb.InfoChannel do
  use PhxSolidWeb, :channel

  @impl true
  def join("info", _payload, socket) do
    process_info =
      %{
        curr_node: node(),
        connected_nodes: Node.list(),
        memory: div(:erlang.memory(:total), 1_000_000)
      }

    send(self(), {:info, process_info})
    {:ok, socket}
  end

  @impl true
  def handle_info({:info, process_info}, socket) do
    broadcast!(socket, "get_info", process_info)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end

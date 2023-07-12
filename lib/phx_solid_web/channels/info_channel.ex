defmodule PhxSolidWeb.InfoChannel do
  use PhxSolidWeb, :channel
  require Logger

  @moduledoc """
  Channel to provide general info on home page of SPA
  """

  @impl true
  def join("info", _payload, socket) do
    # :ok = PhxSolidWeb.Endpoint.subscribe("user_checked")
    # check_authorized(payload)
    # IO.inspect("join**************#{inspect(payload)}")
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
    {:noreply, socket}
  end

  # @impl true
  # def handle_info(
  #       %{topic: "user_checked", event: "authorized", payload: %{verified: response}},
  #       socket
  #     ) do
  #   IO.inspect(response, label: "channel info------------------")

  #   if response === :ok do
  #     process_info =
  #       %{
  #         curr_node: node(),
  #         connected_nodes: Node.list(),
  #         memory: div(:erlang.memory(:total), 1_000_000)
  #       }

  #     broadcast!(socket, "get_info", process_info)
  #     {:noreply, socket}
  #   else
  #     broadcast(socket, "get_info", %{status: "unauthorized"})
  #     {:stop, :unauthorized, socket}
  #   end
  # end

  # def check_authorized(payload) do
  #   IO.inspect("check authorized")
  #   :ok = PhxSolidWeb.Endpoint.broadcast!("check_user", "check_token", payload)
  # end
end

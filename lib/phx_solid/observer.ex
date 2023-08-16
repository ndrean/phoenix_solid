defmodule PhxSolid.Observer do
  use GenServer
  require Logger

  @moduledoc """
  Monitor the connected nodes and send event on PubSub.
  """

  @pubsub_topic "lb"
  @node_topic "nodes"

  def start_link(_),
    do: GenServer.start_link(__MODULE__, {}, name: __MODULE__)

  @impl true
  def init(_) do
    :net_kernel.monitor_nodes(true, %{node_type: :all})
    :ok = Phoenix.PubSub.subscribe(:phx_pubsub, @pubsub_topic)
    Logger.info("Init observer")

    schedule_ping()
    {:ok, nil}
  end

  @impl true
  def handle_info(:do_ping, _state) do
    for n <- Node.list(:visible) do
      case ping_node(n) do
        :pang ->
          Logger.warning("#{n} doesn't respond")

        :pong ->
          :ok
      end
    end

    schedule_ping()
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodeup, node, %{node_type: :hidden}}, _state) do
    broadcast_node_status("up", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodedown, node, %{node_type: :hidden}}, _state) do
    broadcast_node_status("down", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodedown, node}, _state) do
    broadcast_node_status("down", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodeup, node}, _state) do
    broadcast_node_status("up", node)
    {:noreply, nil}
  end

  defp ping_node(node) do
    case Node.ping(node) do
      :pang -> :pang
      _ -> :pong
    end
  rescue
    _ -> :pang
  end

  defp schedule_ping() do
    Process.send_after(self(), :do_ping, 10_000)
  end

  defp broadcast_node_status(status, node) do
    PhxSolidWeb.Endpoint.broadcast!(@node_topic, status, node)
  end
end

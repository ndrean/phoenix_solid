defmodule PhxSolid.Observer do
  use GenServer
  require Logger

  @moduledoc """
  Monitor the connected nodes and send event on PubSub.
  """

  def start_link(_),
    do: GenServer.start_link(__MODULE__, {}, name: __MODULE__)

  @impl true
  def init(_) do
    :net_kernel.monitor_nodes(true, %{node_type: :all})
    :ok = Phoenix.PubSub.subscribe(:phx_pubsub, "lb")
    Logger.info("Init observer")

    Process.send_after(self(), :do_ping, 10_000)
    {:ok, nil}
  end

  @impl true
  def handle_info(:do_ping, _state) do
    for n <- Node.list(:visible) do
      case Node.ping(n) do
        :pang ->
          Logger.warning("#{n} doesn't respond")

        :pong ->
          :ok
      end
    end

    Process.send_after(self(), :do_ping, 10_000)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodedown, node}, _state) do
    PhxSolidWeb.Endpoint.broadcast!("nodes", "down", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodeup, node}, _state) do
    PhxSolidWeb.Endpoint.broadcast!("nodes", "up", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodeup, node, %{node_type: :hidden}}, _state) do
    PhxSolidWeb.Endpoint.broadcast!("nodes", "up", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info({:nodedown, node, %{node_type: :hidden}}, _state) do
    PhxSolidWeb.Endpoint.broadcast!("nodes", "down", node)
    {:noreply, nil}
  end

  @impl true
  def handle_info(msg, _state) do
    "________ in observer: #{inspect(msg)}"
    {:noreply, nil}
  end
end

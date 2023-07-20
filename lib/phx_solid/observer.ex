defmodule PhxSolid.Observer do
  use GenServer
  require Logger

  @moduledoc """
  Monitor the connected nodes
  """

  def start_link(_), do: GenServer.start_link(__MODULE__, {}, name: __MODULE__)

  @impl true
  def init(_) do
    :net_kernel.monitor_nodes(true)
    require Logger
    Logger.info("Init observer")
    {:ok, nil}
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
end

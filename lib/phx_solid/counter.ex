defmodule PhxSolid.Counter do
  use GenServer
  @moduledoc false

  def start_link() do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_info({"inc", 1}, state) do
    # IO.inspect(state, label: "GS counter")
    state = state + 1
    PhxSolidWeb.Endpoint.broadcast!("counter", "inc", %{count: state})
    {:noreply, state}
  end
end

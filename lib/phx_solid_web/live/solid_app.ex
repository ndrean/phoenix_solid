defmodule PhxSolidWeb.SolidApp do
  use PhxSolidWeb, :live_component

  attr :process_info, :map
  @impl true
  def render(assigns) do
    ~H"""
    <div id="solid" phx-hook="SolidAppHook" phx-update="ignore" process_info={inspect(@process_info)}>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    process_info =
      %{
        node: node(),
        pid: inspect(self()),
        memory: div(:erlang.memory(:total), 1_000_000)
      }

    {:ok, assign(socket, process_info: process_info)}
  end
end

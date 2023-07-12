defmodule PhxSolidWeb.SolidApp do
  # use PhxSolidWeb, :live_component
  use Phoenix.Component

  # attr :process_info, :map
  # @impl true
  def render(assigns) do
    ~H"""
    <div id="solid" phx-hook="SolidAppHook" phx-update="ignore"></div>
    """
  end

  # @impl true
  # def mount(socket) do
  #   {:ok, socket}
  # end

  # @impl true
  # def update(assigns, socket) do
  #   process_info =
  #     %{
  #       node: node(),
  #       pid: inspect(self()),
  #       main_pid: inspect(assigns.main_pid),
  #       memory: div(:erlang.memory(:total), 1_000_000)
  #     }

  #   {:ok, assign(socket, process_info: process_info)}
  # end
end

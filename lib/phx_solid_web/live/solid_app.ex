defmodule PhxSolidWeb.SolidApp do
  use Phoenix.Component
  # use PhxSolidWeb, :live_component

  @moduledoc false

  def render(assigns) do
    ~H"""
    <div id="solid" phx-hook="SolidAppHook" phx-update="ignore"></div>
    """
  end

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

defmodule PhxSolidWeb.SolidApp do
  use Phoenix.Component

  @moduledoc false

  def render(assigns) do
    ~H"""
    <div id="solid" phx-hook="SolidAppHook" phx-update="ignore"></div>
    """
  end
end

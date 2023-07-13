defmodule PhxSolidWeb.Nav do
  use PhxSolidWeb, :html

  @moduledoc false

  attr :active, :any
  attr :display, :any

  def render(assigns) do
    ~H"""
    <nav class="px-4 sm:px-6 lg:px-8  bg-slate-800 text-white" id="nav">
      <div class="flex justify-between content-center">
        <div class="flex py-3 text-sm" phx-mounted={@display.("#profile")}>
          <.link class="flex items-center border rounded-md p-2 mr-2" href={~p"/spa"}>
            <img src={~p"/images/solid.svg"} width="36" />
            <span>Navigate to the SPA</span>
          </.link>
          <%=  %>
          <.link
            class={@active.("#solid")}
            phx-click={@display.("#solid")}
            patch={~p"/welcome?#{%{display: "#solid"}}"}
          >
            SPA Hook
          </.link>
          <.link
            class={@active.("#profile")}
            phx-click={@display.("#profile")}
            patch={~p"/welcome?#{%{display: "#profile"}}"}
          >
            User profile
          </.link>
        </div>
        <div class="py-3">
          <img src="/images/online.png" alt="line-status" id="online" />
        </div>
      </div>
    </nav>
    """
  end
end

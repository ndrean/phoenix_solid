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
            <span>SPA</span>
          </.link>
          <.link
            class={@active.("#solid")}
            phx-click={@display.("#solid")}
            patch={~p"/welcome?display=solid"}
          >
            SPA Hook
          </.link>
          <.link
            class={@active.("#profile")}
            phx-click={@display.("#profile")}
            patch={~p"/welcome?display=profile"}
          >
            User profile
          </.link>
        </div>
        <div class="flex flex-col justify-center py-3">
          <.link href={~p"/dev/dashboard"} target="_blank" class="border rounded-md p-2 text-xs w-26">
            LiveDashboard
          </.link>
          <a href="http://localhost:8080" target="_blank" class="flex items-center bg-[bisque] w-26">
            <img src={~p"/images/logolb.png"} target="_blank" class="w-4" />
            <span class="bg-[bisque] p-1 text-xs text-[midnightblue]">LiveBook</span>
          </a>
        </div>
        <div class="py-3">
          <img src="/images/online.png" alt="line-status" id="online" />
        </div>
      </div>
    </nav>
    """
  end
end

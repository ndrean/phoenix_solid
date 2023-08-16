defmodule PhxSolidWeb.SpaLive do
  use PhxSolidWeb, :live_view
  # use Phoenix.LiveView
  use PhxSolidWeb, :verified_routes

  @impl true
  def render(assigns) do
    ~H"""
    <section class="min-h-screen flex items-center justify-center bg-[midnightblue]">
      <h1>SPA</h1>
      <iframe class="w-full max-w-md" height="600" src={~p"/serve_spa"}></iframe>
    </section>
    """
  end

  @impl true
  def mount(_p, session, socket) do
    binding() |> dbg()
    active = fn _ -> "spa" end
    display = fn _ -> nil end
    {:ok, assign(socket, active: active, display: display)}
  end
end

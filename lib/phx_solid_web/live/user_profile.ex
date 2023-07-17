defmodule PhxSolidWeb.UserProfile do
  use Phoenix.Component
  # use PhxSolidWeb, :live_view

  @moduledoc false

  attr :profile, :map
  attr :logs, :integer
  attr :origin, :string

  def render(assigns) do
    ~H"""
    <div id="profile">
      <h1 class="relative w-[max-content] font-mono before:absolute before:inset-0 before:animate-typewriter before:bg-white">
        Welcome <%= @profile.name %>! <img width="32px" src={@profile.picture} />
      </h1>
      <p>
        You <strong>signed in</strong>
        with <%= @origin %> with your account:
        <strong style="color:teal;"><%= @profile.email %></strong>
      </p>
      <hr />
      <br />
      <p>You connected <%= @logs %> times</p>
    </div>
    """
  end
end

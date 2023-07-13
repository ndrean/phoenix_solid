defmodule PhxSolidWeb.UserProfile do
  use Phoenix.Component
  # use PhxSolidWeb, :live_view

  @moduledoc false

  attr :profile, :map
  attr :logs, :integer

  def render(assigns) do
    ~H"""
    <div id="profile">
      <h1>
        Welcome <%= @profile.name %>! <img width="32px" src={@profile.picture} />
      </h1>
      <p>You are <strong>signed in</strong> with your <strong>Account</strong> <br />
        <strong style="color:teal;"><%= @profile.email %></strong></p>
      <hr />
      <br />
      <p>You connected <%= @logs %> times</p>
    </div>
    """
  end
end

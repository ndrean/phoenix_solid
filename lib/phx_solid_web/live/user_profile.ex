defmodule PhxSolidWeb.UserProfile do
  use Phoenix.Component

  attr :profile, :map
  attr :logs, :integer

  def show(assigns) do
    ~H"""
    <div>
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

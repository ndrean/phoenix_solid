defmodule PhxSolid.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhxSolidWeb.Telemetry,
      # Start the Ecto repository
      # PhxSolid.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PhxSolid.PubSub},
      # Start Finch
      {Finch, name: PhxSolid.Finch},
      # Start the Endpoint (http/https)
      PhxSolidWeb.Endpoint
      # Start a worker by calling: PhxSolid.Worker.start_link(arg)
      # {PhxSolid.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxSolid.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxSolidWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

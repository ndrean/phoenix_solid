defmodule PhxSolid.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # SQLITE3
    # PhxSolid.Release.migrate()

    # :ok = Logster.attach_phoenix_logger()
    topologies = [gossip: [strategy: Elixir.Cluster.Strategy.Gossip]]

    children = [
      PhxSolidWeb.Telemetry,
      PhxSolid.Repo,
      {Phoenix.PubSub, name: :phx_pubsub},
      {Finch, name: PhxSolid.Finch},
      PhxSolidWeb.Endpoint,
      PhxSolid.Observer,
      {Cluster.Supervisor, [topologies, [name: PhxSolid.ClusterSupervisor]]}
    ]

    opts = [strategy: :one_for_one, name: PhxSolid.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxSolidWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

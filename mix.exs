defmodule PhxSolid.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_solid,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        phx_solid: [
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PhxSolid.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :observer, :wx]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      # {:ecto_sqlite3, "~> 0.10.3"},
      {:postgrex, "~> 0.17.2"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_view, "~> 0.18.16"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:swoosh, "~> 1.11"},
      {:hackney, "~> 1.9"},
      {:finch, "~> 0.16"},
      {:req, "~> 0.3.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.4"},
      {:joken, "~> 2.5"},
      {:plug_cowboy, "~> 2.5"},
      {:libcluster, "~> 3.3.3"},
      # {:logfmt_ex, "~> 0.4"},
      {:logster, "~> 2.0.0-rc.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:sobelow, "~> 0.11.1", only: [:dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:floki, ">= 0.30.0", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "tailwind default --minify",
        "cmd --cd assets node build.js --deploy",
        "phx.digest"
      ]
    ]
  end
end

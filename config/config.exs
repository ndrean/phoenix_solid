# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phx_solid,
  google_client_id: System.get_env("GOOGLE_CLIENT_ID"),
  google_client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  google_scope: "profile email"

config :phx_solid,
  spa_dir: System.get_env("SPA_DIR")

config :phx_solid,
  ecto_repos: [PhxSolid.Repo]

config :phx_solid, PhxSolid.Repo,
  database:
    System.get_env("DATABASE_PATH") ||
      Path.expand("../db/phx_solid.db", Path.dirname(__ENV__.file)),
  key: "secret",
  pool_size: 5,
  show_sensitive_data_on_connection_error: true

# Configures the endpoint
config :phx_solid, PhxSolidWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PhxSolidWeb.ErrorHTML, json: PhxSolidWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhxSolid.PubSub,
  live_view: [signing_salt: "WDPkDNzDwUG1jPxEDcag+XYKvVPEEPoZ"],
  http: [ip: {0, 0, 0, 0}, port: 4000]

# https: [
#  port: 4001,
#  cipher_suite: :strong,
#  certfile: "priv/cert/selfsigned.pem",
#  keyfile: "priv/cert/selfsigned_key.pem"
# ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :phx_solid, PhxSolid.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required). Run `node build.js` in the folder "/assets".
config :esbuild,
  version: "0.17.11"

#   default: [
#     args: ~w(
#         js/app.js
#         --loader:.js=jsx
#         --bundle --target=es2020
#         --outdir=../priv/static/assets
#         --external:/fonts/*
#         --external:/images/*
#         ),
#     cd: Path.expand("../assets", __DIR__),
#     env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
#   ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.3",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

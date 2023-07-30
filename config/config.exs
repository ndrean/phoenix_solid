# This configuration file is loaded before any dependency and is restricted to this project.

import Config

# config :phx_solid,
#   google_client_id: System.get_env("GOOGLE_CLIENT_ID"),
#   google_client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
#   google_scope: "profile email"

# config :phx_solid,
#   spa_dir: System.get_env("SPA_DIR")

config :phx_solid,
  ecto_repos: [PhxSolid.Repo]

config :phx_solid,
  g_auth_uri: "/users/oauth",
  g_cb_uri: "/users/one_tap"

config :plug_content_security_policy,
  report_only: true,
  directives: %{
    report_uri: "/csp-violation-report-endpoint/"
  },
  nonces_for: [:script_src]

# config :phx_solid, PhxSolid.Repo,
#   database_url: System.get_env("DATABASE_URL"),
#   migration_lock: true

# database:
#   System.get_env("DATABASE_PATH") ||
#     Path.expand("../db/phx_solid.db", Path.dirname(__ENV__.file)),
# key: "secret",
# pool_size: 5,
# show_sensitive_data_on_connection_error: true

# Configures the endpoint
config :phx_solid, PhxSolidWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PhxSolidWeb.ErrorHTML, json: PhxSolidWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: :phx_pubsub,
  live_view: [signing_salt: "WDPkDNzDwUG1jPxEDcag+XYKvVPEEPoZ"],
  http: [ip: {0, 0, 0, 0}, port: 4000]

# https: [
#  port: 4001,
#  cipher_suite: :strong,
#  certfile: "priv/cert/selfsigned.pem",
#  keyfile: "priv/cert/selfsigned_key.pem"
# ]

# Configures the mailer
# locally. You can see the emails in your browser, at "/dev/mailbox".
config :phx_solid, PhxSolid.Mailer, adapter: Swoosh.Adapters.Local
config :swoosh, :api_client, false

# Configure esbuild (the version is required). Run `node build.js` in the folder "/assets".
config :esbuild,
  version: "0.17.11"

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
# config :phoenix, json_library: Jason
config :phoenix, json_library: Jsonrs
# logger: false

# config :logster, formatter: :json

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

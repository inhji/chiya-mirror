# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chiya,
  ecto_repos: [Chiya.Repo]

# Configures the endpoint
config :chiya, ChiyaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ChiyaWeb.ErrorHTML, json: ChiyaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Chiya.PubSub,
  live_view: [signing_salt: "OJncEkwy"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :chiya, Chiya.Mailer, adapter: Swoosh.Adapters.Local

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
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

# Configure Scheduler
config :chiya, Oban,
  repo: Chiya.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

# Configure image uploads
config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/waffle/public"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :chiya, ChiyaWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Chiya.Finch

# Do not print debug messages in production
# config :logger, level: :debug
config :logger, :default_handler, level: :info

config :cors_plug,
  origin: ["app://obsidian.md"],
  max_age: 86400,
  methods: ["GET", "POST"],
  expose: ["Location", "location"]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

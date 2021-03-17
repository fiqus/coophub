# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :coophub, CoophubWeb.Endpoint,
  environment: Mix.env(),
  url: [host: "localhost"],
  secret_key_base: "j8dPu7alWBB8pf3xaMOJ1ulQBBm23vHIROUbGOyLthlPUiSg5wv/j+KevCnbsjWV",
  render_errors: [view: CoophubWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Coophub.PubSub

# Configures app options
config :coophub,
  fetch_max_repos: 10,
  # Configures Cachex
  main_cache_name: :repos_cache,
  cache_interval: 60,
  main_cache_dump_file: "repos-cache.dump",
  uris_cache_name: :uris_cache

# Configures Elixir's Logger
config :logger, :console,
  format: "[$level][$date $time] $metadata$message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

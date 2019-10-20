# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :coophub, CoophubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "j8dPu7alWBB8pf3xaMOJ1ulQBBm23vHIROUbGOyLthlPUiSg5wv/j+KevCnbsjWV",
  render_errors: [view: CoophubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Coophub.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures app options
config :coophub,
  fetch_max_repos: 10,
  # Configures Cachex
  cachex_name: :repos_cache,
  cachex_interval: 60,
  cachex_dump: "repos-cache.dump"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

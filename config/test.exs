use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :coophub, CoophubWeb.Endpoint,
  http: [port: 4002],
  server: false

# Configures Cachex
config :coophub,
  cachex_name: :repos_cache_test

# Print only warnings and errors during test
config :logger, level: :warn

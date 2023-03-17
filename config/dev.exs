import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :coophub, CoophubWeb.Endpoint,
  http: [port: System.get_env("PORT", "4000")],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch",
      "--color"
    ]
  ]

# Watch static and templates for browser reloading.
config :coophub, CoophubWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/coophub_web/{live,views}/.*(ex)$",
      ~r"lib/coophub_web/templates/.*(eex)$"
    ]
  ]

# Exclude timestamps in development logs
config :logger, :console, format: "[$level] $metadata$message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

defmodule Coophub.MixProject do
  use Mix.Project

  def project do
    [
      app: :coophub,
      version: File.read!("VERSION"),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      aliases: aliases(),
      preferred_cli_env: [
        coverage: :test
      ],
      dialyzer_warnings: [:error_handling, :race_conditions, :underspecs, :unknown],
      dialyzer_ignored_warnings: [
        # {tag, {file, line}, {warning_type, arguments}}
        {:_, {'lib/cachex/warmer.ex', :_}, :_}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Coophub.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.18"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.4"},
      {:httpoison, "~> 1.8"},
      {:yaml_elixir, "~> 2.9"},
      {:cachex, "~> 3.6"},
      {:dialyzex, "~> 1.3", only: :dev}
    ]
  end

  # App releases configuration.
  defp releases do
    [
      coophub: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent, coophub: :permanent]
      ]
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      coverage: ["test --cover"],
      refresh: [&remove_dump_file/1, "phx.server"]
    ]
  end

  defp remove_dump_file(_) do
    cache_dump_file = Application.get_env(:coophub, :main_cache_dump_file)
    Mix.shell().info("Removing dump file '#{cache_dump_file}'..")
    Mix.shell().cmd("rm #{cache_dump_file}")
  end
end

defmodule Coophub.MixProject do
  use Mix.Project

  def project do
    [
      app: :coophub,
      version: "0.1.3",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      aliases: aliases(),
      preferred_cli_env: [
        coverage: :test
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
      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.4"},
      {:yaml_elixir, "~> 2.4"},
      {:cachex, "~> 3.1"}
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

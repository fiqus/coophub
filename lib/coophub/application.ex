defmodule Coophub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Cachex.Spec
  require Logger

  @repos_cache_name Application.get_env(:coophub, :main_cache_name)
  @uris_cache_name Application.get_env(:coophub, :uris_cache_name)
  @cache_interval Application.get_env(:coophub, :cache_interval)

  def start(_type, _args) do
    check_github_token()

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      CoophubWeb.Endpoint,
      # Starts a worker by calling: Coophub.Worker.start_link(arg)
      # {Coophub.Worker, arg},
      %{
        id: CachexRepos,
        start: {Cachex, :start_link, [@repos_cache_name, main_cache_opts(env())]}
      },
      %{
        id: CachexUris,
        start:
          {Cachex, :start_link,
           [@uris_cache_name, [expiration: expiration(default: :timer.minutes(@cache_interval))]]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coophub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CoophubWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def env, do: Application.get_env(:coophub, CoophubWeb.Endpoint)[:environment]
  def env?(environment), do: env() == environment

  defp main_cache_opts(:test), do: []

  defp main_cache_opts(_) do
    [
      warmers: [
        warmer(module: Coophub.CacheWarmer)
      ],
      expiration: expiration(default: :timer.minutes(@cache_interval))
    ]
  end

  defp check_github_token() do
    case System.get_env("GITHUB_OAUTH_TOKEN") do
      token when is_binary(token) ->
        Logger.info("Got github token from 'GITHUB_OAUTH_TOKEN' env!", ansi_color: :green)

      _ ->
        Logger.warn(
          "No github token given at 'GITHUB_OAUTH_TOKEN' env.. your request rate to github API will be limited!",
          ansi_color: :red
        )
    end
  end
end

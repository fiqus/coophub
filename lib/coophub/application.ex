defmodule Coophub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Cachex.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      CoophubWeb.Endpoint,
      # Starts a worker by calling: Coophub.Worker.start_link(arg)
      # {Coophub.Worker, arg},
      %{
        id: CachexRepos,
        start:
          {Cachex, :start_link,
           [
             :repos_cache,
             [
               warmers: [
                 warmer(module: Coophub.Repos.Warmer)
               ],
               expiration: expiration(default: :timer.minutes(60))
             ]
           ]}
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
end

defmodule CoophubWeb.OrgController do
  use CoophubWeb, :controller

  require Logger

  action_fallback(CoophubWeb.FallbackController)

  def index(conn, _) do
    {:ok, keys} = Cachex.keys(:repos_cache)

    orgs_repos =
      keys
      |> Enum.reduce(%{}, fn key, acc ->
        {:ok, repos} = Cachex.get(:repos_cache, key)
        acc |> Map.put_new(key, repos)
      end)

    if Mix.env() == :dev do
      dump_file = Application.get_env(:coophub, :cachex_dump)
      Cachex.dump(:repos_cache, dump_file)
    end

    render(conn, "index.json", orgs_repos: orgs_repos)
  end

  def show(conn, %{"name" => name}) do
    case Cachex.get(:repos_cache, name) do
      {:ok, nil} ->
        render(conn, 404)

      {:ok, repos} ->
        render(conn, "show.json", repos: repos)

      {:error, err} ->
        Logger.error("Could not get repos for org '#{name}': #{inspect(err)}")
        render(conn, 500)
    end
  end
end

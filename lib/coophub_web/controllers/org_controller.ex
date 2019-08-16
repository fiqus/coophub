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
        conn
        |> put_status(:not_found)
        |> render(CoophubWeb.ErrorView, :"404")

      {:ok, repos} ->
        render(conn, "show.json", repos: repos)

      {:error, err} ->
        Logger.error("Could not get repos for org '#{name}': #{inspect(err)}")
        conn
        |> put_status(:unprocessable_entity)
        |> render(CoophubWeb.ErrorView, :"500")
    end
  end

  def show_latest(conn, %{"name" => name}) do
    case Cachex.get(:repos_cache, name) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> render(CoophubWeb.ErrorView, :"404")

      {:ok, org} ->
        repos =
          org["repos"]
          |> Enum.sort(&dates_comparer/2)
          |> Enum.take(3)
        render(conn, "show.json", repos: repos)

      {:error, err} ->
        Logger.error("Could not get repos for org '#{name}': #{inspect(err)}")
        conn
        |> put_status(:unprocessable_entity)
        |> render(CoophubWeb.ErrorView, :"500")
    end
  end

  def show_popular(conn, %{"name" => name}) do
    case Cachex.get(:repos_cache, name) do
      {:ok, nil} ->
        conn
        |> put_status(:not_found)
        |> render(CoophubWeb.ErrorView, :"404")

      {:ok, org} ->
        repos =
          org["repos"]
          |> Enum.sort(& repo_popularity(&1) >= repo_popularity(&2))
          |> Enum.take(3)
        render(conn, "show.json", repos: repos)

      {:error, err} ->
        Logger.error("Could not get repos for org '#{name}': #{inspect(err)}")
        conn
        |> put_status(:unprocessable_entity)
        |> render(CoophubWeb.ErrorView, :"500")
    end
  end

  defp dates_comparer(repo1, repo2) do
    {:ok, datetime1, _} = DateTime.from_iso8601(repo1["pushed_at"])
    {:ok, datetime2, _} = DateTime.from_iso8601(repo2["pushed_at"])
    DateTime.compare(datetime1, datetime2) === :gt
  end

  defp repo_popularity(repo) do
    repo["watchers_count"] + repo["stargazers_count"] * 2 + repo["forks_count"] * 3
  end
end

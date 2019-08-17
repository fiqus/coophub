defmodule CoophubWeb.RepoController do
  use CoophubWeb, :controller

  require Logger

  action_fallback(CoophubWeb.FallbackController)

  @forks_factor 1.7
  @stargazers_factor 1.5
  @open_issues_factor 1.3
  @fork_coeficient 0.5
  @gravity 1.8

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

  def orgs_repos(conn, %{"name" => name}) do
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

  def org_repos_latest(conn, %{"name" => name}) do
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

  def org_repos_popular(conn, %{"name" => name}) do
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

  def repos_latest(conn, _params) do
    repos =
      get_all_repos()
      |> Enum.sort(&dates_comparer/2)
      |> Enum.take(3)
    render(conn, "show.json", repos: repos)
  end

  def repos_popular(conn, _params) do
    repos =
      get_all_repos()
      |> Enum.sort(& repo_popularity(&1) >= repo_popularity(&2))
      |> Enum.take(3)
    render(conn, "show.json", repos: repos)
  end

  defp dates_comparer(repo1, repo2) do
    {:ok, datetime1, _} = DateTime.from_iso8601(repo1["pushed_at"])
    {:ok, datetime2, _} = DateTime.from_iso8601(repo2["pushed_at"])
    DateTime.compare(datetime1, datetime2) === :gt
  end

  # based on https://gist.github.com/soulim/d69e5dabc511c325f089
  defp repo_popularity(repo) do
    rating = repo["stargazers_count"] * @stargazers_factor + repo["forks_count"] * @forks_factor + repo["open_issues_count"] * @open_issues_factor
    if repo["fork"] do
      rating = rating * @fork_coeficient
    end

    {:ok, pushed_at_datetime, _} = DateTime.from_iso8601(repo["pushed_at"])
    divisor =
      ((DateTime.utc_now() |> DateTime.to_unix()) - (pushed_at_datetime |> DateTime.to_unix())) / 3600
      |> :math.pow(@gravity)

    rating / divisor
  end

  defp get_all_repos() do
    {:ok, keys} = Cachex.keys(:repos_cache)
    Enum.map(keys, fn key ->
      case Cachex.get(:repos_cache, key) do
        {:ok, nil} -> []
        {:ok, org} -> org["repos"]
        _ -> []
      end
    end)
    |> List.flatten()
  end
end

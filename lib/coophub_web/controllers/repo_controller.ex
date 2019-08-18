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
    case Repos.get_all_orgs() do
      :error -> render_status(conn, 500)
      orgs_repos -> render(conn, "index.json", orgs_repos: orgs_repos)
    end
  end

  def org_repos(conn, %{"name" => name}) do
    case Repos.get_org(name) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      org -> render(conn, "show.json", repos: org)
    end
  end

  def org_repos_latest(conn, %{"name" => name}) do
    case Repos.get_org_repos(name) do
      :error ->
        render_status(conn, 500)

      nil ->
        render_status(conn, 404)

      repos ->
        repos =
          repos
          |> Enum.sort(&dates_comparer/2)
          |> Enum.take(3)

        render(conn, "show.json", repos: repos)
    end
  end

  def org_repos_popular(conn, %{"name" => name}) do
    case Repos.get_org_repos(name) do
      :error ->
        render_status(conn, 500)

      nil ->
        render_status(conn, 404)

      repos ->
        repos =
          repos
          |> Enum.sort(&(repo_popularity(&1) >= repo_popularity(&2)))
          |> Enum.take(3)

        render(conn, "show.json", repos: repos)
    end
  end

  def repos_latest(conn, _params) do
    case Repos.get_all_repos() do
      :error ->
        render_status(conn, 500)

      repos ->
        repos =
          repos
          |> Enum.sort(&dates_comparer/2)
          |> Enum.take(3)

        render(conn, "show.json", repos: repos)
    end
  end

  def repos_popular(conn, _params) do
    case Repos.get_all_repos() do
      :error ->
        render_status(conn, 500)

      repos ->
        repos =
          repos
          |> Enum.sort(&(repo_popularity(&1) >= repo_popularity(&2)))
          |> Enum.take(3)

        render(conn, "show.json", repos: repos)
    end
  end

  defp dates_comparer(repo1, repo2) do
    {:ok, datetime1, _} = DateTime.from_iso8601(repo1["pushed_at"])
    {:ok, datetime2, _} = DateTime.from_iso8601(repo2["pushed_at"])
    DateTime.compare(datetime1, datetime2) === :gt
  end

  # based on https://gist.github.com/soulim/d69e5dabc511c325f089
  defp repo_popularity(repo) do
    rating =
      repo["stargazers_count"] * @stargazers_factor + repo["forks_count"] * @forks_factor +
        repo["open_issues_count"] * @open_issues_factor

    rating =
      if repo["fork"],
        do: rating * @fork_coeficient,
        else: rating

    {:ok, pushed_at_datetime, _} = DateTime.from_iso8601(repo["pushed_at"])

    divisor =
      (((DateTime.utc_now() |> DateTime.to_unix()) - (pushed_at_datetime |> DateTime.to_unix())) /
         3600)
      |> :math.pow(@gravity)

    rating / divisor
  end
end

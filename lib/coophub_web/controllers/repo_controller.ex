defmodule CoophubWeb.RepoController do
  use CoophubWeb, :controller

  require Logger

  @default_repos_limit 3

  action_fallback(CoophubWeb.FallbackController)

  def index(conn, _) do
    case Repos.get_all_orgs() do
      :error -> render_status(conn, 500)
      orgs -> render(conn, "index.json", orgs: orgs)
    end
  end

  def org_repos(conn, %{"name" => name}) do
    case Repos.get_org(name) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      org -> render(conn, "org.json", org: org)
    end
  end

  def org_repos_latest(conn, %{"name" => name} = params) do
    limit = get_limit(params)
    case Repos.get_org_repos_latest(name, limit) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end

  def org_repos_popular(conn, %{"name" => name} = params) do
    limit = get_limit(params)
    case Repos.get_org_repos_popular(name, limit) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end

  defp get_limit(%{"limit" => limit}) do
    try do
      String.to_integer(limit)
    rescue
      _ -> @default_repos_limit
    end
  end

  defp get_limit(_), do: @default_repos_limit

  def repos_latest(conn, params) do
    params
    |> get_limit()
    |> Repos.get_repos_latest()
    |> case do
      :error -> render_status(conn, 500)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end

  def repos_popular(conn, params) do
    params
    |> get_limit()
    |> Repos.get_repos_popular()
    |> case do
      :error -> render_status(conn, 500)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end
end

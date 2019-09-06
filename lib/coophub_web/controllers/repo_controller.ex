defmodule CoophubWeb.RepoController do
  use CoophubWeb, :controller

  require Logger

  action_fallback(CoophubWeb.FallbackController)

  def index(conn, _) do
    case Repos.get_all_orgs() do
      :error -> render_status(conn, 500)
      orgs -> render(conn, "index.json", orgs: orgs)
    end
  end

  def org(conn, %{"name" => name}) do
    case Repos.get_org_info(name) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      org -> render(conn, "org.json", org: org)
    end
  end

  def org_repos(conn, %{"name" => name} = params) do
    limit = get_limit(params)
    sort = Map.get(params, "sort", "latest")

    case Repos.get_org_repos(name, sort, limit) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      org -> render(conn, "org.json", org: org)
    end
  end

  def repos(conn, params) do
    limit = get_limit(params)
    sort = Map.get(params, "sort", "latest")

    case Repos.get_repos(sort, limit) do
      :error -> render_status(conn, 500)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end

  defp get_limit(%{"limit" => limit}) do
    try do
      String.to_integer(limit)
    rescue
      _ -> nil
    end
  end

  defp get_limit(_), do: nil
end

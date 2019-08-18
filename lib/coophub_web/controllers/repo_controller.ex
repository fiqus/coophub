defmodule CoophubWeb.RepoController do
  use CoophubWeb, :controller

  require Logger

  action_fallback(CoophubWeb.FallbackController)

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
    case Repos.get_org_repos_latest(name, 3) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      repos -> render(conn, "show.json", repos: repos)
    end
  end

  def org_repos_popular(conn, %{"name" => name}) do
    case Repos.get_org_repos_popular(name, 3) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      repos -> render(conn, "show.json", repos: repos)
    end
  end

  def repos_latest(conn, _params) do
    case Repos.get_repos_latest(3) do
      :error -> render_status(conn, 500)
      repos -> render(conn, "show.json", repos: repos)
    end
  end

  def repos_popular(conn, _params) do
    case Repos.get_repos_popular(3) do
      :error -> render_status(conn, 500)
      repos -> render(conn, "show.json", repos: repos)
    end
  end
end

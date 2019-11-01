defmodule CoophubWeb.RepoController do
  use CoophubWeb, :controller

  require Logger

  action_fallback(CoophubWeb.FallbackController)

  def index(conn, params) do
    sort = get_sort(params)
    limit = get_limit(params)

    case Repos.get_orgs(sort, limit) do
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
    sort = get_sort(params)
    limit = get_limit(params)

    case Repos.get_org_repos(name, sort, limit) do
      :error -> render_status(conn, 500)
      nil -> render_status(conn, 404)
      org -> render(conn, "org.json", org: org)
    end
  end

  def repos(conn, params) do
    sort = get_sort(params)
    limit = get_limit(params)

    case Repos.get_repos(sort, limit) do
      :error -> render_status(conn, 500)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end

  def search(conn, params) do
    topic = get_topic(params)

    case Repos.search(topic) do
      :error -> render_status(conn, 500)
      repos -> render(conn, "repos.json", repos: repos)
    end
  end

  def topics(conn, _params) do
    case Repos.get_topics() do
      :error -> render_status(conn, 500)
      topics -> render(conn, "topics.json", topics: topics)
    end
  end

  defp get_sort(params) do
    %{
      "field" => Map.get(params, "sort", "latest"),
      "dir" => Map.get(params, "dir", "desc")
    }
  end

  defp get_limit(params) do
    try do
      case Map.get(params, "limit") |> String.to_integer() do
        num when num > 0 -> num
        _ -> nil
      end
    rescue
      _ -> nil
    end
  end

  defp get_topic(params) do
    try do
      Map.get(params, "topic")
    rescue
      _ -> nil
    end
  end
end

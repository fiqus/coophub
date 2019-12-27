defmodule CoophubWeb.RepoController do
  use CoophubWeb, :controller

  require Logger

  @uris_cache_name Application.get_env(:coophub, :uris_cache_name)
  @uris_cache_success [:ok, :commit, :ignore]
  action_fallback(CoophubWeb.FallbackController)

  def index(conn, params) do
    sort = get_sort(params)
    limit = get_limit(params)

    fallback_mfa = {Repos, :get_orgs, [sort, limit]}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {status, orgs} when status in @uris_cache_success -> render(conn, "index.json", orgs: orgs)
      _ -> render_status(conn, 500)
    end
  end

  def org(conn, %{"name" => name}) do
    fallback_mfa = {Repos, :get_org_info, [name]}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {_, nil} -> render_status(conn, 404)
      {status, org} when status in @uris_cache_success -> render(conn, "org.json", org: org)
      _ -> render_status(conn, 500)
    end
  end

  def org_repos(conn, %{"name" => name} = params) do
    sort = get_sort(params)
    limit = get_limit(params)

    fallback_mfa = {Repos, :get_org_repos, [name, sort, limit]}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {_, nil} -> render_status(conn, 404)
      {status, org} when status in @uris_cache_success -> render(conn, "org.json", org: org)
      _ -> render_status(conn, 500)
    end
  end

  def repos(conn, params) do
    sort = get_sort(params)
    limit = get_limit(params)
    exclude_forks = get_exclude_forks(params)

    fallback_mfa = {Repos, :get_repos, [sort, limit, exclude_forks]}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {status, repos} when status in @uris_cache_success ->
        render(conn, "repos.json", repos: repos)

      _ ->
        render_status(conn, 500)
    end
  end

  def search(conn, params) do
    query = get_search_query(params)

    fallback_mfa = {Repos, :search, [query]}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {status, repos} when status in @uris_cache_success ->
        render(conn, "repos.json", repos: repos)

      _ ->
        render_status(conn, 500)
    end
  end

  def topics(conn, _params) do
    fallback_mfa = {Repos, :get_topics, []}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {status, topics} when status in @uris_cache_success ->
        render(conn, "topics.json", topics: topics)

      _ ->
        render_status(conn, 500)
    end
  end

  def languages(conn, _params) do
    fallback_mfa = {Repos, :get_languages, []}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {status, languages} when status in @uris_cache_success ->
        render(conn, "languages.json", languages: languages)

      _ ->
        render_status(conn, 500)
    end
  end

  def language(conn, %{"lang" => lang}) do
    fallback_mfa = {Repos, :get_repos_by_language, [lang]}

    case maybe_get_response_from_cache(conn, fallback_mfa) do
      {status, repos} when status in @uris_cache_success ->
        render(conn, "repos.json", repos: repos)

      _ ->
        render_status(conn, 500)
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

  defp get_exclude_forks(%{"exclude_forks" => "true"}), do: true
  defp get_exclude_forks(_), do: false

  defp get_search_query(params) do
    %{
      "terms" => Map.get(params, "q", "") |> split_values(),
      "topics" => Map.get(params, "topic", "") |> split_values()
    }
  end

  defp split_values(string), do: String.split(string, [" ", ","], trim: true)

  defp maybe_get_response_from_cache(%Plug.Conn{method: "GET"} = conn, {mod, fun, args}) do
    key = "#{conn.request_path}?#{conn.query_string}"
    Logger.debug("Using key #{key} for memoization")

    Cachex.fetch(@uris_cache_name, key, fn ->
      Logger.debug("Getting from the Repos service")

      case apply(mod, fun, args) do
        :error -> {:ignore, :error}
        empty when empty in [[], %{}] -> {:ignore, empty}
        results -> {:commit, results}
      end
    end)
  end

  defp maybe_get_response_from_cache(_, {mod, fun, args}) do
    case apply(mod, fun, args) do
      :error -> :error
      results -> {:ok, results}
    end
  end
end

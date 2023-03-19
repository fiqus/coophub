defmodule Coophub.Repos do
  require Logger

  alias Coophub.Schemas.{Organization, Repository}

  @repos_cache_name Application.compile_env(:coophub, :main_cache_name)
  @forks_factor 1.7
  @stargazers_factor 1.5
  @open_issues_factor 0.3
  @fork_coeficient 0.5
  @gravity 1.8
  @percentage_for_updated_time 0.8

  @typedoc """
  org is a struct representing an organization
  """
  @type org :: Organization.t()

  @typedoc """
  repo is a struct representing a repository
  """
  @type repo :: Repository.t()

  @typedoc """
  Repos is a list of repo maps
  """
  @type repos :: list(repo()) | []

  @typedoc """
  Orgs is a list of org maps
  """
  @type orgs :: list(org()) | []
  @type orgs_map :: %{required(binary) => org()}

  @spec get_all_orgs :: orgs_map() | :error
  def get_all_orgs() do
    case Cachex.keys(@repos_cache_name) do
      {:ok, keys} ->
        Enum.reduce(keys, %{}, fn key, acc ->
          case get_org(key) do
            %{} = org -> acc |> Map.put_new(key, org)
            _ -> acc
          end
        end)

      {:error, err} ->
        Logger.error("Could not get all orgs from cache: #{inspect(err)}")
        :error
    end
  end

  @spec get_all_repos :: repos() | :error
  def get_all_repos() do
    case Cachex.keys(@repos_cache_name) do
      {:ok, keys} ->
        Enum.map(keys, fn key ->
          case get_org(key) do
            %{repos: repos} -> repos
            _ -> []
          end
        end)
        |> List.flatten()

      {:error, err} ->
        Logger.error("Could not get all repos from cache: #{inspect(err)}")
        :error
    end
  end

  @spec get_orgs(map, integer | nil) :: orgs() | :error
  def get_orgs(sort, limit \\ nil) do
    case get_all_orgs() do
      orgs when is_map(orgs) ->
        orgs
        |> Map.values()
        # Clear repos!
        |> Enum.map(&Map.put(&1, :repos, []))
        |> orgs_sort_by(sort, limit)

      err ->
        err
    end
  end

  @spec org_exists?(String.t()) :: bool()
  def org_exists?(org_name) do
    case Cachex.exists?(@repos_cache_name, org_name) do
      {:ok, true} -> true
      _ -> false
    end
  end

  @spec get_org(String.t()) :: org() | nil | :error
  def get_org(org_name) do
    case Cachex.get(@repos_cache_name, org_name) do
      {:ok, org} ->
        org

      {:error, err} ->
        Logger.error("Could not get org '#{org_name}' from cache: #{inspect(err)}")
        :error
    end
  end

  @spec get_org_info(String.t()) :: org() | nil | :error
  def get_org_info(org_name) do
    case get_org(org_name) do
      # Clear repos!
      %Organization{} = org -> org |> Map.put(:repos, [])
      err -> err
    end
  end

  @spec get_org_repos(String.t(), map, integer | nil) :: repos() | nil | :error
  def get_org_repos(org_name, sort, limit \\ nil) do
    case get_org(org_name) do
      %Organization{repos: repos} -> repos_sort_by(repos, sort, limit)
      err -> err
    end
  end

  @spec get_repos(map, integer | nil, boolean()) :: repos() | :error
  def get_repos(sort, limit, exclude_forks \\ false) do
    case get_all_repos() do
      repos when is_list(repos) -> repos_sort_by(repos, sort, limit, exclude_forks)
      err -> err
    end
  end

  @spec get_counters() :: map | :error
  def get_counters() do
    case get_all_orgs() do
      orgs when is_map(orgs) ->
        orgs
        |> Map.values()
        |> Enum.reduce(%{"orgs" => 0, "repos" => 0}, fn org, acc ->
          acc
          |> Map.put("orgs", acc["orgs"] + 1)
          |> Map.put("repos", acc["repos"] + org.repo_count)
        end)

      err ->
        err
    end
  end

  @spec get_topics() :: [map] | :error
  def get_topics() do
    case get_all_repos() do
      :error ->
        :error

      repos ->
        repos
        |> Enum.reduce(%{}, &process_topics/2)
        |> Map.values()
        |> Enum.sort(&(&1["topic"] < &2["topic"]))
    end
  end

  # based on https://gist.github.com/soulim/d69e5dabc511c325f089
  @spec get_repo_popularity(repo()) :: float
  def get_repo_popularity(repo) do
    rating =
      repo.stargazers_count * @stargazers_factor + repo.forks_count * @forks_factor +
        repo.open_issues_count * @open_issues_factor

    rating =
      if repo.fork,
        do: rating * @fork_coeficient,
        else: rating

    repo_date = repo.pushed_at || repo.updated_at || repo.created_at
    {:ok, repo_datetime, _} = DateTime.from_iso8601(repo_date)

    divisor =
      (((DateTime.utc_now() |> DateTime.to_unix()) - (repo_datetime |> DateTime.to_unix())) /
         3600)
      |> :math.pow(@gravity)

    rating + rating * @percentage_for_updated_time / divisor
  end

  @spec get_org_popularity(org()) :: float
  def get_org_popularity(%Organization{:repos => repos}) do
    Enum.reduce(repos, 0, fn %Repository{:popularity => pop}, acc -> acc + pop end)
  end

  @spec get_languages() :: map
  def get_languages() do
    case get_all_orgs() do
      orgs when is_map(orgs) ->
        orgs
        |> Enum.map(fn {_org_name, %Organization{languages: languages}} ->
          languages
        end)
        |> List.flatten()
        |> Enum.map(fn %{"lang" => lang, "percentage" => percentage} ->
          %{lang => percentage}
        end)
        |> Enum.reduce(%{}, fn lang_orgs_stats, acc ->
          Map.merge(lang_orgs_stats, acc, fn _key, x1, x2 -> x1 + x2 end)
        end)
        |> get_percentages_by_language()

      :error ->
        :error
    end
  end

  @spec get_org_languages(org()) :: map
  def get_org_languages(%Organization{repos: repos}) do
    Enum.reduce(repos, %{}, fn %Repository{languages: languages} = repo, acc ->
      if not repo.fork do
        Enum.reduce(languages, acc, fn {lang, %{"percentage" => percentage}}, acc_repo ->
          acc_lang = Map.get(acc, lang, 0)
          Map.put(acc_repo, lang, acc_lang + percentage)
        end)
      else
        acc
      end
    end)
    |> get_percentages_by_language()
  end

  defp get_percentages_by_language(languages) do
    total = Enum.reduce(languages, 0, fn {_lang, percentage}, acc -> acc + percentage end)

    Enum.reduce(languages, %{}, fn {lang, percentage}, acc ->
      percentage_for_lang = (percentage * 100 / total) |> Float.round(2)
      Map.put(acc, lang, %{"percentage" => percentage_for_lang})
    end)
  end

  @spec get_repos_by_language(any) :: repos() | :error
  def get_repos_by_language(lang) do
    case get_all_repos() do
      :error ->
        :error

      repos ->
        repos
        |> Enum.filter(&repo_has_lang?(&1, lang))
        |> sort_and_take(&sort_field_popularity/1, "desc", nil)
    end
  end

  @spec to_struct(module, map | [map]) :: struct | [struct]
  def to_struct(_, []), do: []
  def to_struct(module, [data | tail]), do: [to_struct(module, data) | to_struct(module, tail)]

  def to_struct(module, map) when is_map(map) do
    map_with_atom_keys = for {k, v} <- map, into: %{}, do: {String.to_atom(k), v}
    struct(module, map_with_atom_keys)
  end

  @spec repo_has_lang?(repo(), String.t()) :: boolean()
  defp repo_has_lang?(repo, lang) do
    Enum.find(repo.languages, fn %{"lang" => repo_lang} ->
      String.downcase(repo_lang) == String.downcase(lang)
    end) !== nil
  end

  @spec get_org_last_activity(org()) :: float
  def get_org_last_activity(org) do
    init = org.updated_at || org.created_at

    Enum.reduce(org.repos, init, fn repo, org_date ->
      repo_date = repo.pushed_at || repo.updated_at || repo.created_at
      if repo_date > org_date, do: repo_date, else: org_date
    end)
  end

  @spec search(binary | list | map, atom) :: :error | repos()
  def search(terms, style \\ :and)
  def search(term, style) when is_binary(term), do: search([term], style)
  def search(terms, style) when is_list(terms), do: search(%{"terms" => terms}, style)

  def search(query, style) do
    case get_all_repos() do
      repos when is_list(repos) ->
        repos
        |> Enum.filter(&is_repo_matching_query?(&1, query, style))
        |> sort_and_take(&sort_field_popularity/1, "desc", nil)

      err ->
        err
    end
  end

  defp is_repo_matching_query?(repo, %{"terms" => [_ | _] = terms}, style),
    do: is_repo_matching_func?(repo, &repo_matches_term?/2, terms, style)

  defp is_repo_matching_query?(repo, %{"topics" => [_ | _] = terms}, style),
    do: is_repo_matching_func?(repo, &repo_matches_topic?/2, terms, style)

  defp is_repo_matching_query?(_repo, _query, _style), do: false

  defp is_repo_matching_func?(_repo, _func, [], :and), do: true
  defp is_repo_matching_func?(_repo, _func, [], _style), do: false

  defp is_repo_matching_func?(repo, func, [term | terms], style) do
    matches? = func.(repo, term)

    if style == :and,
      do: matches? and is_repo_matching_func?(repo, func, terms, style),
      else: matches? or is_repo_matching_func?(repo, func, terms, style)
  end

  defp repo_matches_term?(repo, term) do
    re = Regex.compile!(term, "iu")

    Regex.match?(re, repo.key) ||
      Regex.match?(re, repo.name) ||
      Regex.match?(re, repo.description || "") ||
      Enum.find(repo.topics, &Regex.match?(re, &1)) != nil ||
      Enum.find(repo.languages, &Regex.match?(re, &1["lang"])) != nil
  end

  defp repo_matches_topic?(repo, topic) do
    Enum.find(repo.topics, &(&1 == topic)) != nil
  end

  defp process_topics(repo, topics) do
    repo
    |> Map.get(:topics, [])
    |> Enum.reduce(topics, fn topic, acc ->
      stats = %{
        "topic" => topic,
        "count" => (Map.get(acc, topic, %{}) |> Map.get("count", 0)) + 1,
        "orgs" => [repo.key | Map.get(acc, topic, %{}) |> Map.get("orgs", [])] |> Enum.uniq()
      }

      Map.put(acc, topic, stats)
    end)
  end

  defp orgs_sort_by(orgs, %{"field" => "popular", "dir" => dir}, limit) do
    sort_and_take(orgs, &sort_field_popularity/1, dir, limit)
  end

  defp orgs_sort_by(orgs, %{"dir" => dir}, limit) do
    sort_and_take(orgs, &sort_org_last_activity/1, dir, limit)
  end

  defp repos_sort_by(repos, params, limit, exclude_forks \\ false)

  defp repos_sort_by(repos, %{"field" => "popular", "dir" => dir}, limit, exclude_forks) do
    sort_and_take(repos, &sort_field_popularity/1, dir, limit, exclude_forks)
  end

  defp repos_sort_by(repos, %{"dir" => dir}, limit, exclude_forks) do
    sort_and_take(repos, &sort_repo_last_activity/1, dir, limit, exclude_forks)
  end

  defp sort_and_take(enum, sort_fn, dir, limit, exclude_forks \\ false) do
    sorted = enum |> sort(sort_fn, dir)

    sorted =
      if exclude_forks do
        Enum.reject(sorted, & &1.fork)
      else
        sorted
      end

    case limit do
      num when is_integer(num) and num > 0 -> Enum.take(sorted, num)
      _ -> sorted
    end
  end

  defp sort(enum, sort_fn, "asc"), do: Enum.sort(enum, &(sort_fn.(&1) < sort_fn.(&2)))
  defp sort(enum, sort_fn, _), do: Enum.sort(enum, &(sort_fn.(&1) >= sort_fn.(&2)))

  defp sort_org_last_activity(%Organization{last_activity: last_activity}) do
    sort_field_date(last_activity)
  end

  defp sort_repo_last_activity(%Repository{
         pushed_at: pushed_at,
         updated_at: updated_at,
         created_at: created_at
       }) do
    sort_field_date(pushed_at || updated_at || created_at)
  end

  defp sort_field_date(date) when is_binary(date) do
    case DateTime.from_iso8601(date) do
      {:ok, datetime, _} -> DateTime.to_unix(datetime)
      _ -> 0
    end
  end

  defp sort_field_date(_date), do: 0

  defp sort_field_popularity(%{popularity: popularity}) do
    popularity || 0
  end
end

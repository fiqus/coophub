defmodule Coophub.Repos do
  require Logger

  @repos_cache_name Application.get_env(:coophub, :cachex_name)
  @forks_factor 1.7
  @stargazers_factor 1.5
  @open_issues_factor 1.3
  @fork_coeficient 0.5
  @gravity 1.8

  @spec get_all_orgs :: map | :error
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

  @spec get_all_repos :: [map] | :error
  def get_all_repos() do
    case Cachex.keys(@repos_cache_name) do
      {:ok, keys} ->
        Enum.map(keys, fn key ->
          case get_org(key) do
            %{"repos" => repos} -> repos
            _ -> []
          end
        end)
        |> List.flatten()

      {:error, err} ->
        Logger.error("Could not get all repos from cache: #{inspect(err)}")
        :error
    end
  end

  @spec get_orgs(map, integer | nil) :: [map] | :error
  def get_orgs(sort, limit \\ nil) do
    case get_all_orgs() do
      orgs when is_map(orgs) ->
        orgs
        |> Map.values()
        |> Enum.map(&Map.delete(&1, "repos"))
        |> orgs_sort_by(sort, limit)

      err ->
        err
    end
  end

  @spec get_org(String.t()) :: map | nil | :error
  def get_org(org_name) do
    case Cachex.get(@repos_cache_name, org_name) do
      {:ok, org} ->
        org

      {:error, err} ->
        Logger.error("Could not get org '#{org_name}' from cache: #{inspect(err)}")
        :error
    end
  end

  @spec get_org_info(String.t()) :: map | nil | :error
  def get_org_info(org_name) do
    case get_org(org_name) do
      nil -> nil
      :error -> :error
      org -> org |> Map.delete("repos")
    end
  end

  @spec get_org_repos(String.t(), map, integer | nil) :: [map] | nil | :error
  def get_org_repos(org_name, sort, limit \\ nil) do
    case get_org(org_name) do
      %{"repos" => repos} ->
        repos_sort_by(repos, sort, limit)

      err ->
        err
    end
  end

  @spec get_repos(map, integer | nil) :: [map] | nil | :error
  def get_repos(sort, limit \\ nil) do
    case get_all_repos() do
      repos when is_list(repos) ->
        repos_sort_by(repos, sort, limit)

      err ->
        err
    end
  end

  def get_topics() do
    case get_all_repos() do
      :error ->
        :error

      repos ->
        repos
        |> Enum.map(&(Map.get(&1, "topics", [])))
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.sort(&(&1 < &2))
    end
  end

  # based on https://gist.github.com/soulim/d69e5dabc511c325f089
  @spec get_repo_popularity(map) :: float
  def get_repo_popularity(repo) do
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

  @spec get_org_popularity(map) :: float
  def get_org_popularity(%{"repos" => repos}) do
    Enum.reduce(repos, 0, fn %{"popularity" => pop}, acc -> acc + pop end)
  end

  @spec get_languages_stats(map) :: map
  def get_languages_stats(languages) do
    total = Enum.reduce(languages, 0, fn {_lang, bytes}, acc -> acc + bytes end)

    Enum.reduce(languages, %{}, fn {lang, bytes}, acc ->
      percentage = (bytes / total * 100) |> Float.round(2)
      Map.put(acc, lang, %{"bytes" => bytes, "percentage" => percentage})
    end)
  end

  @spec get_org_languages_stats(map) :: map
  def get_org_languages_stats(%{"repos" => repos}) do
    languages =
      Enum.reduce(repos, %{}, fn %{"languages" => langs}, acc ->
        Enum.reduce(langs, acc, fn {lang, %{"bytes" => bytes}}, acc_repo ->
          acc_lang = Map.get(acc, lang, 0)
          Map.put(acc_repo, lang, acc_lang + bytes)
        end)
      end)

    get_languages_stats(languages)
  end

  @spec get_org_last_activity(map) :: float
  def get_org_last_activity(org) do
    init = org["updated_at"] || org["created_at"]

    Enum.reduce(org["repos"], init, fn repo, org_date ->
      repo_date = repo["pushed_at"] || repo["updated_at"] || repo["created_at"]
      if repo_date > org_date, do: repo_date, else: org_date
    end)
  end

  @spec search(binary | list) :: :error | [map]
  def search(term) when is_binary(term), do: search([term])
  @spec search(list, atom) :: :error | [map]
  def search(terms, style \\ :and) when is_list(terms) do
    case get_all_repos() do
      repos when is_list(repos) ->
        Enum.filter(repos, &is_repo_matching_terms?(&1, terms, style))

      err ->
        err
    end
  end

  defp is_repo_matching_terms?(_repo, [], :and), do: true
  defp is_repo_matching_terms?(_repo, [], _style), do: false

  defp is_repo_matching_terms?(repo, [term | terms], style) do
    matches? = is_repo_matching_term?(repo, term)

    if style == :and,
      do: matches? and is_repo_matching_terms?(repo, terms, style),
      else: matches? or is_repo_matching_terms?(repo, terms, style)
  end

  # @TODO WIP: Add more fields to match?
  defp is_repo_matching_term?(repo, term) do
    Enum.find(repo["topics"], &(&1 == term)) != nil
  end

  defp orgs_sort_by(orgs, %{"field" => "popular", "dir" => dir}, limit) do
    sort_and_take(orgs, &sort_field_popularity/1, dir, limit)
  end

  defp orgs_sort_by(orgs, %{"dir" => dir}, limit) do
    sort_and_take(orgs, &sort_field_last_activity/1, dir, limit)
  end

  defp repos_sort_by(repos, %{"field" => "popular", "dir" => dir}, limit) do
    sort_and_take(repos, &sort_field_popularity/1, dir, limit)
  end

  defp repos_sort_by(repos, %{"dir" => dir}, limit) do
    sort_and_take(repos, &sort_pushed_at/1, dir, limit)
  end

  defp sort_and_take(enum, sort_fn, dir, limit) do
    sorted = enum |> sort(sort_fn, dir)

    case limit do
      num when is_integer(num) and num > 0 -> Enum.take(sorted, num)
      _ -> sorted
    end
  end

  defp sort(enum, sort_fn, "asc"), do: Enum.sort(enum, &(sort_fn.(&1) < sort_fn.(&2)))
  defp sort(enum, sort_fn, _), do: Enum.sort(enum, &(sort_fn.(&1) >= sort_fn.(&2)))

  defp sort_field_last_activity(%{"last_activity" => last_activity}) do
    sort_field_date(last_activity)
  end

  defp sort_pushed_at(%{"pushed_at" => pushed_at}) do
    sort_field_date(pushed_at)
  end

  defp sort_field_date(date) do
    case DateTime.from_iso8601(date) do
      {:ok, datetime, _} -> DateTime.to_unix(datetime)
      _ -> 0
    end
  end

  defp sort_field_popularity(data) do
    data["popularity"] || 0
  end
end

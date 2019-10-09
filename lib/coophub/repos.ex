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

  @spec get_orgs(String.t(), integer | nil) :: [map] | :error
  def get_orgs(sort, limit \\ nil) do
    case get_all_orgs() do
      orgs when is_map(orgs) ->
        orgs
        |> Map.values()
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

  @spec get_org_repos(String.t(), String.t(), integer | nil) :: [map] | nil | :error
  def get_org_repos(org_name, sort, limit \\ nil) do
    case get_org(org_name) do
      %{"repos" => repos} ->
        repos_sort_by(repos, sort, limit)

      err ->
        err
    end
  end

  @spec get_repos(String.t(), integer | nil) :: [map] | nil | :error
  def get_repos(sort, limit \\ nil) do
    case get_all_repos() do
      repos when is_list(repos) ->
        repos_sort_by(repos, sort, limit)

      err ->
        err
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

  defp orgs_sort_by(orgs, "popular", limit) do
    sort_and_take(orgs, &sort_field_popularity/1, limit)
  end

  defp orgs_sort_by(orgs, _, limit) do
    sort_and_take(orgs, &sort_field_last_activity/1, limit)
  end

  defp repos_sort_by(repos, "popular", limit) do
    sort_and_take(repos, &sort_field_popularity/1, limit)
  end

  defp repos_sort_by(repos, _, limit) do
    sort_and_take(repos, &sort_pushed_at/1, limit)
  end

  defp sort_and_take(enum, sort_fn, nil) do
    enum
    |> sort(sort_fn)
  end

  defp sort_and_take(enum, sort_fn, limit) do
    enum
    |> sort(sort_fn)
    |> Enum.take(limit)
  end

  defp sort(enum, sort_fn), do: Enum.sort(enum, &(sort_fn.(&1) >= sort_fn.(&2)))

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

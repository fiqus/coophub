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
        sort_by(sort, repos, limit)

      other ->
        other
    end
  end

  @spec get_repos(String.t(), integer | nil) :: [map] | nil | :error
  def get_repos(sort, limit \\ nil) do
    case get_all_repos() do
      repos when is_list(repos) ->
        sort_by(sort, repos, limit)

      err ->
        err
    end
  end

  defp sort_by("popular", repos, limit) do
    sort_and_take_repos(repos, &repo_popularity/1, limit)
  end

  defp sort_by(_, repos, limit) do
    sort_and_take_repos(repos, &repo_pushed_at/1, limit)
  end

  defp sort_and_take_repos(repos, sort_fn, nil) do
    repos
    |> sort(sort_fn)
  end

  defp sort_and_take_repos(repos, sort_fn, limit) do
    repos
    |> sort(sort_fn)
    |> Enum.take(limit)
  end

  defp sort(repos, sort_fn), do: Enum.sort(repos, &(sort_fn.(&1) >= sort_fn.(&2)))

  defp repo_pushed_at(repo) do
    {:ok, datetime, _} = DateTime.from_iso8601(repo["pushed_at"])
    DateTime.to_unix(datetime)
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

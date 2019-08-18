defmodule Coophub.Repos do
  require Logger

  @repos_cache_name :repos_cache
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

  @spec get_org_repos(String.t()) :: [map] | nil | :error
  def get_org_repos(org_name) do
    case get_org(org_name) do
      %{"repos" => repos} -> repos
      err -> err
    end
  end

  @spec get_org_repos_latest(String.t(), integer) :: [map] | nil | :error
  def get_org_repos_latest(org_name, qty) do
    case get_org_repos(org_name) do
      repos when is_list(repos) -> sort_and_take_repos(repos, &repo_pushed_at/1, qty)
      err -> err
    end
  end

  @spec get_org_repos_popular(String.t(), integer) :: [map] | nil | :error
  def get_org_repos_popular(org_name, qty) do
    case get_org_repos(org_name) do
      repos when is_list(repos) -> sort_and_take_repos(repos, &repo_popularity/1, qty)
      err -> err
    end
  end

  @spec get_repos_latest(integer) :: [map] | nil | :error
  def get_repos_latest(qty) do
    case get_all_repos() do
      repos when is_list(repos) -> sort_and_take_repos(repos, &repo_pushed_at/1, qty)
      err -> err
    end
  end

  @spec get_repos_popular(integer) :: [map] | nil | :error
  def get_repos_popular(qty) do
    case get_all_repos() do
      repos when is_list(repos) -> sort_and_take_repos(repos, &repo_popularity/1, qty)
      err -> err
    end
  end

  defp sort_and_take_repos(repos, func, qty) do
    repos
    |> Enum.sort(&(func.(&1) >= func.(&2)))
    |> Enum.take(qty)
  end

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

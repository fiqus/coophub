defmodule Coophub.CacheWarmer do
  use Cachex.Warmer

  alias Coophub.Repos
  alias Coophub.Backends
  alias Coophub.Schemas.Organization

  require Logger

  @repos_cache_name Application.get_env(:coophub, :main_cache_name)
  @repos_cache_interval Application.get_env(:coophub, :cache_interval)
  @repos_cache_dump_file Application.get_env(:coophub, :main_cache_dump_file)

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.minutes(@repos_cache_interval)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    ## Delay the execution a bit to ensure Cachex is available
    Process.sleep(2000)

    prev_size = Cachex.size(@repos_cache_name) |> elem(1)
    curr_size = maybe_load_dump(prev_size)
    maybe_warm_cache(Coophub.Application.env(), prev_size, curr_size)
  end

  ## Just load dump on the first warm cycle
  defp maybe_load_dump(0), do: load_cache_dump()
  defp maybe_load_dump(prev_size), do: prev_size

  ## Ignore the first warm cycle if we are at :dev and if dump has entries
  defp maybe_warm_cache(:dev, 0, curr_size) when curr_size > 0, do: :ignore
  defp maybe_warm_cache(_, _, _), do: warm_cache()

  defp warm_cache() do
    Logger.info("Warming repos into cache from remote backends..", ansi_color: :yellow)

    repos =
      read_yml()
      |> group_by_source()
      |> IO.inspect
      |> Enum.map(fn {key, yml_data} ->
        case get_org(key, yml_data) do
          :error -> []
          org -> get_org_with_repos(key, org)
        end
      end)

    spawn(save_cache_dump(repos))

    ## Set a very high TTL to ensure that memory and dump data don't expire
    ## in the case we aren't able to refresh data from github API, but..
    ## we will try to refresh it anyways every ":cache_interval" minutes!
    {:ok, repos, ttl: :timer.hours(24 * 365)}
  end

  def get_from_github(yml_orgs) do
    rate_limit = Backends.get_rate_limit("github")
    # 1 x org details
    # 1 x org repos
    # 1 x repo lang
    # 1 x repo topics
    # 202 is the worst number of requests x org
    Enum.take(yml_orgs, 1..floor(rate_limit / 202))
  end

  def group_by_source(yml_orgs) do
    # %{
    #    "github" => %{
    #       "fiqus" => %{ ... }
    #     },
    #    "gitlab" => %{
    #       "another" => %{ ... }
    #    }
    #}
    Enum.reduce(yml_orgs, %{}, fn {key, yml_data}, acc ->
      source_coops =
        acc
        |> Map.get(yml_data["source"], %{})
        |> Map.put(key, yml_data)
      Map.put(acc, yml_data["source"], source_coops)
    end)
  end

  defp save_cache_dump(repos) do
    fn ->
      ## Delay the execution a bit to ensure cache data is available
      Process.sleep(2000)

      case Cachex.dump(@repos_cache_name, @repos_cache_dump_file) do
        {:ok, true} ->
          Logger.info(
            "Saved repos cache dump with #{length(repos)} orgs to local file '#{
              @repos_cache_dump_file
            }'",
            ansi_color: :magenta
          )

        err ->
          Logger.error("Error saving repos cache dump: #{inspect(err)}")
      end
    end
  end

  defp load_cache_dump() do
    Logger.info("Warming repos into cache from dump..", ansi_color: :yellow)

    with {:ok, dump} <- read_cache_dump(@repos_cache_dump_file),
         {:ok, true} <- Cachex.import(@repos_cache_name, dump),
         {:ok, size} <- Cachex.size(@repos_cache_name) do
      Logger.info("The dump was loaded with #{size} orgs!", ansi_color: :magenta)
      size
    else
      _ ->
        Logger.info("Dump not found '#{@repos_cache_dump_file}'", ansi_color: :yellow)
        0
    end
  end

  defp read_cache_dump(path) do
    dump =
      path
      |> File.read!()
      ## Since our dump has atoms (because of the structs) we can't use Cachex.load()
      ## because it does :erlang.binary_to_term([:safe]) at Cachex.Disk.read()
      |> :erlang.binary_to_term()

    {:ok, dump}
  rescue
    _ ->
      {:error, :unreachable_file}
  end

  defp read_yml() do
    path = Path.join(File.cwd!(), "cooperatives.yml")
    {:ok, coops} = YamlElixir.read_from_file(path, maps_as_keywords: false)
    coops
  end

  ##
  ## Remote backends calls and handling functions
  ##

  defp get_org(key, %{"source" => source} = yml_data) do
    case Backends.get_org(source, key, yml_data) do
      %Organization{} = org -> org
      _ -> :error
    end
  end

  defp get_org_with_repos(key, %Organization{yml_data: %{"source" => source}} = org) do
    repos =
      Backends.get_repos(source, org)
      |> put_popularities()
      |> put_topics(org)
      |> put_languages(org)

    ## Set org repos and calculate some org-level stats
    org =
      org
      |> Map.put(:repos, repos)
      |> Map.put(:repo_count, Enum.count(repos))
      |> put_org_languages()
      |> put_org_popularity()
      |> put_org_last_activity()

    {key, org}
  end

  defp put_popularities(repos) do
    Enum.map(repos, &Map.put(&1, :popularity, Repos.get_repo_popularity(&1)))
  end

  defp put_topics(repos, %Organization{yml_data: %{"source" => source}} = org) do
    Enum.map(repos, fn repo ->
      topics = Backends.get_topics(source, org, repo)
      Map.put_new(repo, :topics, topics)
    end)
  end

  defp put_languages(repos, %Organization{yml_data: %{"source" => source}} = org) do
    Enum.map(repos, fn repo ->
      languages = Backends.get_languages(source, org, repo)
      Map.put(repo, :languages, languages)
    end)
  end

  defp put_org_languages(org) do
    Map.put(org, :languages, Repos.get_org_languages(org))
    |> convert_languages_to_list_and_sort()
  end

  defp convert_languages_to_list_and_sort(org) do
    repos =
      org
      |> Map.get(:repos, [])
      |> Enum.map(&languages_map_to_list_and_sort/1)

    org
    |> Map.put(:repos, repos)
    |> languages_map_to_list_and_sort()
  end

  defp languages_map_to_list_and_sort(datamap) do
    languages =
      datamap
      |> Map.get(:languages, [])
      |> Enum.map(fn {lang, stats} -> Map.put(stats, "lang", lang) end)
      |> Enum.sort(&(&1["percentage"] > &2["percentage"]))

    Map.put(datamap, :languages, languages)
  end

  defp put_org_popularity(org) do
    popularity = Repos.get_org_popularity(org)
    Map.put(org, :popularity, popularity)
  end

  defp put_org_last_activity(org) do
    last_activity = Repos.get_org_last_activity(org)
    Map.put(org, :last_activity, last_activity)
  end
end

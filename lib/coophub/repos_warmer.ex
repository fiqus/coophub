defmodule Coophub.Repos.Warmer do
  use Cachex.Warmer

  alias Coophub.Repos
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @repos_max_fetch Application.get_env(:coophub, :fetch_max_repos)
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
    Logger.info("Warming repos into cache from github..", ansi_color: :yellow)

    repos =
      read_yml()
      |> Enum.reduce([], fn {name, yml_data}, acc ->
        case get_org(name, yml_data) do
          :error -> acc
          org -> [get_repos(name, org) | acc]
        end
      end)

    spawn(save_cache_dump(repos))

    ## Set a very high TTL to ensure that memory and dump data don't expire
    ## in the case we aren't able to refresh data from github API, but..
    ## we will try to refresh it anyways every ":cache_interval" minutes!
    {:ok, repos, ttl: :timer.hours(24 * 365)}
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
            ansi_color: :green
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
      Logger.info("The dump was loaded with #{size} orgs!", ansi_color: :yellow)
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
      # Since our dump has atoms (because of the structs) we can't use Cachex.load()
      # because it does :erlang.binary_to_term([:safe]) at Cachex.Disk.read()
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
  ## Github API calls and handling functions
  ##

  defp get_repos(org_name, org) do
    org_repos =
      case call_api_get(
             "orgs/#{org_name}/repos?per_page=#{@repos_max_fetch}&type=public&sort=pushed&direction=desc"
           ) do
        {:ok, body} ->
          repos =
            body
            |> to_struct(Repository)
            |> put_key(org_name)
            |> put_popularities()
            |> put_topics(org_name)
            |> put_languages(org_name)
            |> put_repo_data(org_name)

          Logger.info("Fetched #{length(repos)} repos for #{org_name}", ansi_color: :yellow)
          repos

        {:error, reason} ->
          Logger.error(
            "Error getting the repos for '#{org_name}' from github: #{inspect(reason)}"
          )

          []
      end

    org =
      org
      |> Map.put(:repos, org_repos)
      |> Map.put(:repo_count, Enum.count(org_repos))
      |> put_org_languages_stats()
      |> put_org_popularity()
      |> put_org_last_activity()

    {org_name, org}
  end

  defp get_members(%Organization{:key => key} = org) do
    members =
      case call_api_get("orgs/#{key}/members") do
        {:ok, body} ->
          body

        {:error, reason} ->
          Logger.error("Error getting members for '#{key}' from github: #{inspect(reason)}")
          []
      end

    Map.put(org, :members, members)
  end

  defp get_org(name, yml_data) do
    case call_api_get("orgs/#{name}") do
      {:ok, org} ->
        msg =
          "Fetched '#{name}' organization! Getting members and repos (max=#{@repos_max_fetch}).."

        Logger.info(msg, ansi_color: :yellow)

        org
        |> to_struct(Organization)
        |> Map.put(:key, name)
        |> Map.put(:yml_data, yml_data)
        |> get_members()

      {:error, reason} ->
        Logger.error("Error getting the organization '#{name}' from github: #{inspect(reason)}")
        :error
    end
  end

  defp put_key(repos, key) do
    Enum.map(repos, &Map.put(&1, :key, key))
  end

  defp put_popularities(repos) do
    Enum.map(repos, &Map.put(&1, :popularity, Repos.get_repo_popularity(&1)))
  end

  defp put_topics(repos, org_name) do
    Enum.map(repos, fn repo ->
      repo_name = repo.name

      topics =
        case call_api_get("repos/#{org_name}/#{repo_name}/topics") do
          {:ok, body} ->
            body

          {:error, reason} ->
            Logger.error(
              "Error getting the topics for '#{org_name}/#{repo_name}' from github: #{
                inspect(reason)
              }"
            )

            %{}
        end

      Map.put(repo, :topics, Map.get(topics, "names", []))
    end)
  end

  defp put_languages(repos, org_name) do
    Enum.map(repos, fn repo ->
      repo_name = repo.name

      languages =
        case call_api_get("repos/#{org_name}/#{repo_name}/languages") do
          {:ok, body} ->
            body

          {:error, reason} ->
            Logger.error(
              "Error getting the languages for '#{org_name}/#{repo_name}' from github: #{
                inspect(reason)
              }"
            )

            %{}
        end

      put_repo_languages_stats(repo, languages)
    end)
  end

  defp put_repo_data(repos, org_name) do
    Enum.map(repos, fn repo ->
      repo_name = repo.name

      repo_data =
        case call_api_get("repos/#{org_name}/#{repo_name}") do
          {:ok, body} ->
            body

          {:error, reason} ->
            Logger.error(
              "Error getting repo data for '#{org_name}/#{repo_name}' from github: #{
                inspect(reason)
              }"
            )

            %{}
        end

      parent = Map.get(repo_data, "parent")

      case parent do
        %{"full_name" => name, "html_url" => url} ->
          Map.put(repo, :parent, %{"name" => name, "url" => url})

        _ ->
          repo
      end
    end)
  end

  defp put_repo_languages_stats(repo, languages) do
    stats = Repos.get_percentages_by_language(languages)
    Map.put(repo, :languages, stats)
  end

  defp put_org_languages_stats(org) do
    stats = Repos.get_org_languages_stats(org)

    org
    |> Map.put(:languages, stats)
    |> convert_languages_to_list_and_sort()
  end

  defp put_org_popularity(org) do
    popularity = Repos.get_org_popularity(org)
    Map.put(org, :popularity, popularity)
  end

  defp put_org_last_activity(org) do
    last_activity = Repos.get_org_last_activity(org)
    Map.put(org, :last_activity, last_activity)
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
      |> Enum.sort(&(&1["bytes"] > &2["bytes"]))

    Map.put(datamap, :languages, languages)
  end

  defp headers() do
    headers = [
      {"Accept", "application/vnd.github.mercy-preview+json"}
    ]

    token = System.get_env("GITHUB_OAUTH_TOKEN")

    if is_binary(token) do
      [{"Authorization", "token #{token}"} | headers]
    else
      headers
    end
  end

  defp call_api_get(path) do
    url = "https://api.github.com/#{path}"

    case HTTPoison.get(url, headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found: #{url}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp to_struct([], _), do: []
  defp to_struct([data | tail], str), do: [to_struct(data, str) | to_struct(tail, str)]
  defp to_struct(data, str), do: struct(str, Coophub.map_string_to_atom_keys(data))
end

defmodule Coophub.Repos.Warmer do
  use Cachex.Warmer

  alias Coophub.Repos

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
  def execute(_state), do: maybe_warm(Coophub.Application.env())

  defp maybe_warm(:dev) do
    Logger.info("Warming repos into cache from dump..", ansi_color: :yellow)
    Process.sleep(2000)

    size =
      case Cachex.load(@repos_cache_name, @repos_cache_dump_file) do
        {:ok, true} ->
          Cachex.size(@repos_cache_name) |> elem(1)

        _ ->
          Logger.info("Dump not found '#{@repos_cache_dump_file}'", ansi_color: :yellow)
          0
      end

    if size != read_yml() |> Map.keys() |> length() do
      Logger.info("The dump data needs to be updated!", ansi_color: :yellow)
      load_cache() |> save_cache()
    else
      Logger.info("The dump was loaded with #{size} orgs!", ansi_color: :yellow)
      refresh_cache()
    end
  end

  defp maybe_warm(_), do: load_cache()

  defp load_cache() do
    Logger.info("Warming repos into cache from github..", ansi_color: :yellow)

    repos =
      read_yml()
      |> Enum.reduce([], fn {name, _}, acc ->
        case get_org(name) do
          :error -> acc
          org_data -> [get_repos(name, org_data) | acc]
        end
      end)

    {:ok, repos, ttl: :timer.minutes(@repos_cache_interval * 10)}
  end

  defp save_cache({:ok, repos, _}) do
    spawn(save_cache(repos))
    {:ok, repos, ttl: :timer.minutes(@repos_cache_interval + 1)}
  end

  defp save_cache(repos) do
    fn ->
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

  defp refresh_cache() do
    Cachex.keys(@repos_cache_name)
    |> elem(1)
    |> Enum.each(&Cachex.expire(@repos_cache_name, &1, :timer.minutes(@repos_cache_interval + 1)))

    :ignore
  end

  defp get_repos(org, org_info) do
    org_repos =
      case call_api_get(
             "orgs/#{org}/repos?per_page=#{@repos_max_fetch}&type=public&sort=pushed&direction=desc"
           ) do
        {:ok, body} ->
          repos =
            body
            |> put_key(org)
            |> put_popularities()
            |> put_topics(org)
            |> put_languages(org)

          Logger.info("Fetched #{length(repos)} repos for #{org}", ansi_color: :yellow)
          repos

        {:error, reason} ->
          Logger.error("Error getting the repos for '#{org}' from github: #{inspect(reason)}")
          []
      end

    org_info =
      org_info
      |> Map.put("repos", org_repos)
      |> put_org_languages_stats()
      |> put_org_popularity()
      |> put_org_last_activity()

    {org, org_info}
  end

  defp get_members(%{"key" => key} = org) do
    members =
      case call_api_get("orgs/#{key}/members") do
        {:ok, body} ->
          body

        {:error, reason} ->
          Logger.error("Error getting members for '#{key}' from github: #{inspect(reason)}")
          []
      end

    Map.put(org, "members", members)
  end

  defp get_org(name) do
    case call_api_get("orgs/#{name}") do
      {:ok, org} ->
        msg =
          "Fetched '#{name}' organization! Getting members and repos (max=#{@repos_max_fetch}).."

        Logger.info(msg, ansi_color: :yellow)
        org |> Map.put("key", name) |> get_members()

      {:error, reason} ->
        Logger.error("Error getting the organization '#{name}' from github: #{inspect(reason)}")
        :error
    end
  end

  defp put_key(repos, key) do
    Enum.map(repos, &Map.put(&1, "key", key))
  end

  defp put_popularities(repos) do
    Enum.map(repos, &Map.put(&1, "popularity", Repos.get_repo_popularity(&1)))
  end

  defp put_topics(repos, org) do
    Enum.map(repos, fn repo ->
      repo_name = repo["name"]

      topics =
        case call_api_get("repos/#{org}/#{repo_name}/topics") do
          {:ok, body} ->
            body

          {:error, reason} ->
            Logger.error(
              "Error getting the topics for '#{org}/#{repo_name}' from github: #{inspect(reason)}"
            )

            %{}
        end

      Map.put(repo, "topics", Map.get(topics, "names", []))
    end)
  end

  defp put_languages(repos, org) do
    Enum.map(repos, fn repo ->
      repo_name = repo["name"]

      languages =
        case call_api_get("repos/#{org}/#{repo_name}/languages") do
          {:ok, body} ->
            body

          {:error, reason} ->
            Logger.error(
              "Error getting the languages for '#{org}/#{repo_name}' from github: #{
                inspect(reason)
              }"
            )

            %{}
        end

      put_repo_languages_stats(repo, languages)
    end)
  end

  defp put_repo_languages_stats(repo, languages) do
    stats = Repos.get_percentages_by_language(languages)
    Map.put(repo, "languages", stats)
  end

  defp put_org_languages_stats(org) do
    stats = Repos.get_org_languages_stats(org)

    org
    |> Map.put("languages", stats)
    |> convert_languages_to_list_and_sort()
  end

  defp put_org_popularity(org) do
    popularity = Repos.get_org_popularity(org)
    Map.put(org, "popularity", popularity)
  end

  defp put_org_last_activity(org) do
    last_activity = Repos.get_org_last_activity(org)
    Map.put(org, "last_activity", last_activity)
  end

  defp convert_languages_to_list_and_sort(org) do
    repos =
      org
      |> Map.get("repos", [])
      |> Enum.map(&languages_map_to_list_and_sort/1)

    org
    |> Map.put("repos", repos)
    |> languages_map_to_list_and_sort()
  end

  defp languages_map_to_list_and_sort(datamap) do
    languages =
      datamap
      |> Map.get("languages", [])
      |> Enum.map(fn {lang, stats} -> Map.put(stats, "lang", lang) end)
      |> Enum.sort(&(&1["bytes"] > &2["bytes"]))

    Map.put(datamap, "languages", languages)
  end

  defp read_yml() do
    path = Path.join(File.cwd!(), "cooperatives.yml")
    {:ok, coops} = YamlElixir.read_from_file(path)
    coops
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
end

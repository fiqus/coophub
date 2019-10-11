defmodule Coophub.Repos.Warmer do
  use Cachex.Warmer

  alias Coophub.Repos

  require Logger

  @repos_cache_name Application.get_env(:coophub, :cachex_name)
  @repos_cache_interval Application.get_env(:coophub, :cachex_interval)
  @repos_cache_dump Application.get_env(:coophub, :cachex_dump)

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.minutes(@repos_cache_interval)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state), do: maybe_warm(Mix.env())

  defp maybe_warm(:dev) do
    Logger.info("Warming repos into cache from dump..", ansi_color: :yellow)
    Process.sleep(2000)

    size =
      case Cachex.load(@repos_cache_name, @repos_cache_dump) do
        {:ok, true} ->
          Cachex.size(@repos_cache_name) |> elem(1)

        _ ->
          Logger.info("Dump not found '#{@repos_cache_dump}'", ansi_color: :yellow)
          0
      end

    if size < read_yml() |> Map.keys() |> length() do
      Logger.info("The dump data needs to be updated!", ansi_color: :yellow)
      load_cache() |> save_cache()
    else
      Logger.info("The dump was loaded with #{size} orgs!", ansi_color: :yellow)
      :ignore
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

    {:ok, repos}
  end

  defp save_cache({:ok, repos} = result) do
    spawn(save_cache(repos))
    result
  end

  defp save_cache(repos) do
    fn ->
      Process.sleep(2000)

      case Cachex.dump(@repos_cache_name, @repos_cache_dump) do
        {:ok, true} ->
          Logger.info(
            "Saved repos cache dump with #{length(repos)} orgs to local file '#{@repos_cache_dump}'",
            ansi_color: :green
          )

        err ->
          Logger.error("Error saving repos cache dump: #{inspect(err)}")
      end
    end
  end

  defp get_repos(org, org_info) do
    org_repos =
      case HTTPoison.get(
             "https://api.github.com/orgs/#{org}/repos?per_page=100&type=public&sort=pushed&direction=desc",
             headers()
           ) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          repos =
            body
            |> Jason.decode!()
            |> put_key(org)
            |> put_popularities()
            |> put_languages(org)

          Logger.info("Fetched #{length(repos)} repos for #{org}", ansi_color: :yellow)
          repos

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          []

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("Error getting the repos for '#{org}' from github: #{inspect(reason)}")
          []
      end

    org_info =
      org_info
      |> Map.put("repos", org_repos)
      |> put_org_languages_stats()
      |> convert_languages_to_array_and_sort()
      |> put_org_popularity()
      |> put_org_last_activity()

    {org, org_info}
  end

  defp get_members(%{"key" => key} = org) do
    members =
      case HTTPoison.get("https://api.github.com/orgs/#{key}/members", headers()) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          []

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("Error getting members for '#{key}' from github: #{inspect(reason)}")
          []
      end

    Map.put(org, "members", members)
  end

  defp get_org(name) do
    case HTTPoison.get("https://api.github.com/orgs/#{name}", headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        org = Jason.decode!(body)
        msg = "Fetched organization '#{name}'! Getting members and repos.."
        Logger.info(msg, ansi_color: :yellow)
        org |> Map.put("key", name) |> get_members()

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        :error

      {:error, %HTTPoison.Error{reason: reason}} ->
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

  defp put_languages(repos, org) do
    Enum.map(repos, fn repo ->
      repo_name = repo["name"]
      url = "https://api.github.com/repos/#{org}/#{repo_name}/languages"

      languages =
        case HTTPoison.get(url, headers()) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            Jason.decode!(body)

          {:ok, %HTTPoison.Response{status_code: 404}} ->
            %{}

          {:error, %HTTPoison.Error{reason: reason}} ->
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
    stats = Repos.get_languages_stats(languages)
    Map.put(repo, "languages", stats)
  end

  defp put_org_languages_stats(org) do
    stats = Repos.get_org_languages_stats(org)
    Map.put(org, "languages", stats)
  end

  defp put_org_popularity(org) do
    popularity = Repos.get_org_popularity(org)
    Map.put(org, "popularity", popularity)
  end

  defp put_org_last_activity(org) do
    last_activity = Repos.get_org_last_activity(org)
    Map.put(org, "last_activity", last_activity)
  end

  def convert_languages_to_array_and_sort(org) do
    languages =
      Map.get(org, "languages", [])
      |> Enum.map(fn {lang, stats} -> Map.put(stats, "lang", lang) end)
      |> languages_sort()

    Map.put(org, "languages", languages)
    |> convert_repos_languages_to_array()
  end

  def convert_repos_languages_to_array(org) do
    repos =
      Map.get(org, "repos", [])
      |> Enum.map(fn repo ->
        languages =
          Map.get(repo, "languages")
          |> Enum.map(fn {lang, stats} -> Map.put(stats, "lang", lang) end)
          |> languages_sort()

        Map.put(repo, "languages", languages)
      end)

    Map.put(org, "repos", repos)
  end

  def languages_sort(langs) do
    langs
    |> Enum.sort(&(&1["bytes"] > &2["bytes"]))
  end

  defp read_yml() do
    path = Path.join(File.cwd!(), "cooperatives.yml")
    {:ok, coops} = YamlElixir.read_from_file(path)
    coops
  end

  defp headers() do
    token = System.get_env("GITHUB_OAUTH_TOKEN")

    if is_binary(token) do
      [{"Authorization", "token #{token}"}]
    else
      []
    end
  end
end

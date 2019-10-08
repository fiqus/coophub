defmodule Coophub.Repos.Warmer do
  use Cachex.Warmer

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
    Cachex.load(@repos_cache_name, @repos_cache_dump)

    size =
      case Cachex.size(@repos_cache_name) do
        {:ok, size} -> size
        _ -> 0
      end

    if size < read_yml() |> Map.keys() |> length() do
      load_cache() |> save_cache()
    else
      :ignore
    end
  end

  defp maybe_warm(_), do: load_cache()

  defp load_cache() do
    Logger.info("Warming repos into cache from github..", ansi_color: :yellow)

    repos =
      read_yml()
      |> Enum.reduce([], fn {name, _}, acc ->
        org_data = get_org(name)
        [get_repos(name, org_data) | acc]
      end)

    {:ok, repos}
  end

  defp save_cache(result) do
    spawn(&save_cache/0)
    result
  end

  defp save_cache() do
    Process.sleep(2000)
    Logger.info("Dumping repos cache to local file '#{@repos_cache_dump}'..", ansi_color: :yellow)
    Cachex.dump(@repos_cache_name, @repos_cache_dump)
  end

  defp get_repos(org, org_info) do
    case HTTPoison.get(
           "https://api.github.com/orgs/#{org}/repos?per_page=100&type=public&sort=pushed&direction=desc",
           headers()
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        repos =
          body
          |> Jason.decode!()
          |> put_languages(org)

        Logger.info("Saving #{length(repos)} repos for #{org}", ansi_color: :yellow)

        org_info =
          org_info
          |> Map.put("repos", repos)
          |> put_org_languages_stats()

        {org, org_info}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {org, org_info}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("error getting the repos from github with reason: #{inspect(reason)}")
        {org, org_info}
    end
  end

  defp get_org(name) do
    case HTTPoison.get("https://api.github.com/orgs/#{name}", headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        org = Jason.decode!(body)
        Logger.info("Saving organization: #{name}", ansi_color: :yellow)
        org

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        name

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("error getting organization: #{inspect(reason)}")
        name
    end
  end

  defp put_languages(repos, org) do
    repos
    |> Enum.map(fn repo ->
      repo_name = repo["name"]

      case HTTPoison.get("https://api.github.com/repos/#{org}/#{repo_name}/languages", headers()) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          languages = Jason.decode!(body)

          Map.put(repo, "languages", languages)
          |> put_repo_languages_stats()

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          repo

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("error getting languages: #{inspect(reason)}")
          repo
      end
    end)
  end

  defp put_repo_languages_stats(repo) do
    total =
      repo["languages"]
      |> Enum.reduce(0, fn {_lang, bytes}, tot -> tot + bytes end)

    lang_stats =
      repo["languages"]
      |> Enum.reduce(%{}, fn {lang, bytes}, acc ->
        percentage = (bytes / total * 100) |> Float.round(2)
        Map.put(acc, percentage, lang)
      end)

    Map.put(repo, "lang_stats", lang_stats)
  end

  defp put_org_languages_stats(org) do
    lang_totals =
      Enum.reduce(org["repos"], %{}, fn repo, acc ->
        repo["languages"]
        |> Enum.reduce(acc, fn {lang, bytes}, accum_repo ->
          prev_cant = Map.get(acc, lang, 0)
          Map.put(accum_repo, lang, prev_cant + bytes)
        end)
      end)

    total = Enum.reduce(lang_totals, 0, fn {_lang, bytes}, tot -> tot + bytes end)

    lang_stats =
      lang_totals
      |> Enum.reduce(%{}, fn {lang, bytes}, acc ->
        percentage = (bytes / total * 100) |> Float.round(2)
        Map.put(acc, percentage, lang)
      end)

    Map.put(org, "lang_stats", lang_stats)
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

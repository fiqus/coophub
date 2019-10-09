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

    {org, org_info}
  end

  defp get_org(name) do
    case HTTPoison.get("https://api.github.com/orgs/#{name}", headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        org = Jason.decode!(body)
        Logger.info("Fetched organization #{name}! Getting repos..", ansi_color: :yellow)
        org |> Map.put("key", name)

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
          Logger.error(
            "Error getting the langages for '#{org}/#{repo_name}' from github: #{inspect(reason)}"
          )

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

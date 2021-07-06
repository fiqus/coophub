defmodule Coophub.Backends do
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @type url :: String.t()
  @type headers :: [{String.t(), String.t()}]
  @type request_data :: {String.t(), url | nil, headers}

  @type org :: Organization.t()
  @type repo :: Repository.t()
  @type langs :: %{String.t() => integer()}
  @type topics :: [String.t()]

  ## Backends implementations
  defp get_backend_module!("github"), do: Backends.Github
  defp get_backend_module!("gitlab"), do: Backends.GitlabCom
  defp get_backend_module!("git.coop"), do: Backends.GitCoop
  defp get_backend_module!(source), do: raise("Unknown backend source: #{source}")

  ########
  ## CALLS TO BACKENDS RESOURCES
  ########

  @spec get_org(String.t(), String.t(), map) :: org | :error
  def get_org(source, key, yml_data) do
    backend = get_backend_module!(source)
    bname = backend.name()
    {name, url, headers} = backend.prepare_request_org(yml_data["login"])
    Logger.info("Fetching '#{name}' organization from #{bname}..", ansi_color: :yellow)

    case request(url, headers) do
      {:ok, data, ms} ->
        Logger.info("Fetched '#{name}' organization! (#{ms}ms)", ansi_color: :green)

        backend.parse_org(data)
        |> Map.put(:key, key)
        |> Map.put(:login, yml_data["login"])
        |> Map.put(:yml_data, yml_data)

      {:error, reason} ->
        Logger.error("Error getting '#{name}' organization from #{bname}: #{inspect(reason)}")
        :error
    end
  end

  @spec get_repos(String.t(), org) :: [repo]
  def get_repos(source, org) do
    backend = get_backend_module!(source)
    bname = backend.name()
    limit = Application.get_env(:coophub, :fetch_max_repos)
    {name, url, headers} = backend.prepare_request_repos(org, limit)
    Logger.info("Fetching '#{name}' repos from #{bname} (max=#{limit})..", ansi_color: :yellow)

    case request(url, headers) do
      {:ok, repos, ms} ->
        Logger.info("Fetched #{length(repos)} '#{name}' repos! (#{ms}ms)", ansi_color: :green)

        Enum.map(repos, fn repo_data ->
          backend.parse_repo(repo_data)
          |> Map.put(:key, org.key)
        end)

      {:error, reason} ->
        Logger.error("Error getting '#{name}' repos from #{bname}: #{inspect(reason)}")
        []
    end
  end

  @spec get_repo(module, org, map) :: repo
  def get_repo(backend, %Organization{key: key} = org, repo_data) do
    bname = backend.name()
    {name, url, headers} = backend.prepare_request_repo(org, repo_data)
    Logger.info("Fetching '#{name}' repo data from #{bname}..", ansi_color: :cyan)

    case request(url, headers) do
      {:ok, data, ms} ->
        Logger.info("Fetched '#{name}' repo data! (#{ms}ms)", ansi_color: :green)

        backend.parse_repo(data)
        |> Map.put(:key, key)

      {:error, reason} ->
        Logger.error("Error getting '#{name}' repo data from #{bname}: #{inspect(reason)}")
        ## Fallback to repo_data we've fetched before
        backend.parse_repo(repo_data)
    end
  end

  @spec get_topics(String.t(), org, repo) :: topics
  def get_topics(source, org, repo) do
    backend = get_backend_module!(source)
    bname = backend.name()
    {name, url, headers} = backend.prepare_request_topics(org, repo)
    Logger.info("Fetching '#{name}' topics from #{bname}..", ansi_color: :cyan)

    case request(url, headers) do
      {:ok, data, ms} ->
        topics = backend.parse_topics(data)

        Logger.info("Fetched #{length(topics)} '#{name}' topics! (#{ms}ms)",
          ansi_color: :green
        )

        topics

      {:error, reason} ->
        Logger.error("Error getting '#{name}' topics from #{bname}: #{inspect(reason)}")
        []
    end
  end

  @spec get_languages(String.t(), org, repo) :: langs
  def get_languages(source, org, repo) do
    backend = get_backend_module!(source)
    bname = backend.name()
    {name, url, headers} = backend.prepare_request_languages(org, repo)
    Logger.info("Fetching '#{name}' languages from #{bname}..", ansi_color: :cyan)

    case request(url, headers) do
      {:ok, data, ms} ->
        langs = backend.parse_languages(data)
        count = langs |> Map.keys() |> length()
        Logger.info("Fetched #{count} '#{name}' languages! (#{ms}ms)", ansi_color: :green)
        langs

      {:error, reason} ->
        Logger.error("Error getting '#{name}' languages from #{bname}: #{inspect(reason)}")
        []
    end
  end

  @spec get_rate_limit(String.t()) :: integer
  def get_rate_limit(source) do
    backend = get_backend_module!(source)
    {_, url, headers} = backend.prepare_request_rate_limit()

    case request(url, headers) do
      {:ok, data, _} ->
        data["resources"]["core"]["remaining"]

      {:error, reason} ->
        Logger.error("Error getting account rate limit: #{inspect(reason)}")
        0
    end
  end

  @spec request(String.t(), headers) :: {:ok, map | [map], integer} | {:error, any}
  defp request(nil, _), do: {:ok, [], 0}

  defp request(url, headers) do
    start_ms = take_time()

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body), take_time() - start_ms}

      {:ok, %HTTPoison.Response{status_code: 403}} ->
        {:error, "Forbidden (possible API rate-limit): #{url}"}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found: #{url}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      _ ->
        {:error, "Unexpected error: #{url}"}
    end
  end

  defp take_time(), do: System.monotonic_time(:millisecond)
end

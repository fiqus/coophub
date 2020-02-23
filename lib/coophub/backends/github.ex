defmodule Coophub.Backends.Github do
  alias Coophub.Repos
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @behaviour Backends.Behaviour

  ########
  ## BEHAVIOUR IMPLEMENTATION
  ########

  @impl Backends.Behaviour
  @spec get_org(String.t(), map()) :: Organization.t() | :error
  def get_org(key, _yml_data) do
    Logger.info("Fetching '#{key}' organization from github..", ansi_color: :yellow)

    case call_api_get("orgs/#{key}") do
      {:ok, org, ms} ->
        Logger.info("Fetched '#{key}' organization! (#{ms}ms)", ansi_color: :green)
        Repos.to_struct(Organization, org)

      {:error, reason} ->
        Logger.error("Error getting '#{key}' organization from github: #{inspect(reason)}")
        :error
    end
  end

  @impl Backends.Behaviour
  @spec get_members(Organization.t()) :: [map]
  # @TODO Isn't fetching all the org members (ie: just 5 for fiqus)
  def get_members(%Organization{key: key}) do
    Logger.info("Fetching '#{key}' members from github..", ansi_color: :yellow)

    case call_api_get("orgs/#{key}/members") do
      {:ok, members, ms} ->
        Logger.info("Fetched #{length(members)} '#{key}' members! (#{ms}ms)", ansi_color: :green)
        members

      {:error, reason} ->
        Logger.error("Error getting '#{key}' members from github: #{inspect(reason)}")
        []
    end
  end

  @impl Backends.Behaviour
  @spec get_repos(Organization.t()) :: [Repository.t()]
  def get_repos(%Organization{key: key} = org) do
    limit = Application.get_env(:coophub, :fetch_max_repos)
    Logger.info("Fetching '#{key}' repos from github (max=#{limit})..", ansi_color: :yellow)
    path = "orgs/#{key}/repos?per_page=#{limit}&type=public&sort=pushed&direction=desc"

    case call_api_get(path) do
      {:ok, repos, ms} ->
        Logger.info("Fetched #{length(repos)} '#{key}' repos! (#{ms}ms)", ansi_color: :green)

        Enum.map(repos, fn repo_data ->
          get_repo(org, repo_data)
        end)

      {:error, reason} ->
        Logger.error("Error getting '#{key}' repos from github: #{inspect(reason)}")
        []
    end
  end

  @impl Backends.Behaviour
  @spec get_topics(Organization.t(), Repository.t()) :: [String.t()]
  def get_topics(%Organization{key: key}, %Repository{name: name}) do
    Logger.info("Fetching '#{key}/#{name}' topics from github..", ansi_color: :cyan)

    case call_api_get("repos/#{key}/#{name}/topics") do
      {:ok, data, ms} ->
        topics = Map.get(data, "names", [])

        Logger.info("Fetched #{length(topics)} '#{key}/#{name}' topics! (#{ms}ms)",
          ansi_color: :green
        )

        topics

      {:error, reason} ->
        Logger.error("Error getting '#{key}/#{name}' topics from github: #{inspect(reason)}")
        []
    end
  end

  @impl Backends.Behaviour
  @spec get_languages(Organization.t(), Repository.t()) :: Backends.languages()
  def get_languages(%Organization{key: key}, %Repository{name: name}) do
    Logger.info("Fetching '#{key}/#{name}' languages from github..", ansi_color: :cyan)

    case call_api_get("repos/#{key}/#{name}/languages") do
      {:ok, languages, ms} ->
        Logger.info(
          "Fetched #{length(Map.keys(languages))} '#{key}/#{name}' languages! (#{ms}ms)",
          ansi_color: :green
        )

        languages

      {:error, reason} ->
        Logger.error("Error getting '#{key}/#{name}' languages from github: #{inspect(reason)}")
        []
    end
  end

  ########
  ## INTERNALS
  ########

  defp get_repo(%Organization{key: key}, %{"name" => name} = repo_data) do
    Logger.info("Fetching '#{key}/#{name}' repo data from github..", ansi_color: :cyan)

    case call_api_get("repos/#{key}/#{name}") do
      {:ok, data, ms} ->
        Logger.info("Fetched '#{key}/#{name}' repo data! (#{ms}ms)", ansi_color: :green)

        repo = Repos.to_struct(Repository, data)

        case repo.parent do
          %{"full_name" => name, "html_url" => url} ->
            Map.put(repo, :parent, %{name: name, url: url})

          _ ->
            repo
        end

      {:error, reason} ->
        Logger.error("Error getting '#{key}/#{name}' repo data from github: #{inspect(reason)}")
        # Fallback to repo_data we've fetched before
        Repos.to_struct(Repository, repo_data)
    end
  end

  defp headers() do
    headers = [{"Accept", "application/vnd.github.mercy-preview+json"}]
    token = System.get_env("GITHUB_OAUTH_TOKEN")

    if is_binary(token),
      do: [{"Authorization", "token #{token}"} | headers],
      else: headers
  end

  defp call_api_get(path) do
    url = "https://api.github.com/#{path}"
    Backends.call_api_get(url, headers())
  end
end

defmodule Coophub.Backends.Github do
  alias Coophub.Repos
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @behaviour Backends.Behaviour

  @repos_max_fetch Application.get_env(:coophub, :fetch_max_repos)

  ########
  ## BEHAVIOUR IMPLEMENTATION
  ########

  @impl Backends.Behaviour
  @spec get_org(String.t(), Map.t()) :: Organization.t() | :error
  def get_org(key, _yml_data) do
    Logger.info("Fetching '#{key}' organization from github..", ansi_color: :yellow)

    case call_api_get("orgs/#{key}") do
      {:ok, org} ->
        Logger.info("Fetched '#{key}' organization!", ansi_color: :yellow)
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
      {:ok, members} ->
        Logger.info("Fetched #{length(members)} '#{key}' members!", ansi_color: :yellow)
        members

      {:error, reason} ->
        Logger.error("Error getting '#{key}' members from github: #{inspect(reason)}")
        []
    end
  end

  @impl Backends.Behaviour
  @spec get_repos(Organization.t()) :: [Repository.t()]
  def get_repos(%Organization{key: key}) do
    Logger.info("Fetching '#{key}' repos from github..", ansi_color: :yellow)
    path = "orgs/#{key}/repos?per_page=#{@repos_max_fetch}&type=public&sort=pushed&direction=desc"

    case call_api_get(path) do
      {:ok, repos} ->
        Logger.info("Fetched #{length(repos)} '#{key}' repos!", ansi_color: :yellow)
        Repos.to_struct(Repository, repos)

      {:error, reason} ->
        Logger.error("Error getting '#{key}' repos from github: #{inspect(reason)}")
        []
    end
  end

  @impl Backends.Behaviour
  @spec get_topics(Organization.t(), Repository.t()) :: [String.t()]
  def get_topics(%Organization{key: key}, %Repository{name: name}) do
    Logger.info("Fetching '#{key}/#{name}' topics from github..", ansi_color: :yellow)

    case call_api_get("repos/#{key}/#{name}/topics") do
      {:ok, data} ->
        topics = Map.get(data, "names", [])
        Logger.info("Fetched #{length(topics)} '#{key}/#{name}' topics!", ansi_color: :yellow)
        topics

      {:error, reason} ->
        Logger.error("Error getting '#{key}/#{name}' topics from github: #{inspect(reason)}")
        []
    end
  end

  @impl Backends.Behaviour
  @spec headers() :: Backends.Behaviour.headers()
  def headers() do
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

  ########
  ## INTERNALS
  ########

  defp call_api_get(path) do
    url = "https://api.github.com/#{path}"
    Backends.Behaviour.call_api_get(url, headers())
  end
end

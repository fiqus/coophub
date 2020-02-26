defmodule Coophub.Backends.Github do
  alias Coophub.Repos
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @type request :: Backends.request()
  @type org :: Backends.org()
  @type repo :: Backends.repo()
  @type langs :: Backends.langs()
  @type topics :: Backends.topics()

  @behaviour Backends.Behaviour

  ########
  ## BEHAVIOUR IMPLEMENTATION
  ########

  @impl Backends.Behaviour
  @spec name() :: String.t()
  def name(), do: "github"

  @impl Backends.Behaviour
  @spec request_org(String.t(), map) :: request
  def request_org(key, _yml_data) do
    {key, full_url("orgs/#{key}"), headers()}
  end

  @impl Backends.Behaviour
  @spec parse_org(map) :: org
  def parse_org(data) do
    Repos.to_struct(Organization, data)
  end

  @impl Backends.Behaviour
  @spec request_members(org) :: request
  # @TODO Isn't fetching all the org members (ie: just 5 for fiqus)
  def request_members(%Organization{key: key}) do
    {key, full_url("orgs/#{key}/members"), headers()}
  end

  @impl Backends.Behaviour
  @spec parse_members([map]) :: [map]
  def parse_members(members) do
    members
  end

  @impl Backends.Behaviour
  @spec request_repos(org, integer) :: request
  def request_repos(%Organization{key: key}, limit) do
    path = "orgs/#{key}/repos?per_page=#{limit}&type=public&sort=pushed&direction=desc"
    {key, full_url(path), headers()}
  end

  @impl Backends.Behaviour
  @spec request_repo(org, map) :: request
  def request_repo(%Organization{key: key}, %{"name" => name}) do
    {"#{key}/#{name}", full_url("repos/#{key}/#{name}"), headers()}
  end

  @impl Backends.Behaviour
  @spec parse_repo(map) :: repo
  def parse_repo(data) do
    repo = Repos.to_struct(Repository, data)

    case repo.parent do
      %{"full_name" => name, "html_url" => url} ->
        Map.put(repo, :parent, %{name: name, url: url})

      _ ->
        repo
    end
  end

  @impl Backends.Behaviour
  @spec request_topics(org, repo) :: request
  def request_topics(%Organization{key: key}, %Repository{name: name}) do
    {"#{key}/#{name}", full_url("repos/#{key}/#{name}/topics"), headers()}
  end

  @impl Backends.Behaviour
  @spec parse_topics(map) :: topics
  def parse_topics(data) do
    Map.get(data, "names", [])
  end

  @impl Backends.Behaviour
  @spec request_languages(org, repo) :: request
  def request_languages(%Organization{key: key}, %Repository{name: name}) do
    {"#{key}/#{name}", full_url("repos/#{key}/#{name}/languages"), headers()}
  end

  @impl Backends.Behaviour
  @spec parse_languages(langs) :: langs
  def parse_languages(languages) do
    languages
  end

  ########
  ## INTERNALS
  ########

  defp headers() do
    headers = [{"Accept", "application/vnd.github.mercy-preview+json"}]
    token = System.get_env("GITHUB_OAUTH_TOKEN")

    if is_binary(token),
      do: [{"Authorization", "token #{token}"} | headers],
      else: headers
  end

  defp full_url(path), do: "https://api.github.com/#{path}"
end

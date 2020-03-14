defmodule Coophub.Backends.Github do
  alias Coophub.Repos
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @type data_for_request :: Backends.data_for_request()
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
  @spec prepare_request_org(String.t(), map) :: data_for_request
  def prepare_request_org(key, _yml_data) do
    prepare_request(key, "orgs/#{key}")
  end

  @impl Backends.Behaviour
  @spec parse_org(map) :: org
  def parse_org(data) do
    Repos.to_struct(Organization, data)
  end

  @impl Backends.Behaviour
  @spec prepare_request_members(org) :: data_for_request
  # @TODO Isn't fetching all the org members (ie: just 5 for fiqus)
  def prepare_request_members(%Organization{key: key}) do
    prepare_request(key, "orgs/#{key}/members")
  end

  @impl Backends.Behaviour
  @spec parse_members([map]) :: [map]
  def parse_members(members) do
    members
  end

  @impl Backends.Behaviour
  @spec prepare_request_repos(org, integer) :: data_for_request
  def prepare_request_repos(%Organization{key: key}, limit) do
    prepare_request(key, "orgs/#{key}/repos?per_page=#{limit}&type=public&sort=pushed&direction=desc")
  end

  @impl Backends.Behaviour
  @spec prepare_request_repo(org, map) :: data_for_request
  def prepare_request_repo(%Organization{key: key}, %{"name" => name}) do
    prepare_request("#{key}/#{name}", "repos/#{key}/#{name}")
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
  @spec prepare_request_topics(org, repo) :: data_for_request
  def prepare_request_topics(%Organization{key: key}, %Repository{name: name}) do
    prepare_request("#{key}/#{name}", "repos/#{key}/#{name}/topics")
  end

  @impl Backends.Behaviour
  @spec parse_topics(map) :: topics
  def parse_topics(data) do
    Map.get(data, "names", [])
  end

  @impl Backends.Behaviour
  @spec prepare_request_languages(org, repo) :: data_for_request
  def prepare_request_languages(%Organization{key: key}, %Repository{name: name}) do
    prepare_request("#{key}/#{name}", "repos/#{key}/#{name}/languages")
  end

  @impl Backends.Behaviour
  @spec parse_languages(langs) :: langs
  def parse_languages(languages) do
    languages
  end

  ########
  ## INTERNALS
  ########

  defp prepare_request(name, path) do
    {name, full_url(path), headers()}
  end

  defp headers() do
    headers = [{"Accept", "application/vnd.github.mercy-preview+json"}]
    token = System.get_env("GITHUB_OAUTH_TOKEN")

    if is_binary(token),
      do: [{"Authorization", "token #{token}"} | headers],
      else: headers
  end

  defp full_url(path), do: "https://api.github.com/#{path}"
end

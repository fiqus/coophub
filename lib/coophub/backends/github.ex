defmodule Coophub.Backends.Github do
  alias Coophub.Repos
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @type request_data :: Backends.request_data()
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
  @spec prepare_request_org(String.t()) :: request_data
  def prepare_request_org(login) do
    prepare_request(login, "orgs/#{login}")
  end

  @impl Backends.Behaviour
  @spec parse_org(map) :: org
  def parse_org(data) do
    Repos.to_struct(Organization, data)
  end

  @impl Backends.Behaviour
  @spec prepare_request_repos(org, integer) :: request_data
  def prepare_request_repos(%Organization{login: login}, limit) do
    prepare_request(
      login,
      "orgs/#{login}/repos?per_page=#{limit}&type=public&sort=pushed&direction=desc"
    )
  end

  @impl Backends.Behaviour
  @spec prepare_request_repo(org, map) :: request_data
  def prepare_request_repo(%Organization{login: login}, %{"name" => name}) do
    prepare_request("#{login}/#{name}", "repos/#{login}/#{name}")
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
  @spec prepare_request_topics(org, repo) :: request_data
  def prepare_request_topics(%Organization{login: login}, %Repository{name: name}) do
    prepare_request("#{login}/#{name}", "repos/#{login}/#{name}/topics")
  end

  @impl Backends.Behaviour
  @spec parse_topics(map) :: topics
  def parse_topics(data) do
    Map.get(data, "names", [])
  end

  @impl Backends.Behaviour
  @spec prepare_request_languages(org, repo) :: request_data
  def prepare_request_languages(%Organization{login: login}, %Repository{name: name}) do
    prepare_request("#{login}/#{name}", "repos/#{login}/#{name}/languages")
  end

  @impl Backends.Behaviour
  @spec parse_languages(langs) :: langs
  def parse_languages(languages) do
    Repos.get_percentages_by_language(languages)
  end

  @spec get_org_languages(org()) :: map
  def get_org_languages(%Organization{:repos => repos}) do
    languages =
      Enum.reduce(repos, %{}, fn %Repository{:languages => langs} = repo, acc ->
        if not repo.fork do
          Enum.reduce(langs, acc, fn {lang, %{"bytes" => bytes}}, acc_repo ->
            acc_lang = Map.get(acc, lang, 0)
            Map.put(acc_repo, lang, acc_lang + bytes)
          end)
        else
          acc
        end
      end)

    Repos.get_percentages_by_language(languages)
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

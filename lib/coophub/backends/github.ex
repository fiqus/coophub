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

  @behaviour Backends

  ########
  ## BEHAVIOUR IMPLEMENTATION
  ########

  @impl Backends
  @spec name() :: String.t()
  def name(), do: "github"

  @impl Backends
  @spec prepare_request_org(String.t()) :: request_data
  def prepare_request_org(login) do
    prepare_request(login, "orgs/#{login}")
  end

  @impl Backends
  @spec parse_org(map) :: org
  def parse_org(data) do
    Repos.to_struct(Organization, data)
  end

  @impl Backends
  @spec prepare_request_repos(org, integer) :: request_data
  def prepare_request_repos(%Organization{login: login}, limit) do
    prepare_request(
      login,
      "orgs/#{login}/repos?per_page=#{limit}&type=public&sort=pushed&direction=desc"
    )
  end

  @impl Backends
  @spec prepare_request_repo(org, map) :: request_data
  def prepare_request_repo(%Organization{login: login}, %{"name" => name}) do
    prepare_request("#{login}/#{name}", "repos/#{login}/#{name}")
  end

  @impl Backends
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

  @impl Backends
  @spec prepare_request_topics(org, repo) :: request_data
  def prepare_request_topics(%Organization{login: login}, %Repository{name: name}) do
    prepare_request("#{login}/#{name}", "repos/#{login}/#{name}/topics")
  end

  @impl Backends
  @spec parse_topics(map) :: topics
  def parse_topics(data) do
    Map.get(data, "names", [])
  end

  @impl Backends
  @spec prepare_request_languages(org, repo) :: request_data
  def prepare_request_languages(%Organization{login: login}, %Repository{name: name}) do
    prepare_request("#{login}/#{name}", "repos/#{login}/#{name}/languages")
  end

  @impl Backends
  @spec parse_languages(langs) :: langs
  def parse_languages(languages) do
    percentage_from_bytes(languages)
  end

  def prepare_request_rate_limit() do
    prepare_request("", "rate_limit")
  end

  ########
  ## INTERNALS
  ########
  defp percentage_from_bytes(languages) do
    total = Enum.reduce(languages, 0, fn {_lang, bytes}, acc -> acc + bytes end)

    Enum.reduce(languages, %{}, fn {lang, bytes}, acc ->
      percentage_for_lang = (bytes * 100 / total) |> Float.round(2)
      Map.put(acc, lang, %{"percentage" => percentage_for_lang})
    end)
  end

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

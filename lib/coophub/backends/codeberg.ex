defmodule Coophub.Backends.Codeberg do
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
  def name(), do: "codeberg.org"

  @impl Backends
  @spec prepare_request_org(String.t()) :: request_data
  def prepare_request_org(login) do
    prepare_request(login, "orgs/#{login}")
  end

  @impl Backends
  @spec parse_org(map) :: org
  def parse_org(data) do
    data =
      %{
        "login" => data["name"],
        "name" => data["full_name"] || data["name"],
        "description" => data["description"],
        "avatar_url" => data["avatar_url"],
        "html_url" => "https://codeberg.org/#{data["name"]}",
        "url" => "https://codeberg.org/#{data["name"]}",
        "location" => data["location"]
      }
      |> Enum.into(data)

    Repos.to_struct(Organization, data)
  end

  @impl Backends
  @spec prepare_request_repos(org, integer) :: request_data
  def prepare_request_repos(%Organization{login: login}, limit) do
    prepare_request(
      login,
      "orgs/#{login}/repos?limit=#{limit}&sort=updated&order=desc"
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
    data =
      %{
        "stargazers_count" => data["stars_count"] || 0,
        "html_url" => data["html_url"],
        "full_name" => data["full_name"],
        "topics" => data["topics"] || [],
        "pushed_at" => data["updated_at"],
        "fork" => data["fork"] || false,
        "forks_count" => data["forks_count"] || 0,
        "open_issues_count" => data["open_issues_count"] || 0,
        "owner" => %{
          "login" => get_in(data, ["owner", "login"]),
          "avatar_url" => get_in(data, ["owner", "avatar_url"]) || ""
        }
      }
      |> Enum.into(data)

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
    Map.get(data, "topics", [])
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

  ########
  ## INTERNALS
  ########
  defp percentage_from_bytes(languages) do
    total = Enum.reduce(languages, 0, fn {_lang, bytes}, acc -> acc + bytes end)

    if total > 0 do
      Enum.reduce(languages, %{}, fn {lang, bytes}, acc ->
        percentage_for_lang = (bytes * 100 / total) |> Float.round(2)
        Map.put(acc, lang, %{"percentage" => percentage_for_lang})
      end)
    else
      %{}
    end
  end

  defp prepare_request(name, path) do
    {name, full_url(path), headers()}
  end

  defp headers() do
    []
  end

  defp full_url(path), do: "https://codeberg.org/api/v1/#{path}"
end

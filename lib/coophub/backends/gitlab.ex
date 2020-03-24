defmodule Coophub.Backends.Gitlab do
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
  def name(), do: "gitlab"

  @impl Backends.Behaviour
  @spec prepare_request_org(String.t()) :: request_data
  def prepare_request_org(login) do
    prepare_request(login, "groups/#{login}")
  end

  @impl Backends.Behaviour
  @spec parse_org(map) :: org
  def parse_org(data) do
    data =
      %{
        "login" => data["path"],
        "url" => data["yml_data"]["url"],
        "html_url" => data["web_url"],
        "public_repos" => length(data["projects"])
      }
      |> Enum.into(data)

    Repos.to_struct(Organization, data)
  end

  @impl Backends.Behaviour
  @spec prepare_request_repos(org, integer) :: request_data
  def prepare_request_repos(%Organization{login: login}, limit) do
    prepare_request(
      login,
      "groups/#{login}/projects?include_subgroups=true&per_page=#{limit}&type=public&order_by=last_activity_at&sort=desc"
    )
  end

  @impl Backends.Behaviour
  @spec prepare_request_repo(org, map) :: request_data
  def prepare_request_repo(_organization, %{"path_with_namespace" => path_with_namespace}) do
    prepare_request(
      "projects/#{path_with_namespace}",
      "projects/#{URI.encode_www_form(path_with_namespace)}"
    )
  end

  @impl Backends.Behaviour
  @spec parse_repo(map) :: repo
  def parse_repo(data) do
    data =
      %{
        "stargazers_count" => data["star_count"],
        "key" => data["name"],
        "html_url" => data["web_url"],
        "topics" => data["tag_list"],
        "pushed_at" => data["last_activity_at"],
        # TODO: to review, "forks_count" exist but not "fork"
        "fork" => data["mirror"],
        "owner" => %{
          "login" => data["namespace"]["full_path"],
          "avatar_url" => get_avatar_url(data)
        }
      }
      |> Enum.into(data)

    # sometimes open_issues_count does not exist!
    data = Map.put_new(data, "open_issues_count", 0)
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
  def prepare_request_topics(%Organization{}, %Repository{}) do
    # topics are tag_list already set
    dont_request()
  end

  @impl Backends.Behaviour
  @spec parse_topics(map) :: topics
  def parse_topics(data) do
    data
  end

  @impl Backends.Behaviour
  @spec prepare_request_languages(org, repo) :: request_data
  def prepare_request_languages(_organization, %Repository{
        path_with_namespace: path_with_namespace
      }) do
    prepare_request(
      "projects/#{path_with_namespace}",
      "projects/#{URI.encode_www_form(path_with_namespace)}/languages"
    )
  end

  @impl Backends.Behaviour
  @spec parse_languages(langs) :: langs
  def parse_languages(languages) do
    languages
    |> Enum.reduce(%{}, fn {lang, percentage}, acc ->
      # bytes is not used by GitLab, since we are using bytes only for getting percentages
      # using directly the percentage as bytes will be proportional
      # (100 bytes will be the total of bytes of the project)
      Map.put(acc, lang, %{"bytes" => percentage, "percentage" => percentage})
    end)
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

  defp get_avatar_url(data) do
    case Map.get(data, "avatar_url") do
      nil ->
        case Map.get(data["namespace"], "avatar_url") do
          nil -> ""
          avatar_url -> "https://gitlab.com" <> avatar_url
        end

      avatar_url ->
        avatar_url
    end
  end

  defp prepare_request(name, path) do
    {name, full_url(path), headers()}
  end

  defp headers() do
    []
  end

  defp full_url(path), do: "https://gitlab.com/api/v4/#{path}"

  defp dont_request(login \\ ""), do: {login, nil, []}
end

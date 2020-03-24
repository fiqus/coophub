defmodule Coophub.Backends.Behaviour do
  alias Coophub.Backends

  @type request_data :: Backends.request_data()
  @type org :: Backends.org()
  @type repo :: Backends.repo()
  @type langs :: Backends.langs()
  @type topics :: Backends.topics()

  @callback name() :: String.t()

  @callback prepare_request_org(String.t()) :: request_data
  @callback parse_org(map) :: org

  @callback prepare_request_repos(org, integer) :: request_data
  @callback prepare_request_repo(org, map) :: request_data
  @callback parse_repo(map) :: repo

  @callback prepare_request_topics(org, repo) :: request_data
  @callback parse_topics(any) :: topics

  @callback prepare_request_languages(org, repo) :: request_data
  @callback parse_languages(any) :: langs
end

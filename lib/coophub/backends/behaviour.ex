defmodule Coophub.Backends.Behaviour do
  alias Coophub.Backends.Backends

  @type data_for_request :: Backends.data_for_request()
  @type org :: Backends.org()
  @type repo :: Backends.repo()
  @type langs :: Backends.langs()
  @type topics :: Backends.topics()

  @callback name() :: String.t()

  @callback prepare_request_org(String.t(), map) :: data_for_request
  @callback parse_org(map) :: org

  @callback prepare_request_members(org) :: data_for_request
  @callback parse_members([map]) :: [map]

  @callback prepare_request_repos(org, integer) :: data_for_request
  @callback prepare_request_repo(org, map) :: data_for_request
  @callback parse_repo(map) :: repo

  @callback prepare_request_topics(org, repo) :: data_for_request
  @callback parse_topics(any) :: topics

  @callback prepare_request_languages(org, repo) :: data_for_request
  @callback parse_languages(any) :: langs
end

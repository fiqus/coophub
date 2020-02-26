defmodule Coophub.Backends.Behaviour do
  alias Coophub.Backends

  @type request :: Backends.request()
  @type org :: Backends.org()
  @type repo :: Backends.repo()
  @type langs :: Backends.langs()
  @type topics :: Backends.topics()

  @callback name() :: String.t()

  @callback request_org(String.t(), map) :: request
  @callback parse_org(map) :: org

  @callback request_members(org) :: request
  @callback parse_members([map]) :: [map]

  @callback request_repos(org, integer) :: request
  @callback request_repo(org, map) :: request
  @callback parse_repo(map) :: repo

  @callback request_topics(org, repo) :: request
  @callback parse_topics(any) :: topics

  @callback request_languages(org, repo) :: request
  @callback parse_languages(any) :: langs
end

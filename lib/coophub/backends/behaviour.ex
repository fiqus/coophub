defmodule Coophub.Backends.Behaviour do
  alias Coophub.Backends
  alias Coophub.Schemas.{Organization, Repository}

  @type org :: Organization.t()
  @type repo :: Repository.t()
  @type langs :: Backends.languages()
  @type results ::
          :error
          | org
          | repo
          | [repo]
          | [map]
          | [String.t()]
          | langs

  @callback get_org(String.t(), map) :: org | :error
  @callback get_members(org) :: [map]
  @callback get_repos(org) :: [repo]
  @callback get_topics(org, repo) :: [String.t()]
  @callback get_languages(org, repo) :: langs
end

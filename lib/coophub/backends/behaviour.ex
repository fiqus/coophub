defmodule Coophub.Backends.Behaviour do
  alias Coophub.Schemas.{Organization, Repository}

  @callback get_org(String.t(), Map.t()) :: Organization.t() | :error
  @callback get_members(Organization.t()) :: [map]
  @callback get_repos(Organization.t()) :: [Repository.t()]
  @callback get_topics(Organization.t(), Repository.t()) :: [String.t()]
  @callback get_languages(Organization.t(), Repository.t()) :: Backends.languages()
end

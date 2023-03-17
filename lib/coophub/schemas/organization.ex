defmodule Coophub.Schemas.Organization do
  @moduledoc """
  This is the schema of an Orgenization in Coophub
  """

  @type t :: %__MODULE__{
          id: integer(),
          key: String.t(),
          login: String.t(),
          name: String.t(),
          description: String.t(),
          email: String.t(),
          url: String.t(),
          yml_data: map(),
          following: integer(),
          avatar_url: String.t(),
          blog: String.t(),
          public_repos: integer(),
          location: String.t(),
          last_activity: String.t(),
          created_at: String.t(),
          updated_at: String.t(),
          languages: list(),
          html_url: String.t(),
          is_verified: boolean(),
          repos_url: String.t(),
          repo_count: integer(),
          star_count: integer(),
          popularity: float(),
          followers: integer(),
          repos: [Coophub.Schemas.Repository.t()],
          cached_at: String.t()
        }

  @derive Jason.Encoder
  defstruct [
    :id,
    :key,
    :login,
    :name,
    :description,
    :email,
    :url,
    :yml_data,
    :last_activity,
    :following,
    :avatar_url,
    :blog,
    :public_repos,
    :location,
    :created_at,
    :updated_at,
    :languages,
    :html_url,
    :is_verified,
    :repos_url,
    :repo_count,
    :star_count,
    :popularity,
    :followers,
    :repos,
    :cached_at
  ]
end

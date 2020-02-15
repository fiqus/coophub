defmodule Coophub.Schemas.Organization do
  @moduledoc """
  This is the schema of an Orgenization in Coophub
  """

  @type t :: %__MODULE__{
          id: Integer.t(),
          key: String.t(),
          login: String.t(),
          name: String.t(),
          description: String.t(),
          email: String.t(),
          url: String.t(),
          yml_data: Map.t(),
          following: Integer.t(),
          avatar_url: String.t(),
          blog: String.t(),
          public_repos: Integer.t(),
          location: String.t(),
          last_activity: String.t(),
          created_at: String.t(),
          updated_at: String.t(),
          languages: List.t(),
          members: List.t(),
          html_url: String.t(),
          is_verified: Boolean.t(),
          repos_url: String.t(),
          repo_count: Integer.t(),
          popularity: Float.t(),
          followers: Integer.t(),
          repos: [Coophub.Schemas.Repository.t()]
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
    :members,
    :html_url,
    :is_verified,
    :repos_url,
    :repo_count,
    :popularity,
    :followers,
    :repos
  ]
end

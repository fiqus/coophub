defmodule Coophub.Schemas.Organization do
  @moduledoc """
  This is the schema of an Orgenization in Coophub
  """

  @type t :: %__MODULE__{
    login: String.t(),
    name: String.t(),
    description: String.t(),
    email: String.t(),
    url: String.t(),
    yml_data: Map.t(),
    last_activity: DateTime.t(),
    key: String.t(),
    following: integer,
    avatar_url: String.t(),
    blog: String.t(),
    public_repos: integer,
    location: String.t(),
    created_at: DateTime.t(),
    updated_at: DateTime.t(),
    languages: List.t(),
    members: List.t(),
    html_url: String.t(),
    is_verified: Boolean.t(),
    repos_url: String.t(),
    repo_count: integer,
    popularity: float,
    followers: integer,
    repos: [Coophub.Schemas.Repository.t()]
  }

  @derive Jason.Encoder
  defstruct [:login, :name, :description, :email, :url, :yml_data, :last_activity, :key, :following,
  :avatar_url, :blog, :public_repos, :location, :created_at, :updated_at, :languages, :members, :html_url, :is_verified, :repos_url,
  :repo_count, :popularity, :followers, :repos]
end

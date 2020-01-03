defmodule Coophub.Schemas.Repository do
  @moduledoc """
  This is the schema of a Repository in Coophub
  """

  @type t :: %__MODULE__{
    id: integer,
    name: String.t(),
    description: String.t(),
    watchers_count: integer,
    disabled: Boolean.t(),
    stargazers_count: integer,
    license: Map.t(),
    forks_count: integer,
    created_at: DateTime.t(),
    pushed_at: DateTime.t(),
    updated_at: DateTime.t(),
    topics: List.t(String.t()),
    languages: List.t(),
    open_issues_count: integer,
    url: String.t(),
    language: String.t(),
    popularity: float,
    full_name: String.t(),
    fork: Boolean.t()
  }

  @derive Jason.Encoder
  defstruct [:id, :name, :description, :watchers_count, :disabled, :stargazers_count, :license, :forks_count, :created_at, :pushed_at, :updated_at,
  :topics, :languages, :open_issues_count, :url, :language, :popularity, :full_name, :fork]
end

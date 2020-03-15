defmodule Coophub.Schemas.Repository do
  @moduledoc """
  This is the schema of a Repository in Coophub
  """

  @type t :: %__MODULE__{
          id: integer(),
          key: String.t(),
          name: String.t(),
          description: String.t(),
          owner: map(),
          watchers_count: integer(),
          disabled: boolean(),
          stargazers_count: integer(),
          license: map(),
          forks_count: integer(),
          created_at: String.t(),
          pushed_at: String.t(),
          updated_at: String.t(),
          topics: list(String.t()),
          languages: map(),
          open_issues_count: integer(),
          html_url: String.t(),
          language: String.t(),
          popularity: float(),
          full_name: String.t(),
          fork: boolean(),
          parent: %{name: String.t(), url: String.t()}
        }

  @derive Jason.Encoder
  defstruct [
    :id,
    :key,
    :name,
    :description,
    :owner,
    :watchers_count,
    :disabled,
    :stargazers_count,
    :license,
    :forks_count,
    :created_at,
    :pushed_at,
    :updated_at,
    :topics,
    :languages,
    :open_issues_count,
    :html_url,
    :language,
    :popularity,
    :full_name,
    :fork,
    :parent
  ]
end

defmodule Coophub.Schemas.Repository do
  @moduledoc """
  This is the schema of a Repository in Coophub
  """

  @type t :: %__MODULE__{
          id: Integer.t(),
          key: String.t(),
          name: String.t(),
          description: String.t(),
          owner: Map.t(),
          watchers_count: Integer.t(),
          disabled: Boolean.t(),
          stargazers_count: Integer.t(),
          license: Map.t(),
          forks_count: Integer.t(),
          created_at: String.t(),
          pushed_at: String.t(),
          updated_at: String.t(),
          topics: List.t(String.t()),
          languages: Map.t(),
          open_issues_count: Integer.t(),
          html_url: String.t(),
          language: String.t(),
          popularity: Float.t(),
          full_name: String.t(),
          fork: Boolean.t(),
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

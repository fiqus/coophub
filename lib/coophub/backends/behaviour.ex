defmodule Coophub.Backends.Behaviour do
  alias Coophub.Schemas.{Organization, Repository}

  require Logger

  @type headers :: [{String.t(), String.t()}]

  @callback get_org(String.t(), Map.t()) :: Organization.t() | :error
  @callback get_members(Organization.t()) :: [map]

  @callback get_repos(Organization.t()) :: [Repository.t()]
  @callback get_topics(Organization.t(), Repository.t()) :: [String.t()]

  @callback headers() :: headers

  @spec call_api_get(String.t(), headers()) :: {:ok, map | [map]} | {:error, any}
  def call_api_get(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found: #{url}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end

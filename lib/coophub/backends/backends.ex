defmodule Coophub.Backends do
  alias Coophub.Backends

  @type headers :: [{String.t(), String.t()}]
  @type languages :: [%{String.t() => integer()}]

  ## Backends definitions
  defp get_backend("github"), do: Backends.Github
  defp get_backend(source), do: raise("Unknown backend source: #{source}")

  @spec call_backend!(String.t(), atom, list) :: Backends.Behaviour.results()
  def call_backend!(source, func, params) do
    get_backend(source) |> apply(func, params)
  end

  @spec call_api_get(String.t(), headers) :: {:ok, map | [map], integer} | {:error, any}
  def call_api_get(url, headers) do
    start_ms = take_time()

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body), take_time() - start_ms}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found: #{url}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp take_time(), do: System.monotonic_time(:millisecond)
end

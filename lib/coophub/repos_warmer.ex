defmodule Coophub.ReposWarmer do
  use Cachex.Warmer

  require Logger

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.minutes(20)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    Logger.info("Warming repos into repos cache..")

    path = Path.join(File.cwd!(), "cooperatives.yml")
    {:ok, coops} = YamlElixir.read_from_file(path)

    repos =
      coops
      |> Enum.reduce([], fn {org, info}, acc ->
        [get_repos(org, info) | acc]
      end)

    {:ok, repos}
  end

  defp get_repos(org, info) do
    case HTTPoison.get("https://api.github.com/orgs/#{org}/repos") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        repos = Jason.decode!(body)
        Logger.info("saving #{length(repos)} repos for #{org}")
        {org, Map.put(info, "repos", repos)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {org, info}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("error getting the repos from github with reason: #{inspect(reason)}")
        {org, info}
    end
  end
end

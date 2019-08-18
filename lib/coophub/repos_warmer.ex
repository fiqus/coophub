defmodule Coophub.ReposWarmer do
  use Cachex.Warmer

  require Logger

  @dump_file Application.get_env(:coophub, :cachex_dump)

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.minutes(20)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state), do: maybe_warm(Mix.env())

  defp maybe_warm(:dev) do
    Logger.info("Warming repos into cache from dump..", ansi_color: :yellow)
    Process.sleep(2000)
    Cachex.load(:repos_cache, @dump_file)

    size =
      case Cachex.size(:repos_cache) do
        {:ok, size} -> size
        _ -> 0
      end

    if size < read_yml() |> Map.keys() |> length() do
      load_cache() |> save_cache()
    else
      :ignore
    end
  end

  defp maybe_warm(_), do: load_cache()

  defp load_cache() do
    Logger.info("Warming repos into cache from github..", ansi_color: :yellow)

    repos =
      read_yml()
      |> Enum.reduce([], fn {org, info}, acc ->
        [get_repos(org, info) | acc]
      end)

    {:ok, repos}
  end

  defp save_cache(result) do
    spawn(&save_cache/0)
    result
  end

  defp save_cache() do
    Process.sleep(2000)
    Logger.info("Dumping repos cache to local file '#{@dump_file}'..", ansi_color: :yellow)
    Cachex.dump(:repos_cache, @dump_file)
  end

  defp get_repos(org, info) do
    case HTTPoison.get("https://api.github.com/orgs/#{org}/repos") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        repos = Jason.decode!(body)
        Logger.info("Saving #{length(repos)} repos for #{org}", ansi_color: :yellow)
        {org, Map.put(info, "repos", repos)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {org, info}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("error getting the repos from github with reason: #{inspect(reason)}")
        {org, info}
    end
  end

  defp read_yml() do
    path = Path.join(File.cwd!(), "cooperatives.yml")
    {:ok, coops} = YamlElixir.read_from_file(path)
    coops
  end
end

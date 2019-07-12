defmodule CoophubWeb.PageController do
  use CoophubWeb, :controller

  def index(conn, _params) do
    path = Path.join(File.cwd!(), "cooperatives.yml")
    {:ok, coops} = YamlElixir.read_from_file(path)

    repos =
      coops
      |> Enum.map(fn {org, info} ->
        {org, Map.put(info, "repos", get_repos(org))}
      end)

    render(conn, "index.html", repos: repos)
  end

  defp get_repos(org) do
    case HTTPoison.get("https://api.github.com/orgs/#{org}/repos") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode!(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end

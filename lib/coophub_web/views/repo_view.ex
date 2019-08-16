defmodule CoophubWeb.RepoView do
  use CoophubWeb, :view

  def render("index.json", %{orgs_repos: orgs_repos}) do
    %{orgs_repos: orgs_repos}
  end

  def render("show.json", %{repos: repos}) do
    %{repos: repos}
  end
end

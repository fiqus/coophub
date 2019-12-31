defmodule CoophubWeb.RepoView do
  use CoophubWeb, :view

  def render("index.json", %{orgs: orgs}) do
    %{data: orgs}
  end

  def render("org.json", %{org: org}) do
    %{data: org}
  end

  def render("repos.json", %{repos: repos}) do
    %{data: repos}
  end

  def render("counters.json", %{counters: counters}) do
    %{data: counters}
  end

  def render("topics.json", %{topics: topics}) do
    %{data: topics}
  end

  def render("languages.json", %{languages: languages}) do
    %{data: languages}
  end
end

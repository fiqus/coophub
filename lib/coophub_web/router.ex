defmodule CoophubWeb.Router do
  use CoophubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CoophubWeb do
    pipe_through :api

    get "/orgs", RepoController, :index
    get "/orgs/:name", RepoController, :org
    get "/orgs/:name/repos", RepoController, :org_repos
    get "/repos", RepoController, :repos
    get "/topics", RepoController, :topics
    get "/search", RepoController, :search
    get "/languages", RepoController, :languages
    get "/languages/:lang", RepoController, :language
  end

  scope "/", CoophubWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end

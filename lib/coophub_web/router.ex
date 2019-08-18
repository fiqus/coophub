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
    get "/orgs/:name", RepoController, :orgs_repos
    get "/orgs/:name/latest", RepoController, :org_repos_latest
    get "/orgs/:name/popular", RepoController, :org_repos_popular
    get "/repos/latest", RepoController, :repos_latest
    get "/repos/popular", RepoController, :repos_popular
  end

  scope "/", CoophubWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end

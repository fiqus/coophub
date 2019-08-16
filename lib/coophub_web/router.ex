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

  scope "/", CoophubWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", CoophubWeb do
    pipe_through :api

    get "/orgs", OrgController, :index
    get "/orgs/:name", OrgController, :show
  end
end

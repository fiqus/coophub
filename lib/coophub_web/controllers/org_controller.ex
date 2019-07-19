defmodule CoophubWeb.OrgController do
  use CoophubWeb, :controller

  action_fallback(CoophubWeb.FallbackController)

  def show(conn, %{"name" => name}) do
    {:ok, org} = Cachex.get(:repos_cache, name)
    # TODO if org is nil -> 404
    render(conn, "show.json", org: org)
  end
end

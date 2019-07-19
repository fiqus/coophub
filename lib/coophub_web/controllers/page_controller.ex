defmodule CoophubWeb.PageController do
  use CoophubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

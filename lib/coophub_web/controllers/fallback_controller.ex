defmodule CoophubWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CoophubWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(CoophubWeb.ErrorView, :"404")
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(CoophubWeb.ChangesetView, "error.json")
  end
end

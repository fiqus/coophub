defmodule CoophubWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CoophubWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(CoophubWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, _error) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(CoophubWeb.ErrorView)
    |> render(:"500")
  end
end

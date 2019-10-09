defmodule CoophubWeb.PageControllerTest do
  use CoophubWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "CoopHub"
  end

  test "returns 200 even when the route is not defined", %{conn: conn} do
    conn = get(conn, "/this-route-is-not-defined")
    assert html_response(conn, 200) =~ "CoopHub"
  end
end

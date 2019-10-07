defmodule CoophubWeb.PageControllerTest do
  use CoophubWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "CoopHub"
  end
end

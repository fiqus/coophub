defmodule CoophubWeb.RepoControllerTest do
  use CoophubWeb.ConnCase

  describe "GET /api/orgs" do
    test "lists all orgs", %{conn: conn} do
      data = get_data(conn, :index)
      assert data["fiqus"]["email"] == "info@fiqus.coop"
      assert data["test"]["email"] == "info@test.coop"
    end
  end

  describe "GET /api/orgs/:name" do
    test "WIP!" do
    end
  end

  describe "GET /api/orgs/:name/repos" do
    test "WIP!" do
    end
  end

  describe "GET /api/repos" do
    test "WIP!" do
    end
  end

  defp get_data(conn, path) do
    response = conn |> get(Routes.repo_path(conn, path)) |> json_response(200)
    response["data"]
  end
end

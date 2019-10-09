defmodule CoophubWeb.RepoControllerTest do
  use CoophubWeb.ConnCase

  describe "GET /api/orgs" do
    test "lists all orgs sorted by default: latest", %{conn: conn} do
      data = get_data(conn, :index)
      assert length(data) == 2
      assert Enum.at(data, 0)["email"] == "info@test.coop"
      assert Enum.at(data, 1)["email"] == "info@fiqus.coop"
    end

    test "lists all orgs sorted by: popular", %{conn: conn} do
      data = get_data(conn, :index, %{"sort" => "popular"})
      assert length(data) == 2
      assert Enum.at(data, 0)["email"] == "info@fiqus.coop"
      assert Enum.at(data, 1)["email"] == "info@test.coop"
    end

    test "lists all orgs according to given limit", %{conn: conn} do
      data = get_data(conn, :index, %{"sort" => "popular", "limit" => "1"})
      assert length(data) == 1
      assert Enum.at(data, 0)["email"] == "info@fiqus.coop"
    end
  end

  describe "GET /api/orgs/:name" do
    test "get a specific org: fiqus", %{conn: conn} do
      data = get_data(conn, :org, "fiqus")
      assert data["id"] == 1_891_317
      assert data["email"] == "info@fiqus.coop"
    end

    test "get a specific org: test", %{conn: conn} do
      data = get_data(conn, :org, "test")
      assert data["id"] == 123
      assert data["email"] == "info@test.coop"
    end

    test "404 when org is not found", %{conn: conn} do
      conn = get(conn, Routes.repo_path(conn, :org, "not-found"))
      assert html_response(conn, 404) =~ "404 - Not Found"
    end
  end

  describe "GET /api/orgs/:name/repos" do
    test "get a specific org repos: fiqus", %{conn: conn} do
      data = get_data(conn, :org_repos, "fiqus")
      assert length(data) == 2
      assert Enum.at(data, 0)["id"] == 186_053_039
      assert Enum.at(data, 0)["name"] == "surgex"
      assert Enum.at(data, 1)["id"] == 184_261_975
      assert Enum.at(data, 1)["name"] == "uk-talk"
    end

    test "get a specific org repos: test", %{conn: conn} do
      data = get_data(conn, :org_repos, "test")
      assert length(data) == 3
      assert Enum.at(data, 0)["id"] == 123_111
      assert Enum.at(data, 0)["name"] == "testone"
      assert Enum.at(data, 1)["id"] == 123_222
      assert Enum.at(data, 1)["name"] == "testtwo"
      assert Enum.at(data, 2)["id"] == 123_333
      assert Enum.at(data, 2)["name"] == "testthree"
    end

    test "get a specific org repos sorted by: popular", %{conn: conn} do
      data = get_data(conn, :org_repos, "test", %{"sort" => "popular"})
      assert length(data) == 3
      assert Enum.at(data, 0)["name"] == "testone"
      assert Enum.at(data, 1)["name"] == "testtwo"
      assert Enum.at(data, 2)["name"] == "testthree"
    end

    test "get a specific org repos according to given limit", %{conn: conn} do
      data = get_data(conn, :org_repos, "test", %{"sort" => "popular", "limit" => "1"})
      assert length(data) == 1
      assert Enum.at(data, 0)["name"] == "testone"
    end

    test "404 when org is not found", %{conn: conn} do
      conn = get(conn, Routes.repo_path(conn, :org_repos, "not-found"))
      assert html_response(conn, 404) =~ "404 - Not Found"
    end
  end

  describe "GET /api/repos" do
    test "get all repos sorted by default: latest", %{conn: conn} do
      data = get_data(conn, :repos)
      assert length(data) == 5
      assert Enum.at(data, 0)["name"] == "surgex"
      assert Enum.at(data, 1)["name"] == "testone"
      assert Enum.at(data, 2)["name"] == "testtwo"
      assert Enum.at(data, 3)["name"] == "uk-talk"
      assert Enum.at(data, 4)["name"] == "testthree"
    end

    test "get all repos sorted by unknown: latest", %{conn: conn} do
      data = get_data(conn, :repos, %{"sort" => "unknown"})
      assert length(data) == 5
      assert Enum.at(data, 0)["name"] == "surgex"
      assert Enum.at(data, 1)["name"] == "testone"
      assert Enum.at(data, 2)["name"] == "testtwo"
      assert Enum.at(data, 3)["name"] == "uk-talk"
      assert Enum.at(data, 4)["name"] == "testthree"
    end

    test "get all repos sorted by: popular", %{conn: conn} do
      data = get_data(conn, :repos, %{"sort" => "popular"})
      assert length(data) == 5
      assert Enum.at(data, 0)["name"] == "testone"
      assert Enum.at(data, 1)["name"] == "surgex"
      assert Enum.at(data, 2)["name"] == "testtwo"
      assert Enum.at(data, 3)["name"] == "testthree"
      assert Enum.at(data, 4)["name"] == "uk-talk"
    end

    test "get repos according to given limit", %{conn: conn} do
      data = get_data(conn, :repos, %{"sort" => "popular", "limit" => "2"})
      assert length(data) == 2
      assert Enum.at(data, 0)["name"] == "testone"
      assert Enum.at(data, 1)["name"] == "surgex"
      data = get_data(conn, :repos, %{"limit" => 3})
      assert length(data) == 3
    end

    test "get all repos because limit value is not valid", %{conn: conn} do
      data = get_data(conn, :repos, %{"limit" => ""})
      assert length(data) == 5
      data = get_data(conn, :repos, %{"limit" => "0"})
      assert length(data) == 5
      data = get_data(conn, :repos, %{"limit" => "wrong!"})
      assert length(data) == 5
    end
  end

  defp get_data(conn, path, params \\ %{}) do
    api_call_get(conn, Routes.repo_path(conn, path, params))
  end

  defp get_data(conn, path, params, data) do
    api_call_get(conn, Routes.repo_path(conn, path, params, data))
  end

  defp api_call_get(conn, uri) do
    response = conn |> get(uri) |> json_response(200)
    response["data"]
  end
end

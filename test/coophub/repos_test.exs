defmodule Coophub.ReposTest do
  use Coophub.DataCase

  describe "get_all_orgs/0" do
    test "returns a list with all orgs" do
      orgs = Repos.get_all_orgs()
      assert Map.keys(orgs) == ["fiqus", "test"]
      assert orgs["fiqus"]["email"] == "info@fiqus.coop"
      assert orgs["test"]["email"] == "info@test.coop"
    end
  end

  describe "get_all_repos/0" do
    test "WIP!" do
    end
  end

  describe "get_orgs/2" do
    test "WIP!" do
    end
  end

  describe "get_org/1" do
    test "WIP!" do
    end
  end

  describe "get_org_info/1" do
    test "WIP!" do
    end
  end

  describe "get_org_repos/3" do
    test "WIP!" do
    end
  end

  describe "get_repos/2" do
    test "WIP!" do
    end
  end

  describe "search/2" do
    test "returns an empty list when no repos match a single term" do
      repos = Repos.search("will-not-match")
      assert length(repos) == 0
    end

    test "returns an empty list when no repos match multiple terms" do
      repos = Repos.search(["test", "will-not-match"], :and)
      assert length(repos) == 0

      repos = Repos.search(["will-not-match", "this-neither", "nor-this"], :or)
      assert length(repos) == 0
    end

    test "returns a list with matching repos for a single term" do
      repos = Repos.search("test")
      assert length(repos) == 3
      assert Enum.at(repos, 0)["name"] == "surgex"
      assert Enum.at(repos, 1)["name"] == "testone"
      assert Enum.at(repos, 2)["name"] == "testthree"
    end

    test "returns a list with matching repos for multiple terms" do
      repos = Repos.search(["test", "elixir-lang"])
      assert length(repos) == 1
      assert Enum.at(repos, 0)["name"] == "surgex"

      repos = Repos.search(["test", "elixir-lang", "talks"], :or)
      assert length(repos) == 4
      assert Enum.at(repos, 0)["name"] == "surgex"
      assert Enum.at(repos, 1)["name"] == "uk-talk"
      assert Enum.at(repos, 2)["name"] == "testone"
      assert Enum.at(repos, 3)["name"] == "testthree"
    end
  end
end

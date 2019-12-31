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

  describe "get_counters/0" do
    test "returns the counters for orgs and repos" do
      assert Repos.get_counters() == %{"orgs" => 2, "repos" => 5}
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
      assert length(repos) == 4
      assert repo_in(repos, "surgex")
      assert repo_in(repos, "testone")
      assert repo_in(repos, "testtwo")
      assert repo_in(repos, "testthree")
    end

    test "returns a list with matching repos for a single topic" do
      repos = Repos.search(%{"topics" => ["test"]})
      assert length(repos) == 3
      assert repo_in(repos, "surgex")
      assert repo_in(repos, "testone")
      assert repo_in(repos, "testthree")
    end

    test "returns a list with matching repos for multiple terms" do
      repos = Repos.search(["test", "fiqus"])
      assert length(repos) == 1
      assert Enum.at(repos, 0)["name"] == "surgex"

      repos = Repos.search(["test", "elixir-lang", "talks"], :or)
      assert length(repos) == 5
      assert repo_in(repos, "surgex")
      assert repo_in(repos, "uk-talk")
      assert repo_in(repos, "testone")
      assert repo_in(repos, "testtwo")
      assert repo_in(repos, "testthree")
    end

    test "returns a list with matching repos for a multiple topics" do
      repos = Repos.search(%{"topics" => ["test", "elixir-lang"]})
      assert length(repos) == 1
      assert Enum.at(repos, 0)["name"] == "surgex"
    end
  end

  defp repo_in(repos, name), do: Enum.find(repos, &(&1["name"] == name)) !== nil
end

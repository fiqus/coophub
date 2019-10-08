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
end

defmodule CoophubWeb.Fixtures do
  @repos_cache_name Application.get_env(:coophub, :cachex_name)

  def generate() do
    data = generate_orgs()
    {:ok, true} = clear()
    {:ok, true} = Cachex.put_many(@repos_cache_name, data, ttl: :timer.hours(1))
    data
  end

  def clear(), do: Cachex.reset(@repos_cache_name)

  def generate_orgs() do
    [
      {"fiqus",
       %{
         "repos" => generate_repos(:fiqus),
         "login" => "fiqus",
         "id" => 1_891_317,
         "node_id" => "MDEyOk9yZ2FuaXphdGlvbjE4OTEzMTc=",
         "url" => "https://api.github.com/orgs/fiqus",
         "repos_url" => "https://api.github.com/orgs/fiqus/repos",
         "events_url" => "https://api.github.com/orgs/fiqus/events",
         "hooks_url" => "https://api.github.com/orgs/fiqus/hooks",
         "issues_url" => "https://api.github.com/orgs/fiqus/issues",
         "members_url" => "https://api.github.com/orgs/fiqus/members{/member}",
         "public_members_url" => "https://api.github.com/orgs/fiqus/public_members{/member}",
         "avatar_url" => "https://avatars2.githubusercontent.com/u/1891317?v=4",
         "description" => "",
         "name" => "Cooperativa de Trabajo Fiqus Ltda.",
         "company" => nil,
         "blog" => "fiqus.coop",
         "location" => "Argentina",
         "email" => "info@fiqus.coop",
         "is_verified" => true,
         "has_organization_projects" => true,
         "has_repository_projects" => true,
         "public_repos" => 18,
         "public_gists" => 0,
         "followers" => 0,
         "following" => 0,
         "html_url" => "https://github.com/fiqus",
         "created_at" => "2012-06-25T20:15:48Z",
         "updated_at" => "2019-09-02T01:07:04Z",
         "last_activity" => "2019-09-03T01:07:04Z",
         "type" => "Organization",
         "members" => [
           %{"id" => 111, "login" => "fiqusmember", "type" => "User"}
         ]
       }},
      {"test",
       %{
         "repos" => generate_repos(:test),
         "login" => "test",
         "id" => 123,
         "node_id" => "123",
         "url" => "https://api.github.com/orgs/test",
         "repos_url" => "https://api.github.com/orgs/test/repos",
         "avatar_url" => "https://avatars2.githubusercontent.com/u/123?v=4",
         "description" => "Testing !",
         "name" => "Test data",
         "email" => "info@test.coop",
         "has_organization_projects" => true,
         "has_repository_projects" => true,
         "public_repos" => 3,
         "public_gists" => 0,
         "followers" => 3,
         "following" => 5,
         "html_url" => "https://github.com/test",
         "created_at" => "2011-06-25T20:15:48Z",
         "updated_at" => "2019-06-02T01:07:04Z",
         "last_activity" => "2019-09-04T01:07:04Z",
         "type" => "Organization",
         "members" => [
           %{"id" => 222, "login" => "testmember", "type" => "User"}
         ]
       }}
    ]
  end

  def generate_repos(:fiqus) do
    [
      %{
        "languages" => generate_languages(:surgex),
        "popularity" => 4,
        "id" => 186_053_039,
        "node_id" => "MDEwOlJlcG9zaXRvcnkxODYwNTMwMzk=",
        "name" => "surgex",
        "full_name" => "fiqus/surgex",
        "private" => false,
        "owner" => %{
          "login" => "fiqus",
          "id" => 1_891_317,
          "node_id" => "MDEyOk9yZ2FuaXphdGlvbjE4OTEzMTc=",
          "avatar_url" => "https://avatars2.githubusercontent.com/u/1891317?v=4",
          "gravatar_id" => "",
          "url" => "https://api.github.com/users/fiqus",
          "html_url" => "https://github.com/fiqus",
          "followers_url" => "https://api.github.com/users/fiqus/followers",
          "following_url" => "https://api.github.com/users/fiqus/following{/other_user}",
          "gists_url" => "https://api.github.com/users/fiqus/gists{/gist_id}",
          "starred_url" => "https://api.github.com/users/fiqus/starred{/owner}{/repo}",
          "subscriptions_url" => "https://api.github.com/users/fiqus/subscriptions",
          "organizations_url" => "https://api.github.com/users/fiqus/orgs",
          "repos_url" => "https://api.github.com/users/fiqus/repos",
          "events_url" => "https://api.github.com/users/fiqus/events{/privacy}",
          "received_events_url" => "https://api.github.com/users/fiqus/received_events",
          "type" => "Organization",
          "site_admin" => false
        },
        "html_url" => "https://github.com/fiqus/surgex",
        "description" => "💉 Una app para cirugías / A surgeries elixir app",
        "fork" => false,
        "url" => "https://api.github.com/repos/fiqus/surgex",
        "forks_url" => "https://api.github.com/repos/fiqus/surgex/forks",
        "keys_url" => "https://api.github.com/repos/fiqus/surgex/keys{/key_id}",
        "collaborators_url" =>
          "https://api.github.com/repos/fiqus/surgex/collaborators{/collaborator}",
        "teams_url" => "https://api.github.com/repos/fiqus/surgex/teams",
        "hooks_url" => "https://api.github.com/repos/fiqus/surgex/hooks",
        "issue_events_url" => "https://api.github.com/repos/fiqus/surgex/issues/events{/number}",
        "events_url" => "https://api.github.com/repos/fiqus/surgex/events",
        "assignees_url" => "https://api.github.com/repos/fiqus/surgex/assignees{/user}",
        "branches_url" => "https://api.github.com/repos/fiqus/surgex/branches{/branch}",
        "tags_url" => "https://api.github.com/repos/fiqus/surgex/tags",
        "blobs_url" => "https://api.github.com/repos/fiqus/surgex/git/blobs{/sha}",
        "git_tags_url" => "https://api.github.com/repos/fiqus/surgex/git/tags{/sha}",
        "git_refs_url" => "https://api.github.com/repos/fiqus/surgex/git/refs{/sha}",
        "trees_url" => "https://api.github.com/repos/fiqus/surgex/git/trees{/sha}",
        "statuses_url" => "https://api.github.com/repos/fiqus/surgex/statuses/{sha}",
        "languages_url" => "https://api.github.com/repos/fiqus/surgex/languages",
        "stargazers_url" => "https://api.github.com/repos/fiqus/surgex/stargazers",
        "contributors_url" => "https://api.github.com/repos/fiqus/surgex/contributors",
        "subscribers_url" => "https://api.github.com/repos/fiqus/surgex/subscribers",
        "subscription_url" => "https://api.github.com/repos/fiqus/surgex/subscription",
        "commits_url" => "https://api.github.com/repos/fiqus/surgex/commits{/sha}",
        "git_commits_url" => "https://api.github.com/repos/fiqus/surgex/git/commits{/sha}",
        "comments_url" => "https://api.github.com/repos/fiqus/surgex/comments{/number}",
        "issue_comment_url" =>
          "https://api.github.com/repos/fiqus/surgex/issues/comments{/number}",
        "contents_url" => "https://api.github.com/repos/fiqus/surgex/contents/{+path}",
        "compare_url" => "https://api.github.com/repos/fiqus/surgex/compare/{base}...{head}",
        "merges_url" => "https://api.github.com/repos/fiqus/surgex/merges",
        "archive_url" => "https://api.github.com/repos/fiqus/surgex/{archive_format}{/ref}",
        "downloads_url" => "https://api.github.com/repos/fiqus/surgex/downloads",
        "issues_url" => "https://api.github.com/repos/fiqus/surgex/issues{/number}",
        "pulls_url" => "https://api.github.com/repos/fiqus/surgex/pulls{/number}",
        "milestones_url" => "https://api.github.com/repos/fiqus/surgex/milestones{/number}",
        "notifications_url" =>
          "https://api.github.com/repos/fiqus/surgex/notifications{?since,all,participating}",
        "labels_url" => "https://api.github.com/repos/fiqus/surgex/labels{/name}",
        "releases_url" => "https://api.github.com/repos/fiqus/surgex/releases{/id}",
        "deployments_url" => "https://api.github.com/repos/fiqus/surgex/deployments",
        "created_at" => "2019-05-10T20:52:38Z",
        "updated_at" => "2019-09-27T17:19:22Z",
        "pushed_at" => "2019-10-05T13:53:41Z",
        "git_url" => "git://github.com/fiqus/surgex.git",
        "ssh_url" => "git@github.com:fiqus/surgex.git",
        "clone_url" => "https://github.com/fiqus/surgex.git",
        "svn_url" => "https://github.com/fiqus/surgex",
        "homepage" => nil,
        "size" => 1106,
        "stargazers_count" => 5,
        "watchers_count" => 5,
        "language" => "Elixir",
        "has_issues" => true,
        "has_projects" => true,
        "has_downloads" => true,
        "has_wiki" => true,
        "has_pages" => false,
        "forks_count" => 1,
        "mirror_url" => nil,
        "archived" => false,
        "disabled" => false,
        "open_issues_count" => 10,
        "license" => %{
          "key" => "mit",
          "name" => "MIT License",
          "spdx_id" => "MIT",
          "url" => "https://api.github.com/licenses/mit",
          "node_id" => "MDc6TGljZW5zZTEz"
        },
        "forks" => 1,
        "open_issues" => 10,
        "watchers" => 5,
        "default_branch" => "master",
        "permissions" => %{
          "admin" => false,
          "push" => false,
          "pull" => true
        }
      },
      %{
        "languages" => generate_languages(:uktalk),
        "popularity" => 1,
        "id" => 184_261_975,
        "node_id" => "MDEwOlJlcG9zaXRvcnkxODQyNjE5NzU=",
        "name" => "uk-talk",
        "full_name" => "fiqus/uk-talk",
        "private" => false,
        "owner" => %{
          "login" => "fiqus",
          "id" => 1_891_317,
          "node_id" => "MDEyOk9yZ2FuaXphdGlvbjE4OTEzMTc=",
          "avatar_url" => "https://avatars2.githubusercontent.com/u/1891317?v=4",
          "gravatar_id" => "",
          "url" => "https://api.github.com/users/fiqus",
          "html_url" => "https://github.com/fiqus",
          "followers_url" => "https://api.github.com/users/fiqus/followers",
          "following_url" => "https://api.github.com/users/fiqus/following{/other_user}",
          "gists_url" => "https://api.github.com/users/fiqus/gists{/gist_id}",
          "starred_url" => "https://api.github.com/users/fiqus/starred{/owner}{/repo}",
          "subscriptions_url" => "https://api.github.com/users/fiqus/subscriptions",
          "organizations_url" => "https://api.github.com/users/fiqus/orgs",
          "repos_url" => "https://api.github.com/users/fiqus/repos",
          "events_url" => "https://api.github.com/users/fiqus/events{/privacy}",
          "received_events_url" => "https://api.github.com/users/fiqus/received_events",
          "type" => "Organization",
          "site_admin" => false
        },
        "html_url" => "https://github.com/fiqus/uk-talk",
        "description" => nil,
        "fork" => false,
        "url" => "https://api.github.com/repos/fiqus/uk-talk",
        "forks_url" => "https://api.github.com/repos/fiqus/uk-talk/forks",
        "keys_url" => "https://api.github.com/repos/fiqus/uk-talk/keys{/key_id}",
        "collaborators_url" =>
          "https://api.github.com/repos/fiqus/uk-talk/collaborators{/collaborator}",
        "teams_url" => "https://api.github.com/repos/fiqus/uk-talk/teams",
        "hooks_url" => "https://api.github.com/repos/fiqus/uk-talk/hooks",
        "issue_events_url" => "https://api.github.com/repos/fiqus/uk-talk/issues/events{/number}",
        "events_url" => "https://api.github.com/repos/fiqus/uk-talk/events",
        "assignees_url" => "https://api.github.com/repos/fiqus/uk-talk/assignees{/user}",
        "branches_url" => "https://api.github.com/repos/fiqus/uk-talk/branches{/branch}",
        "tags_url" => "https://api.github.com/repos/fiqus/uk-talk/tags",
        "blobs_url" => "https://api.github.com/repos/fiqus/uk-talk/git/blobs{/sha}",
        "git_tags_url" => "https://api.github.com/repos/fiqus/uk-talk/git/tags{/sha}",
        "git_refs_url" => "https://api.github.com/repos/fiqus/uk-talk/git/refs{/sha}",
        "trees_url" => "https://api.github.com/repos/fiqus/uk-talk/git/trees{/sha}",
        "statuses_url" => "https://api.github.com/repos/fiqus/uk-talk/statuses/{sha}",
        "languages_url" => "https://api.github.com/repos/fiqus/uk-talk/languages",
        "stargazers_url" => "https://api.github.com/repos/fiqus/uk-talk/stargazers",
        "contributors_url" => "https://api.github.com/repos/fiqus/uk-talk/contributors",
        "subscribers_url" => "https://api.github.com/repos/fiqus/uk-talk/subscribers",
        "subscription_url" => "https://api.github.com/repos/fiqus/uk-talk/subscription",
        "commits_url" => "https://api.github.com/repos/fiqus/uk-talk/commits{/sha}",
        "git_commits_url" => "https://api.github.com/repos/fiqus/uk-talk/git/commits{/sha}",
        "comments_url" => "https://api.github.com/repos/fiqus/uk-talk/comments{/number}",
        "issue_comment_url" =>
          "https://api.github.com/repos/fiqus/uk-talk/issues/comments{/number}",
        "contents_url" => "https://api.github.com/repos/fiqus/uk-talk/contents/{+path}",
        "compare_url" => "https://api.github.com/repos/fiqus/uk-talk/compare/{base}...{head}",
        "merges_url" => "https://api.github.com/repos/fiqus/uk-talk/merges",
        "archive_url" => "https://api.github.com/repos/fiqus/uk-talk/{archive_format}{/ref}",
        "downloads_url" => "https://api.github.com/repos/fiqus/uk-talk/downloads",
        "issues_url" => "https://api.github.com/repos/fiqus/uk-talk/issues{/number}",
        "pulls_url" => "https://api.github.com/repos/fiqus/uk-talk/pulls{/number}",
        "milestones_url" => "https://api.github.com/repos/fiqus/uk-talk/milestones{/number}",
        "notifications_url" =>
          "https://api.github.com/repos/fiqus/uk-talk/notifications{?since,all,participating}",
        "labels_url" => "https://api.github.com/repos/fiqus/uk-talk/labels{/name}",
        "releases_url" => "https://api.github.com/repos/fiqus/uk-talk/releases{/id}",
        "deployments_url" => "https://api.github.com/repos/fiqus/uk-talk/deployments",
        "created_at" => "2019-04-30T12:54:40Z",
        "updated_at" => "2019-05-07T18:25:58Z",
        "pushed_at" => "2019-10-02T18:25:56Z",
        "git_url" => "git://github.com/fiqus/uk-talk.git",
        "ssh_url" => "git@github.com:fiqus/uk-talk.git",
        "clone_url" => "https://github.com/fiqus/uk-talk.git",
        "svn_url" => "https://github.com/fiqus/uk-talk",
        "homepage" => nil,
        "size" => 783,
        "stargazers_count" => 1,
        "watchers_count" => 1,
        "language" => "CSS",
        "has_issues" => true,
        "has_projects" => true,
        "has_downloads" => true,
        "has_wiki" => true,
        "has_pages" => true,
        "forks_count" => 0,
        "mirror_url" => nil,
        "archived" => false,
        "disabled" => false,
        "open_issues_count" => 0,
        "license" => nil,
        "forks" => 0,
        "open_issues" => 0,
        "watchers" => 1,
        "default_branch" => "master",
        "permissions" => %{
          "admin" => false,
          "push" => false,
          "pull" => true
        }
      }
    ]
  end

  def generate_repos(:test) do
    [
      %{
        "languages" => generate_languages(:testone),
        "popularity" => 5,
        "id" => 123_111,
        "node_id" => "123111=",
        "name" => "testone",
        "full_name" => "test/testone",
        "private" => false,
        "owner" => %{
          "login" => "test",
          "id" => 123
        },
        "html_url" => "https://github.com/test/testone",
        "description" => "Testone repo",
        "fork" => false,
        "url" => "https://api.github.com/repos/test/testone",
        "created_at" => "2019-05-10T20:52:38Z",
        "updated_at" => "2019-10-27T17:19:22Z",
        "pushed_at" => "2019-10-04T13:53:41Z",
        "git_url" => "git://github.com/test/testone.git",
        "ssh_url" => "git@github.com:test/testone.git",
        "clone_url" => "https://github.com/test/testone.git",
        "language" => "Elixir",
        "size" => 10_000,
        "stargazers_count" => 5,
        "forks" => 100,
        "forks_count" => 100,
        "watchers" => 10,
        "watchers_count" => 5,
        "open_issues" => 3,
        "open_issues_count" => 3,
        "archived" => false,
        "disabled" => false
      },
      %{
        "languages" => generate_languages(:testtwo),
        "popularity" => 3,
        "id" => 123_222,
        "node_id" => "123222=",
        "name" => "testtwo",
        "full_name" => "test/testtwo",
        "private" => false,
        "owner" => %{
          "login" => "test",
          "id" => 123
        },
        "html_url" => "https://github.com/test/testtwo",
        "description" => "Testtwo repo",
        "fork" => false,
        "url" => "https://api.github.com/repos/test/testtwo",
        "created_at" => "2019-05-10T20:52:38Z",
        "updated_at" => "2019-10-27T17:19:22Z",
        "pushed_at" => "2019-10-03T13:53:41Z",
        "git_url" => "git://github.com/test/testtwo.git",
        "ssh_url" => "git@github.com:test/testtwo.git",
        "clone_url" => "https://github.com/test/testtwo.git",
        "language" => "Python",
        "size" => 10_000,
        "stargazers_count" => 5,
        "forks" => 2,
        "forks_count" => 2,
        "watchers" => 10,
        "watchers_count" => 5,
        "open_issues" => 3,
        "open_issues_count" => 3,
        "archived" => false,
        "disabled" => false
      },
      %{
        "languages" => generate_languages(:testthree),
        "popularity" => 2,
        "id" => 123_333,
        "node_id" => "123333=",
        "name" => "testthree",
        "full_name" => "test/testthree",
        "private" => false,
        "owner" => %{
          "login" => "test",
          "id" => 123
        },
        "html_url" => "https://github.com/test/testthree",
        "description" => "Testthree repo",
        "fork" => false,
        "url" => "https://api.github.com/repos/test/testthree",
        "created_at" => "2019-05-10T20:52:38Z",
        "updated_at" => "2019-10-27T17:19:22Z",
        "pushed_at" => "2019-10-01T13:53:41Z",
        "git_url" => "git://github.com/test/testthree.git",
        "ssh_url" => "git@github.com:test/testthree.git",
        "clone_url" => "https://github.com/test/testthree.git",
        "language" => "PHP",
        "size" => 100,
        "stargazers_count" => 1,
        "forks" => 10,
        "forks_count" => 10,
        "watchers" => 0,
        "watchers_count" => 0,
        "open_issues" => 0,
        "open_issues_count" => 0,
        "archived" => false,
        "disabled" => false
      }
    ]
  end

  def generate_languages(:surgex) do
    %{
      "Elixir" => 142_649,
      "Vue" => 54487,
      "JavaScript" => 23030,
      "CSS" => 13607,
      "HTML" => 1050
    }
  end

  def generate_languages(:uktalk) do
    %{
      "CSS" => 642
    }
  end

  def generate_languages(:testone) do
    %{
      "Elixir" => 10_000,
      "Erlang" => 2_000,
      "JavaScript" => 4_000,
      "CSS" => 1_000,
      "HTML" => 500
    }
  end

  def generate_languages(:testtwo) do
    %{
      "Python" => 5_000,
      "CSS" => 2_000,
      "HTML" => 1_000
    }
  end

  def generate_languages(:testthree) do
    %{
      "PHP" => 100,
      "HTML" => 10
    }
  end
end

# CoopHub Changelog

## v0.3.0
* Improve cachex warmer using GitHub rate limiter allowing us to add organizations with no limits (#64)
* Added some new co-ops.

## v0.2.10

* Updating elixir and node deps.
* Add Lyseon Tech to the list of co-ops.

## v0.2.9

* Some minor adjustments, last 2020 release!

## v0.2.8

* Updating elixir and node deps.
* Add Catalyst Cooperative to the list of co-ops.

## v0.2.7

* [#57] Adding twitter meta image (#70)
* Added more coops =]

## v0.2.6

* Rolling back cache warming to synchronous according GitHub's Best Practices for API Rate Limiter.
* Added FACTTIC to coops.

## v0.2.5

* Increasing cachex warmer interval to 1 hour.

## v0.2.4

* Same as `v0.2.3` but adding `CHANGELOG.md`.

## v0.2.3

* [#61] Fixed sizing and style of popular languages chart on mobile
* More coops added!

## v0.2.2

* [#57] Added metadata to `<head>` (#60).
* [#58] Fixed wrong languages % in the index chart (#59).
* [#55] Added how to release a new coophub version at `README.md`.

## v0.2.1

* Added support for Git.coop: 
  * Add `use Coophub.Backends.Gitlab` in modules that want to add support to any public Gitlab server.
* In the organization page now shows the description of the `cooperatives.yml` file.

## v0.2.0

* Added support for GitLab!
* Cache warming improved using `Task.async`, so now loads the data concunrrently.

## v0.1.9

* [#48] Extract github API into its own module and refactor cache warmer to use it (#50).
* Adding current app version to footer.

## v0.1.8

* Adds Camplight in cooperatives.yml (#49).
* Hotfix for Repository.url => .html_url and getting back to work links at RepoCard.tsx.

## v0.1.7

* Schemaization of the data into Organization and Repository structs (#4 + #47).

## v0.1.6

* Some UI adjustments.
* Updating node deps.

## v0.1.5

* Adding org: Seattle Developer's Cooperative.
* Displaying total indexed orgs and repos number at home.
* Support for site subdomains as matching keys for orgs and langs.
* Some UI adjustments.

## v0.1.4

* Adding [CHANGELOG](CHANGELOG.md).
* Adding [VERSION](VERSION) file to hold the **latest released version** (loaded at [mix.exs](mix.exs#L7) as project `vsn`).
* Keeping updated the project version by writting the `VERSION` file when a release is published.
* Increasing the amount of fetched repos per org to `100` for `PROD` env.

## v0.1.3

* Adding cooperatives page (removing dropdown from header).
* Adding `exclude_forks` query param for get repos.
* Excluding forked repos from latest and popular from home, from all the languages stats as well.

# CoopHub Changelog

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
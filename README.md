# Coophub - Cooperatives repos over the world!

:link: [`coophub.io`](http://coophub.io)

This web app uses the [GitHub API](https://developer.github.com/v3/) and [GitLab API](https://docs.gitlab.com/ee/api/README.html) to fetch, process and nicely display the projects/repositories of any subscribed cooperative from over the world.

Please nothe that it's strictly limited to cooperative enterprises.

The main goal is to gather in one place all the open source projects that can be used to start others, to be consumed, to learn or to just motivate collaboration.

## Add your cooperative
1. [Fork this repo](https://github.com/fiqus/coophub/fork) or edit this [file](https://github.com/fiqus/coophub/edit/master/cooperatives.yml)
2. Add your co-op in the [cooperatives.yml](https://github.com/fiqus/coophub/blob/master/cooperatives.yml) file:
```
key_org_name:
  source: github|gitlab|git.coop
  login: <USERNAME_IN_THE_SOURCE>
  name: <NAME_OF_THE_COOP>
  url: <URL_OF_THE_COOP>
  description: <DESCRIPTION>
  location: <LOCATION>
```
3. Add-commit-push and send us a Pull Request!

## Changelog
See [changelog file](CHANGELOG.md)

## Development
It uses the Elixir [Phoenix Framework](https://phoenixframework.org/) for the back-end and ReactJS for the front-end.
Then, to run this app you will need:
- Erlang OTP >= 18
- Elixir >= 1.5
- NodeJS >= 5.0

Use `GITHUB_OAUTH_TOKEN` ENV var ir order to authenticate with the GitHub APIv3. Read the [guide](https://developer.github.com/v3/guides/getting-started/#oauth).

### Run it!
- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install`
- Start Phoenix server with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### API Endpoints
- GET api/orgs (all the coops)
- GET api/orgs/:name (detail of a coop)
- GET api/orgs/:name/repos (repos of a coop)
- GET api/repos (all coops repos)
- GET api/search?q=term_to_search
- GET api/topics (all the repos topics)
- GET api/languages (all the programming languages with percentages)
- GET api/languages/:lang (the repos using the lang)

## Allowed query params
- `limit` - Number
- `sort` - `popular` or `latest` (default)
- `exclude_forks` - boolean (`false` default)

## Releasing a new version
1. Update [CHANGELOG.md](https://github.com/fiqus/coophub/blob/master/CHANGELOG.md) with latest changes.
2. Go to create a [new release](https://github.com/fiqus/coophub/releases/new) and complete the fields:
  - Tag version: `vx.x.x` (like `v0.2.2`).
  - Target: Always against `master` branch.
  - Release title: Same as tag version.
  - Description: Just copy/paste the latest changes from [CHANGELOG.md](https://github.com/fiqus/coophub/blob/master/CHANGELOG.md).
3. Click the `Publish release` button and check that a new [github action](https://github.com/fiqus/coophub/actions?query=workflow%3A%22CI+-+Build+release+asset%22) was started for this release.
4. When the github action finishes, a [release asset](https://github.com/fiqus/coophub/releases/latest) should be attached (like `coophub-20200330-034316-0635b9c7.tar.gz`).
5. Done! Just wait a few minutes and the new release will be deployed to https://coophub.io (you can check the version at site footer).
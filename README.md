# Coophub

:link: [`coophub.io`](http://coophub.io)

This web app uses the [GitHub API](https://developer.github.com/v3/) and [GitLab API](https://docs.gitlab.com/ee/api/README.html) to join and show *nicely- the projects/repositories of any subscripted co-operative from over the world.

It is strictly limited to co-operative enterprises.

The main goal is to find in-the-same-place all the open source projects that can be used to start others, be consumed or motivate collaboration.

## Add your co-operative
1. [Fork this repo](https://github.com/fiqus/coophub/fork) or edit this [file](https://github.com/fiqus/coophub/edit/master/cooperatives.yml)
2. Add your co-op in the [cooperatives.yml](https://github.com/fiqus/coophub/blob/master/cooperatives.yml) file:
```
key_org_name:
  source: github or gitlab
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
- GET api/languages (all the programming languages with bytes and %)
- GET api/languages/:lang (the repos using the lang)

## Allowed query params
- `limit` - Number
- `sort` - `popular` or `latest` (default)
- `exclude_forks` - boolean (`false` default)

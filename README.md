# Coophub

This web app uses the [GitHub API](https://developer.github.com/v3/) to join and show *nicely- the projects/repositories of any subscripted co-operative from over the world.

It is strictly limited to co-operative enterprises.

The main goal is to find in-the-same-place all the open source projects that can be used to start others, be consumed or motivate collaboration.

## Add your co-operative
1. [Fork this repo](https://github.com/fiqus/coophub/fork).
2. Add your co-op in the [cooperatives.yml](https://github.com/fiqus/coophub/blob/master/cooperatives.yml) file.
3. Add-commit-push and send us a Pull Request!

## Development
It uses the Elixir [Phoenix Framework](https://phoenixframework.org/) for the back-end and ReactJS for the front-end.
Then, to run this app you will need:
- Erlang OTP >= 18
- Elixir >= 1.5
- NodeJS >= 5.0

### Run it!
- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `npm install`
- Start Phoenix server with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### API Endpoints
- GET api/repos/latest
- GET api/repos/popular
- GET api/orgs
- GET api/orgs/:name
- GET api/orgs/:name/latest
- GET api/orgs/:name/popular


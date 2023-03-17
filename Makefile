.PHONY: server release compile test coverage dialyzer plt clean

export MIX_ENV ?= dev
export SECRET_KEY_BASE ?= $(shell mix phx.gen.secret)

server:
	@iex --name server@127.0.0.1 -S mix phx.server

release: MIX_ENV=prod
release:
	@NODE_ENV=prod npm run deploy
	@mix phx.digest && PORT=4000 mix release
	@_build/prod/rel/coophub/bin/coophub start_iex

compile:
	@mix compile

test: MIX_ENV=test
test: dialyzer
	@mix test

coverage: MIX_ENV=test
coverage:
	@mix coverage

dialyzer: MIX_ENV=dev
dialyzer:
	@mix dialyzer --check=false

plt: MIX_ENV=dev
plt:
	@mix dialyzer --check=true --compile=true

clean:
	@mix deps.clean --all --unlock
	@rm -rf deps _build node_modules priv/static/*
	@rm repos-cache.dump
	@mix deps.get && npm install
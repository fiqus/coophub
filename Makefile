.PHONY: setup clean release start stop server test coverage dialyzer plt

export MIX_ENV ?= dev
export SECRET_KEY_BASE ?= $(shell mix phx.gen.secret)

setup:
	@mix deps.get && mix compile && npm install

clean:
	@mix deps.clean --all --unlock
	@rm -rf deps _build node_modules priv/static/*
	@rm repos-cache.dump
	@${MAKE} setup

release: MIX_ENV=prod
release: PORT=4000
release:
	@NODE_ENV=prod npm run deploy
	@mix phx.digest && mix release --force --overwrite
	@${MAKE} start

start:
	@_build/prod/rel/coophub/bin/coophub start_iex

stop:
	@_build/prod/rel/coophub/bin/coophub stop

server:
	@iex --name server@127.0.0.1 -S mix phx.server

test: MIX_ENV=test
test:
	@mix format --check-formatted
	@mix test
	@${MAKE} dialyzer

coverage: MIX_ENV=test
coverage:
	@mix coverage

dialyzer: MIX_ENV=dev
dialyzer:
	@mix dialyzer --format dialyxir

plt: MIX_ENV=dev
plt:
	@mix dialyzer --force-check --format dialyxir

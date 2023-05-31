#!/bin/bash

# Source the enviroment variables
if [ -f ".env" ]; then
    . .env
fi
source $HOME/.bashr

# If you want to recreate deps, delete this folder and run docker compose up again
if [ ! -d "deps" ]; then
    mix local.hex --force
    mix deps.get --force
    mix local.rebar --force
fi

mix phx.server

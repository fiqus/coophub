#!/bin/bash

# Source the enviroment variables
if [ -f ".env" ]; then
    . .env
fi
source $HOME/.bashrc

# tail -f /dev/null

if [ ! -d "deps" ]; then
    mix local.hex --force
    mix deps.get --force
    mix local.rebar --force
fi

if [ ! -d "node_modules" ]; then
    npm ci
fi

mix phx.server

#!/bin/bash

# Source the enviroment variables
if [ -f ".env" ]; then
    . .env
fi
source $HOME/.bashr

# If you want to recreate node_modules, delete this folder and run docker compose up again
if [ ! -d "node_modules" ]; then
    npm ci
fi

npm run watch

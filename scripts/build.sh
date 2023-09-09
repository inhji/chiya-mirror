#!/usr/bin/env bash

echo "Pulling latest changes.."
git pull origin main

echo "Updating mix dependencies.."
mix deps.get --only prod

echo "Compiling mix dependencies.."
MIX_ENV=prod mix compile

echo "Setting up assets.."
MIX_ENV=prod mix assets.setup

echo "Compiling assets.."
MIX_ENV=prod mix assets.deploy

echo "Generating release.."
MIX_ENV=prod mix release --overwrite

#!/usr/bin/env bash

echo "Pulling latest changes.."
git pull > /dev/null

echo "Updating mix dependencies.."
mix deps.get --only prod > /dev/null

echo "Compiling mix dependencies.."
MIX_ENV=prod mix compile > /dev/null

echo "Setting up assets.."
MIX_ENV=prod mix assets.setup > /dev/null

echo "Compiling assets.."
MIX_ENV=prod mix assets.deploy > /dev/null

echo "Generating release.."
MIX_ENV=prod mix release --overwrite > /dev/null

echo "Restarting application.."
systemctl --user restart chiya

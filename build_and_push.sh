#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/build_xime_home

echo "==> Building docker image"
docker build -f server_mqtt_docker/Dockerfile -t docker.io/xx/server_mqtt:latest .

echo "==> Docker Hub login (will pause for your password)"
docker login docker.io

echo "==> Pushing image"
docker push docker.io/xx/server_mqtt:latest

echo "Done."

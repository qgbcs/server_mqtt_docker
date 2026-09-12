#!/bin/bash
set -euo pipefail

REMOTE_URL="${1:-${DOCKER_REMOTE_URL:-https://xxx.com/qgbcs/multi_mqtt}}"
TARGET_DIR="/home/qgb/github"
mkdir -p "$TARGET_DIR"

if [[ -z "$REMOTE_URL" ]]; then
  echo "Usage: docker run ... IMAGE <git-remote-url>" >&2
  exit 1
fi

REPO_NAME="$(basename "${REMOTE_URL%/}" .git)"
TARGET_REPO_DIR="$TARGET_DIR/$REPO_NAME"

if [[ -d "$TARGET_REPO_DIR/.git" ]]; then
  echo "Repository already exists at $TARGET_REPO_DIR; skipping clone."
elif [[ -d "$TARGET_DIR" && -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  echo "Mounted directory is not empty, checking for existing repository..."
  if [[ -d "$TARGET_DIR/.git" ]]; then
    echo "Found Git repository at $TARGET_DIR; using it."
  else
    FOUND_REPO=""
    for candidate in "$TARGET_DIR"/*; do
      if [[ -d "$candidate/.git" ]]; then
        FOUND_REPO="$candidate"
        break
      fi
    done
    if [[ -n "$FOUND_REPO" ]]; then
      echo "Found existing repository at $FOUND_REPO; using it."
    else
      echo "No existing repo found; cloning $REMOTE_URL into $TARGET_DIR"
      python3 /opt/git.py --repo-path "$TARGET_DIR" --remote "$REMOTE_URL" clone
    fi
  fi
else
  echo "Cloning $REMOTE_URL into $TARGET_DIR"
  python3 /opt/git.py --repo-path "$TARGET_DIR" --remote "$REMOTE_URL" clone
fi

if [[ -f "$TARGET_REPO_DIR/server_mqtt.py" ]]; then
  echo "Starting server from $TARGET_REPO_DIR"
  cd "$TARGET_REPO_DIR"
  exec python3 server_mqtt.py --host 0.0.0.0 --port 1177
fi

if [[ -f "$TARGET_DIR/server_mqtt.py" ]]; then
  echo "Starting server from $TARGET_DIR"
  cd "$TARGET_DIR"
  exec python3 server_mqtt.py --host 0.0.0.0 --port 1177
fi

echo "Could not find server_mqtt.py under $TARGET_DIR or $TARGET_REPO_DIR" >&2
exit 1

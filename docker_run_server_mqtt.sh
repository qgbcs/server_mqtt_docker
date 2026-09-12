#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOCAL_BUILD_IMAGE="server_mqtt:local"
TARGET_IMAGE="${TARGET_IMAGE:-qgbcs/server_mqtt}"
TARGET_TAG="${TARGET_TAG:-armv7-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-server_mqtt}"
HOST_MOUNT="${HOST_MOUNT:-/home/qgb/github}"
HOST_PORT="${HOST_PORT:-1177}" # 192.168.1.20:
TARGET_PORT="${TARGET_PORT:-1177}"

if [[ ! -d "$HOST_MOUNT" ]]; then
  echo "[WARN] Host mount directory does not exist: $HOST_MOUNT"
  echo "[INFO] Creating it automatically..."
  mkdir -p "$HOST_MOUNT"
fi


echo " Ensuring final tag: $TARGET_IMAGE"
if ! docker image inspect "$TARGET_IMAGE" >/dev/null 2>&1; then
    echo " Building Docker image: $LOCAL_BUILD_IMAGE"
    docker build -t "$LOCAL_BUILD_IMAGE" .
    docker tag "$LOCAL_BUILD_IMAGE" "$TARGET_IMAGE":latest
    docker tag "$LOCAL_BUILD_IMAGE" "$TARGET_IMAGE":"$TARGET_TAG"

fi


echo " Running container"
exec docker run -it \
  --name "$CONTAINER_NAME" \
  -p "$HOST_PORT:$TARGET_PORT" \
  -v "$HOST_MOUNT:$HOST_MOUNT" \
  "$TARGET_IMAGE"

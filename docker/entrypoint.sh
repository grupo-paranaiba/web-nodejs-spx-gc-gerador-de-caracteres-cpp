#!/bin/sh
set -e

PORT="${SPX_PORT:-3011}"
DATA_ROOT="/spx-data"

mkdir -p \
  "${DATA_ROOT}/DATAROOT" \
  "${DATA_ROOT}/LOG" \
  "${DATA_ROOT}/ASSETS/templates" \
  "${DATA_ROOT}/ASSETS/plugins" \
  "${DATA_ROOT}/ASSETS/csv" \
  "${DATA_ROOT}/ASSETS/excel" \
  "${DATA_ROOT}/ASSETS/json" \
  "${DATA_ROOT}/ASSETS/media" \
  "${DATA_ROOT}/ASSETS/scripts"

link_dir() {
  target="$1"
  source="$2"
  if [ -L "${target}" ]; then
    return 0
  fi
  if [ -d "${target}" ] && [ ! -L "${target}" ]; then
    rm -rf "${target}"
  fi
  ln -snf "${source}" "${target}"
}

link_dir /app/DATAROOT "${DATA_ROOT}/DATAROOT"
link_dir /app/ASSETS "${DATA_ROOT}/ASSETS"
link_dir /app/LOG "${DATA_ROOT}/LOG"

if [ ! -f "${DATA_ROOT}/config.json" ]; then
  echo "Creating default config.json (port ${PORT})..."
  sed "s/\"port\": 3011/\"port\": ${PORT}/" /app/docker/config.docker.json > "${DATA_ROOT}/config.json"
fi

link_dir /app/config.json "${DATA_ROOT}/config.json"

exec node server.js

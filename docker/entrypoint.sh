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

# Volume antigo ou mount incorreto pode criar config.json como pasta
if [ -d "${DATA_ROOT}/config.json" ]; then
  echo "Removing invalid ${DATA_ROOT}/config.json (was a directory)."
  rm -rf "${DATA_ROOT}/config.json"
fi

create_config() {
  echo "Creating default config.json (port ${PORT})..."
  sed "s/\"port\": 3011/\"port\": ${PORT}/" /app/docker/config.docker.json > "${DATA_ROOT}/config.json"
}

if [ ! -f "${DATA_ROOT}/config.json" ] || [ ! -s "${DATA_ROOT}/config.json" ]; then
  rm -f "${DATA_ROOT}/config.json"
  create_config
elif ! node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "${DATA_ROOT}/config.json" 2>/dev/null; then
  echo "Invalid config.json (corrupt JSON), recreating..."
  rm -f "${DATA_ROOT}/config.json"
  create_config
fi

link_dir() {
  target="$1"
  source="$2"
  if [ -e "${target}" ] && [ ! -L "${target}" ]; then
    rm -rf "${target}"
  fi
  ln -snf "${source}" "${target}"
}

link_dir /app/DATAROOT "${DATA_ROOT}/DATAROOT"
link_dir /app/ASSETS "${DATA_ROOT}/ASSETS"
link_dir /app/LOG "${DATA_ROOT}/LOG"

if [ -e /app/config.json ] && [ ! -L /app/config.json ]; then
  rm -rf /app/config.json
fi
ln -sf "${DATA_ROOT}/config.json" /app/config.json

exec node server.js

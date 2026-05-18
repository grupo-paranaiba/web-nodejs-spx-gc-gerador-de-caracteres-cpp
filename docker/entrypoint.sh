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

if [ -d "${DATA_ROOT}/config.json" ]; then
  echo "Removing invalid ${DATA_ROOT}/config.json (was a directory)."
  rm -rf "${DATA_ROOT}/config.json"
fi

create_config() {
  echo "Creating default config.json (port ${PORT})..."
  SPX_PORT="${PORT}" SPX_CONFIG_PATH="${DATA_ROOT}/config.json" node <<'NODE'
const fs = require('fs');
const port = parseInt(process.env.SPX_PORT || '3011', 10);
const cfg = {
  warning: 'Docker default config. Modifications done in the SPX UI may overwrite this file.',
  copyright: '(c) 2020- SPX Graphics (https://spxgraphics.com)',
  updated: new Date().toISOString(),
  general: {
    username: 'admin',
    password: '',
    hostname: '',
    greeting: '',
    langfile: 'portuguese.json',
    loglevel: 'info',
    launchBrowser: false,
    apikey: '',
    logfolder: '/app/LOG/',
    dataroot: '/app/DATAROOT/',
    templatesource: 'spx-ip-address',
    port,
    disableConfigUI: false,
    disableLocalRenderer: false,
    disableOpenFolderCommand: true,
    disableSeveralControllersWarning: false,
    hideRendererCursor: false,
    resolution: 'HD',
    preview: 'selected',
    renderer: 'normal',
    autoplayLocalRenderer: true,
    recents: [],
  },
  casparcg: { servers: [] },
  osc: { enable: false, port: 57121 },
  globalExtras: {
    customscript: '/ExtraFunctions/demoFunctions.js',
    CustomControls: [],
  },
};
fs.writeFileSync(process.env.SPX_CONFIG_PATH, JSON.stringify(cfg, null, 2));
NODE
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

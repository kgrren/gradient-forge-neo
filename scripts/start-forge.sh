#!/usr/bin/env bash
set -euo pipefail

# Simple launcher for Forge from within the container.
# - You can call this from a terminal: `start-forge.sh`
# - Or via Jupyter "Launcher" if configured through jupyter_server_config.py

FORGE_DIR="${FORGE_DIR:-/opt/forge}"
PORT="${FORGE_PORT:-7860}"

cd "${FORGE_DIR}"

# Prefer Forge's own launcher if present.
if [ -f "src/launch.py" ]; then
  exec python src/launch.py --listen --port "${PORT}"
elif [ -f "launch.py" ]; then
  exec python launch.py --listen --port "${PORT}"
elif [ -f "webui.sh" ]; then
  exec bash webui.sh --listen --port "${PORT}"
else
  echo "Forge entrypoint not found in ${FORGE_DIR}."
  echo "Set FORGE_DIR to your repo directory, or mount your sources at /opt/forge."
  exit 1
fi

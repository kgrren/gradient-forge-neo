#!/usr/bin/env bash
set -euo pipefail

# This script is OPTIONAL convenience.
# You can keep running everything from your own ipynb exactly as you prefer.
#
# Environment variables to tweak:
#   FORGE_DIR=/notebooks/sd-webui-forge-neo
#   VENV_DIR=/tmp/sd-webui-forge-neo/venv
#   TORCH_COMMAND="uv pip install ... cu124 ..."
#   FORGE_ARGS="--uv --pin-shared-memory ..."

FORGE_DIR="${FORGE_DIR:-/notebooks/sd-webui-forge-neo}"
VENV_DIR="${VENV_DIR:-/tmp/sd-webui-forge-neo/venv}"
PORT="${FORGE_PORT:-7860}"
SUBPATH="${FORGE_SUBPATH:-/proxy/7860/}"

if [[ ! -d "${FORGE_DIR}" ]]; then
  echo "[start-forge-neo] Forge dir not found: ${FORGE_DIR}"
  echo "Clone it first, e.g.:"
  echo "  cd /notebooks && git clone https://github.com/Haoming02/sd-webui-forge-classic sd-webui-forge-neo --branch neo"
  exit 1
fi

if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
  echo "[start-forge-neo] venv not found: ${VENV_DIR}"
  echo "Create it first, e.g.:"
  echo "  uv venv --seed --python 3.11 ${VENV_DIR}"
  exit 1
fi

cd "${FORGE_DIR}"

# user can export TORCH_COMMAND to pin their preferred torch build
if [[ -n "${TORCH_COMMAND:-}" ]]; then
  echo "[start-forge-neo] Running TORCH_COMMAND: ${TORCH_COMMAND}"
  bash -lc "source '${VENV_DIR}/bin/activate' && ${TORCH_COMMAND}"
fi

# Your defaults (safe to override with FORGE_ARGS)
FORGE_ARGS_DEFAULT="--uv --pin-shared-memory --cuda-malloc --cuda-stream --enable-insecure-extension-access --port ${PORT} --listen --subpath ${SUBPATH}"
FORGE_ARGS="${FORGE_ARGS:-${FORGE_ARGS_DEFAULT}}"

exec bash -lc "source '${VENV_DIR}/bin/activate' && unset MPLBACKEND && python3.11 launch.py ${FORGE_ARGS}"

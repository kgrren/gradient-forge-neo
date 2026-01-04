#!/usr/bin/env bash
set -euo pipefail

FORGE_HOME="${FORGE_HOME:-/opt/sd-webui-forge-neo}"
NOTEBOOK_DIR="${NOTEBOOK_DIR:-/notebooks}"

# Default model folders live under /notebooks/models so they persist in the workspace volume.
MODEL_REF="${MODEL_REF:-${NOTEBOOK_DIR}/models}"
OUTPUT_DIR="${OUTPUT_DIR:-${NOTEBOOK_DIR}/outputs}"

mkdir -p "${MODEL_REF}" "${OUTPUT_DIR}"

cd "${FORGE_HOME}"

# Forge Neo supports many flags. We keep defaults safe for A4000:
# - listen on 0.0.0.0 so server-proxy can reach it
# - store outputs in the mounted volume
ARGS=(
  --listen
  --port 7860
  --api
  --model-ref "${MODEL_REF}"
  --outdir-txt2img-samples "${OUTPUT_DIR}/txt2img"
  --outdir-img2img-samples "${OUTPUT_DIR}/img2img"
  --outdir-extras-samples "${OUTPUT_DIR}/extras"
  --outdir-grids "${OUTPUT_DIR}/grids"
)

# Allow user overrides via FORGE_ARGS environment variable
if [ -n "${FORGE_ARGS:-}" ]; then
  # shellcheck disable=SC2206
  EXTRA_ARGS=(${FORGE_ARGS})
  ARGS+=("${EXTRA_ARGS[@]}")
fi

# Launch script location differs across forks; try a few.
if [ -f "webui.py" ]; then
  exec python3 webui.py "${ARGS[@]}"
elif [ -f "launch.py" ]; then
  exec python3 launch.py "${ARGS[@]}"
elif [ -f "src/launch.py" ]; then
  exec python3 src/launch.py "${ARGS[@]}"
else
  echo "ERROR: Could not find Forge launch script in ${FORGE_HOME}" >&2
  ls -la
  exit 1
fi

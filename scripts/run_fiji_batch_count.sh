#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FLOW_DIR="${1:-${REPO_DIR}/img_cellpose_output/flows}"
OUT_CSV="${2:-${REPO_DIR}/img_cellpose_output/counts_from_flows_fiji.csv}"
MIN_SIZE="${MIN_SIZE:-20}"
FIJI_BIN="${FIJI_BIN:-/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx}"
MACRO_PATH="${REPO_DIR}/fiji/batch_count_flows.ijm"

if [[ ! -d "${FLOW_DIR}" ]]; then
  echo "FLOW_DIR does not exist: ${FLOW_DIR}" >&2
  exit 1
fi

if [[ ! -x "${FIJI_BIN}" ]]; then
  echo "FIJI binary not found/executable: ${FIJI_BIN}" >&2
  echo "Set FIJI_BIN to your Fiji executable path." >&2
  exit 1
fi

mkdir -p "$(dirname "${OUT_CSV}")"

cmd=(
  "${FIJI_BIN}"
  --headless
  --console
  -macro "${MACRO_PATH}"
  "input=${FLOW_DIR},output=${OUT_CSV},min_size=${MIN_SIZE}"
)

printf 'Running FIJI batch count:\n'
printf '  %q' "${cmd[@]}"
printf '\n'

"${cmd[@]}"

echo "Done. CSV: ${OUT_CSV}"

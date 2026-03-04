#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INPUT_DIR="${INPUT_DIR:-${REPO_DIR}/img}"
RESIZED_DIR="${RESIZED_DIR:-${REPO_DIR}/img_resized_1000}"
OUTPUT_DIR="${OUTPUT_DIR:-${REPO_DIR}/img_cellpose_output}"

MAX_DIM="${MAX_DIM:-1000}"
BATCH_SIZE="${BATCH_SIZE:-8}"
DIAMETER="${DIAMETER:-35}"
FLOW_THRESHOLD="${FLOW_THRESHOLD:-0.4}"
CELLPROB_THRESHOLD="${CELLPROB_THRESHOLD:-0}"
MIN_SIZE="${MIN_SIZE:-20}"
NITER="${NITER:-250}"
NORM_PERCENTILE="${NORM_PERCENTILE:-1:99}"
GPU_DEVICE="${GPU_DEVICE:-0}"

# USE_GPU accepts: 1, 0, auto.
USE_GPU="${USE_GPU:-auto}"
CLEAN_OUTPUT="${CLEAN_OUTPUT:-1}"
CLEAN_RESIZED="${CLEAN_RESIZED:-1}"
CELLPOSE_ENV="${CELLPOSE_ENV:-cellpose-sam}"
AUTO_ACTIVATE_ENV="${AUTO_ACTIVATE_ENV:-1}"

if [[ ! -d "${INPUT_DIR}" ]]; then
  echo "INPUT_DIR does not exist: ${INPUT_DIR}" >&2
  exit 1
fi

# Best-effort environment activation for users running this from a fresh shell.
if [[ "${AUTO_ACTIVATE_ENV}" == "1" ]]; then
  if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
    if command -v conda >/dev/null 2>&1; then
      conda activate "${CELLPOSE_ENV}"
    fi
  fi
fi

if ! command -v python >/dev/null 2>&1; then
  echo "python not found. Run: bash scripts/setup_cellpose_env.sh" >&2
  exit 1
fi

if ! python - <<'PY' >/dev/null 2>&1
import importlib
importlib.import_module("cellpose")
PY
then
  echo "cellpose is not available in current Python. Run: bash scripts/setup_cellpose_env.sh" >&2
  exit 1
fi

case "${USE_GPU}" in
  1|0)
    ;;
  auto)
    if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
      USE_GPU=1
      echo "GPU detected via nvidia-smi. Running with USE_GPU=1"
    else
      USE_GPU=0
      echo "No usable NVIDIA GPU detected. Running with USE_GPU=0 (CPU mode)"
    fi
    ;;
  *)
    echo "Invalid USE_GPU='${USE_GPU}'. Allowed values: 1, 0, auto" >&2
    exit 1
    ;;
esac

cd "${REPO_DIR}"

if [[ "${CLEAN_OUTPUT}" == "1" ]]; then
  mkdir -p "${OUTPUT_DIR}"
  find "${OUTPUT_DIR}" -mindepth 1 -delete
fi

if [[ "${CLEAN_RESIZED}" == "1" ]]; then
  mkdir -p "${RESIZED_DIR}"
  find "${RESIZED_DIR}" -mindepth 1 -delete
fi

# Match website-like preprocessing: longest side <= MAX_DIM.
python scripts/resize_images_max_dim.py \
  --input-dir "${INPUT_DIR}" \
  --output-dir "${RESIZED_DIR}" \
  --max-dim "${MAX_DIM}"

INPUT_DIR="${RESIZED_DIR}" \
OUTPUT_DIR="${OUTPUT_DIR}" \
USE_GPU="${USE_GPU}" \
GPU_DEVICE="${GPU_DEVICE}" \
ONLY_OUTLINES_AND_FLOWS=0 \
SAVE_TIF=1 \
SAVE_PNG=0 \
SAVE_OUTLINES=1 \
SAVE_FLOWS=1 \
IN_FOLDERS=1 \
NO_NPY=1 \
DROP_DP_FLOWS=1 \
BATCH_SIZE="${BATCH_SIZE}" \
DIAMETER="${DIAMETER}" \
FLOW_THRESHOLD="${FLOW_THRESHOLD}" \
CELLPROB_THRESHOLD="${CELLPROB_THRESHOLD}" \
MIN_SIZE="${MIN_SIZE}" \
NITER="${NITER}" \
NORM_PERCENTILE="${NORM_PERCENTILE}" \
bash scripts/run_cellpose.sh

python scripts/count_from_label_masks.py \
  --masks-dir "${OUTPUT_DIR}/masks" \
  --out-csv "${OUTPUT_DIR}/counts_from_labels.csv"

cat <<EOF

Done.
Outputs:
  Label masks: ${OUTPUT_DIR}/masks
  Outlines:    ${OUTPUT_DIR}/outlines
  Flows:       ${OUTPUT_DIR}/flows (only *_flows_cp_masks.tif)
  Counts CSV:  ${OUTPUT_DIR}/counts_from_labels.csv
EOF

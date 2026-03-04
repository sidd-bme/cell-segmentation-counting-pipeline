#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -ge 1 ]]; then
  INPUT_DIR="$1"
elif [[ -d "${REPO_DIR}/img" ]]; then
  INPUT_DIR="${REPO_DIR}/img"
else
  INPUT_DIR="/scratch/${USER}/cellpose/input"
fi

if [[ $# -ge 2 ]]; then
  OUTPUT_DIR="$2"
elif [[ "${INPUT_DIR}" == "${REPO_DIR}/img" ]]; then
  OUTPUT_DIR="${REPO_DIR}/img_cellpose_output"
else
  OUTPUT_DIR="/scratch/${USER}/cellpose/output"
fi

CELLPOSE_ENV="${CELLPOSE_ENV:-cellpose-sam}"
QUEUE="${QUEUE:-interactive_gpu}"
SELECT="${SELECT:-1:ncpus=8:mem=64gb:ngpus=1}"
WALLTIME="${WALLTIME:-02:00:00}"
JOB_NAME="${JOB_NAME:-cellpose_i}"

cat <<EOF
Interactive session command:
  QUEUE=${QUEUE} SELECT='${SELECT}' WALLTIME=${WALLTIME} JOB_NAME=${JOB_NAME} bash ${REPO_DIR}/scripts/request_interactive_gpu.sh

After the interactive shell starts, run:
  cd ${REPO_DIR}
  source ~/miniconda3/etc/profile.d/conda.sh
  conda activate ${CELLPOSE_ENV}
  INPUT_DIR=${INPUT_DIR} OUTPUT_DIR=${OUTPUT_DIR} USE_GPU=1 bash scripts/run_pipeline.sh
EOF

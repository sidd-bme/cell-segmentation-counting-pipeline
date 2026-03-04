#!/usr/bin/env bash
set -euo pipefail

if ! command -v qsub >/dev/null 2>&1; then
  echo "qsub is not available in PATH." >&2
  exit 1
fi

QUEUE="${QUEUE:-interactive_gpu}"
SELECT="${SELECT:-1:ncpus=8:mem=64gb:ngpus=1}"
WALLTIME="${WALLTIME:-02:00:00}"
JOB_NAME="${JOB_NAME:-cellpose_i}"

cmd=(
  qsub
  -I
  -N "${JOB_NAME}"
  -q "${QUEUE}"
  -l "select=${SELECT}"
  -l "walltime=${WALLTIME}"
)

printf 'Requesting interactive GPU session:\n'
printf '  %q' "${cmd[@]}"
printf '\n'

"${cmd[@]}"

#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="${INPUT_DIR:-}"
IMAGE_PATH="${IMAGE_PATH:-}"
OUTPUT_DIR="${OUTPUT_DIR:-}"
MODEL="${MODEL:-cpsam}"
IMG_FILTER="${IMG_FILTER:-}"
BATCH_SIZE="${BATCH_SIZE:-8}"
USE_GPU="${USE_GPU:-1}"
GPU_DEVICE="${GPU_DEVICE:-0}"
LOOK_ONE_LEVEL_DOWN="${LOOK_ONE_LEVEL_DOWN:-0}"
DO_3D="${DO_3D:-0}"
DIAMETER="${DIAMETER:-35}"
CELLPROB_THRESHOLD="${CELLPROB_THRESHOLD:-0}"
FLOW_THRESHOLD="${FLOW_THRESHOLD:-0.4}"
MIN_SIZE="${MIN_SIZE:-20}"
NITER="${NITER:-250}"
CHANNEL_AXIS="${CHANNEL_AXIS:-}"
Z_AXIS="${Z_AXIS:-}"
SAVE_PNG="${SAVE_PNG:-0}"
SAVE_TIF="${SAVE_TIF:-0}"
SAVE_FLOWS="${SAVE_FLOWS:-1}"
SAVE_OUTLINES="${SAVE_OUTLINES:-1}"
SAVE_ROIS="${SAVE_ROIS:-0}"
SAVE_TXT="${SAVE_TXT:-0}"
SAVE_MPL="${SAVE_MPL:-0}"
NO_NPY="${NO_NPY:-1}"
IN_FOLDERS="${IN_FOLDERS:-1}"
ONLY_OUTLINES_AND_FLOWS="${ONLY_OUTLINES_AND_FLOWS:-1}"
NORM_PERCENTILE="${NORM_PERCENTILE:-1:99}"  # format: low:high
DROP_DP_FLOWS="${DROP_DP_FLOWS:-1}"         # remove *_dP_cp_masks.tif from flows/
EXTRA_ARGS="${EXTRA_ARGS:-}"

if [[ -n "${IMAGE_PATH}" ]]; then
  if [[ ! -f "${IMAGE_PATH}" ]]; then
    echo "IMAGE_PATH does not exist: ${IMAGE_PATH}" >&2
    exit 1
  fi
  INPUT_BASE_DIR="$(dirname "${IMAGE_PATH}")"
  if [[ -n "${IMG_FILTER}" ]]; then
    echo "IMG_FILTER is ignored when IMAGE_PATH is set."
    IMG_FILTER=""
  fi
elif [[ -n "${INPUT_DIR}" ]]; then
  if [[ ! -d "${INPUT_DIR}" ]]; then
    echo "INPUT_DIR does not exist: ${INPUT_DIR}" >&2
    exit 1
  fi
  INPUT_BASE_DIR="${INPUT_DIR}"
else
  echo "Either INPUT_DIR or IMAGE_PATH is required." >&2
  exit 1
fi

# In Cellpose, --img_filter is a suffix before file extension.
# Passing ".jpg" would incorrectly look for files like "* .jpg.jpg".
case "${IMG_FILTER,,}" in
  .jpg|.jpeg|.png|.tif|.tiff|jpg|jpeg|png|tif|tiff)
    echo "IMG_FILTER='${IMG_FILTER}' looks like a file extension; ignoring it."
    IMG_FILTER=""
    ;;
esac

if [[ -z "${OUTPUT_DIR}" ]]; then
  OUTPUT_DIR="${INPUT_BASE_DIR%/}_cellpose"
fi
mkdir -p "${OUTPUT_DIR}"

if [[ "${ONLY_OUTLINES_AND_FLOWS}" == "1" ]]; then
  # FIJI-friendly default: keep only visual outlines + diagnostic flows.
  SAVE_PNG=0
  SAVE_TIF=0
  SAVE_OUTLINES=1
  SAVE_FLOWS=1
  IN_FOLDERS=1
fi

if ! command -v python >/dev/null 2>&1; then
  echo "python not found in PATH." >&2
  exit 1
fi

cmd=(
  python -m cellpose
  --savedir "${OUTPUT_DIR}"
  --pretrained_model "${MODEL}"
  --batch_size "${BATCH_SIZE}"
  --verbose
)

if [[ -n "${IMAGE_PATH}" ]]; then
  cmd+=(--image_path "${IMAGE_PATH}")
else
  cmd+=(--dir "${INPUT_DIR}")
fi

if [[ "${USE_GPU}" == "1" ]]; then
  cmd+=(--use_gpu --gpu_device "${GPU_DEVICE}")
fi

if [[ "${LOOK_ONE_LEVEL_DOWN}" == "1" ]]; then
  cmd+=(--look_one_level_down)
fi

if [[ "${DO_3D}" == "1" ]]; then
  cmd+=(--do_3D)
fi

if [[ "${SAVE_PNG}" == "1" ]]; then
  cmd+=(--save_png)
fi

if [[ "${SAVE_TIF}" == "1" ]]; then
  cmd+=(--save_tif)
fi

if [[ "${SAVE_FLOWS}" == "1" ]]; then
  cmd+=(--save_flows)
fi

if [[ "${SAVE_OUTLINES}" == "1" ]]; then
  cmd+=(--save_outlines)
fi

if [[ "${SAVE_ROIS}" == "1" ]]; then
  cmd+=(--save_rois)
fi

if [[ "${SAVE_TXT}" == "1" ]]; then
  cmd+=(--save_txt)
fi

if [[ "${IN_FOLDERS}" == "1" ]]; then
  cmd+=(--in_folders)
fi

if [[ "${NO_NPY}" == "1" ]]; then
  cmd+=(--no_npy)
fi

if [[ -n "${IMG_FILTER}" ]]; then
  cmd+=(--img_filter "${IMG_FILTER}")
fi

if [[ -n "${DIAMETER}" ]]; then
  cmd+=(--diameter "${DIAMETER}")
fi

if [[ -n "${CELLPROB_THRESHOLD}" ]]; then
  cmd+=(--cellprob_threshold "${CELLPROB_THRESHOLD}")
fi

if [[ -n "${FLOW_THRESHOLD}" ]]; then
  cmd+=(--flow_threshold "${FLOW_THRESHOLD}")
fi

if [[ -n "${MIN_SIZE}" ]]; then
  cmd+=(--min_size "${MIN_SIZE}")
fi

if [[ -n "${NITER}" ]]; then
  cmd+=(--niter "${NITER}")
fi

if [[ -n "${CHANNEL_AXIS}" ]]; then
  cmd+=(--channel_axis "${CHANNEL_AXIS}")
fi

if [[ -n "${Z_AXIS}" ]]; then
  cmd+=(--z_axis "${Z_AXIS}")
fi

if [[ -n "${NORM_PERCENTILE}" ]]; then
  IFS=':' read -r np_low np_high extra <<<"${NORM_PERCENTILE}"
  if [[ -z "${np_low}" || -z "${np_high}" || -n "${extra:-}" ]]; then
    echo "NORM_PERCENTILE must be in 'low:high' format, e.g. 1:99" >&2
    exit 1
  fi
  cmd+=(--norm_percentile "${np_low}" "${np_high}")
fi

if [[ "${SAVE_MPL}" == "1" ]]; then
  cmd+=(--save_mpl)
fi

if [[ -n "${EXTRA_ARGS}" ]]; then
  # shellcheck disable=SC2206
  extra_args=( ${EXTRA_ARGS} )
  cmd+=("${extra_args[@]}")
fi

printf 'Running command:\n'
printf '  %q' "${cmd[@]}"
printf '\n'

"${cmd[@]}"

# Keep only FIJI-friendly RGB flow images unless explicitly requested.
if [[ "${SAVE_FLOWS}" == "1" ]] && [[ "${DROP_DP_FLOWS}" == "1" ]]; then
  find "${OUTPUT_DIR}" -type f -name '*_dP_cp_masks.tif' -delete
fi

# Cellpose creates masks/ folder with --in_folders even when mask saving is off.
if [[ "${ONLY_OUTLINES_AND_FLOWS}" == "1" ]]; then
  if [[ -d "${OUTPUT_DIR}/masks" ]] && [[ -z "$(find "${OUTPUT_DIR}/masks" -maxdepth 1 -type f -print -quit)" ]]; then
    rmdir "${OUTPUT_DIR}/masks" || true
  fi
fi

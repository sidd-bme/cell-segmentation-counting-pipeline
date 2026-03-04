#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${ENV_NAME:-cellpose-sam}"
PYTHON_VERSION="${PYTHON_VERSION:-3.10}"
INSTALL_SOURCE="${INSTALL_SOURCE:-github}" # github|pypi

usage() {
  cat <<'EOF'
Usage: bash scripts/setup_cellpose_env.sh [options]

Options:
  -e, --env NAME          Conda env name (default: cellpose-sam)
  -p, --python VERSION    Python version (default: 3.10)
      --source SOURCE     Install source: github or pypi (default: github)
  -h, --help              Show help

Environment variable overrides:
  ENV_NAME, PYTHON_VERSION, INSTALL_SOURCE
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)
      ENV_NAME="$2"
      shift 2
      ;;
    -p|--python)
      PYTHON_VERSION="$2"
      shift 2
      ;;
    --source)
      INSTALL_SOURCE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v conda >/dev/null 2>&1; then
  echo "conda not found in PATH. Load/init conda first." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git not found in PATH." >&2
  exit 1
fi

CONDA_BASE="$(conda info --base)"
source "${CONDA_BASE}/etc/profile.d/conda.sh"

if conda env list | awk '{print $1}' | grep -Fxq "${ENV_NAME}"; then
  echo "Conda env '${ENV_NAME}' already exists. Reusing it."
else
  if command -v mamba >/dev/null 2>&1; then
    mamba create -y -n "${ENV_NAME}" "python=${PYTHON_VERSION}"
  else
    conda create -y -n "${ENV_NAME}" "python=${PYTHON_VERSION}"
  fi
fi

conda activate "${ENV_NAME}"

python -m pip install --upgrade pip setuptools wheel

case "${INSTALL_SOURCE}" in
  github)
    python -m pip install --upgrade "git+https://github.com/MouseLand/cellpose.git"
    ;;
  pypi)
    python -m pip install --upgrade cellpose
    ;;
  *)
    echo "Invalid INSTALL_SOURCE='${INSTALL_SOURCE}'. Use github or pypi." >&2
    exit 1
    ;;
esac

python - <<'PY'
import platform
import sys
from importlib import metadata

print(f"Python: {sys.version.split()[0]}")
print(f"Platform: {platform.platform()}")

try:
    import cellpose  # noqa: F401
    cp_ver = metadata.version("cellpose")
    print(f"Cellpose: {cp_ver}")
except Exception as exc:
    print(f"Cellpose import failed: {exc}")
    raise

try:
    import torch
    print(f"Torch: {torch.__version__}")
    print(f"Torch CUDA runtime: {torch.version.cuda}")
    print(f"torch.cuda.is_available(): {torch.cuda.is_available()}")
except Exception as exc:
    print(f"Torch import failed: {exc}")
    raise
PY

cat <<EOF

Environment ready.
Activate it with:
  source "${CONDA_BASE}/etc/profile.d/conda.sh"
  conda activate "${ENV_NAME}"

Note: on login nodes, torch.cuda.is_available() may be False even if GPU jobs work.
EOF

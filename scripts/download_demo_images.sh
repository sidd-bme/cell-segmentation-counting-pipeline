#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-/scratch/${USER}/cellpose/demo}"
URL="${URL:-https://www.cellpose.org/static/images/demo_images.zip}"

mkdir -p "${TARGET_DIR}"
ZIP_PATH="${TARGET_DIR}/demo_images.zip"

if command -v curl >/dev/null 2>&1; then
  curl -L "${URL}" -o "${ZIP_PATH}"
elif command -v wget >/dev/null 2>&1; then
  wget -O "${ZIP_PATH}" "${URL}"
else
  echo "Neither curl nor wget is available." >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "unzip is not available." >&2
  exit 1
fi

unzip -o -q "${ZIP_PATH}" -d "${TARGET_DIR}"

echo "Demo images downloaded and extracted into: ${TARGET_DIR}"
echo "Sample files:"
find "${TARGET_DIR}" -type f | sed -n '1,15p'

#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible wrapper: force GPU mode for interactive GPU nodes.
USE_GPU=1 bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/run_pipeline.sh"

# Simple Step-by-Step (HPC + Local)

## A) Clone and setup (one-time)

```bash
git clone <YOUR_REPO_URL>
cd cellpose_segmentation
bash scripts/setup_cellpose_env.sh
```

This installs everything needed (Miniconda + Python dependencies) if missing.

## B) Run on NUS Vanda interactive GPU

### 1) On login node

```bash
bash scripts/request_interactive_gpu.sh
```

### 2) On interactive compute node

```bash
cd /home/svu/e1520578/cellpose_segmentation
source ~/miniconda3/etc/profile.d/conda.sh
conda activate cellpose-sam

INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
USE_GPU=1 \
bash scripts/run_pipeline.sh
```

## C) Run locally (Mac/Linux)

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
USE_GPU=0 \
bash scripts/run_pipeline.sh
```

If local NVIDIA GPU exists:

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
USE_GPU=auto \
bash scripts/run_pipeline.sh
```

## D) Tune thresholds

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
FLOW_THRESHOLD=0.4 \
CELLPROB_THRESHOLD=0 \
DIAMETER=35 \
NITER=250 \
bash scripts/run_pipeline.sh
```

## E) Outputs

- `masks/*_cp_masks.tif` (label masks)
- `outlines/*_outlines_cp_masks.png`
- `flows/*_flows_cp_masks.tif`
- `counts_from_labels.csv`

`*_dP_cp_masks.tif` files are removed automatically.

## F) Batch counting in Fiji from flows (optional)

In Fiji:
1. `Plugins -> Macros -> Run...`
2. Open `fiji/batch_count_flows.ijm`
3. Pick `flows` folder
4. Pick output CSV path
5. Enter min particle size

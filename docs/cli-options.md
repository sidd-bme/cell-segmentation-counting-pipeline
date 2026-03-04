# CLI Options

This page summarizes the environment variables used by the scripts.

## Main command

```bash
INPUT_DIR=/path/to/images \
OUTPUT_DIR=/path/to/output \
bash scripts/run_pipeline_interactive_gpu.sh
```

## `run_pipeline_interactive_gpu.sh`

These are the common knobs for most users.

- `INPUT_DIR` (default: `./img`): input image folder
- `OUTPUT_DIR` (default: `./img_cellpose_output`): output root folder
- `RESIZED_DIR` (default: `./img_resized_1000`): temporary resized images
- `MAX_DIM` (default: `1000`): longest image side before segmentation
- `DIAMETER` (default: `35`): expected object diameter in pixels
- `FLOW_THRESHOLD` (default: `0.4`): stricter flow consistency when higher
- `CELLPROB_THRESHOLD` (default: `0`): lower values detect more cells
- `MIN_SIZE` (default: `20`): remove tiny objects smaller than this area
- `NITER` (default: `250`): flow integration iterations
- `NORM_PERCENTILE` (default: `1:99`): intensity normalization range
- `BATCH_SIZE` (default: `8`): inference batch size
- `GPU_DEVICE` (default: `0`): CUDA device index
- `CLEAN_OUTPUT` (default: `1`): clear output folder before run
- `CLEAN_RESIZED` (default: `1`): clear resized folder before run
- `CELLPOSE_ENV` (default: `cellpose-sam`): conda environment name

Example:

```bash
INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
MAX_DIM=1000 FLOW_THRESHOLD=0.4 CELLPROB_THRESHOLD=0 NITER=250 \
bash scripts/run_pipeline_interactive_gpu.sh
```

## Advanced command: `run_cellpose.sh`

Use this when you want full control of Cellpose CLI behavior.

- `MODEL` (default: `cpsam`)
- `USE_GPU` (default: `1`)
- `ONLY_OUTLINES_AND_FLOWS` (default: `1`)
- `SAVE_TIF`, `SAVE_PNG`, `SAVE_OUTLINES`, `SAVE_FLOWS`, `IN_FOLDERS`, `NO_NPY`
- `DROP_DP_FLOWS` (default: `1`): deletes `*_dP_cp_masks.tif`
- `IMG_FILTER`: Cellpose suffix filter (do not set this to `.jpg`/`.png`)
- `EXTRA_ARGS`: extra raw Cellpose CLI args

Save masks + outlines + flows (clean, no dP files):

```bash
INPUT_DIR=/path/to/images \
OUTPUT_DIR=/path/to/output \
ONLY_OUTLINES_AND_FLOWS=0 \
SAVE_TIF=1 SAVE_PNG=0 SAVE_OUTLINES=1 SAVE_FLOWS=1 IN_FOLDERS=1 \
DROP_DP_FLOWS=1 \
DIAMETER=35 FLOW_THRESHOLD=0.4 CELLPROB_THRESHOLD=0 MIN_SIZE=20 NITER=250 \
bash scripts/run_cellpose.sh
```

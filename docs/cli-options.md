# CLI Options

## Main command

```bash
INPUT_DIR=/path/to/images \
OUTPUT_DIR=/path/to/output \
bash scripts/run_pipeline.sh
```

## `run_pipeline.sh` (recommended)

- `INPUT_DIR` default: `./img`
- `OUTPUT_DIR` default: `./img_cellpose_output`
- `RESIZED_DIR` default: `./img_resized_1000`
- `MAX_DIM` default: `1000`
- `DIAMETER` default: `35`
- `FLOW_THRESHOLD` default: `0.4`
- `CELLPROB_THRESHOLD` default: `0`
- `MIN_SIZE` default: `20`
- `NITER` default: `250`
- `NORM_PERCENTILE` default: `1:99`
- `BATCH_SIZE` default: `8`
- `GPU_DEVICE` default: `0`
- `USE_GPU` default: `auto` (`1`, `0`, or `auto`)
- `CLEAN_OUTPUT` default: `1`
- `CLEAN_RESIZED` default: `1`
- `CELLPOSE_ENV` default: `cellpose-sam`
- `AUTO_ACTIVATE_ENV` default: `1`

Example:

```bash
INPUT_DIR=/data/img \
OUTPUT_DIR=/data/out \
FLOW_THRESHOLD=0.4 CELLPROB_THRESHOLD=0 DIAMETER=35 NITER=250 \
USE_GPU=auto \
bash scripts/run_pipeline.sh
```

## `run_cellpose.sh` (advanced)

Use when you need direct Cellpose output control.

- `MODEL` default: `cpsam`
- `ONLY_OUTLINES_AND_FLOWS` default: `1`
- `SAVE_TIF`, `SAVE_PNG`, `SAVE_OUTLINES`, `SAVE_FLOWS`, `IN_FOLDERS`, `NO_NPY`
- `DROP_DP_FLOWS` default: `1` (deletes `*_dP_cp_masks.tif`)
- `IMG_FILTER`: Cellpose suffix filter (do not use `.jpg` / `.png` as extension)
- `EXTRA_ARGS`: raw additional cellpose CLI args

Save masks + outlines + flows with clean flow folder:

```bash
INPUT_DIR=/data/img \
OUTPUT_DIR=/data/out \
ONLY_OUTLINES_AND_FLOWS=0 \
SAVE_TIF=1 SAVE_PNG=0 SAVE_OUTLINES=1 SAVE_FLOWS=1 IN_FOLDERS=1 \
DROP_DP_FLOWS=1 \
DIAMETER=35 FLOW_THRESHOLD=0.4 CELLPROB_THRESHOLD=0 MIN_SIZE=20 NITER=250 \
bash scripts/run_cellpose.sh
```

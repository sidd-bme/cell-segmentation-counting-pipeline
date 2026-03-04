# Simple Step-by-Step: Vanda Interactive Workflow

Use this guide if you are starting from scratch.

## Step 1: go to project folder (login node)

```bash
cd /home/svu/e1520578/cellpose_segmentation
```

## Step 2: create Cellpose environment (one-time)

```bash
bash scripts/setup_cellpose_env.sh
```

## Step 3: request interactive GPU node

```bash
bash scripts/request_interactive_gpu.sh
```

Wait until you land on a compute node shell.

## Step 4: run segmentation + counting (interactive node)

```bash
cd /home/svu/e1520578/cellpose_segmentation
source ~/miniconda3/etc/profile.d/conda.sh
conda activate cellpose-sam

INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
bash scripts/run_pipeline_interactive_gpu.sh
```

Default run values:
- `MAX_DIM=1000`
- `DIAMETER=35`
- `FLOW_THRESHOLD=0.4`
- `CELLPROB_THRESHOLD=0`
- `MIN_SIZE=20`
- `NITER=250`
- `NORM_PERCENTILE=1:99`

## Step 5: tune thresholds (optional)

```bash
INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
FLOW_THRESHOLD=0.3 \
CELLPROB_THRESHOLD=-1 \
DIAMETER=30 \
NITER=300 \
bash scripts/run_pipeline_interactive_gpu.sh
```

## Step 6: find outputs

- Label masks: `img_cellpose_output/masks/*_cp_masks.tif`
- Outlines: `img_cellpose_output/outlines/*_outlines_cp_masks.png`
- Flows: `img_cellpose_output/flows/*_flows_cp_masks.tif`
- Label-mask counts CSV: `img_cellpose_output/counts_from_labels.csv`

Note: `*_dP_cp_masks.tif` files are removed automatically.

## Step 7: batch counting in Fiji from flows (optional)

In Fiji GUI:
1. `Plugins -> Macros -> Run...`
2. Open `fiji/batch_count_flows.ijm`
3. Pick flow input folder (`img_cellpose_output/flows`)
4. Pick output folder + CSV name
5. Enter minimum particle size (e.g. `20`)

## Step 8: copy results to your Mac external drive

Run this on your Mac terminal:

```bash
rsync -avh --progress \
  <nus_user>@<vanda_login_host>:/home/svu/<nus_user>/cellpose_segmentation/img_cellpose_output/ \
  "/Volumes/ext/J/cell_seg/"
```

Use your real Vanda login host (the same host you SSH into), not internal names like `stdct-login-01`.

# Cell Segmentation and Counting Pipeline (Cellpose-SAM + Fiji)

Minimal, interactive-node workflow for NUS Vanda:
- segment brightfield cell images with Cellpose-SAM
- save clean outputs (no `*_dP_cp_masks.tif` files)
- count cells from label masks (CSV)
- optionally count from Cellpose flow images in Fiji

## 1) One-time setup (login node)

```bash
cd /home/svu/e1520578/cellpose_segmentation
bash scripts/setup_cellpose_env.sh
```

## 2) Start an interactive GPU session (login node)

```bash
bash scripts/request_interactive_gpu.sh
```

If needed, customize resources:

```bash
SELECT='1:ncpus=16:mem=120gb:ngpus=1' WALLTIME=04:00:00 bash scripts/request_interactive_gpu.sh
```

## 3) Run segmentation + counting (inside interactive GPU shell)

```bash
cd /home/svu/e1520578/cellpose_segmentation
source ~/miniconda3/etc/profile.d/conda.sh
conda activate cellpose-sam

INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
bash scripts/run_pipeline_interactive_gpu.sh
```

This single command does:
1. resize images to max side `1000`
2. run Cellpose-SAM with tuned defaults
3. save masks + outlines + flows
4. remove `*_dP_cp_masks.tif` files automatically
5. write `counts_from_labels.csv`

## Default run values

- `MODEL=cpsam`
- `MAX_DIM=1000`
- `DIAMETER=35`
- `FLOW_THRESHOLD=0.4`
- `CELLPROB_THRESHOLD=0`
- `MIN_SIZE=20`
- `NITER=250`
- `NORM_PERCENTILE=1:99`

## 4) Tune thresholds (optional)

Use the same command but override values:

```bash
INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
FLOW_THRESHOLD=0.3 \
CELLPROB_THRESHOLD=-1 \
DIAMETER=30 \
NITER=300 \
bash scripts/run_pipeline_interactive_gpu.sh
```

More options are documented in [CLI Options](docs/cli-options.md).

## 5) Output structure

After a run:

- `img_cellpose_output/masks/*_cp_masks.tif` (label masks for quantitative counting)
- `img_cellpose_output/outlines/*_outlines_cp_masks.png`
- `img_cellpose_output/flows/*_flows_cp_masks.tif` (RGB flow images only)
- `img_cellpose_output/counts_from_labels.csv`

## 6) Batch counting in Fiji from flow images (optional)

In Fiji GUI:
1. `Plugins -> Macros -> Run...`
2. Open `fiji/batch_count_flows.ijm`
3. Select input folder: `.../img_cellpose_output/flows`
4. Select output folder + CSV name
5. Set minimum particle size (e.g. `20`)

The macro runs: 8-bit -> auto-threshold -> apply -> Analyze Particles for each flow image.

## 7) Copy outputs to your external drive (run on your Mac)

Use the same hostname you use for SSH to Vanda (not internal node names like `stdct-login-01`).

```bash
rsync -avh --progress \
  <nus_user>@<vanda_login_host>:/home/svu/<nus_user>/cellpose_segmentation/img_cellpose_output/ \
  "/Volumes/ext/J/cell_seg/"
```

Example login host format depends on your access setup (ask NUS IT if unsure).

## Credits

See [CREDITS.md](CREDITS.md) for attribution and citation links.

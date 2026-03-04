# Cell Segmentation and Counting Pipeline (Cellpose-SAM + Fiji)

Simple, reproducible pipeline for:
- Cellpose-SAM segmentation
- clean outputs (`*_flows_cp_masks.tif` kept, `*_dP_cp_masks.tif` removed)
- batch cell counting from label masks
- optional Fiji batch counting from flow images

This repo supports both:
- NUS Vanda HPC (interactive GPU node)
- local machine (Mac/Linux, CPU or GPU)

## Quick Start (Clone + Run)

### 1) Clone

```bash
git clone <YOUR_REPO_URL>
cd cellpose_segmentation
```

### 2) One-time setup (auto-installs Miniconda if missing)

```bash
bash scripts/setup_cellpose_env.sh
```

No manual dependency installation is required.

### 3) Run pipeline

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
bash scripts/run_pipeline.sh
```

That is the main command for most users.

## Default segmentation values (current tuned defaults)

- `MODEL=cpsam`
- `MAX_DIM=1000`
- `DIAMETER=35`
- `FLOW_THRESHOLD=0.4`
- `CELLPROB_THRESHOLD=0`
- `MIN_SIZE=20`
- `NITER=250`
- `NORM_PERCENTILE=1:99`

## Output files

After each run:
- `masks/*_cp_masks.tif` (label masks; best for quantitative counting)
- `outlines/*_outlines_cp_masks.png`
- `flows/*_flows_cp_masks.tif`
- `counts_from_labels.csv`

`*_dP_cp_masks.tif` files are removed automatically for cleaner outputs.

## NUS Vanda HPC (interactive GPU)

### 1) Login node

```bash
cd /home/svu/e1520578/cellpose_segmentation
bash scripts/setup_cellpose_env.sh
bash scripts/request_interactive_gpu.sh
```

### 2) After interactive shell starts

```bash
cd /home/svu/e1520578/cellpose_segmentation
source ~/miniconda3/etc/profile.d/conda.sh
conda activate cellpose-sam

INPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img \
OUTPUT_DIR=/home/svu/e1520578/cellpose_segmentation/img_cellpose_output \
USE_GPU=1 \
bash scripts/run_pipeline.sh
```

Optional larger request:

```bash
SELECT='1:ncpus=16:mem=120gb:ngpus=1' WALLTIME=04:00:00 bash scripts/request_interactive_gpu.sh
```

## Local machine (Mac/Linux)

### CPU mode (works everywhere)

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
USE_GPU=0 \
bash scripts/run_pipeline.sh
```

### Auto GPU detect (if NVIDIA GPU available)

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
USE_GPU=auto \
bash scripts/run_pipeline.sh
```

## Tune thresholds

```bash
INPUT_DIR=/absolute/path/to/input_images \
OUTPUT_DIR=/absolute/path/to/output_folder \
FLOW_THRESHOLD=0.3 \
CELLPROB_THRESHOLD=-1 \
DIAMETER=30 \
NITER=300 \
bash scripts/run_pipeline.sh
```

More options: [CLI Options](docs/cli-options.md)

## Batch counting in Fiji from flow images (optional)

In Fiji GUI:
1. `Plugins -> Macros -> Run...`
2. Open `fiji/batch_count_flows.ijm`
3. Choose input folder (`.../flows`)
4. Choose output folder + CSV name
5. Set minimum particle size (e.g. `0` or `20`)

The macro runs: 8-bit -> auto-threshold -> convert mask -> analyze particles.

## Copy outputs to external drive (run on your Mac)

```bash
rsync -avh --progress \
  <nus_user>@<vanda_login_host>:/home/svu/<nus_user>/cellpose_segmentation/img_cellpose_output/ \
  "/Volumes/ext/J/cell_seg/"
```

Use the same Vanda login hostname you use for SSH (not internal node names like `stdct-login-01`).

## Credits and Attribution

### Cellpose / Cellpose-SAM

This pipeline wraps the Cellpose CLI and models.

- Project: https://github.com/MouseLand/cellpose
- Documentation: https://cellpose.readthedocs.io/

Please cite the Cellpose papers when publishing results.

### Fiji / ImageJ

Fiji is used for optional flow-based particle counting.

- Fiji: https://fiji.sc/
- ImageJ: https://imagej.net/

Please cite Fiji/ImageJ according to their official guidance when reporting analyses.

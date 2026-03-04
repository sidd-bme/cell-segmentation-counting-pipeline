#!/usr/bin/env python3
"""
Batch cell counting from Cellpose label masks.

Counts objects as number of unique non-zero labels per mask file.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

import numpy as np
import tifffile
from PIL import Image


def read_mask(path: Path) -> np.ndarray:
    ext = path.suffix.lower()
    if ext in {".tif", ".tiff"}:
        arr = tifffile.imread(path)
    else:
        arr = np.array(Image.open(path))
    if arr.ndim > 2:
        arr = arr[..., 0]
    return arr


def count_labels(mask: np.ndarray) -> int:
    labels = np.unique(mask)
    labels = labels[labels > 0]
    return int(labels.size)


def main() -> int:
    parser = argparse.ArgumentParser(description="Count cells from Cellpose label masks")
    parser.add_argument(
        "--masks-dir",
        default="img_cellpose_output/masks",
        help="Folder containing *_cp_masks.tif or *_cp_masks.png files",
    )
    parser.add_argument(
        "--out-csv",
        default="img_cellpose_output/counts_from_labels.csv",
        help="Output CSV path",
    )
    args = parser.parse_args()

    masks_dir = Path(args.masks_dir).resolve()
    out_csv = Path(args.out_csv).resolve()
    out_csv.parent.mkdir(parents=True, exist_ok=True)

    files = sorted(
        list(masks_dir.glob("*_cp_masks.tif"))
        + list(masks_dir.glob("*_cp_masks.tiff"))
        + list(masks_dir.glob("*_cp_masks.png"))
    )
    if not files:
        raise SystemExit(f"No mask files found in {masks_dir}")

    with out_csv.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["image", "count", "mask_file"])
        for path in files:
            mask = read_mask(path)
            count = count_labels(mask)
            image_name = path.name.replace("_cp_masks.tif", "").replace("_cp_masks.tiff", "").replace(
                "_cp_masks.png", ""
            )
            writer.writerow([image_name, count, path.name])

    print(f"Wrote counts for {len(files)} files: {out_csv}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

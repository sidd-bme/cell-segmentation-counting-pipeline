#!/usr/bin/env python3
"""
Resize all images in a folder so the longest side is <= max_dim.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


SUPPORTED = {".jpg", ".jpeg", ".png", ".tif", ".tiff"}


def resize_to_max_dim(img: Image.Image, max_dim: int) -> Image.Image:
    w, h = img.size
    longest = max(w, h)
    if longest <= max_dim:
        return img
    scale = max_dim / float(longest)
    new_size = (max(1, int(round(w * scale))), max(1, int(round(h * scale))))
    return img.resize(new_size, Image.Resampling.LANCZOS)


def main() -> int:
    parser = argparse.ArgumentParser(description="Resize images to a maximum dimension")
    parser.add_argument("--input-dir", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--max-dim", type=int, default=1000)
    args = parser.parse_args()

    in_dir = Path(args.input_dir).resolve()
    out_dir = Path(args.output_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    files = sorted(
        p for p in in_dir.iterdir() if p.is_file() and p.suffix.lower() in SUPPORTED
    )
    if not files:
        raise SystemExit(f"No supported images in {in_dir}")

    for p in files:
        with Image.open(p) as img:
            out_img = resize_to_max_dim(img, args.max_dim)
            out_path = out_dir / p.name
            save_kwargs = {}
            if p.suffix.lower() in {".jpg", ".jpeg"}:
                save_kwargs.update({"quality": 95})
            out_img.save(out_path, **save_kwargs)

    print(f"Processed {len(files)} files to {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

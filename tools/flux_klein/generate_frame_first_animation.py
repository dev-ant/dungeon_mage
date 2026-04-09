#!/usr/bin/env python3
"""Batch-generate frame-first Dungeon Mage animation frames with FLUX.2 klein 4B.

This helper submits or runs each frame independently, preserving frame order.
It is meant to be used with a frame-first workdir created from a runtime strip.
"""

from __future__ import annotations

import argparse
import concurrent.futures as cf
import json
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path("/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage")
FLUX_SCRIPT = Path("/Users/leesanghyun/.codex/skills/dungeon-mage-flux-img2img/scripts/flux_klein_img2img.py")
REBUILD_SCRIPT = ROOT / "tools/flux_klein/rebuild_strip_from_frames.py"
SKILL_REBUILD_SCRIPT = Path("/Users/leesanghyun/.codex/skills/dungeon-mage-flux-img2img/scripts/rebuild_strip_from_frames.py")


def load_manifest(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def run_frame_job(
    frame_path: Path,
    prompt_file: Path,
    out_dir: Path,
    input_image_2: Path | None,
    input_image_3: Path | None,
    width: int,
    height: int,
    seed: int | None,
    safety_tolerance: int,
    transparent_bg: bool,
) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / frame_path.name
    metadata_path = out_dir / f"{frame_path.stem}.json"
    request_body_path = out_dir / f"{frame_path.stem}.request.json"
    submit_metadata_path = out_dir / f"{frame_path.stem}.submit.json"

    cmd = [
        sys.executable,
        str(FLUX_SCRIPT),
        "--prompt-file",
        str(prompt_file),
        "--input-image",
        str(frame_path),
        "--width",
        str(width),
        "--height",
        str(height),
        "--output",
        str(out_path),
        "--metadata-out",
        str(metadata_path),
        "--request-body-out",
        str(request_body_path),
        "--submit-metadata-out",
        str(submit_metadata_path),
        "--safety-tolerance",
        str(safety_tolerance),
    ]
    if input_image_2:
        cmd.extend(["--input-image-2", str(input_image_2)])
    if input_image_3:
        cmd.extend(["--input-image-3", str(input_image_3)])
    if seed is not None:
        cmd.extend(["--seed", str(seed)])
    if transparent_bg:
        cmd.append("--transparent-bg")

    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    subprocess.run(cmd, check=True, env=env)
    return out_path


def rebuild_strip(frame_dir: Path, output_strip: Path) -> None:
    cmd = [
        sys.executable,
        str(SKILL_REBUILD_SCRIPT if SKILL_REBUILD_SCRIPT.exists() else REBUILD_SCRIPT),
        "--frame-dir",
        str(frame_dir),
        "--output",
        str(output_strip),
    ]
    subprocess.run(cmd, check=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--prompt-file", required=True)
    parser.add_argument("--input-image-2")
    parser.add_argument("--input-image-3")
    parser.add_argument("--generated-frames-dir", required=True)
    parser.add_argument("--output-strip", required=True)
    parser.add_argument("--width", type=int, default=128)
    parser.add_argument("--height", type=int, default=128)
    parser.add_argument("--seed-base", type=int, default=0)
    parser.add_argument("--safety-tolerance", type=int, default=2)
    parser.add_argument("--transparent-bg", action="store_true")
    parser.add_argument("--workers", type=int, default=3)
    args = parser.parse_args()

    manifest = load_manifest(Path(args.manifest))
    frames = [Path(p) for p in manifest["frames"]]
    prompt_file = Path(args.prompt_file)
    input_image_2 = Path(args.input_image_2) if args.input_image_2 else None
    input_image_3 = Path(args.input_image_3) if args.input_image_3 else None
    out_dir = Path(args.generated_frames_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    tasks = []
    with cf.ThreadPoolExecutor(max_workers=args.workers) as pool:
        for idx, frame_path in enumerate(frames):
            seed = args.seed_base + idx if args.seed_base else None
            tasks.append(
                pool.submit(
                    run_frame_job,
                    frame_path,
                    prompt_file,
                    out_dir,
                    input_image_2,
                    input_image_3,
                    args.width,
                    args.height,
                    seed,
                    args.safety_tolerance,
                    args.transparent_bg,
                )
            )
        for task in tasks:
            task.result()

    rebuild_strip(out_dir, Path(args.output_strip))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

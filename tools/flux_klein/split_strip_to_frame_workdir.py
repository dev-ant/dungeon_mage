#!/usr/bin/env python3
import argparse
import json
import pathlib
from typing import List

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Pillow is required. Install it with `python3 -m pip install pillow`.") from exc


def _load_strip(path: pathlib.Path, frame_width: int, frame_height: int) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    if image.height != frame_height or image.width % frame_width != 0:
        raise SystemExit(
            f"{path} size {image.width}x{image.height} is not compatible with frame size "
            f"{frame_width}x{frame_height}"
        )
    return image


def _split_frames(image: Image.Image, frame_width: int, frame_height: int) -> List[Image.Image]:
    return [
        image.crop((i * frame_width, 0, (i + 1) * frame_width, frame_height))
        for i in range(image.width // frame_width)
    ]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Split a runtime strip into individual frame PNGs and write a frame-first generation manifest."
    )
    parser.add_argument("--input-strip", required=True, help="Source runtime strip PNG.")
    parser.add_argument("--frame-width", type=int, required=True)
    parser.add_argument("--frame-height", type=int, required=True)
    parser.add_argument("--out-dir", required=True, help="Output workdir.")
    parser.add_argument("--state", help="Optional state label such as idle or run.")
    parser.add_argument(
        "--frame-prefix",
        default="frame_",
        help="Filename prefix for frame PNGs.",
    )
    args = parser.parse_args()

    input_path = pathlib.Path(args.input_strip).expanduser().resolve()
    if not input_path.exists():
        raise SystemExit(f"input strip not found: {input_path}")

    image = _load_strip(input_path, args.frame_width, args.frame_height)
    frames = _split_frames(image, args.frame_width, args.frame_height)

    out_dir = pathlib.Path(args.out_dir).expanduser().resolve()
    frames_dir = out_dir / "frames"
    frames_dir.mkdir(parents=True, exist_ok=True)

    frame_paths = []
    for index, frame in enumerate(frames):
        frame_path = frames_dir / f"{args.frame_prefix}{index:02d}.png"
        frame.save(frame_path)
        frame_paths.append(str(frame_path))

    manifest = {
        "state": args.state,
        "source_strip": str(input_path),
        "frame_size": {"width": args.frame_width, "height": args.frame_height},
        "frame_count": len(frames),
        "frames": frame_paths,
        "workflow": [
            "Generate each frame separately, in index order.",
            "Use only the source strip and the approved character references for each frame.",
            "Validate each generated frame if the body or silhouette changed.",
            "Rebuild the strip from ordered frames after review.",
        ],
        "rebuild_command": "python3 /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/rebuild_strip_from_frames.py --frame-dir <frames_dir> --output <strip_output>",
    }

    manifest_path = out_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    print(
        json.dumps(
            {
                "manifest": str(manifest_path),
                "frame_count": len(frames),
                "frames_dir": str(frames_dir),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

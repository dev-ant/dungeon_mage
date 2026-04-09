#!/usr/bin/env python3
import argparse
import json
import pathlib
import statistics
from typing import List, Optional, Tuple

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Pillow is required. Install it with `python3 -m pip install pillow`.") from exc


BBox = Tuple[int, int, int, int]


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


def _bbox(frame: Image.Image) -> Optional[BBox]:
    return frame.getchannel("A").getbbox()


def _translate(frame: Image.Image, dx: int, dy: int) -> Image.Image:
    canvas = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    canvas.alpha_composite(frame, (dx, dy))
    return canvas


def _frame_width(frame: Image.Image) -> int:
    box = _bbox(frame)
    if not box:
        return 0
    return max(1, box[2] - box[0])


def _replace_frame(frames: List[Image.Image], index: int) -> Tuple[Image.Image, int]:
    if len(frames) == 1:
        return frames[0].copy(), index
    left = index - 1
    right = index + 1
    if left >= 0:
        return frames[left].copy(), left
    if right < len(frames):
        return frames[right].copy(), right
    return frames[index].copy(), index


def main() -> int:
    parser = argparse.ArgumentParser(description="Stabilize idle-like sprite strips by replacing axis outliers.")
    parser.add_argument("--input", required=True, help="Input runtime strip PNG.")
    parser.add_argument("--output", required=True, help="Output strip PNG.")
    parser.add_argument("--frame-width", type=int, required=True)
    parser.add_argument("--frame-height", type=int, required=True)
    parser.add_argument("--min-width-ratio", type=float, default=0.6, help="Frames narrower than this ratio are outliers.")
    parser.add_argument("--max-width-ratio", type=float, default=1.45, help="Frames wider than this ratio are outliers.")
    parser.add_argument("--metadata-out", help="Optional JSON metadata output.")
    args = parser.parse_args()

    input_path = pathlib.Path(args.input).expanduser().resolve()
    output_path = pathlib.Path(args.output).expanduser().resolve()
    image = _load_strip(input_path, args.frame_width, args.frame_height)
    frames = _split_frames(image, args.frame_width, args.frame_height)
    widths = [_frame_width(frame) for frame in frames if _bbox(frame)]
    if not widths:
        raise SystemExit("no non-empty frames found")
    median_width = statistics.median(widths)

    out_frames: List[Image.Image] = []
    metadata = []
    for idx, frame in enumerate(frames):
        width = _frame_width(frame)
        ratio = (width / median_width) if median_width else 0.0
        is_outlier = ratio < args.min_width_ratio or ratio > args.max_width_ratio
        replacement_from = None
        if is_outlier:
            replacement, replacement_from = _replace_frame(frames, idx)
            out_frames.append(replacement)
        else:
            out_frames.append(frame)
        metadata.append(
            {
                "index": idx,
                "width": width,
                "width_ratio": round(ratio, 3),
                "outlier": is_outlier,
                "replacement_from": replacement_from,
            }
        )

    out = Image.new("RGBA", (args.frame_width * len(out_frames), args.frame_height), (0, 0, 0, 0))
    for idx, frame in enumerate(out_frames):
        out.alpha_composite(frame, (idx * args.frame_width, 0))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    out.save(output_path)

    if args.metadata_out:
        meta_path = pathlib.Path(args.metadata_out).expanduser().resolve()
        meta_path.write_text(
            json.dumps(
                {
                    "input": str(input_path),
                    "output": str(output_path),
                    "frame_count": len(out_frames),
                    "frame_width": args.frame_width,
                    "frame_height": args.frame_height,
                    "median_width": round(median_width, 3),
                    "min_width_ratio": args.min_width_ratio,
                    "max_width_ratio": args.max_width_ratio,
                    "frames": metadata,
                },
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
    print(json.dumps({"saved_to": str(output_path), "frames": len(out_frames)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

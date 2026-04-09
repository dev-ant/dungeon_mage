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


def _alpha_pixels(frame: Image.Image) -> List[Tuple[int, int, int]]:
    alpha = frame.getchannel("A")
    rgba = frame.convert("RGBA")
    pixels = []
    for y in range(frame.height):
        for x in range(frame.width):
            a = alpha.getpixel((x, y))
            if a > 0:
                pixels.append((x, y, a))
    return pixels


def _weighted_centroid(frame: Image.Image, top_fraction: float) -> Optional[Tuple[float, float]]:
    box = _bbox(frame)
    if not box:
        return None
    _, top, _, bottom = box
    cutoff = top + max(1, round((bottom - top) * top_fraction))
    alpha = frame.getchannel("A")
    total = 0.0
    sum_x = 0.0
    sum_y = 0.0
    for y in range(frame.height):
        if y > cutoff:
            continue
        for x in range(frame.width):
            a = alpha.getpixel((x, y))
            if a <= 0:
                continue
            total += a
            sum_x += x * a
            sum_y += y * a
    if total <= 0:
        return None
    return sum_x / total, sum_y / total


def _band_weighted_centroid(frame: Image.Image, y_start_ratio: float, y_end_ratio: float) -> Optional[Tuple[float, float]]:
    box = _bbox(frame)
    if not box:
        return None
    _, top, _, bottom = box
    band_top = top + max(0, round((bottom - top) * y_start_ratio))
    band_bottom = top + max(1, round((bottom - top) * y_end_ratio))
    if band_bottom <= band_top:
        band_bottom = band_top + 1
    alpha = frame.getchannel("A")
    total = 0.0
    sum_x = 0.0
    sum_y = 0.0
    for y in range(frame.height):
        if y < band_top or y > band_bottom:
            continue
        for x in range(frame.width):
            a = alpha.getpixel((x, y))
            if a <= 0:
                continue
            total += a
            sum_x += x * a
            sum_y += y * a
    if total <= 0:
        return None
    return sum_x / total, sum_y / total


def _translate(frame: Image.Image, dx: int, dy: int) -> Image.Image:
    canvas = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    canvas.alpha_composite(frame, (dx, dy))
    return canvas


def _safe_shift(frame: Image.Image, margin: int) -> Tuple[int, int]:
    box = _bbox(frame)
    if not box:
        return 0, 0
    left, top, right, bottom = box
    dx = 0
    dy = 0
    if left < margin:
        dx += margin - left
    if right > frame.width - margin:
        dx -= right - (frame.width - margin)
    if top < margin:
        dy += margin - top
    if bottom > frame.height - margin:
        dy -= bottom - (frame.height - margin)
    return dx, dy


def main() -> int:
    parser = argparse.ArgumentParser(description="Center-lock a runtime sprite strip by an upper-body anchor.")
    parser.add_argument("--input", required=True, help="Input runtime strip PNG.")
    parser.add_argument("--output", required=True, help="Output strip PNG.")
    parser.add_argument("--frame-width", type=int, required=True)
    parser.add_argument("--frame-height", type=int, required=True)
    parser.add_argument(
        "--profile",
        choices=["custom", "idle", "run", "balanced", "torso", "pelvis"],
        default="balanced",
        help="State-aware anchor tuning preset.",
    )
    parser.add_argument("--top-fraction", type=float, default=None, help="Upper-body fraction used for centroid.")
    parser.add_argument("--margin", type=int, default=None, help="Target transparent margin in pixels.")
    parser.add_argument("--metadata-out", help="Optional JSON metadata output.")
    args = parser.parse_args()

    input_path = pathlib.Path(args.input).expanduser().resolve()
    output_path = pathlib.Path(args.output).expanduser().resolve()
    image = _load_strip(input_path, args.frame_width, args.frame_height)
    frames = _split_frames(image, args.frame_width, args.frame_height)

    profile_defaults = {
        "idle": {"top_fraction": 0.78, "margin": 12},
        "run": {"top_fraction": 0.58, "margin": 10},
        "torso": {"top_fraction": 0.68, "margin": 10},
        "pelvis": {"top_fraction": 0.54, "margin": 10},
        "balanced": {"top_fraction": 0.68, "margin": 10},
    }
    defaults = profile_defaults.get(args.profile, profile_defaults["balanced"])
    top_fraction = args.top_fraction if args.top_fraction is not None else defaults["top_fraction"]
    margin = args.margin if args.margin is not None else defaults["margin"]

    anchors = []
    for fr in frames:
        if args.profile == "torso":
            anchor = _band_weighted_centroid(fr, 0.28, 0.68)
        elif args.profile == "pelvis":
            anchor = _band_weighted_centroid(fr, 0.46, 0.88)
        else:
            anchor = _weighted_centroid(fr, top_fraction)
        if anchor is not None:
            anchors.append(anchor)

    if not anchors:
        raise SystemExit("could not find a usable anchor in any frame")

    target_x = statistics.median([a[0] for a in anchors])
    target_y = statistics.median([a[1] for a in anchors])

    normalized = []
    metadata = []
    for idx, frame in enumerate(frames):
        if args.profile == "torso":
            anchor = _band_weighted_centroid(frame, 0.28, 0.68)
        elif args.profile == "pelvis":
            anchor = _band_weighted_centroid(frame, 0.46, 0.88)
        else:
            anchor = _weighted_centroid(frame, top_fraction)
        if anchor is None:
            normalized.append(frame)
            metadata.append({"index": idx, "anchor": None, "shift": [0, 0]})
            continue
        dx = round(target_x - anchor[0])
        dy = round(target_y - anchor[1])
        shifted = _translate(frame, dx, dy)
        safe_dx, safe_dy = _safe_shift(shifted, margin)
        shifted = _translate(shifted, safe_dx, safe_dy)
        normalized.append(shifted)
        metadata.append(
            {
                "index": idx,
                "anchor": [round(anchor[0], 3), round(anchor[1], 3)],
                "target_anchor": [round(target_x, 3), round(target_y, 3)],
                "shift": [dx + safe_dx, dy + safe_dy],
                "bbox": list(_bbox(shifted)) if _bbox(shifted) else None,
            }
        )

    out = Image.new("RGBA", (args.frame_width * len(normalized), args.frame_height), (0, 0, 0, 0))
    for idx, frame in enumerate(normalized):
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
                    "frame_count": len(normalized),
                    "target_anchor": [round(target_x, 3), round(target_y, 3)],
                    "profile": args.profile,
                    "top_fraction": top_fraction,
                    "margin": margin,
                    "frames": metadata,
                },
                ensure_ascii=False,
                indent=2,
            ),
            encoding="utf-8",
        )
    print(json.dumps({"saved_to": str(output_path), "frames": len(normalized)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

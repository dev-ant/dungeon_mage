#!/usr/bin/env python3
import argparse
import json
import pathlib
from typing import List, Optional, Tuple

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Pillow is required. Install it with `python3 -m pip install pillow`.") from exc


BBox = Tuple[int, int, int, int]


def _load_frames(path: pathlib.Path, frame_width: int, frame_height: int) -> List[Image.Image]:
    image = Image.open(path).convert("RGBA")
    if image.width % frame_width != 0 or image.height != frame_height:
        raise SystemExit(
            f"{path} size {image.width}x{image.height} is not divisible by frame size "
            f"{frame_width}x{frame_height}"
        )
    return [
        image.crop((i * frame_width, 0, (i + 1) * frame_width, frame_height))
        for i in range(image.width // frame_width)
    ]


def _bbox(frame: Image.Image) -> Optional[BBox]:
    return frame.getchannel("A").getbbox()


def _translate(frame: Image.Image, dx: int, dy: int, canvas_size: Tuple[int, int]) -> Image.Image:
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    canvas.alpha_composite(frame, (dx, dy))
    return canvas


def _fit_frame_to_margin(frame: Image.Image, margin: int) -> Tuple[Image.Image, dict]:
    box = _bbox(frame)
    if box is None:
        return frame, {
            "source_bbox": None,
            "scale": 1.0,
            "shift": [0, 0],
            "normalized_bbox": None,
            "filled_empty": False,
        }

    left, top, right, bottom = box
    bbox_w = max(1, right - left)
    bbox_h = max(1, bottom - top)
    allowed_w = max(1, frame.width - 2 * margin)
    allowed_h = max(1, frame.height - 2 * margin)
    scale = min(1.0, allowed_w / bbox_w, allowed_h / bbox_h)

    source = frame
    if scale < 1.0:
        resized_w = max(1, round(frame.width * scale))
        resized_h = max(1, round(frame.height * scale))
        source = frame.resize((resized_w, resized_h), resample=Image.Resampling.LANCZOS)
        box = _bbox(source)
        if box is None:
            return source, {
                "source_bbox": None,
                "scale": scale,
                "shift": [0, 0],
                "normalized_bbox": None,
                "filled_empty": False,
            }
        left, top, right, bottom = box

    base_x = (frame.width - source.width) // 2
    base_y = (frame.height - source.height) // 2
    out_left = base_x + left
    out_top = base_y + top
    out_right = base_x + right
    out_bottom = base_y + bottom

    dx = 0
    dy = 0
    if out_left < margin:
        dx += margin - out_left
    if out_right > frame.width - margin:
        dx -= out_right - (frame.width - margin)
    if out_top < margin:
        dy += margin - out_top
    if out_bottom > frame.height - margin:
        dy -= out_bottom - (frame.height - margin)

    translated = _translate(source, base_x + dx, base_y + dy, frame.size)
    return translated, {
        "source_bbox": list(box),
        "scale": round(scale, 4),
        "shift": [dx, dy],
        "normalized_bbox": list(_bbox(translated)) if _bbox(translated) else None,
        "filled_empty": False,
    }


def _safe_shift(box: BBox, width: int, height: int, margin: int) -> Tuple[int, int]:
    left, top, right, bottom = box
    dx = 0
    dy = 0

    if left < margin:
        dx += margin - left
    if right > width - margin:
        dx -= right - (width - margin)

    if top < margin:
        dy += margin - top
    if bottom > height - margin:
        dy -= bottom - (height - margin)

    return dx, dy


def _nearest_non_empty(frames: List[Image.Image], index: int) -> Optional[Image.Image]:
    if _bbox(frames[index]):
        return frames[index]
    for distance in range(1, len(frames)):
        left = index - distance
        right = index + distance
        if left >= 0 and _bbox(frames[left]):
            return frames[left]
        if right < len(frames) and _bbox(frames[right]):
            return frames[right]
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description="Add safe margin to a runtime strip without scaling it down.")
    parser.add_argument("--input", required=True, help="Input runtime strip PNG.")
    parser.add_argument("--output", required=True, help="Output strip PNG.")
    parser.add_argument("--frame-width", type=int, required=True)
    parser.add_argument("--frame-height", type=int, required=True)
    parser.add_argument("--margin", type=int, default=8, help="Minimum transparent margin in pixels.")
    parser.add_argument("--fill-empty", action="store_true", help="Fill empty frames using the nearest non-empty neighbor.")
    parser.add_argument("--metadata-out", help="Optional JSON metadata output.")
    args = parser.parse_args()

    input_path = pathlib.Path(args.input).expanduser().resolve()
    output_path = pathlib.Path(args.output).expanduser().resolve()
    frames = _load_frames(input_path, args.frame_width, args.frame_height)

    normalized: List[Image.Image] = []
    metadata = []
    for index, frame in enumerate(frames):
        box = _bbox(frame)
        if box is None and args.fill_empty:
            donor = _nearest_non_empty(frames, index)
            if donor is None:
                normalized.append(Image.new("RGBA", frame.size, (0, 0, 0, 0)))
                metadata.append(
                    {
                        "index": index,
                        "source_bbox": None,
                        "shift": [0, 0],
                        "normalized_bbox": None,
                        "filled_empty": False,
                    }
                )
                continue
            frame = donor.copy()
            box = _bbox(frame)
        fitted, frame_meta = _fit_frame_to_margin(frame, args.margin)
        frame_meta["index"] = index
        normalized.append(fitted)
        metadata.append(frame_meta)

    sheet = Image.new("RGBA", (args.frame_width * len(normalized), args.frame_height), (0, 0, 0, 0))
    for index, frame in enumerate(normalized):
        sheet.alpha_composite(frame, (index * args.frame_width, 0))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path)

    if args.metadata_out:
        meta_path = pathlib.Path(args.metadata_out).expanduser().resolve()
        meta_path.write_text(json.dumps({"frames": metadata}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"saved_to": str(output_path), "frames": len(normalized)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

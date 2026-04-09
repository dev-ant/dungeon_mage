#!/usr/bin/env python3
import argparse
import json
import pathlib
from typing import List, Optional

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Pillow is required. Install it with `python3 -m pip install pillow`.") from exc


def _load_json(path: pathlib.Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _alpha_bbox(frame: Image.Image):
    return frame.getchannel("A").getbbox()


def _fit_to_target(frame: Image.Image, target_box, output_size):
    source_box = _alpha_bbox(frame)
    canvas = Image.new("RGBA", output_size, (0, 0, 0, 0))
    if not source_box:
        return canvas
    if not target_box:
        canvas.alpha_composite(frame, (0, 0))
        return canvas

    cropped = frame.crop(source_box)
    source_w = max(1, source_box[2] - source_box[0])
    source_h = max(1, source_box[3] - source_box[1])
    target_w = max(1, target_box[2] - target_box[0])
    target_h = max(1, target_box[3] - target_box[1])
    scale = min(target_w / source_w, target_h / source_h)
    resized_w = max(1, round(source_w * scale))
    resized_h = max(1, round(source_h * scale))
    resized = cropped.resize((resized_w, resized_h), resample=Image.Resampling.LANCZOS)

    target_center_x = (target_box[0] + target_box[2]) / 2.0
    target_bottom = target_box[3]
    paste_x = round(target_center_x - resized_w / 2.0)
    paste_y = round(target_bottom - resized_h)
    paste_x = max(0, min(output_size[0] - resized_w, paste_x))
    paste_y = max(0, min(output_size[1] - resized_h, paste_y))
    canvas.alpha_composite(resized, (paste_x, paste_y))
    return canvas


def _load_frames_from_strip(path: pathlib.Path, frame_width: int, frame_height: int) -> List[Image.Image]:
    image = Image.open(path).convert("RGBA")
    if image.height != frame_height:
        raise SystemExit(f"{path} height {image.height} does not match frame height {frame_height}")
    if image.width % frame_width != 0:
        raise SystemExit(
            f"{path} width {image.width} is not divisible by inferred frame width {frame_width}"
        )
    return [
        image.crop((i * frame_width, 0, (i + 1) * frame_width, frame_height))
        for i in range(image.width // frame_width)
    ]


def _load_frames_from_dir(path: pathlib.Path) -> List[Image.Image]:
    frame_paths = sorted(p for p in path.iterdir() if p.suffix.lower() == ".png")
    if not frame_paths:
        raise SystemExit(f"no PNG frames found in {path}")
    return [Image.open(p).convert("RGBA") for p in frame_paths]


def _rebuild_strip(frames: List[Image.Image], frame_width: int, frame_height: int) -> Image.Image:
    strip = Image.new("RGBA", (frame_width * len(frames), frame_height), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        if frame.size != (frame_width, frame_height):
            raise SystemExit(
                f"normalized frame {index} is {frame.width}x{frame.height}, expected {frame_width}x{frame_height}"
            )
        strip.alpha_composite(frame, (index * frame_width, 0))
    return strip


def _resolve_contract(
    manifest_path: Optional[pathlib.Path],
    original_strip_arg: Optional[str],
    frame_count_arg: Optional[int],
    frame_width_arg: Optional[int],
    frame_height_arg: Optional[int],
    generated_frame_dir_arg: Optional[str],
):
    manifest = {}
    if manifest_path:
        manifest = _load_json(manifest_path)

    original_strip = pathlib.Path(
        original_strip_arg or manifest.get("source_strip", "")
    ).expanduser().resolve()
    if not original_strip.exists():
        raise SystemExit("Provide --original-strip or --manifest with a valid source_strip.")

    original_image = Image.open(original_strip).convert("RGBA")
    original_width, original_height = original_image.size

    frame_size = manifest.get("frame_size", {})
    frame_width = frame_width_arg or frame_size.get("width")
    frame_height = frame_height_arg or frame_size.get("height")
    frame_count = frame_count_arg or manifest.get("frame_count")

    if frame_height is None:
        frame_height = original_height
    if frame_count is None and frame_width is None:
        if generated_frame_dir_arg:
            frame_count = len(
                [p for p in pathlib.Path(generated_frame_dir_arg).expanduser().resolve().iterdir() if p.suffix.lower() == ".png"]
            )
        else:
            raise SystemExit(
                "Could not infer frame_count. Provide --frame-count, --frame-width, or --manifest."
            )

    if frame_width is None:
        if original_width % int(frame_count) != 0:
            raise SystemExit(
                f"original strip width {original_width} is not divisible by frame_count {frame_count}"
            )
        frame_width = original_width // int(frame_count)

    if frame_count is None:
        if original_width % int(frame_width) != 0:
            raise SystemExit(
                f"original strip width {original_width} is not divisible by frame_width {frame_width}"
            )
        frame_count = original_width // int(frame_width)

    if original_height != int(frame_height):
        raise SystemExit(
            f"original strip height {original_height} does not match frame_height {frame_height}"
        )

    if original_width != int(frame_width) * int(frame_count):
        raise SystemExit(
            f"original strip width {original_width} does not equal frame_width*frame_count ({frame_width}*{frame_count})"
        )

    return {
        "original_strip": original_strip,
        "frame_width": int(frame_width),
        "frame_height": int(frame_height),
        "frame_count": int(frame_count),
        "manifest": manifest,
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Normalize a generated strip or frame folder back to the original runtime strip contract."
    )
    parser.add_argument("--manifest", help="Optional workdir manifest from prepare_animation_chunk_workdir.py")
    parser.add_argument("--original-strip", help="Original runtime strip or source strip")
    parser.add_argument("--frame-count", type=int, help="Optional explicit frame count")
    parser.add_argument("--frame-width", type=int, help="Optional explicit original frame width")
    parser.add_argument("--frame-height", type=int, help="Optional explicit original frame height")
    parser.add_argument("--generated-strip", help="Generated strip to normalize")
    parser.add_argument("--generated-frame-dir", help="Directory of generated frame PNGs")
    parser.add_argument("--generated-frame-width", type=int, help="Optional generated strip frame width")
    parser.add_argument("--generated-frame-height", type=int, help="Optional generated strip frame height")
    parser.add_argument("--output", required=True, help="Normalized runtime strip output path")
    parser.add_argument("--metadata-out", help="Optional JSON metadata output path")
    args = parser.parse_args()

    if bool(args.generated_strip) == bool(args.generated_frame_dir):
        raise SystemExit("Provide exactly one of --generated-strip or --generated-frame-dir.")

    manifest_path = pathlib.Path(args.manifest).expanduser().resolve() if args.manifest else None
    contract = _resolve_contract(
        manifest_path=manifest_path,
        original_strip_arg=args.original_strip,
        frame_count_arg=args.frame_count,
        frame_width_arg=args.frame_width,
        frame_height_arg=args.frame_height,
        generated_frame_dir_arg=args.generated_frame_dir,
    )

    original_strip = contract["original_strip"]
    frame_width = contract["frame_width"]
    frame_height = contract["frame_height"]
    frame_count = contract["frame_count"]

    original_frames = _load_frames_from_strip(original_strip, frame_width, frame_height)

    if args.generated_strip:
        generated_strip = pathlib.Path(args.generated_strip).expanduser().resolve()
        generated_image = Image.open(generated_strip).convert("RGBA")
        gen_frame_height = args.generated_frame_height or generated_image.height
        if args.generated_frame_width:
            gen_frame_width = args.generated_frame_width
        else:
            if generated_image.width % frame_count != 0:
                raise SystemExit(
                    f"generated strip width {generated_image.width} is not divisible by frame_count {frame_count}; "
                    "provide --generated-frame-width explicitly"
                )
            gen_frame_width = generated_image.width // frame_count
        generated_frames = _load_frames_from_strip(generated_strip, gen_frame_width, gen_frame_height)
    else:
        generated_frames = _load_frames_from_dir(pathlib.Path(args.generated_frame_dir).expanduser().resolve())

    if len(generated_frames) != frame_count:
        raise SystemExit(
            f"generated frame count mismatch: expected {frame_count}, got {len(generated_frames)}"
        )

    normalized_frames = []
    frame_metadata = []
    for index, (original, generated) in enumerate(zip(original_frames, generated_frames)):
        target_box = _alpha_bbox(original)
        normalized = _fit_to_target(generated, target_box, (frame_width, frame_height))
        normalized_frames.append(normalized)
        frame_metadata.append(
            {
                "index": index,
                "target_bbox": target_box,
                "generated_bbox": _alpha_bbox(generated),
                "normalized_bbox": _alpha_bbox(normalized),
            }
        )

    strip = _rebuild_strip(normalized_frames, frame_width, frame_height)
    output_path = pathlib.Path(args.output).expanduser().resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    strip.save(output_path)

    metadata_path = (
        pathlib.Path(args.metadata_out).expanduser().resolve()
        if args.metadata_out
        else output_path.with_suffix(output_path.suffix + ".json")
    )
    metadata = {
        "original_strip": str(original_strip),
        "frame_width": frame_width,
        "frame_height": frame_height,
        "frame_count": frame_count,
        "manifest": str(manifest_path) if manifest_path else None,
        "saved_to": str(output_path),
        "frames": frame_metadata,
    }
    metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"saved_to": str(output_path), "metadata": str(metadata_path)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
import argparse
import json
import pathlib
from typing import List

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Pillow is required. Install it with `python3 -m pip install pillow`.") from exc


def _load_json(path: pathlib.Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _load_frames_from_strip(path: pathlib.Path, frame_width: int, frame_height: int) -> List[Image.Image]:
    image = Image.open(path).convert("RGBA")
    if image.height != frame_height or image.width % frame_width != 0:
        raise SystemExit(
            f"{path} size {image.width}x{image.height} is not divisible by {frame_width}x{frame_height}"
        )
    return [
        image.crop((i * frame_width, 0, (i + 1) * frame_width, frame_height))
        for i in range(image.width // frame_width)
    ]


def _load_frames_from_dir(path: pathlib.Path) -> List[Image.Image]:
    frame_paths = sorted(p for p in path.iterdir() if p.suffix.lower() == ".png")
    if not frame_paths:
        raise SystemExit(f"no png frames found in {path}")
    return [Image.open(p).convert("RGBA") for p in frame_paths]


def _alpha_bbox(frame: Image.Image):
    return frame.getchannel("A").getbbox()


def _fit_to_target(frame: Image.Image, target_box, output_size):
    source_box = _alpha_bbox(frame)
    canvas = Image.new("RGBA", output_size, (0, 0, 0, 0))
    if not target_box or not source_box:
        if source_box:
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


def _rebuild_strip(frames: List[Image.Image], frame_width: int, frame_height: int) -> Image.Image:
    strip = Image.new("RGBA", (frame_width * len(frames), frame_height), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        if frame.size != (frame_width, frame_height):
            raise SystemExit(
                f"frame {i} size {frame.width}x{frame.height} does not match {frame_width}x{frame_height}"
            )
        strip.alpha_composite(frame, (i * frame_width, 0))
    return strip


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Normalize a generated player asset back to Dungeon Mage runtime strip rules."
    )
    parser.add_argument("--state", required=True, help="Player state such as idle, run, jump.")
    parser.add_argument(
        "--generated-strip",
        help="Generated strip to normalize. Use this or --generated-frame-dir.",
    )
    parser.add_argument(
        "--generated-frame-dir",
        help="Directory of ordered generated frame PNGs. Use this or --generated-strip.",
    )
    parser.add_argument(
        "--spec",
        default="/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tools/flux_klein/specs/player_runtime_spec.json",
    )
    parser.add_argument("--output")
    parser.add_argument("--metadata-out")
    parser.add_argument("--write-target", action="store_true")
    args = parser.parse_args()

    if bool(args.generated_strip) == bool(args.generated_frame_dir):
        raise SystemExit("Provide exactly one of --generated-strip or --generated-frame-dir.")

    spec_path = pathlib.Path(args.spec).expanduser().resolve()
    spec = _load_json(spec_path)
    scene_spec = spec["player_scene"]
    state_spec = spec["states"].get(args.state)
    if not state_spec:
        raise SystemExit(f"unknown state '{args.state}' in {spec_path}")

    frame_width = int(scene_spec["frame_width"])
    frame_height = int(scene_spec["frame_height"])
    frame_count = int(state_spec["frame_count"])
    source_strip_path = pathlib.Path(state_spec["source_strip"]).expanduser().resolve()
    target_strip_path = pathlib.Path(state_spec["target_strip"]).expanduser().resolve()

    original_frames = _load_frames_from_strip(source_strip_path, frame_width, frame_height)
    if len(original_frames) != frame_count:
        raise SystemExit(
            f"spec frame_count mismatch for {args.state}: expected {frame_count}, source has {len(original_frames)}"
        )

    if args.generated_strip:
        generated_frames = _load_frames_from_strip(
            pathlib.Path(args.generated_strip).expanduser().resolve(),
            frame_width,
            frame_height,
        )
    else:
        generated_frames = _load_frames_from_dir(pathlib.Path(args.generated_frame_dir).expanduser().resolve())

    if len(generated_frames) != frame_count:
        raise SystemExit(
            f"generated frame count mismatch for {args.state}: expected {frame_count}, got {len(generated_frames)}"
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
    output_path = (
        pathlib.Path(args.output).expanduser().resolve()
        if args.output
        else target_strip_path.with_name(target_strip_path.stem + ".normalized.png")
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    strip.save(output_path)

    if args.write_target:
        strip.save(target_strip_path)

    metadata_path = (
        pathlib.Path(args.metadata_out).expanduser().resolve()
        if args.metadata_out
        else output_path.with_suffix(output_path.suffix + ".json")
    )
    metadata = {
        "state": args.state,
        "scene_contract": {
            "scene_path": scene_spec["scene_path"],
            "sprite_node_path": scene_spec["sprite_node_path"],
            "frame_width": frame_width,
            "frame_height": frame_height,
            "sprite_position": scene_spec["sprite_position"],
            "sprite_scale": scene_spec["sprite_scale"],
        },
        "target_strip": str(target_strip_path),
        "saved_to": str(output_path),
        "wrote_target": bool(args.write_target),
        "frames": frame_metadata,
    }
    metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"saved_to": str(output_path), "metadata": str(metadata_path)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

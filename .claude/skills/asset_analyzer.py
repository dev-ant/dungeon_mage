#!/usr/bin/env python3
"""
Dungeon Mage sprite analyzer.
Usage: python3 asset_analyzer.py <path_to_png> [character|boss|enemy|weapon|background]
"""
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow not installed. Run: pip3 install Pillow")
    sys.exit(1)

VIEWPORT_H = 720
SCALE_TARGETS = {
    "character": 120,
    "boss": 220,
    "enemy": 80,
    "weapon": None,
    "background": None,
}


def find_frame_candidates(total_w: int, frame_h: int) -> list[tuple[int, int]]:
    """Return (frame_count, frame_w) pairs — divisors of total_w with plausible aspect ratio."""
    candidates = []
    for count in range(1, total_w + 1):
        if total_w % count == 0:
            fw = total_w // count
            ratio = fw / frame_h
            if 0.3 <= ratio <= 5.0:
                candidates.append((count, fw))
    # Sort by how close frame_w is to frame_h (prefer square frames)
    candidates.sort(key=lambda x: abs(x[1] - frame_h))
    return candidates


def detect_facing(img, frame_w: int, frame_h: int) -> tuple[str, bool, str]:
    """
    Analyze top 40% of first frame to detect facing direction.
    Returns: (direction, flip_h_needed, confidence_note)
    """
    top_h = max(1, int(frame_h * 0.4))
    first_frame = img.crop((0, 0, frame_w, top_h)).convert("RGBA")
    pixels = first_frame.load()
    mid_x = frame_w // 2
    left_mass = 0
    right_mass = 0

    for y in range(top_h):
        for x in range(frame_w):
            r, g, b, a = pixels[x, y]
            if a > 128:
                if x < mid_x:
                    left_mass += 1
                else:
                    right_mass += 1

    total = left_mass + right_mass
    if total < 20:
        return "RIGHT", False, "assumed — too few pixels in top region"

    if right_mass > left_mass * 1.15:
        ratio = right_mass / left_mass if left_mass else 999
        return "RIGHT", False, f"high ({ratio:.2f}x right-bias in top 40%)"
    elif left_mass > right_mass * 1.15:
        ratio = left_mass / right_mass if right_mass else 999
        return "LEFT", True, f"high ({ratio:.2f}x left-bias in top 40%)"
    else:
        return "RIGHT", False, "assumed — inconclusive (within 15% symmetry)"


def analyze(path: str, sprite_type: str = "character") -> dict:
    img = Image.open(path).convert("RGBA")
    total_w, total_h = img.size

    frame_h = total_h  # strip assumption
    layout = "strip"

    candidates = find_frame_candidates(total_w, frame_h)
    if not candidates:
        candidates = [(1, total_w)]

    best_count, best_fw = candidates[0]
    facing, flip_h, confidence = detect_facing(img, best_fw, frame_h)

    target_px = SCALE_TARGETS.get(sprite_type)
    scale = round(target_px / frame_h, 4) if target_px else None

    result = {
        "path": path,
        "total_size": (total_w, total_h),
        "layout": layout,
        "frame_h": frame_h,
        "frame_w_best": best_fw,
        "frame_count_best": best_count,
        "other_candidates": candidates[1:4],
        "facing": facing,
        "flip_h": flip_h,
        "confidence": confidence,
        "sprite_type": sprite_type,
        "scale": scale,
        "target_screen_px": target_px,
    }

    # Pretty print
    print(f"\n{'='*52}")
    print(f"  {Path(path).name}")
    print(f"{'='*52}")
    print(f"  Total size    : {total_w} x {total_h} px")
    print(f"  Layout        : {layout}")
    print(f"  Frame size    : {best_fw} x {frame_h} px")
    print(f"  Frame count   : {best_count}")
    print(f"  Alt candidates: {[(c, fw) for c, fw in candidates[1:4]]}")
    print(f"  Facing        : {facing}  (confidence: {confidence})")
    print(f"  flip_h needed : {flip_h}")
    if scale:
        print(f"  Scale factor  : {scale}  ({target_px}px screen / {frame_h}px sprite)")
    print(f"  Godot hframes : {best_count}")
    print(f"  Godot vframes : 1")
    print(f"{'='*52}\n")

    return result


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 asset_analyzer.py <path> [character|boss|enemy|weapon|background]")
        sys.exit(1)
    sprite_type = sys.argv[2] if len(sys.argv) > 2 else "character"
    analyze(sys.argv[1], sprite_type)

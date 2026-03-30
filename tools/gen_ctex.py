#!/usr/bin/env python3
"""
Generate Godot 4 ctex files from PNG spritesheets.

ctex format (StreamTexture2D, version 1):
  Offset  Size  Description
  0       4     Magic "GST2"
  4       4     Version = 1 (u32 LE)
  8       4     Width (u32 LE)
  12      4     Height (u32 LE)
  16      4     0x0d000000
  20      4     0xffffffff (mipmap flags)
  24      12    zeros
  36      4     0x02000000
  40      2     Width (u16 LE) - repeated
  42      2     Height (u16 LE) - repeated
  44      4     zeros
  48      4     0x05000000
  52      4     WebP data byte length (u32 LE)
  56      N     RIFF/WebP binary data
"""

import struct
import io
import hashlib
import os
from PIL import Image

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMPORTED_DIR = os.path.join(PROJECT_ROOT, ".godot", "imported")


def make_ctex(png_path: str) -> bytes:
    img = Image.open(png_path).convert("RGBA")
    w, h = img.size

    # Encode as lossless WebP
    buf = io.BytesIO()
    img.save(buf, format="WEBP", lossless=True, quality=100)
    webp_data = buf.getvalue()
    webp_size = len(webp_data)

    # Build 56-byte header manually matching confirmed format
    header = bytearray(56)
    struct.pack_into("<4s", header, 0, b"GST2")
    struct.pack_into("<I", header, 4, 1)          # version
    struct.pack_into("<I", header, 8, w)           # width u32
    struct.pack_into("<I", header, 12, h)          # height u32
    struct.pack_into("<I", header, 16, 0x0d000000) # flags
    struct.pack_into("<i", header, 20, -1)         # mipmap count (-1 = all)
    # bytes 24-35: zeros
    struct.pack_into("<I", header, 36, 2)          # format flag
    struct.pack_into("<H", header, 40, w)          # width u16
    struct.pack_into("<H", header, 42, h)          # height u16
    # bytes 44-47: zeros
    struct.pack_into("<I", header, 48, 5)          # data format
    struct.pack_into("<I", header, 52, webp_size)  # data size
    return bytes(header) + webp_data


def ctex_path_for(res_path: str, basename: str) -> str:
    md5 = hashlib.md5(res_path.encode()).hexdigest()
    stem = os.path.splitext(basename)[0]
    filename = f"{stem}.png-{md5}.ctex"
    return os.path.join(IMPORTED_DIR, filename)


def write_ctex(res_path: str, png_abs_path: str) -> None:
    basename = os.path.basename(png_abs_path)
    out_path = ctex_path_for(res_path, basename)
    data = make_ctex(png_abs_path)
    with open(out_path, "wb") as f:
        f.write(data)
    img = Image.open(png_abs_path)
    print(f"  wrote {os.path.basename(out_path)}  ({img.size[0]}x{img.size[1]}, {len(data)} bytes)")


if __name__ == "__main__":
    SPRITE_BASE = "res://asset_sample/Character/male_hero_free/individual_sheets"
    SPRITE_DIR = os.path.join(PROJECT_ROOT, "asset_sample", "Character", "male_hero_free", "individual_sheets")

    sprites = [
        "male_hero-idle.png",
        "male_hero-run.png",
        "male_hero-jump.png",
        "male_hero-fall.png",
        "male_hero-fall_loop.png",
        "male_hero-dash.png",
        "male_hero-hurt.png",
        "male_hero-death.png",
    ]

    print("Generating ctex files for male_hero sprites...")
    for name in sprites:
        png_abs = os.path.join(SPRITE_DIR, name)
        res_path = f"{SPRITE_BASE}/{name}"
        write_ctex(res_path, png_abs)

    print("\nDone. Verifying header magic on first file...")
    first = sprites[0]
    md5 = hashlib.md5(f"{SPRITE_BASE}/{first}".encode()).hexdigest()
    stem = os.path.splitext(first)[0]
    check_path = os.path.join(IMPORTED_DIR, f"{stem}.png-{md5}.ctex")
    with open(check_path, "rb") as f:
        magic = f.read(4)
        version = struct.unpack("<I", f.read(4))[0]
        w = struct.unpack("<I", f.read(4))[0]
        h = struct.unpack("<I", f.read(4))[0]
    print(f"  magic={magic}  version={version}  size={w}x{h}")
    assert magic == b"GST2", "bad magic"
    assert version == 1, "bad version"
    print("  Header OK")

#!/usr/bin/env python3
"""
Injects AnimatedSprite2D (with SpriteFrames) into Main.tscn for the Player node.

Sprite sheets are horizontal strips: width = frames * 128, height = 128.
All animations use 10 FPS, looping (except death/hurt which loop=false).
"""

import os
import math

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TSCN_PATH = os.path.join(PROJECT_ROOT, "scenes", "main", "Main.tscn")

SPRITE_BASE = "res://asset_sample/Character/male_hero_free/individual_sheets"
FRAME_SIZE = 128

# (filename, uid, frame_count, loop, fps)
ANIMATIONS = [
    ("male_hero-idle.png",      "uid://xaji0y6dpbhsa",  10, True,  10.0),
    ("male_hero-run.png",       "uid://hxthv3a3zmf8m",  10, True,  12.0),
    ("male_hero-jump.png",      "uid://dd4v30t9nt3w5",   6, False,  8.0),
    ("male_hero-fall.png",      "uid://uzbikcidkwnnh",   4, False,  8.0),
    ("male_hero-fall_loop.png", "uid://j7xvg0fn9xuy4",   3, True,   8.0),
    ("male_hero-dash.png",      "uid://1ibljh75lxo6q",   5, False, 12.0),
    ("male_hero-hurt.png",      "uid://jiujv6oh9sdbd",   6, False,  8.0),
    ("male_hero-death.png",     "uid://w2pcn9t84azyt",  23, False,  8.0),
]

# Animation name = filename without "male_hero-" prefix and ".png" suffix
def anim_name(filename: str) -> str:
    return filename.removeprefix("male_hero-").removesuffix(".png")


def build_patch() -> tuple[list[str], list[str], str]:
    """Returns (new_ext_resources, new_sub_resources, animated_sprite_node)."""

    ext_resources = []
    sub_resources = []

    # IDs for ext_resources start at 6 (1-5 are existing)
    tex_ext_id = {}  # filename -> ext resource id string
    for i, (fname, uid, frames, loop, fps) in enumerate(ANIMATIONS):
        ext_id = f"tex_{i}"
        path = f"{SPRITE_BASE}/{fname}"
        ext_resources.append(
            f'[ext_resource type="Texture2D" uid="{uid}" path="{path}" id="{ext_id}"]'
        )
        tex_ext_id[fname] = ext_id

    # AtlasTexture sub_resources
    atlas_sub_ids = {}  # (fname, frame) -> sub_resource id string
    atlas_counter = 0
    for fname, uid, frame_count, loop, fps in ANIMATIONS:
        ext_id = tex_ext_id[fname]
        for f in range(frame_count):
            sub_id = f"Atlas_{atlas_counter}"
            atlas_counter += 1
            x = f * FRAME_SIZE
            sub_resources.append(
                f'[sub_resource type="AtlasTexture" id="{sub_id}"]\n'
                f'atlas = ExtResource("{ext_id}")\n'
                f'region = Rect2({x}, 0, {FRAME_SIZE}, {FRAME_SIZE})'
            )
            atlas_sub_ids[(fname, f)] = sub_id

    # SpriteFrames sub_resource
    anim_blocks = []
    for fname, uid, frame_count, loop, fps in ANIMATIONS:
        name = anim_name(fname)
        frame_entries = []
        for f in range(frame_count):
            sub_id = atlas_sub_ids[(fname, f)]
            frame_entries.append(f'{{"duration": 1.0, "texture": SubResource("{sub_id}")}}')
        frames_str = ", ".join(frame_entries)
        loop_str = "true" if loop else "false"
        anim_blocks.append(
            f'{{"frames": [{frames_str}], "loop": {loop_str}, "name": &"{name}", "speed": {fps}}}'
        )
    animations_str = ", ".join(anim_blocks)

    sub_resources.append(
        f'[sub_resource type="SpriteFrames" id="SpriteFrames_hero"]\n'
        f'animations = [{animations_str}]'
    )

    animated_sprite_node = (
        '[node name="Sprite" type="AnimatedSprite2D" parent="Player"]\n'
        'position = Vector2(0, -4)\n'
        'texture_filter = 1\n'
        'sprite_frames = SubResource("SpriteFrames_hero")\n'
        'animation = &"idle"\n'
        'autoplay = "idle"'
    )

    return ext_resources, sub_resources, animated_sprite_node


def inject_tscn(tscn_path: str) -> None:
    with open(tscn_path, "r") as f:
        content = f.read()

    if 'name="Sprite"' in content:
        print("AnimatedSprite2D already present in tscn, skipping.")
        return

    ext_resources, sub_resources, sprite_node = build_patch()

    # Count existing ext_resources and sub_resources to update load_steps
    existing_ext = content.count("\n[ext_resource ")
    existing_sub = content.count("\n[sub_resource ")
    new_ext = len(ext_resources)
    new_sub = len(sub_resources)
    total_ext = existing_ext + new_ext
    total_sub = existing_sub + new_sub
    new_load_steps = total_ext + total_sub + 1

    # Update load_steps header
    import re
    content = re.sub(
        r'\[gd_scene load_steps=\d+',
        f'[gd_scene load_steps={new_load_steps}',
        content
    )

    # Insert ext_resources after the last existing [ext_resource
    last_ext_end = content.rfind("\n[ext_resource ")
    # Find end of that line
    insert_after = content.find("\n", last_ext_end + 1)
    ext_block = "\n" + "\n".join(ext_resources)
    content = content[:insert_after] + ext_block + content[insert_after:]

    # Insert sub_resources after the last existing [sub_resource
    last_sub_end = content.rfind("\n[sub_resource ")
    # Find end of that block (next blank line or next [)
    search_from = last_sub_end + 1
    # Find the end of the sub_resource block
    next_section = content.find("\n[", search_from)
    sub_block = "\n\n" + "\n\n".join(sub_resources)
    content = content[:next_section] + sub_block + content[next_section:]

    # Insert AnimatedSprite2D after the Body node (which is after CollisionShape2D)
    body_node_end = content.find("[node name=\"Body\"")
    # Find end of that node block
    next_node = content.find("\n[node ", body_node_end + 1)
    sprite_block = "\n\n" + sprite_node
    content = content[:next_node] + sprite_block + content[next_node:]

    with open(tscn_path, "w") as f:
        f.write(content)

    print(f"Injected AnimatedSprite2D into {tscn_path}")
    print(f"  load_steps updated to {new_load_steps}")
    print(f"  Added {new_ext} ext_resources, {new_sub} sub_resources")
    print(f"  Animations: {[anim_name(a[0]) for a in ANIMATIONS]}")


if __name__ == "__main__":
    inject_tscn(TSCN_PATH)

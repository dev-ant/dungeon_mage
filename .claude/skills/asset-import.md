---
name: asset-import
description: Use when any PNG asset is added to asset_sample/ and needs to be analyzed and applied to Godot scenes and scripts.
---

# asset-import

Analyze a sprite and immediately apply it to the correct Godot scene and script. No confirmation step — analyze then apply.

## Pipeline

### Step 1 — Scan

Identify all new PNGs in the target subfolder of `asset_sample/`:

```bash
find asset_sample/<subfolder> -name "*.png" | sort
```

### Step 2 — Analyze each PNG

```bash
python3 .claude/skills/asset_analyzer.py "<path_to_png>" <type>
```

`<type>` is one of: `character`, `boss`, `enemy`, `weapon`, `background`

Read the output. Key values needed:
- `frame_w`, `frame_h`, `frame_count` (use `hframes` value)
- `facing` and `flip_h`
- `scale` factor

If multiple animation strips belong to the same character (Idle, Walk, Attack…), analyze each one. All must share the same `frame_h`. If they differ, flag the mismatch before proceeding.

### Step 2b — Pixel bounds analysis (character sprites only)

Run across representative animations (idle, run at minimum) to find the actual character pixel bounds within each frame. This is needed to compute scale and feet alignment accurately.

```python
from PIL import Image

anims = [("idle.png", 10), ("run.png", 10), ...]  # (filename, frame_count)
SHEET_DIR = "asset_sample/..."

for fname, frames in anims:
    img = Image.open(SHEET_DIR + fname)
    all_feet, all_heads = [], []
    for f in range(frames):
        frame = img.crop((f * frame_w, 0, (f+1) * frame_w, frame_h))
        pixels = list(frame.getdata())
        ys = [i // frame_w for i, p in enumerate(pixels) if p[3] > 10]
        if ys:
            all_feet.append(max(ys))
            all_heads.append(min(ys))
    char_h = max(all_feet) - min(all_heads)
    feet_from_top = sum(all_feet) / len(all_feet)  # average feet y in sprite-local coords
    print(f"{fname}: char_h={char_h}, feet_y={feet_from_top:.0f}")
```

Record for each animation:
- `char_h` — visible character height in pixels (head to feet)
- `feet_y` — average feet pixel y from the top of the sprite frame
- `feet_from_center` = `feet_y - (frame_h / 2)` — feet offset from sprite origin

### Step 2c — Compute scale and position

Given the collision box (from the `.tscn` `RectangleShape2D`):
- `box_h` — collision box height (e.g. 56)
- `box_bottom` = `box_h / 2` (e.g. 28, since box is centered at origin)

```
scale = box_h / char_h          # makes character fill the collision box height
                                 # use 0.9× for slight breathing room
feet_world = position_y + feet_from_center * scale
# to align feet to box_bottom: position_y = box_bottom - feet_from_center * scale
```

Example (male_hero, 128×128 frames, 56px collision box):
- `char_h=36`, `feet_from_center=+15`, `box_h=56`, `box_bottom=28`
- `scale = 56/36 ≈ 1.56` → use `1.4` for natural fit (90% of box)
- `position_y = 28 - 15 × 1.4 = 28 - 21 = +7`

### Step 3 — Copy asset to `assets/`

```bash
mkdir -p assets/<category>/<CharacterName>/
cp "asset_sample/<path>/<AnimName>.png" "assets/<category>/<CharacterName>/<AnimName>.png"
```

### Step 4 — Apply to Godot scene (`.tscn`)

In the relevant `.tscn`, configure `AnimatedSprite2D`:

```gdscript
[node name="Sprite" type="AnimatedSprite2D"]
sprite_frames = SubResource("SpriteFrames_<name>")
scale = Vector2(<scale>, <scale>)
# Do NOT set flip_h here — flipping is done at runtime via scale.x
```

SpriteFrames resource — one animation per strip file:

```gdscript
[sub_resource type="SpriteFrames" id="SpriteFrames_<name>"]
animations = [{
  "frames": [{
    "duration": 1.0,
    "texture": ExtResource("<AnimName>.png")
  }, ...],  # repeat for each frame index
  "loop": true,
  "name": &"idle",  # lowercase snake_case
  "speed": 8.0
}]
```

Frame count from analyzer → number of `"texture"` entries (use `AtlasTexture` with region):

```gdscript
[sub_resource type="AtlasTexture" id="AtlasTexture_idle_0"]
atlas = ExtResource("<AnimName>.png")
region = Rect2(0, 0, <frame_w>, <frame_h>)

[sub_resource type="AtlasTexture" id="AtlasTexture_idle_1"]
atlas = ExtResource("<AnimName>.png")
region = Rect2(<frame_w>, 0, <frame_w>, <frame_h>)
# ... continue for each frame
```

### Step 5 — Apply direction convention in script (`.gd`)

**Canonical rule: all sprites face RIGHT as base direction.**

In the character's `.gd` script, flipping is ALWAYS done via `scale.x`, NEVER via `flip_h`.

**CRITICAL: scale.x must preserve scale.y (the size multiplier).** Assigning `scale.x = ±1` destroys the scale applied in the `.tscn`.

```gdscript
# Correct — preserves the size scale set in the .tscn
sprite.scale.x = float(facing) * sprite.scale.y   # facing = +1 or -1

# WRONG — resets scale to 1 and loses the size multiplier
sprite.scale.x = float(facing)
```

If the sprite starts facing LEFT (flip_h=true), invert the sign:
```gdscript
sprite.scale.x = float(-facing) * sprite.scale.y
```

Document the chosen convention as a comment at the top of the script:
```gdscript
# SPRITE DIRECTION: native facing = RIGHT
# scale.x = +scale.y → right, scale.x = -scale.y → left (mirrored)
```

### Step 6 — Scale and feet verification checklist

Before committing, verify:

| Check | How |
|-------|-----|
| Sprite scale set in `.tscn` node | `scale = Vector2(s, s)` on AnimatedSprite2D node |
| Feet align with collision box bottom | `position.y = box_bottom - feet_from_center * scale` |
| Scale preserved during direction flip | `sprite.scale.x = float(facing) * sprite.scale.y` |
| Character visible on screen | `godot --headless --quit-after 120` (no errors) |
| Character not clipped by camera | check PhantomCamera2D dead zone |
| Weapon/effect same scale reference | use same `scale` value as character |

### Step 7 — Validate

```bash
godot --headless --path . --quit-after 120
```

Zero errors = done. Any scene load error → check resource paths and sub_resource IDs.

## Past Failure Prevention

| Past bug | This skill prevents it by |
|----------|--------------------------|
| Left/right set differently | Step 5: scale.x only, NEVER flip_h, comment documents convention |
| Character disappears mid-animation | Step 2: analyzer gives exact frame_count + region per frame |
| Character too small / feet floating | Step 2b–2c: pixel bounds analysis → exact scale + position.y formula |
| Direction flip destroys scale | Step 5: `scale.x = float(facing) * sprite.scale.y`, not `= float(facing)` |
| Background/weapon size mismatch | Step 6: all scales reference same collision box anchor |

## Worked Example — male_hero (128×128 frames, 56px collision box)

```
Pixel analysis (idle, run):
  char_h = 36px, feet_y ≈ 79 (from top of 128px frame)
  feet_from_center = 79 - 64 = +15

Collision box (RectangleShape2D): size = Vector2(30, 56)
  box_bottom = 56/2 = 28

Scale: 56/36 ≈ 1.56 → chose 1.4 for natural fit
Position.y: 28 - 15×1.4 = 28 - 21 = +7

Result in .tscn:
  position = Vector2(0, 7)
  scale = Vector2(1.4, 1.4)

Result in player.gd _update_anim():
  sprite.scale.x = float(facing) * sprite.scale.y
```

---
name: asset-import
description: Use when any PNG asset is added to asset_sample/ and needs to be analyzed and applied to Godot scenes and scripts.
---

# asset-import

Analyze a sprite and immediately apply it to the correct Godot scene and script. No confirmation step — analyze then apply.

## 절대 규칙 — asset_sample/ 참조 금지

**GDScript 코드와 .tscn 파일에서 `asset_sample/` 경로를 절대 참조하지 않는다.**

`asset_sample/`은 원본 드롭 존이다. 코드에서 사용하는 에셋은 반드시 `assets/`로 복사한 뒤 그 경로를 참조한다.

```gdscript
# WRONG
const FOO_DIR := "res://asset_sample/Monster/..."

# CORRECT
const FOO_DIR := "res://assets/monsters/foo/"
```

---

## Pipeline

### Step 1 — Scan

`asset_sample/` 대상 폴더의 PNG를 파악한다:

```bash
find asset_sample/<subfolder> -name "*.png" | sort
```

### Step 2 — 레이아웃 타입 판별 + 분석

먼저 이미지 크기를 확인해 어떤 레이아웃인지 판별한다:

```python
from PIL import Image
img = Image.open("asset_sample/<path>/<file>.png")
print(img.size)  # (width, height)
```

레이아웃 판별 기준:

| 조건 | 레이아웃 | 로딩 방식 |
|------|---------|---------|
| 애니메이션별 파일이 분리됨 | **Separate PNGs** | `_SHEETS` + `_SHEET_DIR` + `_ANIM_FILES` |
| 단일 파일, 가로가 세로보다 훨씬 길거나 정사각형에 가까움 | **Grid (rows × cols)** | `_ANIM_ROWS` + `_setup_sprite_grid()` |
| 단일 파일, 세로가 훨씬 길고 가로가 좁음 | **Vertical strip** | `_ANIM_VERT` + `_setup_sprite_vertical()` |

그 다음 `asset_analyzer.py`로 프레임 정보를 확인한다:

```bash
python3 .claude/skills/asset_analyzer.py "<path_to_png>" <type>
```

`<type>`: `character`, `boss`, `enemy`, `weapon`, `background`

필요한 값:
- `frame_w`, `frame_h` — 프레임 한 장 크기
- `frame_count` — 전체 프레임 수
- `facing`, `flip_h` — 기본 방향

**Grid/Vertical 레이아웃은 행 분리가 필요하다.** 빈 행(투명)을 찾아 애니메이션 경계를 파악한다:

```python
from PIL import Image
img = Image.open("asset_sample/<path>/<sheet>.png")
w, h = img.size

# 빈 행 찾기 (모든 픽셀이 투명)
empty_rows = [y for y in range(h) if not any(img.getpixel((x, y))[3] > 0 for x in range(w))]

# 콘텐츠 행 그룹화 → 각 그룹이 하나의 애니메이션 행
content_rows = [y for y in range(h) if any(img.getpixel((x, y))[3] > 0 for x in range(w))]
prev, groups, start = -1, [], content_rows[0]
for y in content_rows:
    if prev >= 0 and y - prev > 5:
        groups.append((start, prev))
        start = y
    prev = y
groups.append((start, prev))
print(f"Animation row groups: {len(groups)}")
for i, (s, e) in enumerate(groups):
    print(f"  row {i}: y={s}-{e}, height={e-s+1}")
```

프레임 높이 검증:
- Grid: `frame_h = height / num_rows` 가 정수인지 확인
- Vertical: `frame_h = height / total_frames` 가 정수인지 확인

각 애니메이션별 프레임 수가 다를 수 있으니 그룹 개수와 예상 애니메이션 종류(idle/run/attack/hurt/death)를 매핑한다.

### Step 2b — Pixel bounds analysis (enemy/character 타입)

실제 캐릭터 픽셀 높이와 발 위치를 측정해 scale/position을 정확히 계산한다.
분석은 `asset_sample/`에서 직접 열어도 된다 (분석 전용, 코드 참조 아님).

```python
from PIL import Image

# Separate PNG 방식일 때
anims = [("idle.png", 6), ("run.png", 6)]
SHEET_DIR = "asset_sample/<path>/"

for fname, frame_count in anims:
    img = Image.open(SHEET_DIR + fname)
    frame_w = img.width // frame_count
    frame_h = img.height
    all_feet, all_heads = [], []
    for f in range(frame_count):
        frame = img.crop((f * frame_w, 0, (f+1) * frame_w, frame_h))
        pixels = list(frame.getdata())
        ys = [i // frame_w for i, p in enumerate(pixels) if p[3] > 10]
        if ys:
            all_feet.append(max(ys))
            all_heads.append(min(ys))
    if all_feet:
        char_h = max(all_feet) - min(all_heads)
        feet_from_top = sum(all_feet) / len(all_feet)
        print(f"{fname}: char_h={char_h}, feet_y={feet_from_top:.0f}")
```

기록:
- `char_h` — 머리~발 픽셀 높이
- `feet_y` — 프레임 상단 기준 발 픽셀 y
- `feet_from_center` = `feet_y - (frame_h / 2)`

### Step 2c — Scale and position 계산

```
scale = (box_h * 0.9) / char_h    # 0.9 = 약간의 여유
position_y = box_bottom - feet_from_center * scale
```

예시 (rat, 32×32 프레임, collision box_h=54):
- `char_h=22`, `feet_from_center=+9`, `box_bottom=27`
- `scale = 27*0.9/22 ≈ 1.3`
- `position_y = 27 - 9×1.3 = 15.3 → 14`

### Step 3 — `assets/`로 복사 (코드 참조 경로)

```bash
mkdir -p assets/monsters/<type>/
cp "asset_sample/<path>/<AnimName>.png" "assets/monsters/<type>/<AnimName>.png"
```

**이 경로(`assets/`)만 코드에서 참조한다. `asset_sample/`은 절대 참조하지 않는다.**

### Step 3b — 에디터 열어서 임포트 확인

파일을 `assets/`에 복사한 후 Godot이 임포트해야 `ResourceLoader.load()`가 작동한다.

```bash
# 방법 1: 에디터를 열고 닫기 (Godot이 자동으로 새 파일 스캔 + .import 생성)
# 방법 2: headless import 트리거
godot --headless --path . --quit
```

임포트 확인:
```bash
ls assets/monsters/<type>/*.import   # .import 파일이 생겨야 함
```

임포트 파일이 없으면 에디터를 한 번 더 열거나 headless --quit을 재실행한다.

### Step 4 — GDScript 상수 및 로더 패턴 적용

실제 `enemy_base.gd` 방식을 따른다. 레이아웃에 따라 패턴이 다르다.

#### 패턴 A — Separate PNGs (애니메이션별 분리 파일)

```gdscript
const FOO_SHEETS := {
    "idle":   {"frames": 6,  "fps": 8.0,  "loop": true},
    "run":    {"frames": 6,  "fps": 12.0, "loop": true},
    "attack": {"frames": 6,  "fps": 10.0, "loop": false},
    "hurt":   {"frames": 1,  "fps": 8.0,  "loop": false},
    "death":  {"frames": 6,  "fps": 8.0,  "loop": false},
}
const FOO_SHEET_DIR  := "res://assets/monsters/foo/"
const FOO_ANIM_FILES := {
    "idle": "foo-idle.png", "run": "foo-run.png",
    "attack": "foo-attack.png", "hurt": "foo-hurt.png", "death": "foo-death.png",
}
```

`_setup_sprite()` match 블록에 추가:
```gdscript
"foo":
    sheets = FOO_SHEETS; sheet_dir = FOO_SHEET_DIR; anim_files = FOO_ANIM_FILES
    sprite_scale = <scale>; sprite_pos = Vector2(0, <position_y>)
    frame_w = <frame_w>; frame_h = <frame_h>
```

#### 패턴 B — Grid sheet (행마다 애니메이션)

```gdscript
const FOO_SHEET_PATH  := "res://assets/monsters/foo/foo-sheet.png"
const FOO_ANIM_ROWS := {
    "idle":   {"row": 0, "frames": 6, "fps": 7.0,  "loop": true},
    "run":    {"row": 1, "frames": 6, "fps": 10.0, "loop": true},
    "attack": {"row": 2, "frames": 6, "fps": 10.0, "loop": false},
    "hurt":   {"row": 3, "frames": 6, "fps": 10.0, "loop": false},
    "death":  {"row": 4, "frames": 6, "fps": 7.0,  "loop": false},
}
```

`_setup_sprite()` 상단 분기에 추가:
```gdscript
if enemy_type == "foo":
    _setup_sprite_grid(FOO_SHEET_PATH, FOO_ANIM_ROWS, <frame_w>, <frame_h>, <scale>, Vector2(0, <pos_y>))
    return
```

#### 패턴 C — Vertical strip (프레임이 수직으로 쌓임)

```gdscript
const FOO_SHEET_PATH := "res://assets/monsters/foo/foo-sheet.png"
const FOO_ANIM_VERT := {
    "idle":   {"start": 0,  "frames": 10, "fps": 7.0,  "loop": true},
    "run":    {"start": 10, "frames": 10, "fps": 10.0, "loop": true},
    "attack": {"start": 20, "frames": 15, "fps": 10.0, "loop": false},
    "hurt":   {"start": 35, "frames": 10, "fps": 10.0, "loop": false},
    "death":  {"start": 45, "frames": 5,  "fps": 7.0,  "loop": false},
}
```

`_setup_sprite()` 상단 분기에 추가:
```gdscript
if enemy_type == "foo":
    _setup_sprite_vertical(FOO_SHEET_PATH, FOO_ANIM_VERT, <frame_w>, <frame_h>, <scale>, Vector2(0, <pos_y>))
    return
```

### Step 5 — 방향 컨벤션 적용 (`.gd`)

**모든 스프라이트의 기본 방향은 RIGHT.**

방향 전환은 `scale.x`로만 처리. `flip_h` 사용 금지.

```gdscript
# CORRECT — scale.y(크기 배율)를 보존
sprite.scale.x = float(facing) * sprite.scale.y   # facing = +1 or -1

# WRONG — scale을 1로 덮어써서 크기 배율 파괴
sprite.scale.x = float(facing)
```

스프라이트가 LEFT를 기본으로 할 경우:
```gdscript
sprite.scale.x = float(-facing) * sprite.scale.y
```

스크립트 상단에 컨벤션 주석 추가:
```gdscript
# SPRITE DIRECTION: native facing = RIGHT
# scale.x = +scale.y → right, scale.x = -scale.y → left (mirrored)
```

### Step 6 — 검증 체크리스트

| 항목 | 확인 방법 |
|------|---------|
| `assets/`에 파일 복사됨 | `ls assets/monsters/<type>/` |
| `.import` 파일 생성됨 | `ls assets/monsters/<type>/*.import` |
| GDScript 경로가 `res://assets/...` | `grep asset_sample scripts/enemies/enemy_base.gd` → 결과 없어야 함 |
| 발 위치 정렬 | `position.y = box_bottom - feet_from_center * scale` |
| 방향 전환 시 scale 보존 | `sprite.scale.x = float(facing) * sprite.scale.y` |

### Step 7 — Validate

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

모든 테스트 통과 = 완료.

---

## Past Failure Prevention

| 과거 버그 | 이 스킬이 방지하는 방법 |
|----------|----------------------|
| `asset_sample/` 직접 참조 | Step 3 금지 원칙 + Step 6 grep 확인 |
| 에디터 임포트 누락 → 런타임 텍스처 로드 실패 | Step 3b: .import 파일 존재 확인 |
| 그리드/수직 시트 프레임 오판 | Step 2: 빈 행 분석으로 레이아웃 타입 판별 |
| 좌우 방향이 일관되지 않음 | Step 5: scale.x만 사용, flip_h 금지, 주석 문서화 |
| 애니메이션 도중 캐릭터 사라짐 | Step 2: 정확한 frame_count + region |
| 캐릭터가 너무 작거나 발이 뜸 | Step 2b-2c: 픽셀 바운드 → scale + position.y 공식 |
| 방향 전환 시 크기 배율 파괴 | Step 5: `scale.x = float(facing) * scale.y` |

---

## Worked Example — rat (32×32 Separate PNGs, collision box_h=54)

```
레이아웃: Separate PNGs (idle/run/attack/hurt/death 분리)
프레임: 32×32, idle 6f, run 6f, attack 6f, hurt 1f, death 6f

Pixel bounds (idle, run):
  char_h = 22px, feet_y ≈ 25 (from top of 32px frame)
  feet_from_center = 25 - 16 = +9
  box_h = 54, box_bottom = 27
  scale = 27*0.9/22 ≈ 1.3
  position_y = 27 - 9×1.3 = 15 → 14

GDScript 상수:
  const RAT_SHEET_DIR := "res://assets/monsters/rat/"
  sprite_scale = 1.3; sprite_pos = Vector2(0, 14); frame_w = 32; frame_h = 32
```

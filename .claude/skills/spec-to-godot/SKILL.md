---
name: spec-to-godot
description: Use when a Codex design document from docs/ needs to be translated into a Godot implementation task list.
---

# spec-to-godot

Translate Codex design documents into concrete Godot implementation tasks.

## Translation Map

| Codex section | → | Godot output |
|---|---|---|
| `## Implementation Handoff > Goal` | → | One-line feature description |
| `## Implementation Handoff > Likely Files Or Systems` | → | Exact file paths to create/edit |
| `## Implementation Handoff > Acceptance Criteria` | → | GUT test stub per bullet |
| `## Implementation Handoff > Non-Goals` | → | Skip list — do NOT implement |
| Spell table row | → | One entry in `data/spells.json` |
| Progression rule | → | Logic in `GameState.gd` or `player.gd` |
| Floor/room description | → | Entry in `data/rooms.json` |

## Step-by-Step

### 1. Read the doc

```bash
cat docs/<filename>.md
```

Locate the `## Implementation Handoff` section. This defines scope.

### 2. Check addon requirements

Before writing a single line of code, confirm:

| Need | Required addon | Wrong approach |
|------|---------------|----------------|
| Camera follow / event framing | `PhantomCamera2D` | `Camera2D` directly |
| Player/enemy state (idle, cast, hurt…) | `Godot State Charts` | `match` / `enum` state machine |
| Behavior test | `GUT` in `res://tests/` | No test at all |

### 3. Build task list from "Likely Files Or Systems"

For each item in that section, create a concrete task:

```
Codex: "player spell runtime logic"
→ Task: Edit scripts/player/player.gd
        Add: SpellResource loading, can_cast(), _execute_spell()
        Test: tests/test_player_spells.gd

Codex: "data/ spell definitions"
→ Task: Edit data/spells.json
        Add: all 15 spells with base stats and scaling
        Test: tests/test_spell_resource.gd (load from JSON, verify fields)

Codex: "progression UI"
→ Task: Edit scripts/ui/game_ui.gd + scenes/ui/GameUI.tscn
        Add: skill level display, mana bar
        Test: tests/test_game_ui.gd (verify label updates on level change)
```

### 4. Write GUT stubs first (TDD)

For each Acceptance Criterion bullet:

```gdscript
# tests/test_<feature>.gd
extends GutTest

func test_<criterion_in_snake_case>() -> void:
    # STUB — fill in after implementation
    pass
```

Commit stubs before implementation so tests start RED.

### 5. Validate after each task

```bash
godot --headless --path . --quit-after 120
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

## Folder Convention Reminder

```
data/spells.json                ← active 투사체 주문 수치 (damage, speed, cooldown…)
data/skills/skills.json         ← 모든 스킬 정의 (buff/toggle/deploy/passive/mastery)
data/skills/buff_combos.json    ← 버프 조합 콤보
data/enemies/enemies.json       ← 적 HP, 속도, 피해량, tint
data/items/equipment.json       ← 장비 아이템 정의
data/rooms.json                 ← 룸 레이아웃 + 스폰 위치
scripts/player/player.gd        ← 플레이어 물리/입력
scripts/player/spell_manager.gd ← 주문 시전 로직, 쿨다운, spell_cast 시그널
scripts/autoload/game_state.gd  ← 레벨, 마나, 버프, get_spell_runtime()
scripts/autoload/game_database.gd ← JSON 로더 (get_spell, get_skill_data, get_enemy_data)
scripts/enemies/enemy_base.gd   ← 모든 적 공통 로직 (스프라이트, AI, 피격)
scenes/                         ← scripts/ 구조 미러
tests/                          ← 시스템 1개당 테스트 파일 1개
```

## Non-Goals Protocol

When Codex lists "Non-Goals", add a comment block in the relevant file:

```gdscript
# NON-GOAL (see docs/<filename>.md): full balance pass
# NON-GOAL: final acquisition pacing for late-game spells
# Implement ONLY what Acceptance Criteria specify.
```

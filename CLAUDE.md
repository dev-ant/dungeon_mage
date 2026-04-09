# Dungeon Mage — Claude Code Project Instructions

## Project
- Godot 4.6, viewport 1280×720, headless-compatible
- Genre: 2D action Metroidvania
- Combat reference: MapleStory, 귀혼, Skul, 산나비

## Required Addons (always use these, never bypass)
- Camera: `PhantomCamera2D` / `PhantomCameraHost` (never raw Camera2D)
- Entity states: `Godot State Charts` (never custom state machines)
- Tests: `GUT` in `res://tests/` (every new behavior gets a test)

## Asset Workflow
When ANY asset is added to `asset_sample/`:
1. Invoke `asset-import` skill BEFORE writing any scene or script code
2. The skill runs pixel analysis and applies settings directly to Godot
   (Skills are local to this project: `.claude/skills/<name>.md`. Invoke via the Skill tool.)

### Asset Import Folder Rule (MANDATORY)
**All assets used in code MUST be copied to `assets/` and referenced from there.**
`asset_sample/` is a drop zone only — never reference it from scripts or scenes.

Correct workflow for any new sprite/texture:
1. Analyze source file in `asset_sample/` (pixel dimensions, frame count, etc.)
2. Copy to the appropriate `assets/` subdirectory (e.g. `assets/monsters/<type>/`)
3. Reference only the `assets/` path in code (`res://assets/...`)
4. Open the Godot editor once after copying so Godot imports the new files (`.import` files appear next to the PNGs)

**Never write:**
```gdscript
const FOO_DIR := "res://asset_sample/..."  # WRONG
```
**Always write:**
```gdscript
const FOO_DIR := "res://assets/..."        # CORRECT
```

This rule applies to monsters, player sprites, UI textures, tilesets — all asset types.

## Validation Commands

```bash
# Startup check (must pass before every commit)
godot --headless --path . --quit

# Short runtime check
godot --headless --path . --quit-after 120

# Run all GUT tests
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

## Folder Convention

```
asset_sample/   ← user drops raw assets here
assets/         ← Claude copies processed assets here
data/           ← JSON (spells.json, rooms.json)
scripts/
  autoload/     ← GameState, GameDatabase singletons
  player/       ← player.gd, spell_*.gd
  enemies/      ← enemy_base.gd, enemy_*.gd
  world/        ← room_builder.gd, interactables
  ui/           ← game_ui.gd, HUD
scenes/         ← .tscn files (mirror scripts/ structure)
tests/          ← GUT test files
```

## Codex Handoff
Design docs from Codex live in `docs/`. When implementing:
- Invoke `spec-to-godot` skill first
  (Use the Skill tool with skill name `spec-to-godot`)
- Map "Implementation Handoff" section → task list
- Map "Acceptance Criteria" → GUT test stubs
- If the task changes enemy stats, damage formulas, resistances, status resistances, super armor, or break rules, read and update `docs/progression/rules/enemy_stat_and_damage_rules.md` in the same change.

## Combat Implementation
Invoke `godot-combat` skill (via Skill tool) when implementing any:
- Spell effect, damage, buff, installation, or on-off mechanic
- State transition (Idle/Walk/Jump/Cast/Hit/Dead)
- Hit feel (hitstop, shake, damage numbers)
- Enemy stat tuning, defense/resistance handling, super armor, break, or damage pipeline

Combat balance rule:
- Before changing combat numbers that affect enemy damage intake, read `docs/progression/rules/enemy_stat_and_damage_rules.md`.
- If those rules change, update that document together with the code and tests.

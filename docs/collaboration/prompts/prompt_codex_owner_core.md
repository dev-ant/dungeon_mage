---
title: Dungeon Mage — Codex 구현 에이전트 프롬프트 (owner_core 역할)
doc_type: prompt
status: active
section: collaboration
owner: owner_core
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
update_when:
  - handoff_changed
  - ownership_changed
  - runtime_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# Dungeon Mage — Codex 구현 에이전트 프롬프트 (owner_core 역할)

> 이 문서는 Codex가 Claude Code와 동일한 방식으로 Dungeon Mage 프로젝트의
> `owner_core` 역할 작업을 장기적으로 수행하기 위한 완전한 운영 매뉴얼이다.
> **매 세션 시작 시 공통 거버넌스 시작 체인을 먼저 읽고, 그다음 이 문서를 owner_core 역할 매뉴얼로 적용한다.**

---

## 0. 거버넌스 잠금

모든 실행 프롬프트와 세션은 아래 순서를 같은 기본 시작 체인으로 사용한다.

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
8. [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md)
9. 그다음 이 문서, 역할 계약, workstream, 관련 작업 문서

이 체인 위에 아래 규칙을 추가로 잠근다.

- 요청 범위가 넓으면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 관련 `plan`보다 먼저 읽는다.
- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 엔진 | Godot 4.6 |
| 언어 | GDScript |
| 장르 | 2D 횡스크롤 액션 RPG (전투 중심) |
| 전투 레퍼런스 | MapleStory, 귀혼, Skul, 산나비 |
| 뷰포트 | 1280×720 |
| 환경 | headless-compatible (CI/테스트 모두 headless로 통과해야 함) |

### 필수 애드온 — 반드시 사용, 절대 우회 금지

| 용도 | 사용 | 금지 |
|------|------|------|
| 카메라 | `PhantomCamera2D` / `PhantomCameraHost` | raw `Camera2D` |
| 엔티티 상태 머신 | `Godot State Charts` | 커스텀 state machine, `match` enum |
| 테스트 | `GUT` (`res://tests/`) | 테스트 없음 |

---

## 2. 역할 분리 계약

이 프로젝트는 **두 AI 에이전트가 파일 소유권을 분리**하여 병렬 작업한다.

- **owner_core (이 프롬프트의 역할)**: 전투 코어, 데이터, 런타임, 적, 월드, 비 GUI 테스트
- **friend_gui**: 아이템창/스킬창/설정창/장비창 GUI 구현 전담

### Allowed implementation files

```
data/**
scripts/player/**
scripts/enemies/**
scripts/world/**
scripts/autoload/**
tests/test_player_controller.gd
tests/test_spell_manager.gd
tests/test_game_state.gd
tests/test_enemy_base.gd
tests/test_equipment_system.gd
```

### Allowed documentation files

```
docs/implementation/**
docs/collaboration/workstreams/owner_core_workstream.md
```

### Conditionally allowed source-of-truth docs for same-turn sync

```
Only when the same turn changed the connected owner-core system and the docs must be synchronized immediately.
docs/progression/rules/**       # touched combat, skill, buff, equipment, or enemy rules only
docs/progression/schemas/**     # touched runtime data fields or allowed values only
docs/progression/trackers/**    # touched implementation status rows only
docs/progression/catalogs/**    # touched roster/content entries only
docs/progression/plans/**       # only when the same change updates an active migration or follow-up plan
docs/collaboration/archive/owner_core_workstream_archive_*.md   # only when rolling over the active owner workstream
Examples:
- docs/progression/rules/enemy_stat_and_damage_rules.md
- docs/progression/schemas/enemy_data_schema.md
- docs/progression/trackers/enemy_content_tracker.md
- docs/progression/rules/skill_system_design.md
- docs/progression/schemas/skill_data_schema.md
```

### Forbidden files

```
scripts/admin/admin_menu.gd
scripts/ui/game_ui.gd
scripts/ui/** (GUI 창 파일)
scenes/ui/**
scenes/main/Main.tscn
tests/test_admin_menu.gd
docs/collaboration/workstreams/friend_gui_workstream.md
docs/collaboration/prompts/**
docs/collaboration/policies/**
docs/governance/**
docs/foundation/**
docs/implementation/archive/**
docs/progression/archive/**
docs/collaboration/archive/** outside the owned workstream rollover file
unrelated docs/progression/** outside the conditional sync scope
```

### 교차 의존 처리

상대 소유 파일 수정이 필요하다고 판단되면:
- **직접 수정하지 않는다**
- `docs/collaboration/workstreams/owner_core_workstream.md`의 `교차 의존 요청` 섹션에 이유/필요 입력/예상 파일을 기록한다

---

## 3. 세션 시작 프로토콜 (매 세션 필수)

```
Step 1. docs/README.md 읽기
Step 2. docs/governance/README.md 읽기
Step 3. ai_native_operating_model.md 읽기
Step 4. ai_update_protocol.md 읽기
Step 5. clarification_loop_protocol.md 읽기
Step 6. skills_and_mcp_policy.md 읽기
Step 7. docs/implementation/README.md 읽기
Step 8. docs/collaboration/README.md 읽기
Step 9. 이 문서 읽기
Step 10. docs/collaboration/policies/role_split_contract.md 읽기
          → 파일 소유권과 금지 범위 확인
Step 11. docs/collaboration/workstreams/owner_core_workstream.md 읽기
          → 현재 진행 로그, 다음 우선 작업, 교차 의존 요청 확인
Step 12. 요청 범위가 넓으면 docs/implementation/spec_clarification_backlog.md를 plan보다 먼저 읽기
Step 13. 관련 작업 문서 읽기
          → docs/implementation/plans/combat_first_build_plan.md
          → docs/implementation/increments/combat_increment_0*.md
          → docs/progression/rules/enemy_stat_and_damage_rules.md
Step 14. 기획이 모호하면 구현 대신 정확히 10문항 질문 라운드 시작
Step 15. 반복 작업이면 관련 skill 먼저 적용, scene/node/script wiring 확인이면 Godot MCP 먼저 시도
Step 16. 구현 시작 — 아래 5사이클 워크플로우 적용
```

---

## 4. 작업 사이클 (세션당 최대 5사이클)

각 사이클은 하나의 독립된 전투 기능 단위다.

```
[Cycle N]
1. 관련 파일 읽기 (Read tool로 실제 현재 코드 확인)
2. 변경 최소화 원칙으로 구현
3. GUT 테스트 추가/갱신
4. 검증 명령 실행
5. owner_core_workstream.md 진행 로그 갱신
6. 필요하면 baseline/rule/schema/tracker/plan 문서를 같은 턴에 동기화
```

### 검증 명령 (순서대로 반드시 실행)

```bash
# 1. 스타트업 파싱 체크 (매 사이클 후 필수)
godot --headless --path . --quit

# 2. 런타임 체크
godot --headless --path . --quit-after 120

# 3. GUT 전체 테스트 (매 사이클 후 필수)
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

**모든 테스트가 통과해야 다음 사이클로 진행한다.**

### 전투 수치 규칙 변경 시 추가 의무

아래 항목이 바뀌면 코드만 수정하고 끝내면 안 된다.

- 적 스탯 키
- 방어력 공식
- 속성 저항/약점
- 상태이상 저항
- 슈퍼아머/브레이크
- 적이 받는 최종 피해 계산 순서

위 항목 변경 시 반드시
`docs/progression/rules/enemy_stat_and_damage_rules.md`
를 같은 커밋 안에서 함께 수정한다.

진행 로그는 `docs/collaboration/workstreams/owner_core_workstream.md`에만 남긴다.
하지만 같은 턴 소스 오브 트루스 동기화는 위 조건부 문서 범위 안에서 예외적으로 허용한다.

---

## 5. 폴더 구조

```
asset_sample/   ← 원본 에셋 드롭존 (코드에서 절대 참조 금지)
assets/         ← 복사된 에셋 (코드에서 이 경로만 참조)
  effects/      ← 스킬 이펙트 애니메이션 PNG
  monsters/     ← 몬스터 스프라이트 (타입별 서브폴더)
  player/       ← 플레이어 스프라이트
data/
  spells.json                  ← 투사체 주문 수치
  rooms.json                   ← 룸 레이아웃 + 스폰
  enemies/enemies.json         ← 적 스탯
  items/equipment.json         ← 장비 아이템
  skills/skills.json           ← 스킬 정의 (buff/toggle/deploy/passive)
  skills/buff_combos.json      ← 버프 조합
scripts/
  autoload/
    game_state.gd    ← HP/마나/버프/스킬 레벨/장비/공명 — 핵심 싱글톤
    game_database.gd ← JSON 로더 (get_spell, get_skill_data, get_enemy_data...)
  player/
    player.gd           ← 물리/입력/상태차트/피격 처리
    spell_manager.gd    ← 쿨다운, 마나, spell_cast 시그널
    spell_projectile.gd ← 투사체 비주얼 + 충돌
  enemies/
    enemy_base.gd  ← 모든 적 공통 로직 (스프라이트, AI, 피격, 체력바)
  world/           ← room_builder.gd, interactables
  ui/              ← game_ui.gd (친구 소유 — 수정 금지)
scenes/            ← scripts/ 구조 미러
tests/             ← GUT 테스트 파일
docs/
  implementation/  ← 인크리먼트 설계 문서
  collaboration/   ← 역할 분리 계약 + workstream 문서
```

---

## 6. 핵심 아키텍처 패턴

### 6-1. 스킬 시전 흐름

```
Input.is_action_just_pressed(action)
  → spell_manager.attempt_cast(skill_id)
      → GameState.get_spell_runtime(skill_id)   # 레벨 보정 수치 딕셔너리
      → GameState.consume_skill_mana(skill_id)
      → GameState.register_spell_use(skill_id, school)
      → spell_cast.emit(payload)                # 투사체 스포너가 수신
```

### 6-2. get_spell_runtime() 반환 딕셔너리 주요 키

```gdscript
var runtime: Dictionary = GameState.get_spell_runtime(skill_id)
# 키: "damage", "speed", "cooldown", "range", "knockback", "size",
#      "duration", "school", "spell_id", "skill_id", "skill_level"
# 버프 런타임 수정자(_apply_buff_runtime_modifiers)까지 자동 적용되어 반환됨
```

### 6-3. 스킬 타입별 처리

| skill_type | 처리 위치 | 패턴 |
|------------|----------|------|
| `"active"` (투사체) | `spell_manager._cast_active()` → `spell_cast.emit(payload)` | `data/spells.json` 수치 |
| `"buff"` | `GameState.try_activate_buff(skill_id)` | active_buffs: Array |
| `"deploy"` | `spell_manager._cast_deploy()` → `spell_cast.emit(payload)` | duration/size/damage |
| `"toggle"` | `spell_manager._cast_toggle(skill_id)` | active_toggles: Dictionary |
| `"passive"` | 자동 — `GameState._apply_buff_runtime_modifiers()` | 코드 추가 불필요 |

### 6-4. 플레이어 피격 함수

```gdscript
# player.gd
func receive_hit(amount: int, source: Vector2, knockback: float,
                 school: String = "", utility_effects: Array = []) -> void:
    if invuln_timer > 0.0 or is_dead: return
    invuln_timer = IFRAME_TIME   # 0.8s 무적
    hit_stun_timer = HIT_STUN_TIME * (1.0 - poise_reduction) * stagger_mult
    velocity = Vector2(push_dir * knockback * stagger_mult, -240.0)
    GameState.damage(amount, school)
    _apply_player_utility_effects(utility_effects)  # "slow" 등 상태이상
    _cam_shake_timer = 0.3; _cam_shake_intensity = 8.0
    _sc_send("hit_taken")
```

### 6-5. 적 피격 함수

```gdscript
# enemy_base.gd
func receive_hit(amount: int, source: Vector2, knockback: float,
                 school: String, utility_effects: Array = []) -> void:
    health -= amount
    _update_health_bar()
    _apply_utility_effects(utility_effects)
    if state_chart and is_node_ready():
        if super_armor_active:
            stagger_accumulator += amount
            if stagger_accumulator >= stagger_threshold:
                state_chart.send_event("stagger")
        else:
            state_chart.send_event("stagger")
    if health <= 0: died.emit(self); _play_death_and_free()
```

### 6-6. 적 투사체 발사 패턴

```gdscript
# enemy_base.gd — fire_projectile 시그널로 발송 (instantiate 아님)
signal fire_projectile(payload: Dictionary)

func _fire_ranged_shot() -> void:
    var dir := (target.global_position - global_position).normalized()
    fire_projectile.emit({
        "position": global_position + dir * 18.0,
        "velocity": dir * 380.0,
        "range": 320.0, "team": "enemy",
        "damage": contact_damage, "knockback": 120.0,
        "school": "fire", "size": 10.0, "color": projectile_color, "owner": self
    })
```

### 6-7. State Chart (GDScript 프로그래밍 방식 구성)

```gdscript
# State Chart는 .tscn에 배치하지 않고 GDScript로 런타임 생성
var state_chart = StateChartScript.new()
var _sc_root    = CompoundStateScript.new()

func _build_state_chart() -> void:
    state_chart.add_child(_sc_root)
    var st_idle := _add_state("Idle")
    var st_pursue := _add_state("Pursue")
    # 트랜지션
    _add_transition(st_idle, st_pursue, "target_found")
    add_child(state_chart)

func _add_state(name: String) -> Object:
    var st := AtomicStateScript.new(); st.name = name
    _sc_root.add_child(st)
    if _sc_root.initial_state.is_empty():
        _sc_root.initial_state = _sc_root.get_path_to(st)
    return st

func _add_transition(from_state, to_state, event: String, delay: float = 0.0):
    var t := TransitionScript.new()
    from_state.add_child(t)
    t.to = t.get_path_to(to_state); t.event = event
    t.delay_in_seconds = delay

func _sc_send(event: String) -> void:
    if state_chart and is_node_ready():
        state_chart.send_event(event)
```

---

## 7. 데이터 파일 형식

### data/spells.json (투사체 주문)

```json
{
  "spell_id": {
    "id": "spell_id",
    "name": "Display Name",
    "school": "fire",
    "color": "#ff8f45",
    "damage": 14, "speed": 900, "range": 400,
    "cooldown": 0.32, "knockback": 240, "size": 16,
    "pierce": 0,
    "mastery_threshold": 4,
    "mastery_bonus": { "damage": 6, "speed": 80, "size": 3 }
  }
}
```

### data/enemies/enemies.json (적 스탯)

```json
{
  "enemy_id": "brute",
  "display_name": "Brute",
  "enemy_type": "brute",
  "role": "melee_chaser",
  "max_hp": 52, "move_speed": 120.0, "contact_damage": 13,
  "attack_period": 1.4, "stagger_threshold": 9999,
  "knockback_resistance": 0.0, "super_armor_tags": [],
  "tint": "#c25a62", "projectile_color": "#ffcf73",
  "drop_profile": "common"
}
```

### data/items/equipment.json (장비)

```json
{
  "item_id": "focus_void_lens",
  "display_name": "Void Lens",
  "slot": "offhand",
  "rarity": "rare",
  "stats": {
    "dark_damage_multiplier": 1.22,
    "projectile_speed_multiplier": 1.08
  }
}
```

### data/rooms.json (룸)

```json
{
  "room_id": "void_rift",
  "width": 1800,
  "background": "#080010",
  "floor_segments": [...],
  "spawns": [
    {"type": "eyeball", "x": 400, "y": 300},
    {"type": "elite", "x": 800, "y": 300}
  ],
  "objects": [
    {"type": "echo", "x": 600, "y": 250},
    {"type": "rest", "x": 900, "y": 250}
  ],
  "entry_text": "Something watches from the dark."
}
```

---

## 8. game_state.gd 주요 API

```gdscript
# 피해/HP
GameState.damage(amount: int, school: String)          # HP 차감
GameState.health / GameState.max_health

# 마나
GameState.has_enough_mana(skill_id: String) -> bool
GameState.consume_skill_mana(skill_id: String) -> bool
GameState.mana / GameState.max_mana

# 스킬/주문 런타임
GameState.get_spell_runtime(spell_id: String) -> Dictionary
GameState.get_spell_level(spell_id: String) -> int
GameState.register_spell_use(spell_id, school)         # resonance 카운트 + mastery

# 장비 배율
GameState.get_equipment_damage_multiplier(school: String) -> float
GameState.get_equipment_projectile_speed_multiplier() -> float
GameState.get_equipment_projectile_count_bonus() -> int
GameState.get_equipment_aoe_multiplier() -> float
GameState.get_equipment_cooldown_multiplier() -> float
GameState.get_equipment_buff_duration_multiplier() -> float
GameState.get_equipment_install_duration_multiplier() -> float

# 버프
GameState.try_activate_buff(skill_id: String) -> bool
GameState.active_buffs: Array
GameState.get_super_armor_charges() -> int

# 공명 시스템
GameState.resonance: Dictionary        # {"fire": 0, "ice": 0, ...}
GameState.resonance_bonus_school: String   # resonance 30 도달 school
GameState.resonance_bonus_timer: float    # 15초 10% 보너스 타이머

# 메시지
GameState.push_message(text: String, duration: float)
GameState.ui_message: String

# 테스트 초기화
GameState.reset_progress_for_tests()

# 어드민
GameState.admin_infinite_health: bool
GameState.admin_infinite_mana: bool
GameState.admin_ignore_cooldowns: bool
```

---

## 9. GUT 테스트 패턴

### 기본 구조

```gdscript
extends "res://addons/gut/test.gd"

const SCRIPT := preload("res://scripts/path/to/script.gd")

func before_each() -> void:
    GameState.health = GameState.max_health
    GameState.reset_progress_for_tests()

func test_something() -> void:
    var obj = autofree(SCRIPT.new())
    # ... assertions
```

### 핵심 assert 함수

```gdscript
assert_true(value, msg)
assert_false(value, msg)
assert_eq(actual, expected, msg)
assert_ne(actual, expected, msg)
assert_gt(actual, expected, msg)    # greater than
assert_lt(actual, expected, msg)    # less than
assert_almost_eq(actual, expected, tolerance, msg)
assert_string_contains(string, substring, msg)
assert_null(value, msg)
assert_not_null(value, msg)
```

### 시그널 캡처 패턴 (bool 캡처 버그 주의)

```gdscript
# WRONG: GDScript 클로저는 값 캡처 → bool이 업데이트 안 됨
var fired := false
enemy.fire_projectile.connect(func(p): fired = true)

# CORRECT: Array로 래핑
var payloads: Array = []
enemy.fire_projectile.connect(func(p): payloads.append(p))
enemy._fire_ranged_shot()
assert_eq(payloads.size(), 1)
assert_eq(str(payloads[0].get("school", "")), "dark")
```

### 자주 쓰는 테스트 픽스처

```gdscript
# enemy_base.gd 테스트
var enemy = autofree(ENEMY_SCRIPT.new())
enemy.configure({"type": "brute", "position": Vector2.ZERO}, null)

# player.gd 테스트 (debug 메서드 활용)
var player = autofree(PLAYER_SCRIPT.new())
player.debug_setup_state_chart()
player.debug_setup_spell_manager()
player.debug_try_jump(true)          # grounded=true
player.debug_begin_dash()
player.debug_advance_timers(0.5)     # delta 직접 적용
player.debug_mark_dead()
```

---

## 10. 에셋 임포트 워크플로우

**asset_sample/에 PNG가 추가되면 이 절차를 따른다.**

### Step 1 — 레이아웃 판별

```bash
find asset_sample/<subfolder> -name "*.png" | sort
python3 -c "
from PIL import Image
img = Image.open('asset_sample/<path>/<file>.png')
print(img.size)
"
```

| 조건 | 레이아웃 | GDScript 패턴 |
|------|---------|--------------|
| 애니메이션별 파일 분리 | Separate PNGs | `_SHEETS` + `_SHEET_DIR` + `_ANIM_FILES` |
| 단일 파일, 가로 or 정사각형 | Grid (rows×cols) | `_ANIM_ROWS` + `_setup_sprite_grid()` |
| 단일 파일, 세로가 훨씬 긺 | Vertical strip | `_ANIM_VERT` + `_setup_sprite_vertical()` |

### Step 2 — 픽셀 바운드 분석 (캐릭터/적)

```python
from PIL import Image
img = Image.open("asset_sample/<path>/idle.png")
frame_w = img.width // frame_count
frame_h = img.height
pixels = list(img.getdata())
ys = [i // frame_w for i, p in enumerate(pixels) if p[3] > 10]
char_h = max(ys) - min(ys)
feet_from_center = max(ys) - (frame_h / 2)
print(f"char_h={char_h}, feet_from_center={feet_from_center:.1f}")
```

**scale/position 공식:**
```
scale = (box_h * 0.9) / char_h
position_y = box_bottom - feet_from_center * scale
# Godot 충돌박스 기준: box_h ≈ 54, box_bottom ≈ 27
```

### Step 3 — assets/로 복사 후 임포트

```bash
mkdir -p assets/monsters/<type>/
cp "asset_sample/<path>/<file>.png" "assets/monsters/<type>/<file>.png"
godot --headless --path . --quit   # 임포트 트리거
ls assets/monsters/<type>/*.import  # .import 파일 존재 확인
```

**코드에서는 반드시 `res://assets/...` 경로만 사용. `asset_sample/` 절대 참조 금지.**

### Step 4 — GDScript 상수 패턴

#### Separate PNGs
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
# _setup_sprite() match 블록에 추가:
# "foo": sheets = FOO_SHEETS; sheet_dir = FOO_SHEET_DIR; anim_files = FOO_ANIM_FILES
#         sprite_scale = <scale>; sprite_pos = Vector2(0, <pos_y>)
```

#### Grid Sheet
```gdscript
const FOO_SHEET_PATH := "res://assets/monsters/foo/foo-sheet.png"
const FOO_ANIM_ROWS := {
    "idle":   {"row": 0, "frames": 6, "fps": 7.0,  "loop": true},
    "run":    {"row": 1, "frames": 6, "fps": 10.0, "loop": true},
    "attack": {"row": 2, "frames": 6, "fps": 10.0, "loop": false},
    "hurt":   {"row": 3, "frames": 4, "fps": 10.0, "loop": false},
    "death":  {"row": 4, "frames": 6, "fps": 7.0,  "loop": false},
}
# _setup_sprite()에 추가:
# if enemy_type == "foo":
#     _setup_sprite_grid(FOO_SHEET_PATH, FOO_ANIM_ROWS, <fw>, <fh>, <scale>, Vector2(0, <py>))
#     return
```

#### Vertical Strip
```gdscript
const FOO_SHEET_PATH := "res://assets/monsters/foo/foo-sheet.png"
const FOO_ANIM_VERT := {
    "idle":   {"start": 0,  "frames": 10, "fps": 7.0,  "loop": true},
    "run":    {"start": 10, "frames": 10, "fps": 10.0, "loop": true},
    "attack": {"start": 20, "frames": 15, "fps": 10.0, "loop": false},
    "hurt":   {"start": 35, "frames": 5,  "fps": 10.0, "loop": false},
    "death":  {"start": 40, "frames": 5,  "fps": 7.0,  "loop": false},
}
# _setup_sprite()에 추가:
# if enemy_type == "foo":
#     _setup_sprite_vertical(FOO_SHEET_PATH, FOO_ANIM_VERT, <fw>, <fh>, <scale>, Vector2(0, <py>))
#     return
```

### Step 5 — 스프라이트 방향 컨벤션

```gdscript
# 모든 스프라이트 기본 방향 = RIGHT
# CORRECT — scale.y(크기 배율) 보존
sprite.scale.x = float(facing) * sprite.scale.y   # facing = +1(right) or -1(left)

# WRONG — scale 덮어쓰기
sprite.scale.x = float(facing)   # 크기 배율 파괴

# 파일 상단 주석 필수
# SPRITE DIRECTION: native facing = RIGHT
# scale.x = +scale.y → right, scale.x = -scale.y → left (mirrored)
```

### Step 6 — 스킬 이펙트 에셋 적용 패턴 (fire_bolt 기준)

```gdscript
# spell_projectile.gd
func _build_visual(color: Color) -> void:
    if spell_id == "fire_bolt":
        _build_fire_bolt_visual()   # AnimatedSprite2D 방식
        return
    # 나머지는 school별 polygon shape
    var polygon := Polygon2D.new()
    polygon.polygon = _build_school_polygon(school, radius)
    add_child(polygon)

func _build_fire_bolt_visual() -> void:
    var sprite := AnimatedSprite2D.new()
    var frames := SpriteFrames.new()
    frames.add_animation("default")
    for i in range(15):   # assets/effects/fire_bolt/ 에 0~14.png
        var tex = load("res://assets/effects/fire_bolt/fire_bolt_%d.png" % i)
        frames.add_frame("default", tex)
    frames.set_animation_loop("default", true)
    frames.set_animation_speed("default", 12.0)
    sprite.sprite_frames = frames
    sprite.scale = Vector2(0.5, 0.5)
    sprite.scale.x = 0.5 if velocity.x >= 0 else -0.5
    sprite.play("default")
    add_child(sprite)
```

---

## 11. Godot MCP 사용 방법

Godot MCP가 연결된 환경에서는 파일 직접 편집보다 MCP 툴을 우선 사용한다.

### MCP 연결 확인

```bash
claude mcp list
# godot: npx -y @coding-solo/godot-mcp - ✓ Connected
```

### 주요 MCP 툴과 사용 시점

| 툴 | 사용 시점 |
|----|----------|
| `get_project_info(projectPath=".")` | 모든 작업의 첫 번째 단계 — 씬/스크립트 목록 파악 |
| `create_scene(path, root_type)` | 새 .tscn 파일 생성 |
| `add_node(scene_path, node_type, parent)` | 씬에 노드 추가 |
| `save_scene(scene_path)` | 씬 변경 후 반드시 호출 |
| `run_project(projectPath=".", scene="res://...")` | 런타임 동작 확인 |
| `get_debug_output()` | run_project 후 출력 캡처 |
| `stop_project()` | 실행 종료 |
| `load_sprite(scene_path, node_path, texture_path)` | Sprite2D에 텍스처 연결 |
| `get_uid(path)` / `update_project_uids(projectPath)` | UID 불일치 수정 |

### MCP 사용 규칙

- 씬 작업 전 반드시 `get_project_info` 호출
- 카메라는 반드시 `PhantomCamera2D` (raw Camera2D 금지)
- `save_scene` 없이 씬 작업 종료하지 않음
- 런타임 에러 확인은 `run_project` → `get_debug_output` → `stop_project` 순서

### MCP 불가 시 Fallback

| MCP 툴 | 대체 방법 |
|--------|----------|
| `get_project_info` | `find . -name "*.tscn"` + `find . -name "*.gd"` |
| `create_scene` / `add_node` | `.tscn` 파일 직접 Write/Edit |
| `run_project` + `get_debug_output` | `godot --headless --path . --quit-after 120` |
| `load_sprite` | `.tscn`의 `texture = ExtResource(...)` 직접 편집 |

---

## 12. 과거 실수 방지 (알려진 버그 패턴)

| 잘못된 패턴 | 올바른 패턴 |
|------------|------------|
| `asset_sample/` 경로를 코드에서 참조 | 반드시 `assets/`로 복사 후 `res://assets/...` 참조 |
| `Camera2D` 직접 사용 | `PhantomCamera2D` 사용 |
| `match` / enum 상태 머신 | `Godot State Charts` |
| `SpellResource` 클래스 | 딕셔너리 기반, `GameState.get_spell_runtime(id)` |
| `spell.projectile_scene.instantiate()` | `spell_cast.emit(payload)` 시그널 방식 |
| `active_buffs["id"] = {...}` 딕셔너리 | `active_buffs: Array`, `try_activate_buff(id)` |
| `State Chart를 .tscn에 배치` | GDScript `_build_state_chart()` 런타임 생성 |
| `var fired := false; func(): fired = true` | `var fired := [false]; func(): fired[0] = true` |
| `get_all_spells()` 호출 | `GameDatabase.get_spell("spell_id")` 개별 조회 |
| `get_equipped_item("slot")` (단수) | `GameState.get_equipped_items()["slot"]` |

---

## 13. 신규 적 추가 체크리스트

새로운 적 타입을 추가할 때 반드시 거치는 단계:

```
□ data/enemies/enemies.json: 스탯 엔트리 추가
□ scripts/enemies/enemy_base.gd:
    □ 스프라이트 상수 추가 (SHEETS/ANIM_ROWS/ANIM_VERT)
    □ _setup_sprite(): 타입 분기 추가
    □ _apply_stats_from_data(): fallback 스탯 추가
    □ _run_ai(): pursue/kite 분기 추가 (attack_window 트리거)
    □ _on_attack_state_entered(): 공격 분기 추가
    □ 필요 시 helper 함수 추가 (_fire_*, _special_*)
□ assets/에 스프라이트 복사 + godot --headless --path . --quit (임포트)
□ tests/test_enemy_base.gd: 최소 3개 테스트 추가
    □ configure() 후 스탯 확인
    □ 공격 시그널/행동 확인
    □ 특수 변수(stagger_threshold 등) 확인
□ GUT 전체 통과 확인
□ owner_core_workstream.md 갱신
```

---

## 14. 신규 스펠/스킬 추가 체크리스트

```
□ data/spells.json (투사체 주문) 또는 data/skills/skills.json (기타) 엔트리 추가
□ scripts/autoload/game_state.gd:
    □ SCHOOL_ORDER에 신규 속성 추가 (없는 경우)
    □ resonance 초기값 / reset_progress_for_tests() 리셋에 추가
    □ get_equipment_damage_multiplier(): 신규 속성 case 추가
    □ DEFAULT_SPELL_HOTBAR: 슬롯 추가 (key 바인딩 포함)
    □ ensure_input_map(): InputEventKey 등록 추가
    □ LEGACY_SPELL_TO_SKILL / SCHOOL_TO_MASTERY: 연결 확인
□ EQUIPMENT_PRESETS: 관련 프리셋 추가 (필요시)
□ data/items/equipment.json: 관련 장비 추가 (필요시)
□ tests/: 관련 테스트 추가
□ GUT 전체 통과 확인
□ owner_core_workstream.md 갱신
```

---

## 15. workstream 문서 갱신 형식

작업 완료 후 `docs/collaboration/workstreams/owner_core_workstream.md`를 아래 형식으로 갱신한다:

```markdown
### YYYY-MM-DD (N차 세션 - Cycle X)

#### [기능명] (Cycle X)

**완료 항목:**
- `파일경로`: 구체적 변경 내용 (변수명, 함수명, 수치 포함)

**검증:** GUT NNN/NNN 통과, headless --quit 통과

#### 다음 우선 작업 (다음 세션)

1. **[작업명]**: 설명
2. ...
```

---

## 16. 장기 유지보수 원칙

1. **코드 최소화**: 필요한 것만 구현. 미래를 위한 추상화, 유틸리티 함수, 에러 핸들링 추가 금지
2. **테스트 먼저**: 신규 동작에는 반드시 GUT 테스트. 구현 전 또는 구현과 동시에 작성
3. **문서 동기화**: 씬/스크립트 변경 후 docs/implementation/ 관련 문서 갱신
4. **headless 필수**: 모든 검증은 headless 환경에서 통과
5. **파일 소유권 준수**: role_split_contract.md 기준을 매 작업 전 확인
6. **진행 로그 갱신**: 매 사이클 후 workstream 문서 갱신 — 다음 에이전트(또는 다음 세션)가 중복 작업하지 않도록

---

## 17. 참고 문서 목록

| 문서 | 역할 |
|------|------|
| `docs/README.md` | 루트 인덱스 + active/archive 진입 분리 |
| `docs/governance/README.md` | 공통 시작 체인 잠금 |
| `docs/governance/ai_native_operating_model.md` | 실행 체인과 질문 루프 기준 |
| `docs/governance/ai_update_protocol.md` | 문서 동기화 규칙 |
| `docs/governance/clarification_loop_protocol.md` | 정확히 10문항 질문 라운드 |
| `docs/governance/skills_and_mcp_policy.md` | skill 우선 / Godot MCP 우선 규칙 |
| `CLAUDE.md` | 프로젝트 필수 규칙 (카메라/상태머신/에셋 규칙) |
| `docs/collaboration/policies/role_split_contract.md` | 파일 소유권 계약 |
| `docs/collaboration/workstreams/owner_core_workstream.md` | 진행 로그 + 다음 작업 |
| `docs/implementation/plans/combat_first_build_plan.md` | 전체 구현 목표 기준 |
| `docs/implementation/increments/combat_increment_0*.md` | 인크리먼트별 설계 |
| `$dungeon-mage-asset-import` | 에셋 임포트 상세 절차 |
| `$dungeon-mage-godot-combat` | 전투 코드 패턴 레퍼런스 |
| `$dungeon-mage-godot-mcp` | MCP 우선 / fallback 작업 절차 |
| `$dungeon-mage-spec-to-godot` | 설계 문서 → 구현 태스크 변환 |
| `.claude/skills/asset-import/SKILL.md` | 레거시 Claude 기준 레퍼런스 (수정 금지, 필요 시 비교용 읽기 전용) |
| `.claude/skills/godot-combat/SKILL.md` | 레거시 Claude 기준 레퍼런스 (읽기 전용) |
| `.claude/skills/godot-mcp/SKILL.md` | 레거시 Claude 기준 레퍼런스 (읽기 전용) |
| `.claude/skills/spec-to-godot/SKILL.md` | 레거시 Claude 기준 레퍼런스 (읽기 전용) |

---

## 18. 세션 시작 예시 프롬프트

```
이 프로젝트의 owner_core 역할로 작업을 이어서 진행해줘.

순서:
1. docs/README.md 읽기
2. docs/governance/README.md 읽기
3. docs/governance/ai_native_operating_model.md 읽기
4. docs/governance/ai_update_protocol.md 읽기
5. docs/governance/clarification_loop_protocol.md 읽기
6. docs/governance/skills_and_mcp_policy.md 읽기
7. docs/implementation/README.md 읽기
8. docs/collaboration/README.md 읽기
9. docs/collaboration/policies/role_split_contract.md 읽기
10. docs/collaboration/workstreams/owner_core_workstream.md 읽기
11. 넓은 요청이면 docs/implementation/spec_clarification_backlog.md를 먼저 읽기
12. 다음 우선 작업과 관련 구현 문서 확인
13. 기획이 모호하면 구현 대신 정확히 10문항 질문 라운드로 전환
14. 구현 → 테스트 → 검증 → workstream 갱신 순서로 최대 5사이클 진행

owner_core 역할 규칙:
- 수정 가능: data/**, scripts/player/**, scripts/enemies/**, scripts/world/**, scripts/autoload/**, 지정 test 파일 5개
- 절대 수정 금지: scripts/admin/admin_menu.gd, scripts/ui/**, scenes/ui/**, scenes/main/Main.tscn, tests/test_admin_menu.gd
- 반복 작업은 등록된 Codex 스킬 우선 사용: $dungeon-mage-spec-to-godot, $dungeon-mage-godot-combat, $dungeon-mage-godot-mcp, $dungeon-mage-asset-import
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도
- 각 사이클 후 GUT 전체 통과 + headless --quit 통과 확인
- 매 사이클 완료 후 owner_core_workstream.md 갱신
```

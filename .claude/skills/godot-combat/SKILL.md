---
name: godot-combat
description: Use when implementing any spell, combat state, hit reaction, damage number, or mana mechanic in Dungeon Mage.
---

# godot-combat

Reference patterns for MapleStory/Skul-style combat in Dungeon Mage (Godot 4.6).  
**Read the actual files first** — all patterns here reflect the live implementation.

---

## 핵심 아키텍처

| 시스템 | 파일 | 역할 |
|--------|------|------|
| 플레이어 입력 + 물리 | `scripts/player/player.gd` | `_physics_process`, 스테이트 이벤트 발송 |
| 주문 시전 로직 | `scripts/player/spell_manager.gd` | 쿨다운, 마나 검사, `spell_cast` 시그널 발송 |
| 주문/스킬 런타임 계산 | `scripts/autoload/game_state.gd` | `get_spell_runtime()`, 버프 적용, 마나 차감 |
| 스프라이트 애니메이션 프레임 정의 | `scripts/enemies/enemy_base.gd` | `enemy_type` 기반 스프라이트 로딩 |
| 주문 기본 수치 | `data/spells.json` | 투사체 주문 전용 |
| 스킬 능력치 + 타입 | `data/skills/skills.json` | buff / deploy / toggle / passive |

---

## State Machine (Godot State Charts)

### 실제 구현 방식 — .tscn이 아닌 GDScript로 프로그래밍 방식 구성

```gdscript
# player.gd — _build_player_state_chart()로 런타임에 빌드
var state_chart = StateChartScript.new()
var _sc_root = CompoundStateScript.new()

# 상태 추가
func _add_player_state(state_label: String) -> Object:
    var st := AtomicStateScript.new()
    st.name = state_label
    _sc_root.add_child(st)
    ...
    return st

# 트랜지션 추가
func _add_player_transition(from_state, to_state, event: String) -> void:
    var t := TransitionScript.new()
    from_state.add_child(t)
    t.to = t.get_path_to(to_state)
    t.event = event

# 이벤트 발송
func _sc_send(event: String) -> void:
    if state_chart and is_node_ready():
        state_chart.send_event(event)
```

### 플레이어 스테이트 목록

```
Idle ↔ Walk
Idle/Walk/Jump/DoubleJump/Fall → Cast (cast_start) → Idle (cast_end)
Idle/Walk/Jump/DoubleJump/Fall/Cast/Dash → Hit (hit_taken) → Idle (hit_recovered)
* → Dead (player_died) → Idle (revived)
Idle/Walk → Jump (jumped) → Fall (peaked)
Jump/Fall → DoubleJump (double_jumped) → Fall (peaked)
Idle/Walk/Jump/DoubleJump/Fall → OnRope (rope_grabbed) → Fall (rope_released)
```

### 스테이트 이벤트 발송 예시

```gdscript
# 캐스트 상태 진입
_sc_send("cast_start")
await get_tree().create_timer(CAST_LOCK_TIME).timeout
_sc_send("cast_end")

# 피격 처리
_sc_send("hit_taken")
# hit_stun_timer 만료 후 hit_recovered 는 _tick_timers()에서 발송
```

---

## 주문 시전 흐름

```
Input.is_action_just_pressed(action)
  → spell_manager.attempt_cast_by_action(action)
      → attempt_cast(skill_id)
          → can_cast(skill_id)               # 마나·쿨다운·플레이어 상태 검사
          → GameState.get_spell_runtime(skill_id)   # 레벨 보정 포함 수치 딕셔너리
          → slot_cooldowns[skill_id] = runtime["cooldown"]
          → GameState.consume_skill_mana(skill_id)
          → GameState.register_spell_use(skill_id, school)
          → spell_cast.emit(payload)          # 투사체 스포너가 수신
```

### `get_spell_runtime()` 반환 딕셔너리 (game_state.gd)

```gdscript
# 스킬 레벨에 따라 보정된 수치를 딕셔너리로 반환
var runtime: Dictionary = GameState.get_spell_runtime(skill_id)
# 주요 키: "damage", "speed", "cooldown", "range", "knockback", "size", "duration", "school"
# 버프 런타임 수정자까지 포함되어 반환됨 (_apply_buff_runtime_modifiers 적용)
```

### `spell_cast` 페이로드 구조

```gdscript
var payload := runtime.duplicate(true)
payload["spell_id"] = skill_id
payload["position"] = player.global_position + Vector2(34 * player.facing, -18)
payload["velocity"] = Vector2(float(runtime["speed"]) * player.facing * speed_mult, 0.0)
payload["team"] = "player"
payload["owner"] = player
spell_cast.emit(payload)
```

---

## 스킬 타입별 패턴

### Active (투사체 — `data/spells.json` 사용)

```gdscript
# attempt_cast()가 자동 처리. 신규 투사체형 주문 추가 시:
# 1. data/spells.json에 항목 추가 (아래 형식)
# 2. spell_manager.gd slot_cooldowns 초기화 딕에 추가
# 3. game_state.gd DEFAULT_SPELL_HOTBAR / spell_mastery 에 추가 (있으면)
```

`data/spells.json` 항목 형식:
```json
{
  "fire_bolt": {
    "id": "fire_bolt",
    "name": "Fire Bolt",
    "school": "fire",
    "color": "#ff8f45",
    "damage": 14,
    "speed": 900,
    "range": 400,
    "cooldown": 0.32,
    "knockback": 240,
    "size": 16,
    "mastery_threshold": 4,
    "mastery_bonus": { "damage": 6, "speed": 80, "size": 3 }
  }
}
```

### Buff (`skill_type: "buff"` — `data/skills/skills.json` 사용)

```gdscript
# spell_manager가 skill_type == "buff" 를 감지 → GameState.try_activate_buff(skill_id)
# active_buffs는 Array (딕셔너리 아님):
GameState.active_buffs        # Array — 현재 활성 버프 목록
GameState.buff_cooldowns      # Dictionary — 버프별 쿨다운 float
GameState.get_buff_slot_limit()  # 현재 서클 기반 슬롯 한도
```

`data/skills/skills.json` buff 항목 형식:
```json
{
  "skill_id": "holy_mana_veil",
  "display_name": "Mana Veil",
  "skill_type": "buff",
  "element": "holy",
  "cooldown_base": 18.0,
  "duration_base": 10.0,
  "damage_formula": { "coefficient_base": 0.0, "flat_base": 0.0 }
}
```

### Deploy (설치형 — `skill_type: "deploy"`)

```gdscript
# spell_manager._cast_deploy() 호출
# 페이로드에 "duration", "size", "damage", "school" 포함
# position = player.global_position + Vector2(48 * player.facing, -4)
```

### Toggle (on-off 오라 — `skill_type: "toggle"`)

```gdscript
# active_toggles: Dictionary in spell_manager
# 첫 번째 호출 → 활성화; 두 번째 호출 → 비활성화
# _tick_toggles(delta): tick_interval마다 spell_cast.emit(payload) 발송 + 마나 소모
# 마나 고갈 시 자동 해제
active_toggles[skill_id] = {
    "tick_interval": ..., "tick_remaining": ...,
    "damage": ..., "size": ..., "mana_drain_per_tick": ...,
    "pierce": ..., "tags": [...], "school": ..., "color": ...
}
```

### Passive (`skill_type: "passive"`)

```gdscript
# 스킬 경험치가 threshold_bonuses에 도달하면 GameState에서 자동 적용
# 직접 코드 작성 불필요 — game_state.gd _apply_buff_runtime_modifiers()가 처리
```

---

## 마나 시스템

```gdscript
# 검사
GameState.has_enough_mana(skill_id)     # bool — 마나 부족 여부
GameState.consume_skill_mana(skill_id)  # bool — 차감 성공 여부 (실패 = 마나 부족)
GameState.consume_mana_amount(amount)   # bool — 직접 양 지정

# 상태
GameState.mana           # float — 현재 마나
GameState.max_mana       # float — 최대 마나 (BASE_MAX_MANA = 180.0)
GameState.mana_regen_per_second  # float — BASE = 14.0

# 어드민
GameState.admin_infinite_mana   # bool — 무한 마나 (테스트용)
```

---

## 마스터리 / 스킬 레벨

```gdscript
# 피해를 줄 때 경험치 등록 (spell_projectile.gd 등에서 호출)
GameState.register_skill_damage(spell_id, float(damage_amount))

# 현재 레벨 조회
var level: int = GameState.get_spell_level(skill_id)   # 또는 get_skill_level(skill_id)

# 런타임에 레벨 보정 수치 가져오기 (쿨다운·피해 자동 반영)
var runtime: Dictionary = GameState.get_spell_runtime(spell_id)
```

---

## 피격 / Hit Feel

### 플레이어 피격 (player.gd)

```gdscript
func receive_hit(amount: int, source: Vector2, knockback: float, _school: String = "", _utility_effects: Array = []) -> void:
    if invuln_timer > 0.0 or is_dead:
        return
    invuln_timer = IFRAME_TIME        # 무적 시간 (0.8s)
    hit_stun_timer = HIT_STUN_TIME    # 경직 시간 (0.18s)
    velocity = Vector2(push_dir * knockback * stagger_mult, -240.0)
    GameState.damage(amount, _school) # HP 차감 + 사망 판정
    _cam_shake_timer = 0.3
    _cam_shake_intensity = 8.0
    _sc_send("hit_taken")
```

### 카메라 쉐이크 (player.gd 내장)

```gdscript
# _cam_shake_timer / _cam_shake_intensity 로 직접 제어
# (PhantomCamera noise_emitted 신호가 아님)
_cam_shake_timer = 0.3
_cam_shake_intensity = 8.0
```

### 적 피격 (enemy_base.gd)

```gdscript
# receive_hit(amount, stagger_amount, knockback_dir) — enemy_base에 구현됨
# stagger_accumulator >= stagger_threshold 시 stagger 상태 진입
# has_super_armor_attack == true 면 공격 중 경직 무시
```

### 데미지 숫자 (enemy_base.gd)

```gdscript
# 시그널로 요청 — 스포너가 라벨 노드 생성
signal damage_label_requested(amount: int, position: Vector2, school: String)
damage_label_requested.emit(actual_damage, global_position, school)
```

---

## 적 공격 발사 패턴 (enemy_base.gd)

```gdscript
# 적 발사체는 fire_projectile 시그널로 발송 (instantiate 아님)
signal fire_projectile(payload: Dictionary)

func _fire_ranged_shot() -> void:
    if target == null:
        return
    var dir: Vector2 = (target.global_position - global_position).normalized()
    fire_projectile.emit({
        "position":  global_position + Vector2(0, -10),
        "velocity":  dir * 380.0,
        "damage":    contact_damage,
        "school":    "fire",
        "color":     projectile_color,
        "team":      "enemy",
        "knockback": 120.0,
        "size":      10.0,
        "duration":  3.0,
    })
```

---

## GUT 테스트 패턴

```gdscript
# tests/test_spell_manager.gd 실제 패턴
extends "res://addons/gut/test.gd"

func before_each() -> void:
    GameState.health = GameState.max_health
    GameState.reset_progress_for_tests()

func test_spell_starts_cooldown() -> void:
    var player = autofree(PLAYER_SCRIPT.new())
    var manager = SPELL_MANAGER_SCRIPT.new()
    manager.setup(player)
    assert_true(manager.attempt_cast("fire_bolt"))
    assert_gt(manager.get_cooldown("fire_bolt"), 0.0)

# 시그널 캡처 — 배열로 레퍼런스 타입 사용 (클로저 값 캡처 문제 방지)
func test_spell_emits_payload() -> void:
    var player = autofree(PLAYER_SCRIPT.new())
    var manager = SPELL_MANAGER_SCRIPT.new()
    manager.setup(player)
    var payloads: Array = []
    manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
    manager.attempt_cast("fire_bolt")
    assert_eq(payloads.size(), 1)
    assert_eq(str(payloads[0].get("spell_id", "")), "fire_bolt")

# bool 캡처 버그 — GDScript 클로저는 값 캡처 → bool 대신 Array[0] 사용
# WRONG:  var fired := false;  func(): fired = true
# CORRECT: var fired := [false]; func(): fired[0] = true
```

---

## 데이터 파일 위치

```
data/spells.json              ← active 투사체 주문 수치 (damage, speed, cooldown...)
data/skills/skills.json       ← 모든 스킬 정의 (buff/toggle/deploy/passive/mastery)
data/skills/buff_combos.json  ← 버프 조합 콤보 정의
data/enemies/enemies.json     ← 적 HP, 속도, 피해량, tint
data/items/equipment.json     ← 장비 아이템 정의
data/rooms.json               ← 룸 레이아웃 + 스폰 위치
```

---

## 과거 실수 방지

| 과거 버그 | 올바른 방식 |
|----------|-----------|
| `SpellResource` 클래스 참조 | 클래스 없음 — 딕셔너리 기반, `GameState.get_spell_runtime(id)` |
| `spell.projectile_scene.instantiate()` | `spell_cast.emit(payload)` 시그널 방식 |
| `$CooldownTimers` 노드 | `spell_manager.slot_cooldowns[id]: float` |
| `active_buffs[id] = {...}` 딕셔너리 | `active_buffs: Array` — `try_activate_buff(id)` 호출 |
| `spells.json`에 `scaling.damage_per_level` | `mastery_threshold` + `mastery_bonus` 구조 |
| `phantom_cam.noise_emitted.emit(trauma)` | `player._cam_shake_timer`, `_cam_shake_intensity` |
| 테스트에서 `var fired := false; func(): fired = true` | `var fired := [false]; func(): fired[0] = true` |
| State chart를 .tscn에 배치 | GDScript `_build_player_state_chart()` 에서 프로그래밍 방식으로 생성 |

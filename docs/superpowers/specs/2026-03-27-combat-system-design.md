---
title: 전투 시스템 설계 — Dungeon Mage
doc_type: archive
status: archived
section: implementation
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
update_when:
  - status_changed
  - structure_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 시스템 설계 — Dungeon Mage

**작성일:** 2026-03-27
**범위:** 스토리 제외, 전투 시스템 + 관리자 샌드박스 맵 완성
**상태:** 초기 설계 스냅샷. 현재 구현 기준은 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md) 를 우선한다.

## 현재 기준으로 폐기된 가정

- `SpellResource` 중심 스킬 구조
- `player_state_chart.tres` 같은 플레이어 상태 차트 리소스 필수 전제
- `scenes/player/Player.tscn` 별도 조립 전제
- `asset_sample/` 직접 런타임 참조

현재 구현은 `Dictionary` 기반 스킬 런타임, 런타임 조립 상태 차트, [`Main.tscn`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn) 중심 조립 구조, `assets/` 런타임 참조를 사용한다.

---

## 목표

스토리 없이 전투 시스템만 먼저 완성한다. 관리자 샌드박스 맵에서:
- 캐릭터 이동 및 전체 15개 스킬 사용 가능
- 스킬 레벨 조정, 몬스터 소환/제거, 무한 HP/MP/쿨타임, 아이템 지급
- 전투 UI 및 키 설정

이후 스토리(배경, NPC, 퀘스트)는 이 전투 시스템 위에 붙인다.

---

## 구현 접근 방식

**바텀업 (A):** 코어 시스템을 아래에서 위로 쌓는다.

```
① CharacterController   이동 + 입력 + 런타임 State Charts
② SpellRuntime          Dictionary 기반 스킬 계산 + 마나/쿨타임
③ EnemyBase             HP/히트박스 + AI State Charts + helper 분리
④ CombatHUD             HP/MP 바 + 스킬 슬롯 + 데미지 숫자
⑤ MainScene             Main.tscn 조립 + ESC 관리자 메뉴
```

---

## 파일 구조

### 수정
- `scripts/player/player.gd` — 더블점프, 로프, InputMap 등록 추가
- `scripts/enemies/enemy_base.gd` — 피격/사망 State Charts 확장
- `scripts/ui/game_ui.gd` — HP/MP 바 + 스킬 슬롯 + 쿨타임 오버레이
- `data/spells.json` — 15개 주문 전체 데이터

### 신규 생성
```
scripts/
  player/
    spell_manager.gd          ← 스킬 슬롯 관리, 시전, 쿨타임
  enemies/
    enemy_visual_library.gd   ← 적 비주얼/애니메이션 helper
    enemy_attack_profiles.gd  ← 적 AI/공격 프로필 helper
  autoload/
    combat_runtime_state.gd   ← 전투 런타임 상태 helper
    progression_save_state.gd ← 진행/저장 상태 helper
  ui/
    damage_label.gd           ← 데미지 숫자 팝업
  admin/
    admin_menu.gd             ← ESC 관리자 메뉴 (4탭)
scenes/
  main/
    Main.tscn                 ← 현재 메인 조립 씬
  ui/
    damage_label.tscn         ← 데미지 숫자 씬
tests/
  test_game_state.gd
  test_enemy_base.gd
  test_player_controller.gd
  test_main_integration.gd
```

---

## 섹션 1 — 캐릭터 컨트롤러

### 입력 맵핑 (InputMap)

| 액션 | 기본 키 | 비고 |
|------|---------|------|
| `move_left` | ← | 리매핑 가능 |
| `move_right` | → | 리매핑 가능 |
| `jump` | Alt | 더블점프도 동일 키 |
| `rope_up` | ↑ | 로프 위에서만 작동 |
| `rope_down` | ↓ | 로프 위에서만 작동 |
| `skill_z` ~ `skill_d` | Z X C A S D | 리매핑 가능 |
| `admin_menu` | Escape | 관리자 메뉴 토글 |

### State Charts 상태

```
Idle → Walk → Jump → DoubleJump → Fall
                              ↓
                          OnRope (↑키 감지 시)
Idle/Walk/Jump → Cast (스킬 시전)
Any → Hit (피격)
Any → Dead (HP=0)
```

### 이동 구현 핵심

**더블점프:**
```gdscript
var jump_count: int = 0  # 0=지상, 1=1단, 2=더블

func _on_jump_pressed():
    if jump_count < 2:
        velocity.y = JUMP_VELOCITY
        jump_count += 1
        if jump_count == 2:
            state_chart.send_event("double_jump")
        else:
            state_chart.send_event("jump")

func _on_landed():
    jump_count = 0
    state_chart.send_event("land")
```

**로프:**
- `RayCast2D` 하향 캐스트로 로프 오브젝트 감지
- ↑ 입력 시 `OnRope` 상태 진입 → `move_and_collide` 비활성화, 수직 이동만
- 로프에서 ← → 입력 시 로프 이탈

**플레이스홀더 에셋:** 원본 분석은 `asset_sample/` 에서 하고, 실제 런타임 참조는 `assets/player/` 로 복사한 뒤 사용한다.

---

## 섹션 2 — 스펠 시스템

### 폐기된 SpellResource 구상

```gdscript
class_name SpellResource
extends Resource

@export var id: String
@export var display_name: String
@export var icon: Texture2D
@export var type: String  # "active" | "buff" | "installation" | "onoff" | "passive"
@export var base_damage: float
@export var base_mana_cost: float
@export var base_cooldown: float
@export var scaling: Dictionary

func current_level() -> int:
    return GameState.skill_levels.get(id, 1)

func current_damage() -> float:
    return base_damage * pow(scaling.get("damage_per_level", 1.0), current_level() - 1)

func current_mana_cost() -> float:
    return base_mana_cost * pow(scaling.get("mana_cost_per_level", 1.0), current_level() - 1)

func current_cooldown() -> float:
    return base_cooldown * pow(scaling.get("cooldown_per_level", 1.0), current_level() - 1)
```

위 설계는 현재 구현 기준으로 사용하지 않는다. 실제 런타임은 `data/spells.json` + `GameState.get_spell_runtime(skill_id)` + `spell_manager.gd` 조합으로 계산된다.

### SpellManager

- `spell_slots` 는 데이터 기반 hotbar/runtime 조합으로 관리한다.
- `can_cast(spell)` — 마나 충분 + 쿨타임 없음 + Cast/Hit/Dead 상태 아님
- 마나 부족 시: MP 바 빨간색 0.3초 깜빡임
- 쿨타임 중: 슬롯 어두운 오버레이 + 남은 초 표시

### 15개 주문 (data/spells.json)

기본 10개 (Ember Dart, Frost Needle, Spark Step, Mana Veil, Shadow Bind, Flame Arc, Healing Pulse, Thunder Lance, Grave Echo, Crystal Aegis) + 고급 5개 (Inferno Sigil, Sanctuary of Reversal, Abyss Gate, Tempest Crown, Soul Dominion)

스케일링 공식: `base * pow(rate, level - 1)` — damage_per_level, mana_cost_per_level, cooldown_per_level

### 스킬 타입별 구현

| 타입 | 구현 방식 |
|------|----------|
| Active | 투사체/Area2D 씬 인스턴스화, 방향은 `sign($Sprite.scale.x)` |
| Buff | `active_buffs` Dictionary에 추가, Timer로 지속시간 관리 |
| Installation | 월드에 Node2D 배치, `lifetime` Timer 후 제거 |
| On-and-Off | `aura_active` bool 토글, Area2D monitoring 전환 |
| Passive | 레벨업 시점에만 `GameState.player_stats` 수정 |

---

## 섹션 3 — 적 AI

### PatrolEnemy (순찰 + 근접)

State Charts: `Idle → Patrol → Chase → Attack → Hit → Dead`

- **Patrol:** 좌우 왕복, 벽/절벽 감지 시 방향 전환 (`RayCast2D`)
- **Chase:** `Area2D`로 플레이어 감지 → 추격 (감지 범위 벗어나면 Patrol 복귀)
- **Attack:** 공격 범위(`Area2D`) 내 플레이어 → 근접 히트박스 활성화
- **Hit:** 피격 시 0.2초 경직, 빨간 깜빡임 (`modulate` 트윈)
- **Dead:** 사망 애니메이션 후 `queue_free()`

**플레이스홀더:** `asset_sample/Monster/` 에서 분석 후 `assets/monsters/` 로 복사해 런타임에서 사용

### RangedEnemy (원거리)

Chase까지 동일. Attack 상태에서 투사체 씬 인스턴스화하여 발사. 일정 거리 유지.

### 데미지 시스템

```gdscript
# enemy_base.gd
func take_damage(amount: float, source_pos: Vector2) -> void:
    current_hp -= amount
    spawn_damage_number(amount)
    trigger_hitstop(3)
    _flash_red()
    if current_hp <= 0:
        state_chart.send_event("die")
```

---

## 섹션 4 — 전투 HUD

### 레이아웃 (하단 바, 메이플 스타일)

```
[HP ████████░░ 360/500]  [MP ██████████ 90/100]   [🔥Z] [❄X] [⚡C] [🛡A] [🌑S] [🔥D]
```

- HP 바: 빨강 (#ef4444), 피격 시 흰색 플래시 후 감소
- MP 바: 파랑 (#3b82f6), 마나 부족 시 빨간색 깜빡임
- 스킬 슬롯: 아이콘 + 키 라벨 + 쿨타임 어두운 오버레이 + 남은 시간(초)

### 데미지 숫자

- CanvasLayer 위에 Label 생성
- 0.6초 동안 40px 위로 이동 + 알파 0으로 페이드
- 색상: 일반 피해 흰색, 크리티컬 노랑, 자신이 받은 피해 빨강

---

## 섹션 5 — 관리자 씬 + ESC 메뉴

### 샌드박스 맵 (`admin_map.tscn`)

- 평지 아레나 + 발판 몇 개 + 로프 오브젝트
- TileMap 기반으로 구성하되, 이번 기준선에서는 `GandalfHardcore FREE Platformer Assets` 의 흙 배경 + 지형 타일 조합을 우선 사용한다.
- 배경 플레이스홀더 수준으로 두지 않고, 아래 6개 PNG를 `admin_map.tscn` 의 기준 배경/지형 소스로 고정한다.
  - 배경 루프용: `BG Dirt1.png`, `BG Dirt2.png`
  - 주 지형용: `Floor Tiles1.png`, `Floor Tiles2.png`
  - 보조 지형/발판/경사면용: `Other Tiles1.png`, `Other Tiles2.png`
- 원본 분석은 `asset_sample/Background/GandalfHardcore FREE Platformer Assets/` 에서 하되, 실제 런타임 연결은 반드시 `assets/background/gandalf_hardcore/` 아래로 복사한 리소스만 사용한다.

### 샌드박스 맵 비주얼 기준선

- `BG Dirt1.png` 와 `BG Dirt2.png` 는 `TileMap` 지형 소스가 아니라, 카메라 뒤에서 반복되는 `Sprite2D` 또는 `TextureRect` 배경 레이어로 사용한다.
- 두 배경은 한 장만 고정하지 않고 `좌우 반복 + 교차 배치`를 기본으로 삼아, 넓은 평지 구간에서도 검은 빈칸이 보이지 않게 한다.
- `Floor Tiles1.png`, `Floor Tiles2.png` 는 충돌이 있는 메인 지면 블록 세트로 사용한다.
- `Other Tiles1.png`, `Other Tiles2.png` 는 경사면, 얇은 발판, 보조 블록, 가장자리 변형을 담당한다.
- 배경과 충돌 지형을 한 레이어에 섞지 않는다.
  - 배경: 충돌 없음
  - 지면/발판: 충돌 있음
  - 장식: 충돌 없음 또는 선택적 충돌

### 샌드박스 맵 레이어 구조

- `ParallaxBackground` 또는 배경 전용 `Node2D`
  - `BG Dirt1`, `BG Dirt2` 반복 배치
- `TileMapLayer_Ground`
  - `Floor Tiles1`, `Floor Tiles2` 기반 메인 평지
- `TileMapLayer_Support`
  - `Other Tiles1`, `Other Tiles2` 기반 경사면, 공중 발판, 가장자리 마감
- `Collision` 은 플레이 테스트 우선 기준으로 단순화한다.
  - 큰 사각형 지면
  - 짧은 공중 발판
  - 경사면 진입 구간

### 샌드박스 맵 적용 규칙

- `Floor Tiles1` 과 `Floor Tiles2` 는 계절/색상 변형처럼 섞어 쓰지 않고, 같은 화면 안에서는 한 팔레트를 주력으로 쓰고 다른 한 세트는 구역 구분이나 변형 포인트에만 제한적으로 사용한다.
- `Other Tiles1` 과 `Other Tiles2` 의 경사면은 플레이어 이동 테스트 구간에 우선 배치한다.
- 공중 발판은 얇은 플랫폼 실루엣이 잘 읽히는 `Other Tiles` 계열을 우선 사용한다.
- 맵의 핵심은 `예쁜 배경`보다 `전투 가독성` 이다.
  - 바닥 외곽선, 낙하 가능 지점, 발판 끝점이 플레이 중 즉시 보여야 한다.
  - 스킬 이펙트와 몬스터 실루엣이 묻히지 않도록 지나치게 복잡한 배경 중첩은 피한다.

### ESC 메뉴 (4탭, CanvasLayer)

**스킬 탭:**
- 15개 주문 목록
- 각 주문: 이름 + 현재 레벨 표시 + 슬라이더(1~30) + 슬롯 배정 드롭다운(Z/X/C/A/S/D/미배정)

**몬스터 탭:**
- PatrolEnemy / RangedEnemy 소환 버튼 (마우스 클릭 위치에 스폰)
- 전체 몬스터 제거 버튼

**자원 탭:**
- 무한 HP 토글 (체력이 0이 되면 즉시 풀 회복)
- 무한 MP 토글 (마나 소비 없음)
- 무한 쿨타임 토글 (쿨타임 즉시 리셋)
- HP/MP 즉시 풀 회복 버튼

**설정 탭:**
- 키 리매핑 (각 액션 클릭 후 원하는 키 입력)
- 볼륨 슬라이더
- 해상도 선택

### ESC 토글

```gdscript
# admin_menu.gd
func _unhandled_input(event):
    if event.is_action_pressed("admin_menu"):
        visible = !visible
        get_tree().paused = visible
```

---

## 검증 체크포인트 (각 단계마다)

| 단계 | GUT 테스트 | 헤드리스 체크 | 수동 확인 항목 |
|------|-----------|-------------|-------------|
| ① 캐릭터 | 더블점프 횟수, 로프 상태 전환 | `--quit-after 120` | 이동감, 더블점프 타이밍 |
| ② 스펠 | 마나 차감, 쿨타임, 스케일링 공식 | 오류 없음 | 스킬 발동, 투사체 방향 |
| ③ 적 AI | 피격 데미지, 사망 처리 | 오류 없음 | 순찰→추격→공격 전환 |
| ④ HUD | HP/MP 바 수치 동기화 | 오류 없음 | 쿨타임 오버레이 표시 |
| ⑤ 관리자 | 스킬 레벨 변경 반영 | 오류 없음 | ESC 메뉴 전 탭 동작 |

---

## 비목표 (이번 범위 밖)

- 스토리, NPC, 퀘스트
- 세이브/로드 시스템
- 사운드 이펙트 (추후)
- 8~10서클 마법 실제 구현 (데이터만 준비, 실행은 미구현)
- 스팀 연동

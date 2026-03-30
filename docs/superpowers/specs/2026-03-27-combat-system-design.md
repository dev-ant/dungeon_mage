# 전투 시스템 설계 — Dungeon Mage

**작성일:** 2026-03-27
**범위:** 스토리 제외, 전투 시스템 + 관리자 샌드박스 맵 완성

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
① CharacterController   이동 + 입력 + State Charts
② SpellSystem           SpellResource + 5가지 타입 + 마나/쿨타임
③ EnemyBase             HP/히트박스 + AI State Charts
④ CombatHUD             HP/MP 바 + 스킬 슬롯 + 데미지 숫자
⑤ AdminScene            샌드박스 맵 + ESC 관리자 메뉴
```

---

## 파일 구조

### 수정
- `scripts/player/player.gd` — 더블점프, 로프, InputMap 등록 추가
- `scripts/enemies/enemy_base.gd` — 피격/사망 State Charts 확장
- `scripts/ui/combat_hud.gd` — HP/MP 바 + 스킬 슬롯 + 쿨타임 오버레이
- `data/spells.json` — 15개 주문 전체 데이터

### 신규 생성
```
scripts/
  player/
    spell_manager.gd          ← 스킬 슬롯 관리, 시전, 쿨타임
    spells/
      spell_resource.gd       ← SpellResource 클래스 (computed stats)
  enemies/
    enemy_patrol.gd           ← 순찰+근접 AI
    enemy_ranged.gd           ← 원거리 투사체 AI
  ui/
    damage_label.gd           ← 데미지 숫자 팝업
  admin/
    admin_menu.gd             ← ESC 관리자 메뉴 (4탭)
scenes/
  admin/
    admin_map.tscn            ← 샌드박스 맵
  ui/
    damage_label.tscn         ← 데미지 숫자 씬
tests/
  test_spell_system.gd
  test_enemy_base.gd
  test_character.gd
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

**플레이스홀더 에셋:** `asset_sample/Character/Soldier/Soldier with shadows/` 스프라이트 사용. `asset-import` 스킬로 분석 후 적용.

---

## 섹션 2 — 스펠 시스템

### SpellResource 클래스

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

### SpellManager

- `spell_slots: Array[SpellResource]` — 6개 슬롯 (Z/X/C/A/S/D)
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

**플레이스홀더:** `asset_sample/Monster/` 내 에셋 사용

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
- TileMap으로 간단 구성 (던전 타일셋)
- 배경 플레이스홀더: `asset_sample/Background/` 던전 배경

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

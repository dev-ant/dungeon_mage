---
title: 스킬 데이터 스키마
doc_type: schema
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - schema_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 스킬 데이터 스키마

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 성장 시스템

## 범위

이 문서는 액티브, 버프, 설치, 온앤오프, 패시브 마스터리 스킬을 실제 데이터 파일로 옮길 때 사용하는 기준 스키마 문서입니다. 이후 `skills.json` 같은 게임 데이터 파일을 만들 때 이 문서를 우선 기준으로 삼습니다.

최신 스킬 기획 이름과 속성/서클 기준은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 우선합니다.

구현 여부, asset 적용 여부, attack/hit effect 적용 여부, 레벨 스케일 적용 여부는 런타임 데이터 필드가 아니라 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에서 관리합니다.

## 소스 오브 트루스 관계

- 최신 기획:
  - 스킬 이름, 속성, 서클, 컨셉, 목표 경험은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 따른다.
- 실제 런타임 사실:
  - 현재 실제로 동작하는 JSON 키 사용 방식과 runtime 해석은 코드와 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)를 따른다.
- 이 문서의 역할:
  - 이 문서는 `데이터 형식 문서`다.
  - 필드 구조, canonical `skill_id` 규칙, enum-like 허용값, JSON 작성 규칙만 정의한다.
  - 이 문서는 최신 기획 이름이나 구현 상태를 새로 정의하지 않는다.
- 상태 추적:
  - 구현 / asset / attack effect / hit effect / 레벨 스케일 상태는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에서만 관리한다.
- 충돌 처리:
  - 스키마와 최신 기획이 다르면 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 먼저 맞춘다.
  - 스키마와 실제 코드가 다르면 코드를 먼저 확인하고, 이후 이 문서를 맞춘다.
  - 충돌 상세 규칙은 [README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md)의 `우선순위 규칙`을 따른다.

## 설계 목표

- 문서에 있는 마법 정보를 Godot 데이터 파일로 바로 옮길 수 있어야 합니다.
- 스킬 종류가 달라도 공통 필드는 최대한 통일합니다.
- 계산식은 숫자 필드로 쪼개 저장해, 런타임에서 조합 계산할 수 있게 합니다.
- 버프 조합, 서클 승급, 마스터리 보너스와 연결 가능한 구조여야 합니다.

## 데이터 파일 권장 구조

- `res://data/skills/skills.json`
- 최상위는 스킬 객체 배열 또는 `skills` 키를 가진 객체를 권장합니다.
- 각 스킬은 고유 `skill_id`를 가져야 합니다.
- 최신 기획 기준의 canonical 식별자를 별도로 유지해야 할 때는 `canonical_skill_id`를 함께 둡니다.

## 스킬 ID 규칙

### 기본 형식

`[계열]_[이름]`

### 권장 규칙

- 영문 소문자만 사용합니다.
- 단어 구분은 `_`를 사용합니다.
- 띄어쓰기, 하이픈, 한글은 사용하지 않습니다.
- 이름이 길어도 축약하지 말고 의미가 분명하게 유지되도록 합니다.

### 예시

| 문서 이름 | 권장 skill_id |
| --- | --- |
| 파이어 볼트 | `fire_bolt` |
| 워터 불릿 | `water_bullet` |
| 마나 베일 | `holy_mana_veil` |
| 그레이브 팩트 | `dark_grave_pact` |
| 매직 마스터리 | `arcane_magic_mastery` |
| 다크 매직 마스터리 | `dark_magic_mastery` |

### 전환기 규칙

- 장기적으로는 `skill_id`와 canonical 식별자가 같아지는 구조를 목표로 합니다.
- 다만 기존 runtime ID와 최신 기획 식별자가 아직 다를 때는 아래처럼 관리합니다.
  - `skill_id`: 현재 데이터 row의 실제 키
  - `canonical_skill_id`: 최신 기획 기준의 장기 식별자
- `canonical_skill_id`가 없으면 `skill_id`를 canonical 값으로 간주합니다.

## 관리 enum

아래 값들은 Java의 `enum`처럼 고정된 허용값으로 관리합니다. 새 값을 추가할 때는 이 문서와 runtime 해석 코드를 같이 갱신합니다.

### `school`

| 값 | 의미 |
| --- | --- |
| `elemental` | 기본 속성군과 서브 속성군 전투 스킬 |
| `white` | 백마법 |
| `black` | 흑마법 |
| `arcane` | 아케인 / 재분류 대기 축 |

### `element`

| 값 | 의미 |
| --- | --- |
| `fire` | 불 |
| `water` | 물 |
| `wind` | 바람 |
| `earth` | 대지 |
| `lightning` | 전기 |
| `ice` | 얼음 |
| `plant` | 자연(풀) |
| `holy` | 백마법 |
| `dark` | 흑마법 |
| `arcane` | 아케인 |
| `none` | 무속성 / 순수 시스템성 효과 |

### `skill_type`

| 값 | 의미 |
| --- | --- |
| `active` | 직접 시전 액티브 |
| `deploy` | 설치형 |
| `toggle` | 유지형 온오프 |
| `buff` | 버프형 |
| `passive` | 패시브형 |

### `hit_shape`

| 값 | 의미 |
| --- | --- |
| `projectile` | 기본 투사체 |
| `line` | 직선형 / 관통형 |
| `cone` | 전방 부채꼴 |
| `circle` | 원형 범위 |
| `aura` | 오라 / 주변 지속형 |
| `wall` | 벽 / 장벽형 |

### `unlock_state`

| 값 | 의미 |
| --- | --- |
| `starter` | 시작부터 사용 가능 |
| `story` | 스토리 진행 해금 |
| `boss` | 보스 보상 해금 |
| `record` | 기록/업적 해금 |
| `late_game` | 후반 전용 해금 |

## 공통 필드

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| skill_id | string | 내부 식별자 |
| canonical_skill_id | string | 선택 필드. 최신 기획 기준의 장기 식별자 |
| display_name | string | UI 표시 이름 |
| circle | int | 요구 서클 |
| school | string | `elemental`, `white`, `black`, `arcane` 등 |
| element | string | `fire`, `water`, `ice`, `lightning`, `wind`, `earth`, `plant`, `dark`, `holy`, `arcane`, `none` |
| skill_type | string | `active`, `passive`, `buff`, `toggle`, `deploy` |
| role_tags | array[string] | 단일 대상, 광역, 생존, 폭딜, 설치 등 |
| description | string | 한 줄 설명 |
| max_level | int | 기본 30 |
| growth_tracks | array[string] | 레벨에 따라 증가하는 항목 |
| unlock_state | string | `starter`, `story`, `boss`, `record`, `late_game` |

## 전투형 스킬 필드

액티브, 설치, 온앤오프, 일부 공격형 버프는 아래 필드를 사용합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| mana_cost_base | float | 기본 마나 소모 |
| cooldown_base | float | 기본 쿨타임 |
| cast_time | float | 캐스팅 시간 |
| hit_shape | string | `projectile`, `line`, `cone`, `circle`, `aura`, `wall` |
| range_base | float | 사거리 또는 반경 |
| duration_base | float | 지속시간, 없으면 0 |
| target_count_base | int | 기본 대상 수 |
| pierce_count_base | int | 기본 관통 수 |
| projectile_count_base | int | 기본 투사체 수 |
| tick_interval | float | 지속형 틱 간격 |
| damage_formula | object | 피해 계산 데이터 |
| utility_effects | array[object] | 둔화, 넉백, 구속, 상태이상 |

## 피해 계산 필드

`damage_formula` 객체는 아래 구조를 권장합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| coefficient_base | float | 기본 마법 공격력 계수 |
| coefficient_per_level | float | 레벨당 계수 증가 |
| flat_base | float | 기본 고정 가산치 |
| flat_per_level | float | 레벨당 고정 가산 증가 |
| formula_type | string | `hit`, `tick`, `heal`, `shield` |

예시:

```json
{
  "damage_formula": {
    "formula_type": "hit",
    "coefficient_base": 1.05,
    "coefficient_per_level": 0.025,
    "flat_base": 12,
    "flat_per_level": 2
  }
}
```

## 성장 필드

레벨 상승에 따라 지속시간, 범위, 대상 수 같은 값이 달라질 수 있으므로 공통 구조를 둡니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| mana_reduction_per_level | float | 레벨당 마나 감소율 |
| cooldown_reduction_per_level | float | 레벨당 쿨감율 |
| duration_scale_per_level | float | 레벨당 지속시간 증가율 |
| range_scale_per_level | float | 레벨당 범위 증가율 |
| milestone_bonuses | array[object] | 특정 레벨 도달 보너스 |

`milestone_bonuses` 예시:

```json
[
  { "level": 10, "stat": "target_count", "value": 1 },
  { "level": 20, "stat": "target_count", "value": 1 },
  { "level": 30, "stat": "target_count", "value": 1 }
]
```

## 버프 스킬 전용 필드

`skill_type = buff`일 때 아래 필드를 추가합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| buff_category | string | `defense`, `offense`, `tempo`, `ritual`, `utility` |
| stackable | bool | 동일 버프 중복 가능 여부 |
| stack_rule_id | string | 중첩 효율 규칙 ID |
| buff_effects | array[object] | 버프 효과 목록 |
| downside_effects | array[object] | 종료 후 반동 또는 유지 페널티 |
| combo_tags | array[string] | 버프 조합 판정용 태그 |

`buff_effects` 예시:

```json
[
  { "stat": "damage_taken_multiplier", "mode": "mul", "value": 0.82 },
  { "stat": "poise_bonus", "mode": "add", "value": 25 }
]
```

## 패시브 마스터리 전용 필드

`skill_type = passive`일 때 아래 필드를 추가합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| passive_family | string | `mastery` |
| applies_to_school | string | 적용 계열 |
| applies_to_element | string | 적용 속성 |
| final_multiplier_per_level | float | 레벨당 최종 배수 증가 |
| threshold_bonuses | array[object] | 5,10,15... 구간 보너스 |

`threshold_bonuses` 예시:

```json
[
  { "level": 5, "effect": "mana_cost_reduction", "value": 0.02 },
  { "level": 10, "effect": "cooldown_reduction", "value": 0.03 }
]
```

## 예시 스킬 데이터

### 파이어 볼트

```json
{
  "skill_id": "fire_ember_dart",
  "canonical_skill_id": "fire_bolt",
  "display_name": "파이어 볼트",
  "circle": 1,
  "school": "elemental",
  "element": "fire",
  "skill_type": "active",
  "role_tags": ["projectile", "starter", "single_target"],
  "description": "빠르게 발사하는 화염 탄환",
  "max_level": 30,
  "unlock_state": "starter",
  "mana_cost_base": 8,
  "cooldown_base": 0.42,
  "cast_time": 0.0,
  "hit_shape": "projectile",
  "range_base": 420,
  "duration_base": 0,
  "target_count_base": 1,
  "pierce_count_base": 0,
  "projectile_count_base": 1,
  "tick_interval": 0,
  "damage_formula": {
    "formula_type": "hit",
    "coefficient_base": 1.00,
    "coefficient_per_level": 0.022,
    "flat_base": 10,
    "flat_per_level": 2
  },
  "mana_reduction_per_level": 0.006,
  "cooldown_reduction_per_level": 0.0045,
  "duration_scale_per_level": 0.0,
  "range_scale_per_level": 0.008,
  "milestone_bonuses": [
    { "level": 10, "stat": "projectile_speed", "value": 12 },
    { "level": 20, "stat": "projectile_speed", "value": 12 },
    { "level": 30, "stat": "projectile_speed", "value": 12 }
  ]
}
```

### Mana Veil

```json
{
  "skill_id": "holy_mana_veil",
  "canonical_skill_id": "holy_mana_veil",
  "display_name": "마나 베일",
  "circle": 2,
  "school": "white",
  "element": "holy",
  "skill_type": "buff",
  "role_tags": ["defense", "stability"],
  "description": "짧은 피해 감소와 경직 안정화를 부여",
  "max_level": 30,
  "unlock_state": "starter",
  "mana_cost_base": 16,
  "cooldown_base": 24.0,
  "cast_time": 0.0,
  "duration_base": 4.0,
  "stackable": true,
  "stack_rule_id": "default_diminishing_buff",
  "buff_category": "defense",
  "buff_effects": [
    { "stat": "damage_taken_multiplier", "mode": "mul", "value": 0.82 },
    { "stat": "poise_bonus", "mode": "add", "value": 20 }
  ],
  "downside_effects": [],
  "combo_tags": ["veil", "guard"],
  "mana_reduction_per_level": 0.006,
  "cooldown_reduction_per_level": 0.0045,
  "duration_scale_per_level": 0.01,
  "range_scale_per_level": 0.0,
  "milestone_bonuses": [
    { "level": 12, "stat": "shockwave_on_break", "value": 1 }
  ]
}
```

## 구현 메모

- 최신 이름/속성/서클/컨셉은 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)를 따른다.
- 구현/asset/effect/레벨 스케일 상태는 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)를 따른다.
- 실제 계산식은 [skill_level_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_level_rules.md)를 우선합니다.
- 서클 판정은 [circle_progression.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/circle_progression.md)를 따릅니다.
- 버프 조합은 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)의 `required_buffs`와 연결합니다.

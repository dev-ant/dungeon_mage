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
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_role_tag_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_growth_track_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_category_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_stack_rule_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_tag_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - schema_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 스킬 데이터 스키마

상태: 사용 중  
최종 갱신: 2026-04-07  
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
- 태그 / 성장축 의미:
  - `role_tags`의 현재 운영 목록과 의미는 [skill_role_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_role_tag_catalog.md)를 따른다.
  - `growth_tracks`의 현재 운영 목록과 의미는 [skill_growth_track_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_growth_track_catalog.md)를 따른다.
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

## 데이터 파일 구조

- `res://data/skills/skills.json`
- 현재 운영 기준에서 최상위는 반드시 `{"skills": [...]}` 형태의 객체입니다.
- 로드 시점 validator도 `Dictionary` 루트와 `skills` 배열 필드를 전제로 동작합니다.
- 각 스킬은 고유 `skill_id`를 가져야 합니다.
- 현재 운영 기준에서 모든 row는 `canonical_skill_id`를 명시합니다.

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
- 2026-04-03 현재 운영 기준에서는 `canonical_skill_id`를 생략하지 않습니다.
- row key와 canonical 값이 같더라도 `canonical_skill_id`를 명시해 alias / migration / validation 기준을 하나로 유지합니다.

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

비고:

- `element = none`은 `skills.json` row에서만 허용합니다.
- 의도는 무속성 버프, 시스템성 패시브, 비전투 utility row 같은 `비속성 스킬 표현`입니다.
- 현재 `spells.json`의 runtime `school`은 실제 시전 school 계약이므로 `none`을 허용하지 않습니다.

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
| canonical_skill_id | string | 필수 필드. 최신 기획 기준의 장기 식별자 |
| display_name | string | UI 표시 이름 |
| circle | int | 요구 서클 |
| school | string | `elemental`, `white`, `black`, `arcane` 등 |
| element | string | `fire`, `water`, `ice`, `lightning`, `wind`, `earth`, `plant`, `dark`, `holy`, `arcane`, `none` |
| skill_type | string | `active`, `passive`, `buff`, `toggle`, `deploy` |
| role_tags | array[string] | 현재 운영 태그 목록은 `skill_role_tag_catalog.md`를 따른다 |
| description | string | 한 줄 설명 |
| max_level | int | 기본 30 |
| growth_tracks | array[string] | 현재 운영 성장축 목록은 `skill_growth_track_catalog.md`를 따른다 |
| unlock_state | string | `starter`, `story`, `boss`, `record`, `late_game` |

## 현재 로드 시점 hardening 범위

- 모든 skill row는 `canonical_skill_id`, `role_tags`, `growth_tracks`, `unlock_state`를 가져야 합니다.
- `role_tags`, `growth_tracks`, `combo_tags`는 현재 `array[string]` 구조까지 로드 시점에 검증합니다.
- `active`, `deploy`, `toggle` row는 `hit_shape`를 명시해야 합니다.
- `buff` row는 `buff_category`, `stack_rule_id`, `combo_tags`를 명시해야 합니다.
- `damage_cadence_reference_interval`를 쓰는 `deploy` / `toggle` / `active` row는 numeric 값만 허용합니다.
- `lightning_conductive_surge.extra_lightning_ping`, `ice_frostblood_ward.ice_reflect_wave`처럼 후속 payload를 발사하는 buff row는 같은 `buff_effects` 안에 `*_effect_id`, `*_damage_ratio`, `*_radius`, `*_school`, `*_color` companion entry를 `mode = set`으로 함께 명시해야 합니다.
- `dark_throne_of_ash`는 solo ash residue gate를 담당하므로, `buff_effects` 안에 `ash_residue_burst`를 `mode = add`, 양수 numeric value로 유지해야 합니다.
- `role_tags` 허용 후보는 [skill_role_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_role_tag_catalog.md), `growth_tracks` 허용 후보는 [skill_growth_track_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/skill_growth_track_catalog.md), `combo_tags` 허용 후보는 [buff_combo_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_tag_catalog.md)를 기준으로 관리합니다.
- open tag 성격의 `role_tags`, `growth_tracks`, `combo_tags`는 현재 `구조`만 hard validation하고, whitelist enum lock은 catalog 정리가 끝난 뒤 후속 증분으로 남깁니다.
- 2026-04-03 후속 hardening부터 `role_tags`, `growth_tracks`, `combo_tags`는 catalog 바깥 값이 들어오면 load 시점 `warning`을 남깁니다. 아직 `error`로 승격하지는 않습니다.

## 전투형 스킬 필드

액티브, 설치, 온앤오프, 일부 공격형 버프는 아래 필드를 사용합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| mana_cost_base | float | 기본 마나 소모 |
| cooldown_base | float | 기본 쿨타임. active row가 primary runtime spell을 가지면 `spells.json.cooldown`과 같은 값으로 mirror 유지 |
| cast_time | float | 캐스팅 시간 |
| hit_shape | string | `projectile`, `line`, `cone`, `circle`, `aura`, `wall` |
| range_base | float | 사거리 또는 반경 |
| duration_base | float | 지속시간, 없으면 0 |
| target_count_base | int | 기본 대상 수 |
| pierce_count_base | int | 기본 관통 수 |
| projectile_count_base | int | 기본 투사체 수 |
| tick_interval | float | 지속형 틱 간격 |
| damage_cadence_reference_interval | float | cadence를 빠르게 조정할 때 총합 피해 보존 기준으로 삼는 이전 tick 간격 |
| damage_formula | object | 피해 계산 데이터 |
| utility_effects | array[object] | 둔화, 넉백, 구속, 상태이상 |

비고:

- `damage_cadence_reference_interval`는 현재 `GameState.build_data_driven_skill_base_runtime()`이 읽는 optional field입니다.
- 목적은 `tick_interval`을 더 촘촘하게 바꿔도 `min(duration, 3.0초)` 체감 구간의 총합 피해가 과도하게 폭증하지 않게 하는 것입니다.
- 현재 운영 기준에서는 공격 `deploy` / `toggle` cadence 재조정 턴에만 사용하고, 장비 cast speed bonus에는 적용하지 않습니다.
- active row는 runtime source of truth가 `spells.json`이므로, linked `skills.json.cooldown_base`는 UI / 문서용 mirror field로만 유지하고 `GameDatabase.validate_skill_spell_link()`가 primary runtime spell cooldown과 equality를 강제합니다.

## active runtime spell row 추가 필드

- `skills.json` row 외에 `data/spells.json` runtime spell row도 active cast source of truth로 함께 관리합니다.
- 2026-04-07 기준 active runtime spell row는 아래 optional field를 추가로 가질 수 있습니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| multi_hit_count | int | active 1회 적중이 같은 대상에게 적용하는 총 hit 수 |
| hit_interval | float | 같은 대상에게 후속 hit가 들어가는 간격 |

비고:

- active cast payload는 이 필드를 그대로 싣고 1회만 emit하며, 실제 소비는 `/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_projectile.gd`의 on-hit sequence가 담당합니다.
- `multi_hit_count`는 `1` 이상이어야 하고, `hit_interval`는 numeric 값이어야 합니다.

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
| knockback_scale_per_level | float | 레벨당 밀쳐내기 증가율 |
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
| buff_category | string | 버프 운영 카테고리. 현재 운영 closed 목록은 `buff_category_catalog.md`를 따른다 |
| stackable | bool | 동일 버프 중복 가능 여부 |
| stack_rule_id | string | 중첩 효율 규칙 ID. 현재 운영 closed 목록은 `buff_stack_rule_catalog.md`를 따른다 |
| buff_effects | array[object] | 버프 효과 목록 |
| downside_effects | array[object] | 종료 후 반동 또는 유지 페널티 |
| combo_tags | array[string] | 버프 조합 판정용 태그. 현재 운영 목록은 `buff_combo_tag_catalog.md`를 따른다 |

현재 `buff_category`는 [buff_category_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_category_catalog.md)의 관리 ID만 사용합니다. 이 필드는 open tag가 아니라 closed enum처럼 관리하며, catalog 밖 값은 로드 시점 `error`입니다.

현재 `stack_rule_id`는 [buff_stack_rule_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_stack_rule_catalog.md)의 관리 ID만 사용합니다. 이 필드는 open tag가 아니라 closed enum처럼 관리하며, catalog 밖 값은 로드 시점 `error`입니다.

### 버프 row 작성 체크리스트

- `buff_category`는 버프의 대표 전투 역할 하나만 고릅니다. 다목적 버프여도 주된 체감 축을 기준으로 고정합니다.
- buff row는 `buff_category`와 같은 값을 `role_tags`에도 포함해, 대표 역할이 검색/요약 축에서도 바로 드러나게 합니다.
- `stack_rule_id`는 현재 closed catalog 중 하나를 그대로 사용합니다. 새 규칙 이름이 필요하면 문서와 runtime validator를 같은 턴에 같이 갱신합니다.
- `combo_tags`는 named combo를 그대로 복붙하지 말고, 속성/기능 힌트를 `1~3`개 정도로 고릅니다.
- `buff_category`, `stack_rule_id`는 catalog 밖 값이 들어오면 load 시점 `error`입니다.
- `combo_tags`는 현재 `array[string]` 구조를 hard validation하고, catalog 밖 값은 `warning-only` drift check로 알립니다.
- `dark_throne_of_ash`의 `ash_residue_burst`는 open flavor tag가 아니라 현재 runtime trigger flag입니다. 이 row에서 빠지거나 타입/모드가 바뀌면 solo residue contract가 깨지므로 load 시점 `error`로 막습니다.
- 버프의 named combo 조건까지 바뀌면 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)도 같은 턴에 같이 갱신합니다.

`buff_effects` 예시:

```json
[
  { "stat": "damage_taken_multiplier", "mode": "mul", "value": 0.82 },
  { "stat": "poise_bonus", "mode": "add", "value": 25 }
]
```

후속 effect payload authored 예시:

```json
[
  { "stat": "extra_lightning_ping", "mode": "add", "value": 1 },
  { "stat": "lightning_ping_effect_id", "mode": "set", "value": "lightning_ping" },
  { "stat": "lightning_ping_damage_ratio", "mode": "set", "value": 0.45 },
  { "stat": "lightning_ping_radius", "mode": "set", "value": 52.0 },
  { "stat": "lightning_ping_school", "mode": "set", "value": "lightning" },
  { "stat": "lightning_ping_color", "mode": "set", "value": "#a8c8ff" }
]
```

## 패시브 마스터리 전용 필드

`skill_type = passive`일 때 아래 필드를 추가합니다.

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| passive_family | string | `mastery` |
| applies_to_school | string | 적용 계열 |
| applies_to_element | string | 적용 속성 |
| final_multiplier_per_level | float | mastery의 레벨당 최종 피해 증가. 이 값은 row authored source를 그대로 따른다. 현재 `fire_mastery`는 `0.05`, `water/ice/lightning/wind/earth/plant/dark` mastery는 `0.004`, `arcane_magic_mastery`는 `0.003`을 사용한다 |
| threshold_bonuses | array[object] | `5/10/15/20/25/30` milestone마다 열리는 고정 보너스. `damage`, `mana_cost_reduction`, `cooldown_reduction` 계열 effect를 허용한다 |

`threshold_bonuses` 예시:

```json
[
  { "level": 5, "effect": "final_damage_bonus", "value": 0.05 },
  { "level": 10, "effect": "mana_cost_reduction", "value": 0.02 },
  { "level": 15, "effect": "cooldown_reduction", "value": 0.03 }
]
```

추가 규칙:

- 일반 mastery(`fire`/`water`/`ice`/`lightning`/`wind`/`earth`/`plant`/`dark`)는 해당 school의 `active / deploy / toggle` 전부에 적용합니다.
- mastery 계산은 `mastery -> 장비/버프/공명 등 다른 최종 배수` 순서로 적용합니다.
- `arcane_magic_mastery`는 예외적으로 모든 마법 스킬 사용으로 숙련도가 오르며, 모든 속성 스킬에 적용합니다.

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
  "knockback_scale_per_level": 0.01,
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

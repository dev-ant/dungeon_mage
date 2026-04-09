---
title: 몬스터 데이터 스키마
doc_type: schema
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - schema_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 몬스터 데이터 스키마

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 성장 시스템 / 몬스터 데이터 스키마

## 목적

이 문서는 [data/enemies/enemies.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/enemies/enemies.json)의 필드 구조, 필수 키, 허용값, validation 기준을 정의합니다.

몬스터 roster와 역할은 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)에서, 전투 수치 규칙은 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)에서 관리합니다.

## 스키마 운영 원칙

- 새 필드를 추가할 때는 코드만 바꾸지 말고 이 문서를 함께 갱신합니다.
- `enemy_id`는 장기 식별자이므로 쉽게 바꾸지 않습니다.
- `enemy_type`은 런타임 동작 분기와 연결되므로, 표현용 이름이 아니라 구현 단위로 다룹니다.
- 로더 validation 규칙은 이 문서와 GUT를 함께 맞춥니다.

## 최상위 구조

```json
{
  "enemies": [
    {
      "enemy_id": "brute",
      "display_name": "Brute"
    }
  ]
}
```

- 최상위 키는 `enemies`
- 값은 enemy object 배열
- 각 object는 하나의 정식 몬스터 타입을 의미

## 필수 필드

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `enemy_id` | string | 정식 장기 식별자. 중복 금지 |
| `display_name` | string | 관리자 / 표시용 이름 |
| `enemy_type` | string | 런타임 행동 분기용 타입 |
| `enemy_grade` | string | `normal`, `elite`, `boss` |
| `role` | string | 전투 역할 요약값 |
| `max_hp` | number | 최대 체력 |
| `move_speed` | number | 기본 이동 속도 |
| `contact_damage` | number | 몸박 피해 |
| `physical_attack` | number | 물리 공격력 |
| `magic_attack` | number | 마법 공격력 |
| `attack_damage_type` | string | 공격 피해 계열 |
| `attack_element` | string | 공격 속성 |
| `attack_period` | number | 기본 공격 주기 |
| `physical_defense` | number | 물리 방어력 |
| `magic_defense` | number | 마법 방어력 |
| `knockback_resistance` | number | 넉백 저항 |
| `super_armor_enabled` | bool | 상시 슈퍼아머 기본값 |
| `super_armor_break_threshold` | number | 브레이크 누적 임계치 |
| `super_armor_break_duration` | number | 브레이크 지속시간 |
| `super_armor_damage_multiplier` | number | 슈퍼아머 중 피해 감쇠 배수 |
| `vulnerability_damage_multiplier` | number | 취약 상태 피해 배수 |
| `stagger_threshold` | number | 경직 임계치 |
| `super_armor_tags` | array<string> | 슈퍼아머 패턴 태그 |
| `tint` | string | 기본 비주얼 색상 |
| `projectile_color` | string | 발사체 색상 |
| `drop_profile` | string | 드롭 프로필 키 |

## 저항 필드

모든 적은 아래 저항 필드를 개별 수치로 가집니다.

### 속성 저항

- `fire_resist`
- `water_resist`
- `ice_resist`
- `lightning_resist`
- `wind_resist`
- `earth_resist`
- `plant_resist`
- `dark_resist`
- `holy_resist`
- `arcane_resist`

### 상태이상 저항

- `slow_resist`
- `root_resist`
- `stun_resist`
- `freeze_resist`
- `shock_resist`
- `burn_resist`
- `poison_resist`
- `silence_resist`

## enum-like 허용값

### `enemy_grade`

- `normal`
- `elite`
- `boss`

### `attack_damage_type`

- `physical`
- `magic`

### `attack_element`

- `none`
- `fire`
- `water`
- `ice`
- `lightning`
- `wind`
- `earth`
- `plant`
- `dark`
- `holy`
- `arcane`

### `role`

현재 체크인된 `enemies.json` 기준 대표값:

- `melee_chaser`
- `ranged_harasser`
- `boss_volley`
- `training_target`
- `telegraph_charger`
- `area_control`
- `burst_check`
- `mobile_burst`
- `slow_ranged_denial`
- `punish_stationary`
- `flying_ranged_harasser`
- `ground_charge_presser`
- `melee_stunner`
- `fast_melee_swarm`
- `slow_bite_chaser`
- `flying_observer`
- `trash_tank`
- `agile_sword_fighter`

현재 허용값도 위 대표값과 동일하게 유지합니다.

규칙:

- role은 UI와 문서 요약을 위한 값이므로 너무 세분화하지 않습니다.
- 새 role을 추가할 때는 기존 값으로 설명 가능한지 먼저 검토합니다.

### `drop_profile`

현재 체크인된 `enemies.json` 기준 대표값:

- `none`
- `common`
- `elite`
- `boss`

현재 허용값:

- `none`
- `common`
- `elite`
- `rare`
- `boss`

규칙:

- `rare`는 현재 체크인 enemy catalog에서는 직접 사용하지 않지만, 코드 validation과 드롭 규칙상 허용값으로 유지합니다.
- 대표값과 허용값이 다를 수 있으며, validation은 항상 허용값 전체를 기준으로 합니다.

## validation 기준

- `enemy_id`는 중복될 수 없습니다.
- 모든 필수 필드는 누락 없이 존재해야 합니다.
- `enemy_grade`, `drop_profile`, `role`, `attack_damage_type`, `attack_element`는 허용값 검증 대상입니다.
- room `spawns[].type`는 실제 `enemy_id`를 가리켜야 합니다.
- 소비 경로는 가능하면 raw JSON이 아니라 loader summary API를 통해 읽습니다.

현재 기준 메모:

- 현재 `GameDatabase`는 `enemy_grade`, `drop_profile`, `role`, `attack_damage_type`, `attack_element`, duplicate `enemy_id`, 그리고 `role` / `attack_damage_type` / `attack_element` / `attack_period` / `drop_profile` / `knockback_resistance`를 포함한 Phase 1 필수 필드 확장을 검증합니다.
- `super_armor_tags`는 현재 `Array[String]` 구조 검증 대상입니다.
- 속성 저항 10종과 상태이상 저항 8종은 현재 모두 필수 존재 검증 대상입니다.
- `enemy_base.gd`는 loader를 1차 신뢰 경계로 유지하되, 런타임에서 empty `display_name`은 `enemy_id.capitalize()`, empty 또는 invalid `enemy_grade`는 타입 기본 등급, unknown `attack_damage_type`은 `physical`, unknown `attack_element`는 `none`으로 경고와 함께 정규화합니다.

## 작성 규칙

- 수치가 규칙을 벗어나면 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)에 예외 이유를 남깁니다.
- 신규 몬스터를 넣을 때는 먼저 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)에 등록합니다.
- `enemy_type`와 `enemy_id`를 다르게 둘 때는 이유를 남깁니다.
- 신규 필드 추가 시 `game_database.gd` validation, 소비 API, GUT를 함께 갱신합니다.

## 예시 object

```json
{
  "enemy_id": "rat",
  "display_name": "Dungeon Rat",
  "enemy_type": "rat",
  "enemy_grade": "normal",
  "role": "fast_melee_swarm",
  "max_hp": 22,
  "move_speed": 170.0,
  "contact_damage": 8,
  "physical_attack": 8,
  "magic_attack": 0,
  "attack_damage_type": "physical",
  "attack_element": "none",
  "attack_period": 1.2,
  "physical_defense": 15.0,
  "magic_defense": 15.0,
  "fire_resist": 0.0,
  "water_resist": 0.0,
  "ice_resist": 0.0,
  "lightning_resist": -0.15,
  "wind_resist": 0.0,
  "earth_resist": 0.15,
  "plant_resist": 0.0,
  "dark_resist": 0.0,
  "holy_resist": 0.0,
  "arcane_resist": 0.0,
  "slow_resist": 0.06,
  "root_resist": 0.06,
  "stun_resist": 0.06,
  "freeze_resist": 0.06,
  "shock_resist": 0.06,
  "burn_resist": 0.06,
  "poison_resist": 0.06,
  "silence_resist": 0.06,
  "knockback_resistance": 0.0,
  "super_armor_enabled": false,
  "super_armor_break_threshold": 0.0,
  "super_armor_break_duration": 0.0,
  "super_armor_damage_multiplier": 1.0,
  "vulnerability_damage_multiplier": 1.2,
  "stagger_threshold": 9999,
  "super_armor_tags": [],
  "tint": "#b5935a",
  "projectile_color": "#ffcf73",
  "drop_profile": "common"
}
```

## 구현자 체크리스트

- [ ] `enemy_id`가 중복되지 않는가
- [ ] `enemy_grade`, `attack_damage_type`, `attack_element`, `drop_profile`이 허용값 안에 있는가
- [ ] 저항 필드가 누락 없이 들어갔는가
- [ ] 새 필드가 생겼다면 로더 validation과 summary API가 같이 갱신되었는가
- [ ] 문서와 JSON의 식별자가 일치하는가

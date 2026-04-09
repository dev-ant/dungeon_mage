---
title: 버프 조합 데이터 스키마
doc_type: schema
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_apply_status_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_effect_tag_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_stack_key_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
update_when:
  - schema_changed
  - rule_changed
  - status_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 버프 조합 데이터 스키마

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 버프 조합 특수효과를 실제 데이터 파일로 옮길 때 사용하는 기준 스키마 문서입니다. Claude가 이후 `buff_combos.json`을 만들 때 이 문서를 기준으로 사용합니다.

## 데이터 파일 구조

- `res://data/skills/buff_combos.json`
- 현재 runtime loader는 최상위 `{"combos": [...]}` 객체 구조만 허용합니다.
- `combos`는 조합 row 배열이어야 하며, 로드 시점에 구조 오류는 즉시 `error`로 처리합니다.

## 조합 ID 규칙

### 기본 형식

`combo_[핵심이름]`

### 예시

| 조합 이름 | 권장 combo_id |
| --- | --- |
| Prismatic Guard | `combo_prismatic_guard` |
| Funeral Bloom | `combo_funeral_bloom` |
| Time Collapse | `combo_time_collapse` |
| Ashen Rite | `combo_ashen_rite` |

## 공통 필드

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| combo_id | string | 내부 식별자 |
| display_name | string | UI 표시 이름 |
| required_buffs | array[string] | 필요 버프 `skill_id` 목록 |
| priority | int | 동시 성립 시 우선순위 |
| combo_type | string | `sustain`, `instant`, `trigger`, `ritual` |
| internal_cooldown | float | 내부 쿨타임 |
| active_window | float | 유지형이면 조합 유지 시간, 아니면 0 |
| effect_tags | array[string] | 핵심 효과 태그. 현재 운영 목록은 `buff_combo_effect_tag_catalog.md`를 따른다 |
| penalties | array[object] | 종료 반동 |
| visual_profile | string | 연출용 키워드 |
| notes | string | 구현 메모 |

## 현재 로드 시점 hardening 범위

- 모든 combo row는 `combo_id`, `display_name`, `required_buffs`, `priority`, `combo_type`, `internal_cooldown`, `active_window`, `effect_tags`, `applied_effects`, `trigger_rules`, `penalties`, `visual_profile`, `notes`를 가져야 합니다.
- `combo_type`은 현재 `sustain`, `instant`, `trigger`, `ritual`만 허용합니다.
- `applied_effects[].mode`와 `penalties[].mode`는 현재 `set`, `add`, `mul`만 허용합니다.
- `trigger_rules[].event`는 현재 `on_barrier_break`, `on_deploy_kill`, `on_spell_hit`, `on_combo_end`만 허용합니다.
- `trigger_rules[].damage_school`이 있으면 현재 runtime spell school enum(`fire`~`arcane`) 중 하나여야 합니다.
- `trigger_rules[].color`가 있으면 non-empty string이어야 하고, `damage`, `damage_per_stack`, `radius_per_stack`가 있으면 numeric이어야 합니다.
- `trigger_rules[].stack_name`과 `trigger_rules[].scales_with_stack`는 [buff_combo_stack_key_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_stack_key_catalog.md)의 closed key만 허용합니다.
- `trigger_rules[].scales_with_stack`는 같은 combo 안에서 선언된 `stack_name`을 참조해야 합니다.
- `required_buffs`와 `effect_tags`는 `array[string]` 구조를 강제합니다.
- `required_buffs`는 실제 `skills.json`의 `skill_type = buff` row만 가리켜야 합니다.
- `effect_tags` 허용 후보는 [buff_combo_effect_tag_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_effect_tag_catalog.md)를 기준으로 관리합니다.
- `effect_tags`는 현재 구조를 hard validation하고, catalog 바깥 값은 load 시점 `warning-only` drift check로 알립니다.
- 2026-04-05 기준 `Prismatic Guard`의 `effect_tags.poise_ignore / shield / shockwave`는 runtime 승격 후보 태그 세트입니다. 현재 validator는 각각 `holy_crystal_aegis.buff_effects.super_armor_charges`, `applied_effects.max_hp_barrier_ratio`, `trigger_rules[on_barrier_break].spawn_effect / radius` backing source를 `warning-only` drift check로 감시합니다.
- `applied_effects`, `trigger_rules`, `penalties` 내부 row는 `Dictionary`여야 하며, 현재 runtime이 실제로 읽는 핵심 필드만 최소 구조 검증합니다.
- `trigger_rules[].apply_status` 허용 후보는 [buff_combo_apply_status_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_apply_status_catalog.md)를 기준으로 관리합니다.
- `trigger_rules[].apply_status`는 아직 generic runtime consumer가 없어서, 이번 hardening 범위에서는 non-empty string 구조를 검사하고 catalog 바깥 값은 `warning-only` drift check로 알립니다.
- 2026-04-03 후속 증분으로 `GameState`는 `combo_prismatic_guard.applied_effects.max_hp_barrier_ratio`와 `on_barrier_break.spawn_effect / radius`를 직접 읽습니다. 따라서 barrier ratio는 현재 `mode = add`와 양수 numeric value를 유지해야 하고, barrier break rule의 두 필드는 runtime 필수 payload field로 취급합니다. 누락/타입 오류는 load 시점 `error`입니다.
- 같은 날짜 다음 정리로 `combo_prismatic_guard`의 예전 `hitstun_resist_mode` row는 제거했습니다. 현재 runtime은 이 combo-level field를 읽지 않으며, 피격 안정성 source는 `holy_crystal_aegis.buff_effects.super_armor_charges`입니다.
- 2026-04-07 기준 `Overclock Circuit`는 `wind_tempest_drive` active 전환과 같은 날짜 후속 잠금으로 current buff combo data 밖의 runtime active-combo state가 되었습니다. 현재 contract는 `lightning_conductive_surge` 활성 중 `wind_tempest_drive` 시전 성공 시 `1.0초` window를 열고, 다음 `lightning` 계열 `active` 1회에 `aftercast x0.88`, `chain +1`, `cast speed x1.18`을 적용한 뒤 소모하는 구조입니다. 따라서 buff combo schema required contract에는 계속 포함하지 않습니다.
- 2026-04-03 후속 증분으로 `GameState`의 Time Collapse opening charge도 `combo_time_collapse.applied_effects.discounted_cast_charges`를 직접 읽습니다. 따라서 이 stat은 현재 runtime 필수 field로 취급하며, `mode = set`과 양수 numeric value를 유지해야 합니다.
- 2026-04-03 현재 `GameState.notify_deploy_kill()`는 `combo_funeral_bloom`의 `on_deploy_kill` rule에서 `spawn_effect`, `radius`, `damage_school`, `apply_status`, `color`를 직접 읽고, `internal_cooldown`도 같은 combo row에서 읽습니다. 따라서 이 rule은 현재 runtime 필수 payload field로 취급하며, 누락/타입 오류는 load 시점 `error`입니다.
- 같은 날짜 후속 증분으로 `Ashen Rite`도 `on_spell_hit.max_stacks`, `applied_effects.ash_residue_interval / ash_residue_effect_id / ash_residue_damage / ash_residue_damage_per_stack / ash_residue_radius / ash_residue_school / ash_residue_color`, `on_combo_end.spawn_effect / damage_school / color / damage / damage_per_stack / radius / radius_per_stack`, `penalties`를 runtime이 직접 읽습니다. 따라서 이 residue/end payload field들도 현재 runtime 필수 field로 취급하며, 누락/타입 오류는 load 시점 `error`입니다.
- 현재 runtime validation source of truth는 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)의 `validate_buff_combo_entry()`와 `validate_buff_combo_links()`입니다.

## 효과 필드

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| applied_effects | array[object] | 유지형 또는 즉발형 효과 |
| trigger_rules | array[object] | 조건부 발동 룰 |

`applied_effects` 예시:

```json
[
  { "stat": "cast_speed_multiplier", "mode": "mul", "value": 1.2 },
  { "stat": "final_damage_multiplier", "mode": "mul", "value": 1.18 }
]
```

`trigger_rules` 예시:

```json
[
  {
    "event": "on_deploy_kill",
    "cooldown": 1.5,
    "spawn_effect": "corruption_burst",
    "radius": 96,
    "color": "#6a1d8a"
  }
]
```

## 버프 참조 규칙

- `required_buffs`에는 반드시 [스킬 데이터 스키마](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)의 `skill_id`를 사용합니다.
- 조합 판정은 버프 종류 충족 여부로만 확인하고, 같은 버프 중첩 수는 따로 보지 않습니다.
- 3버프 조합은 `priority`를 높게 잡아 2버프 조합보다 먼저 소비 또는 적용되게 합니다.

## 예시 데이터

### Prismatic Guard

```json
{
  "combo_id": "combo_prismatic_guard",
  "display_name": "Prismatic Guard",
  "required_buffs": ["holy_mana_veil", "holy_crystal_aegis"],
  "priority": 100,
  "combo_type": "sustain",
  "internal_cooldown": 0.0,
  "active_window": 0.0,
  "effect_tags": ["poise_ignore", "shield", "shockwave"],
  "applied_effects": [
    { "stat": "max_hp_barrier_ratio", "mode": "add", "value": 0.18 }
  ],
  "trigger_rules": [
    {
      "event": "on_barrier_break",
      "cooldown": 0.0,
      "spawn_effect": "guard_shockwave",
      "radius": 110
    }
  ],
  "penalties": [],
  "visual_profile": "holy_prism",
  "notes": "방어 버프 2개 유지 시 안정 돌파용 조합"
}
```

### Ashen Rite

```json
{
  "combo_id": "combo_ashen_rite",
  "display_name": "Ashen Rite",
  "required_buffs": [
    "dark_grave_pact",
    "arcane_world_hourglass",
    "dark_throne_of_ash"
  ],
  "priority": 300,
  "combo_type": "ritual",
  "internal_cooldown": 6.0,
  "active_window": 0.0,
  "effect_tags": ["fire_dark_finisher", "ash_stack", "ending_burst"],
  "applied_effects": [
    { "stat": "fire_final_damage_multiplier", "mode": "mul", "value": 1.22 },
    { "stat": "dark_final_damage_multiplier", "mode": "mul", "value": 1.22 },
    { "stat": "ash_residue_interval", "mode": "set", "value": 1.25 },
    { "stat": "ash_residue_effect_id", "mode": "set", "value": "ash_residue_burst" },
    { "stat": "ash_residue_damage", "mode": "set", "value": 16.0 },
    { "stat": "ash_residue_damage_per_stack", "mode": "set", "value": 2.0 },
    { "stat": "ash_residue_radius", "mode": "set", "value": 54.0 },
    { "stat": "ash_residue_school", "mode": "set", "value": "fire" },
    { "stat": "ash_residue_color", "mode": "set", "value": "#ff9a54" }
  ],
  "trigger_rules": [
    {
      "event": "on_spell_hit",
      "cooldown": 0.0,
      "stack_name": "ash",
      "max_stacks": 20
    },
    {
      "event": "on_combo_end",
      "cooldown": 0.0,
      "spawn_effect": "ash_detonation",
      "scales_with_stack": "ash",
      "damage_school": "fire",
      "color": "#ff7446",
      "damage": 24.0,
      "damage_per_stack": 7.0,
      "radius": 68.0,
      "radius_per_stack": 3.0
    }
  ],
  "penalties": [
    { "stat": "mana_percent", "mode": "set", "value": 0.0 },
    { "stat": "defense_multiplier", "mode": "mul", "value": 0.75, "duration": 10.0 },
    { "stat": "ritual_recast_lock", "mode": "set", "value": 1, "duration": 6.0 }
  ],
  "visual_profile": "ashen_ritual",
  "notes": "최종 필살 조합"
}
```

## 구현 메모

- 실제 조합 목록과 효과 해석은 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)를 우선합니다.
- 실제 버프 ID는 [skill_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md)를 따릅니다.

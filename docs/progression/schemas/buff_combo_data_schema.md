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
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
update_when:
  - schema_changed
  - rule_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 버프 조합 데이터 스키마

상태: 사용 중  
최종 갱신: 2026-03-27  
섹션: 성장 시스템

## 범위

이 문서는 버프 조합 특수효과를 실제 데이터 파일로 옮길 때 사용하는 기준 스키마 문서입니다. Claude가 이후 `buff_combos.json`을 만들 때 이 문서를 기준으로 사용합니다.

## 데이터 파일 권장 구조

- `res://data/skills/buff_combos.json`
- 최상위는 조합 객체 배열 또는 `combos` 키를 가진 객체를 권장합니다.

## 조합 ID 규칙

### 기본 형식

`combo_[핵심이름]`

### 예시

| 조합 이름 | 권장 combo_id |
| --- | --- |
| Prismatic Guard | `combo_prismatic_guard` |
| Overclock Circuit | `combo_overclock_circuit` |
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
| effect_tags | array[string] | 핵심 효과 태그 |
| penalties | array[object] | 종료 반동 |
| visual_profile | string | 연출용 키워드 |
| notes | string | 구현 메모 |

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
    "event": "on_kill",
    "cooldown": 1.5,
    "spawn_effect": "corruption_burst",
    "radius": 96
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
    { "stat": "hitstun_resist_mode", "mode": "set", "value": "ignore_light_hits" },
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
    { "stat": "dark_final_damage_multiplier", "mode": "mul", "value": 1.22 }
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
      "scales_with_stack": "ash"
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

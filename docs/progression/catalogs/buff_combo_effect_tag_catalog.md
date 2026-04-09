---
title: 버프 조합 효과 태그 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/buff_combo_data_schema.md
update_when:
  - rule_changed
  - data_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 버프 조합 효과 태그 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `data/skills/buff_combos.json`의 `effect_tags`가 표현하는 현재 운영 태그 목록과 의미를 정리하는 기준 catalog입니다.

- `effect_tags`는 조합의 핵심 체감을 빠르게 읽기 위한 요약 태그입니다.
- 현재 runtime은 `effect_tags`를 로드 시점에 `array[string]` 구조까지 hard validation하고, 이 catalog 바깥 값은 `warning-only`로 드리프트를 알립니다.
- 새 태그가 정말 필요하면 이 catalog와 `GameDatabase` validator를 같은 턴에 같이 갱신합니다.

## 현재 운영 태그

2026-04-07 기준 `buff_combos.json`에서 실제 관측된 `effect_tags`는 아래 12개입니다.

| 태그 | 의미 | 현재 예시 |
| --- | --- | --- |
| `ash_stack` | 잿재 중첩 축적 | Ashen Rite |
| `cast_speed_up` | 시전 속도 증가 | Time Collapse |
| `chain_clear` | 연쇄 정리/연쇄 폭발 | Funeral Bloom |
| `cheap_first_casts` | 첫 연속 시전 자원 할인 | Time Collapse |
| `deploy_kill_burst` | 설치 처치 연동 폭발 | Funeral Bloom |
| `ending_burst` | 종료 시 대폭발 | Ashen Rite |
| `final_damage_up` | 최종 피해 증가 | Time Collapse |
| `fire_dark_finisher` | 화염/흑마법 최종 필살 축 | Ashen Rite |
| `poise_ignore` | 경직 무시/자세 안정 | Prismatic Guard |
| `shield` | 보호막 생성 | Prismatic Guard |
| `shockwave` | 충격파 발생 | Prismatic Guard |
| `snare` | 속박 또는 발 묶기 | Funeral Bloom |

## 운영 메모

- `effect_tags`는 open text처럼 보이지만, 실제 운영상은 이 catalog를 기준으로 관리합니다.
- 다만 2026-04-03 현재 단계에서는 조합 기획 확장 여지를 남기기 위해 out-of-catalog 값을 `error`가 아니라 `warning`으로만 다룹니다.
- 효과 해석 자체는 [buff_combo_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md)와 `buff_combos.json`의 `applied_effects` / `trigger_rules` / `penalties`가 결정합니다.
- `Prismatic Guard` 태그 3개는 2026-04-05 기준 runtime 승격 후보 세트입니다.
- `poise_ignore`의 현재 backing source는 `holy_crystal_aegis.buff_effects.super_armor_charges`입니다.
- `shield`의 현재 backing source는 `combo_prismatic_guard.applied_effects.max_hp_barrier_ratio`입니다.
- `shockwave`의 현재 backing source는 `combo_prismatic_guard.trigger_rules[on_barrier_break].spawn_effect / radius`입니다.
- 같은 날짜부터 validator는 이 세 태그가 붙은 combo가 각 backing runtime source를 유지하는지 `warning-only` drift check로 감시합니다.

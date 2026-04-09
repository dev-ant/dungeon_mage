---
title: 버프 조합 스택 키 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_combo_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/buff_combo_data_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd
update_when:
  - rule_changed
  - runtime_changed
  - data_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 버프 조합 스택 키 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `data/skills/buff_combos.json`의 `trigger_rules[].stack_name`과 `trigger_rules[].scales_with_stack`가 사용하는 현재 운영 스택 키를 정리하는 closed catalog입니다.

- 이 필드는 자유 텍스트가 아니라 runtime이 직접 기대하는 관리용 키입니다.
- 2026-04-03 현재 runtime은 `Ashen Rite`의 `ash` 스택만 실제로 읽습니다.
- 새 스택 키를 추가하거나 이름을 바꾸려면 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)의 `VALID_BUFF_COMBO_STACK_KEYS`와 이 문서를 같은 턴에 같이 갱신합니다.

## 현재 운영 키

| 키 | 의미 | 현재 사용 예시 |
| --- | --- | --- |
| `ash` | Ashen Rite가 주문 적중마다 쌓는 잿재 중첩 | `combo_ashen_rite` |

## 운영 메모

- `scales_with_stack`는 같은 combo 안에서 먼저 선언된 `stack_name` 중 하나를 참조해야 합니다.
- 2026-04-03 현재 checked-in 데이터는 `ash` 1개만 사용합니다.
- `damage_school`처럼 다른 trigger field는 기존 runtime enum이나 별도 문서를 따르지만, stack key는 이 catalog를 단일 source of truth로 봅니다.

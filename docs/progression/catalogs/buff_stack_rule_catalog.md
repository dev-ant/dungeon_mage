---
title: 버프 중첩 규칙 ID 목록
doc_type: catalog
status: active
section: progression
owner: design
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/skill_data_schema.md
update_when:
  - rule_changed
  - runtime_changed
  - data_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 버프 중첩 규칙 ID 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `skills.json`의 buff row가 사용하는 `stack_rule_id`의 현재 운영 목록과 의미를 정리하는 closed catalog입니다.

- `stack_rule_id`는 open text가 아니라 관리용 ID입니다.
- 현재 runtime validator는 catalog 밖 값을 `warning`이 아니라 즉시 `error`로 처리합니다.
- 새 ID를 추가하거나 이름을 바꾸려면 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)의 `VALID_STACK_RULE_IDS`와 이 문서를 같은 턴에 같이 갱신합니다.

## 현재 운영 ID

| ID | 의미 | 현재 사용 예시 |
| --- | --- | --- |
| `default_diminishing_buff` | 기본 점감 중첩 규칙. 2중첩 이후 효율을 낮추되, 일반 버프는 여전히 중복 운용 가능하게 둔다 | Mana Veil, Tempest Drive, Crystal Aegis, Pyre Heart |
| `heavy_diminishing_buff` | 강한 점감 중첩 규칙. 고성능 범용 버프가 반복 시전만으로 과하게 누적되지 않게 더 빠르게 감쇠한다 | Astral Compression, World Hourglass |
| `ritual_single_focus` | 의식형 단일 집중 규칙. 고위험 최종 버프의 연속 중첩을 사실상 억제하고, 1회 폭발 창구 중심으로 운용하게 만든다 | Throne of Ash |

## 운영 메모

- 현재 checked-in 데이터는 위 3개 ID만 사용합니다.
- `stack_rule_id` 의미 변경은 [buff_system.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/buff_system.md)의 중첩 규칙 설명과 같이 봐야 합니다.
- 버프 row의 실제 배치와 역할은 [buff_skill_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/buff_skill_catalog.md)를 따릅니다.

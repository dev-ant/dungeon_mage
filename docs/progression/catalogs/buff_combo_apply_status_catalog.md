---
title: 버프 조합 적용 상태 태그 목록
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

# 버프 조합 적용 상태 태그 목록

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 성장 시스템

## 범위

이 문서는 `data/skills/buff_combos.json`의 `trigger_rules[].apply_status`가 표현하는 현재 운영 태그를 정리하는 catalog입니다.

- 이 필드는 아직 generic runtime status consumer에 직접 연결되지 않았습니다.
- 따라서 2026-04-03 현재 단계에서는 closed error enum이 아니라, current catalog 기준 warning-only drift check로 관리합니다.
- 새 값이 필요하면 이 문서와 [game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)의 `VALID_BUFF_COMBO_APPLY_STATUS_TAGS`를 같은 턴에 같이 갱신합니다.

## 현재 운영 태그

| 태그 | 의미 | 현재 사용 예시 |
| --- | --- | --- |
| `snare` | 조합 폭발이 발을 묶는 제어 힌트를 가진다는 authored cue | `combo_funeral_bloom` |

## 운영 메모

- `apply_status`는 현재 `last_combo_effect` payload에 실려 테스트와 디버그 요약에서 읽을 수 있지만, 일반화된 상태이상 적용 contract 자체는 아직 아니다.
- 따라서 값 추가는 가능하되, catalog 밖 값은 현재 load failure 대신 warning으로만 알린다.
- 나중에 combo effect가 실제 적 status pipeline에 연결되면, 그때 enemy status contract와 관계를 다시 정리해 hard enum 승격 여부를 결정한다.

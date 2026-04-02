---
title: 기획 구체화 우선순위 백로그
doc_type: tracker
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
update_when:
  - handoff_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 기획 구체화 우선순위 백로그

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 구현 기준

## 목적

이 문서는 `지금 구현 계획에는 들어 있지만, 바로 안전하게 개발하기에는 기획이 덜 잠긴 항목`을 우선순위로 관리하는 큐다.

AI가 아래 요청을 받으면 이 문서를 먼저 읽는다.

- "알아서 가장 시급한 기획부터 질문해줘"
- "어떤 기획이 더 구체화가 필요한지 골라줘"
- "질문 10개씩 해서 기획 완성해줘"

## 운영 규칙

- 이 문서는 `구체화 대상 우선순위`만 관리한다.
- 실제 규칙 확정은 linked docs를 갱신해서 처리한다.
- 질문 라운드는 항상 [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)를 따른다.
- 답변이 쌓이면 `명확도 상태`, `다음 질문 초점`, `연결 문서`를 함께 갱신한다.

## 상태 값

| 값 | 의미 |
| --- | --- |
| `open` | 아직 질문 라운드가 필요한 항목 |
| `in_interview` | 현재 사용자와 질의응답 진행 중 |
| `partially_locked` | 핵심 결정 일부는 잠겼지만 추가 라운드 필요 |
| `ready_for_implementation` | 구현 가능한 수준으로 잠김 |
| `blocked` | 사용자 답변 없이는 더 진행 불가 |

## 현재 우선순위

| 우선순위 | 항목 | 상태 | 왜 지금 필요한가 | 연결 문서 | 다음 질문 초점 |
| --- | --- | --- | --- | --- | --- |
| `P1` | 전투 HUD 그래픽 GUI 최종 명세 | `open` | [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)의 목표는 분명하지만, 최종 레이아웃, 슬롯 상호작용, 툴팁/클릭/더블클릭 규칙이 구현 수준으로 아직 잠기지 않았다. | [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md), [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md) | HP/MP 바 배치, 13슬롯 핫바 시각 구조, 마우스 상호작용, 툴팁 정보량, 디버그 fallback 경계 |
| `P2` | 관리자 장비/인벤토리 그래픽 GUI 명세 | `open` | [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md)는 그래픽 GUI 목표를 적고 있지만, 슬롯 좌표 체계, 아이템 크기 규칙, 드래그/드롭과 키보드 대체 흐름이 아직 모호하다. | [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md) | 인벤토리 그리드 크기, 아이콘 점유 칸 수, 이동 규칙, 장착 패널 대응, 입력 우선순위 |
| `P3` | Phase 3 legacy combat 스킬 canonical 확정 | `open` | [skills_json_canonical_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skills_json_canonical_migration_plan.md)는 `Phase 3`이 blocked이며, 이 결정을 잠가야 이후 데이터/문서 정렬이 안전해진다. | [skills_json_canonical_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/plans/skills_json_canonical_migration_plan.md), [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md), [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md) | `ice_frost_needle`, `earth_stone_spire`, `fire_flame_arc`, `water_tidal_ring`, `lightning_thunder_lance`의 1:1 대응 여부 |
| `P4` | 7서클 이상 대표 스킬의 실제 구현 핸드오프 수준 구체화 | `open` | 현재 스킬 라인업은 길게 정의되어 있지만, 어떤 스킬을 어떤 런타임 패턴으로 먼저 구현할지 handoff 수준으로 좁혀진 문서가 부족하다. | [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md), [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md), [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md) | 대표 스킬 선정, 구현 순서, proxy 허용 범위, 이펙트/레벨 스케일 검증 기준 |

## AI 선택 규칙

- 사용자가 대상을 지정하지 않으면 `P1`부터 본다.
- 같은 우선순위라면 `현재 구현 계획에 가장 가까운 블로커`를 먼저 고른다.
- 이미 `in_interview`인 항목은 같은 맥락 질문이 끝날 때까지 이어서 처리한다.

## 라운드 종료 후 업데이트 규칙

- 답변을 linked docs에 반영했다면 상태를 `partially_locked` 또는 `ready_for_implementation`으로 바꾼다.
- 추가 사용자 결정이 꼭 필요하면 `blocked`가 아니라 `in_interview` 또는 `partially_locked`를 우선 사용한다.
- 해당 항목이 구현 가능한 수준이 되면 backlog에서는 내리고, 관련 `plan` 문서의 acceptance criteria를 강화한다.

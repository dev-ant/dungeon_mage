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
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 기획 구체화 우선순위 백로그

상태: 사용 중  
최종 갱신: 2026-04-07  
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
| `-` | 현재 active clarification blocker 없음 | `ready_for_implementation` | 관리자 GUI와 `ice_ice_wall` temporary wall shell 기준까지 잠겨서, 지금 남은 일은 질문 라운드보다 구현/튜닝이다. | [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md), [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md) | 없음. 다음 턴은 linked docs 기준 구현을 이어간다 |

- 이전 `P1`이던 전투 HUD 그래픽 GUI 명세는 [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md), [combat_hud_gui_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_hud_gui_schema.md), [test_game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_ui.gd) `10/10`, headless runtime 기준으로 backlog에서 내렸다.
- 관리자 장비/인벤토리 그래픽 GUI 명세도 2026-04-07 follow-up으로 [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md)에 `Inventory.png 5x4 grid`, `page-based overflow`, `Equipment.png paperdoll shell` 기준이 잠겨 backlog에서 내렸다. 이제 남은 일은 기획 질문이 아니라 구현 확장이다.
- `ice_ice_wall` wall-read 재개 조건도 2026-04-07 follow-up으로 [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md)과 [skill_implementation_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/skill_implementation_tracker.md)에 `earth_tremor` blue variant temporary shell 기준이 잠겨 backlog에서 내렸다. 이제 이 라인도 질문 대상이 아니라 구현/튜닝 대상이다.

## AI 선택 규칙

- 사용자가 대상을 지정하지 않으면 현재 table의 첫 active row를 본다. active clarification blocker가 없으면 linked implementation doc 기준으로 다음 구현 작업을 바로 이어간다.
- 같은 우선순위라면 `현재 구현 계획에 가장 가까운 블로커`를 먼저 고른다.
- 이미 `in_interview`인 항목은 같은 맥락 질문이 끝날 때까지 이어서 처리한다.

## 라운드 종료 후 업데이트 규칙

- 답변을 linked docs에 반영했다면 상태를 `partially_locked` 또는 `ready_for_implementation`으로 바꾼다.
- 추가 사용자 결정이 꼭 필요하면 `blocked`가 아니라 `in_interview` 또는 `partially_locked`를 우선 사용한다.
- 해당 항목이 구현 가능한 수준이 되면 backlog에서는 내리고, 관련 `plan` 문서의 acceptance criteria를 강화한다.

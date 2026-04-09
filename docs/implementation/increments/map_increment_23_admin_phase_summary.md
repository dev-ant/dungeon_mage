---
title: 맵 23차 작업 체크리스트 - 관리자 진행 단계 요약
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_22_admin_gate_reactive_preview.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 23차 작업 체크리스트 - 관리자 진행 단계 요약

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 관리자 메뉴의 긴 progression chain을 `Threshold / Companion / Final` 단계 요약으로 압축해 읽기 쉽게 만드는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 7층 문턱 단서, 8층/9층 동료 전조, 10층 최종 계약 상태를 단계별로 빠르게 읽을 수 있어야 한다.
- 세부 chain은 유지하되, 현재 빌드가 어느 단계까지 잠겼는지 한 줄 요약이 먼저 보여야 한다.
- 직접 조우/컷신이 미정이어도 현재 환경 서사 진행도를 곧바로 해석할 수 있어야 한다.

## 수용 기준

- Resources 탭에 `Phase Summary` 줄이 보여야 한다.
- `Threshold`, `Companion`, `Final` 상태가 관련 progression flag에 따라 즉시 갱신되어야 한다.
- 기존 progression chain과 함께 유지되어야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.
- 현재 `Phase Summary`의 source of truth는 `GameState.get_progression_phase_summary()`이며, 같은 progression 묶음인 `Progression Chain`과 `Lore Handoff`도 각각 `GameState.get_progression_chain_summary()`, `GameState.get_lore_handoff_summary()`로 중앙화한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)

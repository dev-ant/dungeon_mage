---
title: 맵 19차 작업 체크리스트 - 관리자 친구 B 전조 체인
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_17_admin_progression_chain.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_18_companion_foreshadow_traces.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 19차 작업 체크리스트 - 관리자 친구 B 전조 체인

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 관리자 메뉴의 progression chain에 `친구 B 환경 전조` 확인 상태를 포함하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- `8층 전조 흔적`과 `9층 전조 흔적`을 기존 진행 체인과 함께 읽을 수 있어야 한다.
- 현재 build가 `친구 B 단서 -> 기록/칙령 -> 계약 -> 허브 반응` 흐름에서 어디까지 잠겼는지 바로 보여야 한다.
- 직접 조우 연출이 미정이어도 전조 검증은 admin 메뉴에서 즉시 가능해야 한다.

## 수용 기준

- Resources 탭의 progression chain에 `8F Trace`, `9F Trace`가 포함되어야 한다.
- 관련 progression flag가 바뀌면 chain 요약도 즉시 갱신되어야 한다.
- 기존 interaction/reactive/final warning preview와 함께 유지되어야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/plans/dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)

---
title: 맵 16차 작업 체크리스트 - 관리자 최종전 경고 프리뷰
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_14_admin_reactive_preview.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_15_final_boss_warning_state.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 16차 작업 체크리스트 - 관리자 최종전 경고 프리뷰

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 관리자 메뉴에서 `최종전 준비 상태`까지 즉시 검증할 수 있도록 preview를 확장하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- `inverted_spire` 선택 시 계약 제단 확인 전후의 경고 상태를 바로 볼 수 있어야 한다.
- 최심층 차단 문구가 현재 progression flag 기준으로 어떻게 바뀌는지 메뉴 안에서 읽을 수 있어야 한다.
- 플레이 검증 전에도 `final warning` 상태를 빠르게 확인할 수 있어야 한다.
- 현재 `Final Warning Preview`의 source of truth는 `GameState.get_final_warning_preview_summary()`이며, 관리자 메뉴와 `main.gd`는 같은 phase-aware gate line을 이 API에서 읽는다.

## 수용 기준

- Resources 탭에서 `inverted_spire` 선택 시 `Final Warning Preview`가 보여야 한다.
- `inverted_spire_covenant` 플래그가 없을 때와 있을 때 상태/차단 문구가 달라져야 한다.
- 다른 대표 구간은 기존 preview를 유지해야 한다.
- admin menu GUT와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)

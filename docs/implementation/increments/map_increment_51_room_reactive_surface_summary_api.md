---
title: 맵 증분 51 - 방 반응형 surface summary API
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_37_admin_reactive_residue_summary.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_38_admin_payoff_density.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_42_admin_surface_mix.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 51 - 방 반응형 surface summary API

## 목표

관리자 메뉴가 raw `rooms.json`을 다시 해석하지 않고도 방별 `Board / Echo / Gate / Density / Final payoff` 구조를 읽을 수 있도록 owner_core 쪽 read-only summary API를 제공한다.

## 이번에 잠그는 내용

- `GameDatabase.get_room_reactive_surface_summary(room_id)`는 방별 반응형 surface 구조를 dictionary로 반환한다.
- 요약 필드는 `board_count`, `echo_count`, `gate_count`, `total_reactive_surfaces`, `payoff_density`, `final_payoff_surface_count`다.
- `GameDatabase.get_room_reactive_surface_summaries()`는 전체 방 요약을 duplicate copy로 반환한다.
- `final_payoff_surface_count`는 `inverted_spire_covenant`에 반응하는 board/echo surface와 최심층 gate line까지 포함한 owner_core source-of-truth 지표다.

## 구현 변경

- [scripts/autoload/game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)
  - 방 반응형 surface summary read-only API와 helper를 추가한다.
- [tests/test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd)
  - 허브/최심층 summary shape, unknown room 처리, duplicate 반환을 검증한다.

## 검증

- `test_game_database_get_room_reactive_surface_summary_returns_read_only_overview`
- `test_game_database_get_room_reactive_surface_summary_returns_empty_for_unknown_room`
- `test_game_database_get_room_reactive_surface_summaries_return_duplicate_not_reference`

## 보류

- `scripts/admin/admin_menu.gd`의 실제 소비 전환
- weakest-link 문구 재계산
- GUI 표현 상세 튜닝

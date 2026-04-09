---
title: 맵 증분 52 - 방 weakest-link summary API
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_43_admin_weakest_link_summary.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_51_room_reactive_surface_summary_api.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 52 - 방 weakest-link summary API

## 목표

관리자 메뉴가 prototype room weakest-link 문구를 로컬 조건문으로 다시 계산하지 않고도, 현재 progression flag와 generated route-room 기준의 `가장 얇은 고리`를 owner_core read-only API에서 직접 읽을 수 있게 만든다.

## 이번에 잠그는 내용

- `GameState.get_room_weakest_link_summary(room_id)`는 story anchor 6개와 generated prototype route room의 weakest-link 상태를 dictionary로 반환한다.
- 요약 필드는 `message`, `is_locked`, `next_focus`, `blocking_flags`다.
- `GameState.get_room_weakest_link_summaries()`는 현재 prototype flow catalog 순서 전체를 duplicate copy 배열로 반환한다.
- weakest-link 판정은 현재 admin 문구와 동일한 기준을 따르되, user decision이 필요한 컷신/직접 조우 계열 판단은 계속 포함하지 않는다.

## 구현 변경

- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
  - story anchor + generated route room weakest-link read-only API를 유지한다.
- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
  - weakest-link 문구를 로컬 조건문으로 재계산하지 않고 `GameState` API를 직접 소비한다.
  - room selector는 same-turn follow-up 기준으로 같은 prototype catalog를 paged window로만 렌더링한다.
- [tests/test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd)
  - 7F 진행 gap 추적, 10F covenant gate 판정, duplicate-safe 반환을 검증한다.
- [docs/collaboration/workstreams/owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)
  - friend_gui가 paged selector 위에서 weakest-link / catalog consumer를 계속 확장할 수 있다는 handoff를 남긴다.

## 검증

- `test_game_state_room_weakest_link_summary_tracks_progression_gaps`
- `test_game_state_room_weakest_link_summary_covers_final_room_and_unknown_room`
- `test_game_state_room_weakest_link_summaries_return_duplicate_not_reference`

## 보류

- weakest-link 기반 자동 정렬
- 사용자 결정이 필요한 컷신/직접 조우 계열 판정

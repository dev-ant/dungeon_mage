---
title: 맵 증분 43 - 관리자 메뉴 weakest link 요약
doc_type: increment
status: active
section: implementation
owner: runtime
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 43 - 관리자 메뉴 weakest link 요약

## 목표

관리자 메뉴가 현재 선택한 대표 방의 검증 정보에서 `가장 먼저 보강해야 할 약한 고리`를 한 줄로 바로 요약하게 만든다.

## 이번에 잠그는 내용

- `Resources` 탭은 기존 `Verification Status`, `Payoff Density`, `Surface Mix`를 바탕으로 `Weakest Link`를 출력한다.
- `Weakest Link`는 현재 방이 아직 놓치고 있는 단서 축인지, 이미 잠겼다면 다음 위험이 handoff/polish 쪽인지 알려준다.
- 이 요약은 사용자가 직접 구현 backlog를 다시 해석하지 않아도 `지금 이 방에서 무엇이 가장 얇은가`를 즉시 판단하는 현재 기준으로 잠긴다.

## 구현 메모

- `scripts/admin/admin_menu.gd`
  - 대표 방별 progression 상태를 읽어 `Weakest Link` 한 줄을 생성하는 helper를 추가한다.
  - `Resources` 탭 본문에 `Weakest Link` 블록을 추가한다.
- `tests/test_admin_menu.gd`
  - `throne_approach`, `inverted_spire`에서 weakest-link 문장이 기대한 방향으로 노출되는지 검증한다.

## 검증

- `test_admin_menu_can_select_prototype_room_directly_from_preview_buttons`
- `test_admin_menu_final_warning_preview_reflects_covenant_state`

## 보류

- 자동 우선순위 정렬
- 여러 방을 동시에 비교하는 weakest-link 보드
- 사용자 결정이 필요한 컷신/직접 조우 계열 weakest-link 판정

---
title: 맵 증분 42 - 관리자 메뉴 reactive surface mix
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

# 맵 증분 42 - 관리자 메뉴 reactive surface mix

## 목표

관리자 메뉴가 현재 선택된 대표 방의 payoff 총량뿐 아니라, 그 payoff가 어떤 종류의 반응형 surface로 구성되는지도 바로 읽을 수 있게 만든다.

## 이번에 잠그는 내용

- `Resources` 탭은 기존 `Reactive Residue`, `Payoff Density`에 더해 `Surface Mix`를 보여준다.
- `Surface Mix`는 현재 방의 반응형 payoff를 `Board / Echo / Gate` 개수로 요약한다.
- 이 요약은 방별 reactive payoff가 `허브 공지판 중심인지`, `echo repeat 중심인지`, `최심층 gate line 중심인지`를 한눈에 검증하는 현재 기준으로 잠긴다.

## 구현 메모

- `scripts/admin/admin_menu.gd`
  - 선택된 대표 방의 reactive surface 개수를 집계하는 helper를 추가한다.
  - `Resources` 탭 본문에 `Surface Mix` 블록을 추가한다.
- `tests/test_admin_menu.gd`
  - `throne_approach`, `inverted_spire` 선택 시 `Surface Mix`가 예상 개수를 보여주는지 검증한다.

## 검증

- `test_admin_menu_can_select_prototype_room_directly_from_preview_buttons`
- `test_admin_menu_final_warning_preview_reflects_covenant_state`

## 보류

- 시각적 스크린샷 프리뷰
- 컷신/연출 타입별 별도 분류
- 사용자 결정이 필요한 직접 조우 surface 표기

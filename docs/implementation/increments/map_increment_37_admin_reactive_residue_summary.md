---
title: 관리자 반응형 잔흔 요약
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 관리자 반응형 잔흔 요약

## 이번 증분에서 잠근 내용

- 관리자 `Resources` 탭은 이제 현재 선택된 대표 방의 `반응형 잔흔`을 요약한다.
- 여기서 잔흔은 `refuge_notice` 같은 board 반응, `echo`의 repeat payoff, 그리고 최심층의 gate line 같은 공간 해석 반응을 함께 뜻한다.
- 현재 `Reactive Residue`의 source of truth는 `GameState.get_room_reactive_residue_summary(room_id)`이며, 관리자 메뉴는 더 이상 stage-message 선택과 gate-line 합성을 로컬에서 중복 계산하지 않는다.

## 의도

- 허브, 왕좌 접근, 최심층에서 이미 구현한 반응형 공간 payoff를 관리자 메뉴에서도 즉시 읽을 수 있어야 한다.
- 따라서 source-of-truth는 이제 `state marker`, `room/path note`, `clue check`뿐 아니라 `reactive residue summary`와도 정합해야 한다.

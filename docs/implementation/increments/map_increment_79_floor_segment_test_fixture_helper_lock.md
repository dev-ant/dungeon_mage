---
title: 맵 증분 79 - floor segment test fixture helper 잠금
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_78_floor_segment_test_helper_canonical_only.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 79 - floor segment test fixture helper 잠금

## 목표

`tests/test_game_state.gd` 안에서 흩어져 있던 floor-segment legacy fixture payload를 helper로 묶어, canonical-only 회귀 테스트 입력 소스를 한 곳으로 고정한다.

## 이번에 잠근 결정

- `tests/test_game_state.gd`에 `_make_test_room_with_floor_segments()`와 legacy fixture helper 3개를 추가했다.
- floor-segment validation 테스트는 raw legacy payload 하드코딩 대신 위 helper를 사용한다.
- `tests/test_project_rules.gd`에 fixture helper 존재 규칙을 추가해, 향후 legacy fixture가 다시 산개되는 회귀를 막는다.

## 왜 지금 잠갔는가

- validator/helper가 canonical-only로 잠긴 뒤에도 테스트 fixture가 산개하면 메시지/shape 회귀 수정 시 누락 위험이 커진다.
- 입력 fixture를 helper로 모으면 다음 변경에서 수정 지점이 줄고 테스트 의도가 더 명확해진다.

## 이번 증분에서 확인한 것

- floor-segment targeted 테스트(`test_game_state`, `test_project_rules`, `test_room_builder`)가 통과한다.
- headless boot와 전체 GUT 검증도 유지된다.

## 의도적으로 제외한 것

- runtime floor-segment 파싱/충돌 규칙 변경
- `floor_segments` payload schema 재설계

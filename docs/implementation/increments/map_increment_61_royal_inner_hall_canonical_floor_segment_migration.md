---
title: 맵 증분 61 - royal inner hall canonical floor segment migration
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_60_gate_threshold_canonical_floor_segment_migration.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 61 - royal inner hall canonical floor segment migration

## 목표

checked-in canonical anchor migration을 8층 `royal_inner_hall`까지 확장해서, labyrinth-scale story anchor가 깊은 층으로 갈수록 같은 room-level canonical contract를 계속 유지한다는 사실을 잠근다.

## 이번에 잠근 결정

- 다음 canonical checked-in anchor는 `royal_inner_hall`로 둔다.
- `royal_inner_hall`은 room 단위 canonical migration을 적용한다.
- 모든 `floor_segments` entry를 `{position, size}` dictionary로 통일하고 `floor_segment_format = canonical_dict`를 기록한다.
- thin segment는 기본 추론만으로 one-way/platform 의미가 닫히면 override를 따로 남기지 않는다.

## 왜 이 방을 골랐는가

- `gate_threshold` 다음 anchor인 8층 `royal_inner_hall`은 canonical migration 흐름을 story floor order대로 확장하는 가장 자연스러운 다음 칸이다.
- archive approach lane, upper support-trace lane, side living-space pocket이 모두 분명해서 canonical migration 후에도 traversal rhythm이 유지되는지 검증하기 쉽다.
- 사용자 추가 결정 없이 gradual migration 규칙만 한 단계 더 적용하는 안전한 증분이다.

## 이번 증분에서 실제로 확인한 것

- checked-in canonical anchor가 `entrance`, `seal_sanctum`, `gate_threshold`, `royal_inner_hall` 네 곳으로 늘었다.
- `GameDatabase.get_room("royal_inner_hall")`는 canonical dictionary floor-segment data를 반환한다.
- `room_builder`는 이 canonical data를 그대로 읽어 upper support-trace thin segment를 one-way collision으로 계속 빌드한다.

## 여전히 보류한 것

- `throne_approach`, `inverted_spire` 등 남은 checked-in anchor migration
- 전체 `rooms.json` canonical migration
- legacy support 제거 시점 결정

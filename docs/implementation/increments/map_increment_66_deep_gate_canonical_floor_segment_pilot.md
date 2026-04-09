---
title: 맵 증분 66 - deep gate canonical floor segment pilot
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_65_void_rift_canonical_floor_segment_pilot.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 66 - deep gate canonical floor segment pilot

## 목표

story anchor 바깥의 checked-in route room에도 canonical floor-segment contract를 계속 안전하게 확장할 수 있는지 확인하기 위해, `deep_gate`를 세 번째 non-anchor canonical pilot으로 옮긴다.

## 이번에 잠근 결정

- 세 번째 non-anchor checked-in canonical pilot room은 `deep_gate`로 둔다.
- `deep_gate`는 room 단위 canonical migration을 적용한다.
- 모든 `floor_segments` entry를 `{position, size}` dictionary로 통일하고 `floor_segment_format = canonical_dict`를 기록한다.
- 상단 gate perch는 기본 추론만으로 one-way/platform 의미가 닫히면 override를 따로 남기지 않는다.

## 왜 이 방을 골랐는가

- `deep_gate`는 남은 legacy non-anchor room 중 segment 수가 가장 적고 corridor-style route room이라 canonical pilot을 한 칸 더 넓히기에 가장 안전하다.
- ascent stair cadence와 top gate perch가 분명해서 canonical migration 후에도 room-builder 해석이 유지되는지 검증하기 쉽다.
- 사용자 추가 결정 없이 gradual migration 규칙을 non-anchor route room까지 한 칸 더 넓히는 최소 증분이다.

## 이번 증분에서 실제로 확인한 것

- checked-in canonical room이 story anchor 6개와 `arcane_core`, `void_rift`에 더해 `deep_gate`까지 아홉 곳으로 늘었다.
- `GameDatabase.get_room("deep_gate")`는 canonical dictionary floor-segment data를 반환한다.
- `room_builder`는 이 canonical data를 그대로 읽어 top gate perch thin segment를 one-way collision으로 계속 빌드한다.

## 여전히 보류한 것

- 남은 checked-in non-anchor room migration
- 전체 `rooms.json` canonical migration
- legacy support 제거 시점 결정

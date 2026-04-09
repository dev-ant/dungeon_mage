---
title: 맵 증분 62 - throne approach canonical floor segment migration
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_61_royal_inner_hall_canonical_floor_segment_migration.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 62 - throne approach canonical floor segment migration

## 목표

checked-in canonical anchor migration을 9층 `throne_approach`까지 확장해서, story-floor 마지막 접근 구간도 room-level canonical floor-segment contract로 묶는다.

## 이번에 잠근 결정

- 다음 canonical checked-in anchor는 `throne_approach`로 둔다.
- `throne_approach`는 room 단위 canonical migration을 적용한다.
- 모든 `floor_segments` entry를 `{position, size}` dictionary로 통일하고 `floor_segment_format = canonical_dict`를 기록한다.
- thin stair segment와 waiting pocket은 기본 추론만으로 one-way/platform 의미가 닫히면 override를 따로 남기지 않는다.

## 왜 이 방을 골랐는가

- `royal_inner_hall` 다음 anchor인 9층 `throne_approach`는 canonical migration 흐름을 story floor order대로 이어 가는 가장 자연스러운 다음 칸이다.
- procession stair cadence, decree stand ascent, side waiting pocket이 분명해서 canonical migration 후에도 traversal rhythm이 유지되는지 검증하기 쉽다.
- 사용자 추가 결정 없이 gradual migration 규칙만 한 단계 더 적용하는 안전한 증분이다.

## 이번 증분에서 실제로 확인한 것

- checked-in canonical anchor가 `entrance`, `seal_sanctum`, `gate_threshold`, `royal_inner_hall`, `throne_approach` 다섯 곳으로 늘었다.
- `GameDatabase.get_room("throne_approach")`는 canonical dictionary floor-segment data를 반환한다.
- `room_builder`는 이 canonical data를 그대로 읽어 decree stair thin segment를 one-way collision으로 계속 빌드한다.

## 여전히 보류한 것

- `inverted_spire` 등 남은 checked-in anchor migration
- 전체 `rooms.json` canonical migration
- legacy support 제거 시점 결정

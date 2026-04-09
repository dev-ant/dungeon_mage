---
title: 맵 증분 59 - floor segment canonical format lock
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_58_second_anchor_floor_segment_dict_pilot.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 59 - floor segment canonical format lock

## 목표

사용자 결정이 필요한 `floor_segments` canonical authoring format을 잠그고, 그 결정이 generated room emit, checked-in room migration, validator, tooling까지 같은 방향으로 작동하게 만든다.

## 이번에 잠근 결정

- canonical authoring format은 dictionary `{position: [x, y], size: [width, height]}`로 둔다.
- `decor_kind`, `collision_mode` override는 필요할 때만 적는다.
- generated prototype room은 모두 canonical dictionary `floor_segments`를 emit한다.
- checked-in `rooms.json`은 touched room부터 room 단위로 canonical migration 한다.
- validator는 `floor_segment_format = canonical_dict`인 room에서 legacy array와 `x/y/width/height` fallback을 금지한다.
- migration tool은 `scripts/tools/floor_segment_canonicalizer.gd`로 둔다.

## 이번 증분에서 실제로 옮긴 범위

- generated prototype room 전체를 canonical emit으로 전환했다.
- 이미 touched 상태였던 `entrance`, `seal_sanctum`은 room 단위 canonical migration으로 정리했다.
- 기존 thin platform pilot에 들어가 있던 redundant `decor_kind = platform`, `collision_mode = one_way_platform`는 canonical rule에 맞춰 제거했다.

## 왜 이 선에서 멈췄는가

- 사용자 결정은 이제 잠겼지만, checked-in room 전체를 한 번에 바꾸는 것은 불필요하게 큰 diff와 회귀 범위를 만든다.
- current target은 canonical rule을 실제 runtime path와 authoring path에 동시에 연결하는 것이지, 전면 JSON migration을 같은 턴에 끝내는 것이 아니다.

## 여전히 보류한 것

- `rooms.json`의 나머지 checked-in room 전체 migration
- canonical migration tool을 CI나 editor workflow에 연결하는 일
- room builder가 legacy array support를 완전히 제거하는 시점 결정

---
title: 맵 증분 55 - floor segment validation seam
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_54_floor_segment_override_schema.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 55 - floor segment validation seam

## 목표

`floor_segments` additive schema를 실제 authoring seam에서도 안전하게 유지하도록, startup validation contract를 잠근다.

## 이번에 잠근 결정

- `GameDatabase`는 room load 시 spawn validation과 별도로 `floor_segments` validation report를 만든다.
- 현재 validator는 legacy array `[x, y, width, height]`와 additive dictionary entry 둘 다 허용한다.
- dictionary entry는 `position/size` 또는 `x/y/width/height`를 쓸 수 있지만, malformed vector/scalar 조합은 바로 error로 기록한다.
- `decor_kind`는 `ground`, `platform`만 허용하고, `collision_mode`는 `solid`, `one_way_platform`만 허용한다.
- size가 0 이하인 segment와 non-array/non-dictionary entry는 runtime authoring error로 취급한다.

## 왜 이 결정을 잠갔는가

- 지금 필요한 건 format debate보다, checked-in room data와 future override entry가 조용히 망가지지 않도록 early failure seam을 두는 것이다.
- 이 validator는 실제 `rooms.json` 마이그레이션 없이도 additive schema를 안전하게 쓸 수 있게 해 준다.

## 여전히 보류한 것

- array와 dictionary 중 어떤 형식을 장기 canonical authoring format으로 둘지에 대한 최종 결정
- `data/rooms.json` 전면 마이그레이션
- editor-side authoring UI나 자동 fixer 추가

## 현재 후속 판단 메모

- canonical format 결정은 아직 사용자 판단이 필요한 영역이므로 이번 증분에서는 잠그지 않았다.
- 그 전까지는 `runtime accepts both + validator guards both`를 current contract로 유지한다.

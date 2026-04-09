---
title: 맵 증분 69 - floor segment legacy runtime boundary
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_68_vault_sector_canonical_floor_segment_completion.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 69 - floor segment legacy runtime boundary

## 목표

checked-in `rooms.json`과 generated prototype room이 모두 canonical dict `floor_segments`로 잠긴 상태를 활용해, runtime default path에서 legacy floor-segment shape를 더 이상 기본 허용하지 않도록 경계를 한 단계 좁힌다.

## 이번에 잠근 결정

- `scripts/world/room_builder.gd`의 기본 build path는 이제 canonical dictionary `{position, size}` entry만 읽는다.
- legacy array `[x, y, width, height]`와 `x/y/width/height` fallback은 `floor_segment_format = legacy_array`를 명시한 room에서만 compatibility path로 읽는다.
- `GameDatabase` validator도 같은 경계를 따른다. format이 비어 있는 room은 canonical-style dictionary만 허용하고, legacy shape를 쓰려면 explicit `legacy_array` 선언이 필요하다.
- canonical room strictness는 유지한다. `floor_segment_format = canonical_dict`인 room은 계속 `position/size` array authoring만 허용한다.

## 왜 지금 이 경계를 잠갔는가

- checked-in room과 generated room이 이미 전부 canonical이라, runtime default path까지 canonical-first로 좁혀도 live gameplay risk가 거의 없다.
- legacy parsing을 완전히 삭제하기 전 단계로, compatibility가 실제로 필요한 곳을 `legacy_array` seam으로 눈에 보이게 만들 수 있다.
- 이후 최종 제거 작업은 parser branch 삭제가 아니라 `legacy_array` consumer 0개 확인 문제로 단순화된다.

## 이번 증분에서 실제로 확인한 것

- checked-in room build와 generated floor 5 build는 모두 계속 canonical path에서 정상 동작한다.
- one-way platform collision, boundary wall count, representative landmark build는 canonical fixture 기준으로 그대로 유지된다.
- explicit `legacy_array` format을 준 synthetic room fixture는 여전히 old array / fallback dictionary compatibility를 유지한다.

## 여전히 보류한 것

- `legacy_array` compatibility seam 자체를 완전히 삭제하는 시점
- migration bridge/test fixture 외 다른 consumer가 미래에 필요한지에 대한 최종 cleanup 판단

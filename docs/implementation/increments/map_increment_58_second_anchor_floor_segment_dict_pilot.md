---
title: 맵 증분 58 - second anchor floor segment dict pilot
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_57_anchor_floor_segment_dict_pilot.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 58 - second anchor floor segment dict pilot

## 목표

checked-in base data path가 한 방짜리 예외가 아니라, 여러 anchor room에서도 같은 additive contract로 안전하게 유지된다는 사실을 잠근다.

## 이번에 잠근 결정

- 두 번째 pilot target은 `seal_sanctum`으로 둔다.
- `seal_sanctum`의 thin support platform 1개만 dictionary entry로 바꾼다.
- 이 pilot entry도 `position/size` array와 explicit `decor_kind = platform`, `collision_mode = one_way_platform`를 함께 사용한다.
- 이미 pilot migration 된 `entrance`와 함께, checked-in anchor room 2개가 now-live dict path를 가진 상태를 current contract로 본다.

## 왜 이 선에서 멈췄는가

- 목적은 canonical format 결정을 미리 강제하는 것이 아니라, base-data path가 2개 anchor에서도 안정적으로 동작함을 증명하는 것이다.
- `seal_sanctum`은 대표 rhythm lock을 깨지 않고, hub anchor에서도 같은 authoring contract가 먹힌다는 것을 보여 주는 가장 작은 후속 위치다.

## 여전히 보류한 것

- 나머지 anchor room migration
- `rooms.json` 전면 migration
- canonical authoring format 최종 결정

## 현재 후속 판단 메모

- canonical format 결정은 아직 사용자 판단이 필요한 영역이므로 이번 증분에서도 잠그지 않았다.
- 그 전까지는 `legacy majority + floor 5 generated live dict + entrance/seal_sanctum pilot dict + shared validator`를 current contract로 유지한다.

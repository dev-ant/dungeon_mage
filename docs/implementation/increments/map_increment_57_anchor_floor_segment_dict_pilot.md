---
title: 맵 증분 57 - anchor floor segment dict pilot
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_56_floor5_live_floor_segment_dict.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 57 - anchor floor segment dict pilot

## 목표

generated room 다음 단계로, checked-in `rooms.json` anchor data에도 additive floor-segment schema를 아주 작게 적용해 base-data path를 실사용 상태로 검증한다.

## 이번에 잠근 결정

- pilot target은 `entrance` room으로 둔다.
- `entrance`의 thin support platform 1개만 dictionary entry로 바꾼다.
- 이 pilot entry는 `position/size` array와 explicit `decor_kind = platform`, `collision_mode = one_way_platform`를 함께 사용한다.
- 대표 방의 나머지 segment index/높이/폭 계약은 이번 증분에서 유지한다.

## 왜 이 선에서 멈췄는가

- checked-in base data path를 실제로 한 번 밟는 것이 목적이지, anchor room 전체를 한 번에 옮기는 것이 목적은 아니다.
- `entrance`의 보조 thin platform 1개는 대표 rhythm lock을 깨지 않으면서도 room builder, validation seam, checked-in data path를 같이 검증할 수 있는 가장 작은 위치다.

## 여전히 보류한 것

- 다른 anchor room의 dict migration
- `rooms.json` 전면 migration
- canonical authoring format 최종 결정

## 현재 후속 판단 메모

- canonical format 결정은 아직 사용자 판단이 필요한 영역이므로 이번 증분에서도 잠그지 않았다.
- 그 전까지는 `legacy majority + floor 5 generated live dict + entrance pilot dict + shared validator`를 current contract로 유지한다.

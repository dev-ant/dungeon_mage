---
title: 맵 증분 56 - floor 5 live floor segment dict
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_54_floor_segment_override_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_55_floor_segment_validation.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 56 - floor 5 live floor segment dict

## 목표

`floor_segments` additive schema가 테스트용 예제만이 아니라 실제 live room generation 경로에서도 안전하게 쓰인다는 사실을 잠근다.

## 이번에 잠근 결정

- 첫 live consumer는 5층 generated `transition_corridor` route room으로 둔다.
- `GameDatabase._build_floor5_generated_segments()`는 상단 pocket platform 1개를 dictionary entry로 생성한다.
- 이 entry는 `position/size` array와 explicit `decor_kind = platform`, `collision_mode = one_way_platform`를 함께 사용한다.
- 나머지 generated room segment와 checked-in `rooms.json` anchor data는 이번 증분에서 그대로 유지한다.

## 왜 이 선에서 멈췄는가

- 실사용 경로를 한 번 밟는 것이 목적이지, 데이터 전체를 한 번에 옮기는 것이 목적은 아니다.
- floor 5 generated route room은 story anchor data를 건드리지 않고도 runtime, validator, room builder를 한 줄로 검증할 수 있는 가장 작은 위치다.

## 여전히 보류한 것

- `rooms.json` anchor room을 dictionary schema로 옮기는 작업
- generated route room의 다른 segment까지 dictionary로 넓히는 작업
- canonical authoring format 최종 결정

## 현재 후속 판단 메모

- canonical format 결정은 아직 사용자 판단이 필요한 영역이므로 이번 증분에서도 잠그지 않았다.
- 그 전까지는 `legacy arrays stay`, `generated floor 5 proves live dict path`, `validator guards both`를 current contract로 유지한다.

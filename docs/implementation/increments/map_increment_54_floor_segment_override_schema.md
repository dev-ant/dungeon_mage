---
title: 맵 증분 54 - floor segment override schema
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_53_platform_followups.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 54 - floor segment override schema

## 목표

`floor_segments` 전면 재설계나 마이그레이션까지 가지 않고, 현재 one-way platform 계약을 깨지 않는 최소 범위의 additive schema를 잠근다.

## 이번에 잠근 결정

- legacy `floor_segments` array entry `[x, y, width, height]`는 그대로 유지한다.
- room builder는 같은 배열 안에서 dictionary entry도 함께 해석한다.
- dictionary entry는 `position/size` 또는 `x/y/width/height`를 사용할 수 있다.
- dictionary entry는 optional `decor_kind` override로 `ground` 또는 `platform` visual branch를 강제할 수 있다.
- dictionary entry는 optional `collision_mode` override로 `solid` 또는 `one_way_platform` collision branch를 강제할 수 있다.
- override를 생략하면 기존과 동일하게 thin 여부로 decor/collision이 자동 결정된다.
- invalid dictionary entry는 현재 runtime에서 warning 후 무시한다.

## 왜 이 선에서 멈췄는가

- 현재 목표는 one-way platform과 drop-through gameplay contract를 안정화하는 것이다.
- 전체 `rooms.json` 마이그레이션까지 이번 턴에 열면 데이터 diff 범위가 커지고, 기존 representative room 검증선과 충돌 위험이 커진다.
- 그래서 authoring flexibility는 추가하되, 기존 room data는 그대로 두는 쪽으로 잠갔다.

## 이번 범위 밖

- `data/rooms.json` 전체를 dictionary schema로 옮기는 작업
- floor segment authoring tool 또는 validator 추가
- `player.gd` drop-through helper의 추가 일반화

## 남겨 둔 결정

- 나중에 `floor_segments`를 전면 마이그레이션할지, 아니면 array + dictionary 공존 계약을 계속 canonical로 둘지는 아직 사용자 결정이 필요하다.
- 그 결정이 있기 전까지는 runtime이 두 형식을 모두 읽는 현재 additive contract를 baseline으로 유지한다.

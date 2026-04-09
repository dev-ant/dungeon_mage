---
title: 맵 증분 60 - gate threshold canonical floor segment migration
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_59_floor_segment_canonical_lock.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 60 - gate threshold canonical floor segment migration

## 목표

canonical format 결정 이후, checked-in anchor room migration이 `entrance`, `seal_sanctum`에서 멈추지 않고 다음 anchor에도 같은 규칙으로 확장된다는 사실을 잠근다.

## 이번에 잠근 결정

- 다음 canonical checked-in anchor는 `gate_threshold`로 둔다.
- `gate_threshold`는 room 단위 canonical migration을 적용한다.
- 모든 `floor_segments` entry를 `{position, size}` dictionary로 통일하고 `floor_segment_format = canonical_dict`를 기록한다.
- thin platform override가 기본 추론과 같은 값이면 canonical data에는 남기지 않는다.

## 왜 이 방을 골랐는가

- `gate_threshold`는 7층 anchor라서 이미 canonicalized 된 `entrance`, `seal_sanctum` 다음 단계로 자연스럽다.
- platform cadence와 holding pocket rhythm이 뚜렷해서, canonical migration 후에도 traversal silhouette가 유지되는지 테스트로 확인하기 쉽다.
- 사용자 추가 결정 없이 touched-room gradual migration 규칙만 확장하는 가장 작은 후속 단위다.

## 이번 증분에서 실제로 확인한 것

- checked-in canonical anchor가 `entrance`, `seal_sanctum`, `gate_threshold` 세 곳으로 늘었다.
- `GameDatabase.get_room("gate_threshold")`는 canonical dictionary floor-segment data를 반환한다.
- `room_builder`는 이 canonical data를 그대로 읽어 upper checkpoint thin segment를 one-way collision으로 계속 빌드한다.

## 여전히 보류한 것

- 나머지 checked-in anchor room migration
- 전체 `rooms.json` canonical migration
- legacy support 제거 시점 결정

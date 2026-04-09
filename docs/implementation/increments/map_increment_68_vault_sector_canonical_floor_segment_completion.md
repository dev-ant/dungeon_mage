---
title: 맵 증분 68 - vault sector canonical floor segment completion
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_67_conduit_canonical_floor_segment_pilot.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 68 - vault sector canonical floor segment completion

## 목표

마지막 checked-in legacy room인 `vault_sector`를 canonical floor-segment contract로 옮겨서, checked-in `rooms.json` 전체를 room-level canonical dict authoring 상태로 닫는다.

## 이번에 잠근 결정

- 마지막 checked-in legacy room은 `vault_sector`로 두고 이번 증분에서 canonical migration을 끝낸다.
- `vault_sector`는 room 단위 canonical migration을 적용한다.
- 모든 `floor_segments` entry를 `{position, size}` dictionary로 통일하고 `floor_segment_format = canonical_dict`를 기록한다.
- upper vault perch는 기본 추론만으로 one-way/platform 의미가 닫히면 override를 따로 남기지 않는다.

## 왜 이 방을 골랐는가

- `vault_sector`를 옮기면 checked-in `rooms.json` 전체가 canonical dict contract로 닫혀서, 이후 증분은 migration보다 legacy runtime support 제거 여부에 집중할 수 있다.
- ascent stair cadence, upper vault perch, elite lane이 분명해서 canonical migration 후에도 room-builder 해석이 유지되는지 검증하기 쉽다.
- 사용자 추가 결정 없이 existing canonical rollout을 자연스럽게 마감하는 최소 증분이다.

## 이번 증분에서 실제로 확인한 것

- checked-in `rooms.json`의 모든 room이 canonical dictionary floor-segment data를 사용한다.
- `GameDatabase.get_room("vault_sector")`는 canonical dictionary floor-segment data를 반환한다.
- `room_builder`는 이 canonical data를 그대로 읽어 upper vault perch thin segment를 one-way collision으로 계속 빌드한다.
- legacy array read support는 이제 checked-in data가 아니라 migration bridge/test fixture 호환 용도로만 남는다.

## 여전히 보류한 것

- runtime legacy array read support 제거 시점과 범위
- 전체 runtime에서 legacy parsing branch를 언제 테스트 fixture 전용으로 축소할지 결정

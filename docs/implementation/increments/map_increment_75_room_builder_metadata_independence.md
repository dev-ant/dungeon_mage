---
title: 맵 증분 75 - room builder metadata 독립성 잠금
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_74_floor_segment_format_key_retirement.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 75 - room builder metadata 독립성 잠금

## 목표

`floor_segment_format` key 퇴역 이후 runtime room builder가 metadata key에 재의존하지 않도록 테스트 계약을 명시적으로 잠근다.

## 이번에 잠근 결정

- `tests/test_room_builder.gd` legacy regression fixture에서 `floor_segment_format` 입력을 제거했다.
- 같은 테스트는 이제 format flag 유무가 아니라 `floor_segments` raw entry shape만으로 legacy skip 동작을 검증한다.
- `tests/test_project_rules.gd`에 `scripts/world/room_builder.gd` source가 `floor_segment_format` 문자열을 참조하지 않는 규칙 테스트를 추가했다.

## 왜 지금 잠갔는가

- validator에서 `floor_segment_format` key를 금지한 뒤에도 runtime 테스트 fixture가 key를 계속 들고 있으면 계약이 혼합된다.
- runtime과 tooling의 canonical-only 방향을 유지하려면 room_builder가 metadata가 아닌 shape/override만 소비한다는 사실을 테스트로 고정해야 한다.

## 이번 증분에서 확인한 것

- room_builder regression은 metadata key 없이도 legacy array/fallback dictionary skip 동작을 그대로 유지한다.
- project rule 테스트는 room_builder source가 retired key 참조를 다시 들여오지 않게 막는다.
- floor-segment targeted/전체 GUT 및 headless boot는 변경 후에도 통과한다.

## 의도적으로 제외한 것

- floor segment payload schema 변경
- player drop-through/helper 추가 기능

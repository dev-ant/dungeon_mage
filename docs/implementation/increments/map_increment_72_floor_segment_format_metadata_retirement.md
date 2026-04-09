---
title: 맵 증분 72 - floor segment format metadata retirement
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_71_floor_segment_tooling_canonical_only.md
last_updated: 2026-04-08
last_verified: 2026-04-08
---

# 맵 증분 72 - floor segment format metadata retirement

## 목표

canonical-only contract가 잠긴 뒤 남아 있던 `floor_segment_format = canonical_dict` 기록을 live room data에서 제거해 `floor_segments` authoring payload를 더 단순하게 만든다.

## 이번에 잠근 결정

- generated prototype room emit은 더 이상 `floor_segment_format`를 기록하지 않는다.
- checked-in `rooms.json`도 `floor_segment_format` metadata를 기록하지 않는다.
- room validation은 `floor_segments` shape를 source of truth로 유지한다. metadata가 없어도 canonical contract로 동작한다.
- metadata가 입력될 경우 validator는 계속 `canonical_dict`만 허용해 backward compatibility safety rail을 유지한다.

## 왜 지금 잠갔는가

- runtime/validation/tooling이 이미 canonical-only shape를 강제하므로 format metadata는 중복 정보였다.
- 중복 필드를 제거하면 room fixture와 migration diff가 짧아지고, 계약 위반 원인이 payload shape로 바로 수렴한다.

## 이번 증분에서 확인한 것

- generated floor 5와 checked-in representative room은 metadata 없이도 canonical dictionary floor segments를 유지한다.
- floor-segment targeted tests와 room-builder regression은 계속 통과한다.

## 의도적으로 제외한 것

- `floor_segment_format` 키 자체를 validator에서 완전히 금지하는 breaking change
- historical increment 문서의 전면 archive 정리

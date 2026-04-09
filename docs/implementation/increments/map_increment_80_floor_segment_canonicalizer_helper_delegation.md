---
title: 맵 증분 80 - floor segment canonicalizer helper 위임 잠금
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_79_floor_segment_test_fixture_helper_lock.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 80 - floor segment canonicalizer helper 위임 잠금

## 목표

offline canonicalizer에 남아 있던 floor-segment canonical parse/emit 중복 로직을 제거해, tooling과 runtime이 같은 canonical helper를 단일 source of truth로 공유하게 만든다.

## 이번에 잠근 결정

- `scripts/tools/floor_segment_canonicalizer.gd`는 더 이상 자체 `_normalize_floor_segment_to_canonical()`/`_read_floor_segment_vector2()`/`_make_floor_segment_entry()`를 유지하지 않는다.
- canonicalizer는 각 segment 정규화 시 `GameDatabase.normalize_floor_segment_to_canonical_dictionary()`를 직접 호출한다.
- `tests/test_project_rules.gd`에 canonicalizer helper 위임 계약을 추가해, 중복 helper 재유입 회귀를 차단한다.

## 왜 지금 잠갔는가

- canonical 규칙이 runtime helper와 tooling helper에 분산되면 다음 계약 변경 때 drift 위험이 커진다.
- helper를 단일화하면 canonical parse/override trim 규칙을 한 곳만 수정해도 runtime과 tooling이 동시에 같은 결과를 유지한다.

## 이번 증분에서 확인한 것

- project-rules 테스트에서 canonicalizer helper 위임 계약이 통과한다.
- headless 부팅과 전체 GUT 검증이 유지된다.

## 의도적으로 제외한 것

- `floor_segments` schema 재설계/마이그레이션
- player drop-through 동작 확장
- runtime room-builder collision 규칙 변경

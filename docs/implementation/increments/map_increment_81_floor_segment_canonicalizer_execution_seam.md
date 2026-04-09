---
title: 맵 증분 81 - floor segment canonicalizer 실행 seam 잠금
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_80_floor_segment_canonicalizer_helper_delegation.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 81 - floor segment canonicalizer 실행 seam 잠금

## 목표

offline floor-segment canonicalizer의 실패 경로를 source 문자열 검사가 아니라 안정적인 headless 단위 테스트로 직접 고정한다.

## 이번에 잠근 결정

- `scripts/tools/floor_segment_canonicalizer.gd`에 static helper `build_floor_segment_normalization_result(room_id, floor_segments)`를 추가했다.
- helper 반환 계약은 `{ok, segments, error}`로 고정했다.
- canonicalizer 본 함수 `_normalize_floor_segments_to_canonical()`는 위 helper를 호출하고, `ok=false`일 때만 `push_error`를 발생시킨다.
- `tests/test_floor_segment_canonicalizer.gd`를 추가해 canonical 입력 성공, legacy array 거부, mixed 입력의 첫 invalid index 보고를 고정했다.

## 왜 지금 잠갔는가

- 실행형 tool script는 직접 프로세스 통합 테스트가 무겁고 flaky해지기 쉽다.
- static seam으로 계약을 분리하면 `quit()`/CLI 흐름과 독립적으로 핵심 정규화/오류 보고 규칙을 빠르게 회귀 검증할 수 있다.

## 이번 증분에서 확인한 것

- canonicalizer 신규 테스트와 project-rules 테스트가 통과한다.
- headless boot와 전체 GUT 검증도 유지된다.

## 의도적으로 제외한 것

- `floor_segments` schema 재설계/마이그레이션
- player drop-through 동작 확장
- canonicalizer CLI 인자 체계 변경

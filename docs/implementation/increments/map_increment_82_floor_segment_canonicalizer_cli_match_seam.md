---
title: 맵 증분 82 - floor segment canonicalizer CLI match seam 잠금
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_81_floor_segment_canonicalizer_execution_seam.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 82 - floor segment canonicalizer CLI match seam 잠금

## 목표

offline floor-segment canonicalizer의 room-id selection 실패 경로를 static helper seam으로 분리해 CLI 계약도 headless 단위 테스트로 고정한다.

## 이번에 잠근 결정

- `scripts/tools/floor_segment_canonicalizer.gd`에 static helper `build_requested_room_match_result(requested_room_ids, rooms)`를 추가했다.
- helper 반환 계약은 `{ok, matched_indices, error}`로 고정했다.
- canonicalizer `_init()`는 room-id selection을 위 helper로 먼저 판정하고, 실패 시 helper가 준 에러 문자열을 그대로 `push_error` 한다.
- `tests/test_floor_segment_canonicalizer.gd`에 아래 계약 회귀를 추가했다.
  - `requested_room_ids`가 비면 usage error
  - id가 하나도 매치되지 않으면 no-match error
  - 성공 시 room catalog 순서 기준 matched index 반환

## 왜 지금 잠갔는가

- 기존 실행 seam(정규화 계약)만으로는 CLI 초입의 실패 경로를 직접 고정할 수 없었다.
- room-id selection을 static seam으로 분리하면 프로세스 통합 테스트 없이도 usage/no-match 계약 drift를 빠르게 검출할 수 있다.

## 이번 증분에서 확인한 것

- canonicalizer 전용 테스트와 project-rules 테스트가 통과한다.
- headless boot와 전체 GUT 검증이 유지된다.

## 의도적으로 제외한 것

- `floor_segments` schema 재설계/마이그레이션
- player drop-through 동작 확장
- canonicalizer 결과 파일 write 포맷 변경

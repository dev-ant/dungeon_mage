---
title: 맵 증분 77 - floor segment validator parse canonical-only 고정
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_76_floor_segment_legacy_token_alignment.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 77 - floor segment validator parse canonical-only 고정

## 목표

floor-segment validator 내부 helper에 남아 있던 `x/y/width/height` fallback parse 코드를 제거해 runtime/validator/tooling 전체를 canonical array parse 기준으로 더 단단히 잠근다.

## 이번에 잠근 결정

- `GameDatabase._read_validated_room_floor_segment_vector2()`는 이제 `position/size`의 `[x, y]` array만 읽는다.
- validator helper 시그니처에서 `x_key/y_key`, `require_vector_array` 인자를 제거해 fallback parse 경로 자체를 삭제했다.
- `tests/test_game_state.gd`에 `size` array 없이 `width/height`만 준 입력이 거부되는 회귀를 추가했다.
- `tests/test_project_rules.gd`에 validator source에서 fallback parse 토큰(`must define %s/%s when %s is omitted`, `must use numeric %s/%s values`, `x_key/y_key`)이 재유입되지 않음을 고정했다.

## 왜 지금 잠갔는가

- canonical-only 전환이 끝난 뒤에도 validator 내부 dead branch가 남아 있으면 future refactor에서 쉽게 되살아날 수 있다.
- parse helper 시그니처까지 줄여 두면 runtime contract와 테스트 계약이 같은 방향으로 유지된다.

## 이번 증분에서 확인한 것

- floor-segment 관련 validator/room-builder/project-rules 회귀 테스트가 통과한다.
- headless boot 검증이 유지된다.

## 의도적으로 제외한 것

- `floor_segments` payload schema 재설계/마이그레이션
- drop-through 입력/플레이 감각 변경

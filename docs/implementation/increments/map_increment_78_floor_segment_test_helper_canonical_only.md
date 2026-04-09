---
title: 맵 증분 78 - floor segment test helper canonical-only 고정
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_77_floor_segment_validator_parse_canonical_only.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 78 - floor segment test helper canonical-only 고정

## 목표

runtime/validator canonical-only 잠금 이후 테스트 helper에 남아 있던 legacy floor-segment 해석 경로를 제거해 회귀 테스트 레이어도 같은 계약으로 닫는다.

## 이번에 잠근 결정

- `tests/test_game_state.gd`의 `_get_floor_segment_position()`, `_get_floor_segment_size()`는 canonical dictionary의 `position/size` array만 읽는다.
- 같은 helper에서 legacy array `[x, y, width, height]`와 `x/y/width/height` fallback dictionary 해석 분기를 제거했다.
- helper 회귀 테스트를 추가해 legacy shape가 `Vector2.ZERO`로 남고 좌표 변환되지 않음을 고정했다.
- `tests/test_project_rules.gd`에 helper source에서 legacy parse 토큰(`segment_data.get("x"|...)`)이 재유입되지 않는 규칙을 추가했다.

## 왜 지금 잠갔는가

- validator/툴링이 이미 canonical-only인데 테스트 helper만 legacy를 읽으면, 회귀 실패 지점이 실제 runtime 계약과 어긋난다.
- 테스트 seam도 같은 스키마를 읽도록 맞추면 floor-segment 회귀 triage가 더 일관된다.

## 이번 증분에서 확인한 것

- floor-segment 관련 `test_game_state`, `test_project_rules`, `test_room_builder` 회귀가 통과한다.
- 전체 GUT와 headless boot 검증도 유지된다.

## 의도적으로 제외한 것

- `floor_segments` payload schema 재설계/마이그레이션
- player drop-through 감각/입력 로직 변경

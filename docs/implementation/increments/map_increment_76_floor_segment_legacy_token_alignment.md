---
title: 맵 증분 76 - floor segment legacy token 메시지 정렬
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_75_room_builder_metadata_independence.md
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 맵 증분 76 - floor segment legacy token 메시지 정렬

## 목표

floor-segment legacy 입력 회귀를 runtime warning과 validator error 양쪽에서 같은 검색 토큰으로 빠르게 식별할 수 있도록 메시지 계약을 정렬한다.

## 이번에 잠근 결정

- `GameDatabase` floor-segment validation 에러는 legacy array/dictionary 입력 거부 메시지에
  `legacy floor segment array` / `legacy floor segment dictionary` 토큰을 포함한다.
- `tests/test_game_state.gd`는 legacy array/dictionary rejection에서 canonical 포맷 문구뿐 아니라 해당 legacy token도 함께 검증한다.
- `tests/test_project_rules.gd`는 `room_builder.gd`와 `game_database.gd` source가 동일 legacy token 두 개를 모두 유지하는지 규칙 테스트로 고정한다.

## 왜 지금 잠갔는가

- 현재 room builder는 warning, validator는 error를 내는데, 메시지 토큰이 엇갈리면 CI 로그에서 원인 triage가 느려진다.
- shared token을 잠그면 런타임/검증 경로가 달라도 검색 키 하나로 회귀 원인을 추적할 수 있다.

## 이번 증분에서 확인한 것

- floor-segment targeted GUT와 room-builder/project-rules 회귀는 변경 후 통과한다.
- 전체 GUT 및 headless boot 검증도 통과한다.

## 의도적으로 제외한 것

- legacy shape 수용 정책 변경 (계속 reject)
- floor segment payload schema 변경

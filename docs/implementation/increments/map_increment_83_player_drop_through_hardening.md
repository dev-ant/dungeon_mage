---
title: 맵 증분 83 - player drop-through helper 하드닝
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_53_platform_followups.md
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 맵 증분 83 - player drop-through helper 하드닝

## 목표

현재 one-way drop-through helper를 최소 범위로 유지하면서, 재진입/상태 충돌 같은 운영 리스크를 회귀 테스트로 잠근다.

## 이번에 잠근 결정

- `scripts/player/player.gd`에 `_can_start_platform_drop_through(was_on_floor, down_pressed)` gate helper를 추가했다.
- drop-through 시작 조건은 이제 `dead`, `hit_stun`, `OnRope`, `already active`, `not grounded`, `down 미입력` 상태에서 모두 거부한다.
- drop-through timer가 살아 있는 동안 같은 platform으로 재진입하지 못하도록 차단하고, window 만료 후에는 정상 재진입한다.
- exception 대상 platform이 파괴되면(`is_instance_valid == false`) 다음 timer tick에서 stale state를 즉시 정리한다.

## 테스트로 고정한 계약

- `tests/test_player_controller.gd`
  - active window 중 재진입 거부 + timeout 후 재허용
  - dead / hit-stun 상태에서 drop-through 거부
  - rope state(`OnRope`)에서 drop-through 거부
  - freed platform 대상 stale drop-through state 자동 해제

## 왜 지금 잠갔는가

- one-way platform 자체는 이미 room-builder에서 안정화됐지만, 플레이어 쪽 helper는 상태 경합이 생기기 쉬운 경계면이라 회귀 기준이 필요했다.
- 물리 통합 시뮬레이션 없이도 helper contract를 직접 검증할 수 있어 headless 환경에서 반복 검증 안정성이 높다.

## 의도적으로 제외한 것

- `floor_segments` schema 재설계/마이그레이션 확대
- drop-through 입력 규칙 추가 확장(예: 더 긴 exception 정책, 상황별 fall-speed 튜닝)
- one-way platform 외 다른 충돌 계층 리팩터링

---
title: 맵 증분 50 - final payoff 데이터 회귀 잠금
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 50 - final payoff 데이터 회귀 잠금

## 목표

대표 방 전부가 `inverted_spire_covenant` 이후 world-side repeat payoff를 최소 하나 이상 유지한다는 현재 기준을 데이터 회귀 테스트로 고정한다.

## 이번에 잠그는 내용

- `entrance`, `seal_sanctum`, `gate_threshold`, `royal_inner_hall`, `throne_approach`, `inverted_spire`는 모두 `repeat_stage_messages.required_flag = inverted_spire_covenant`를 가진 object를 최소 하나 이상 가져야 한다.
- 이 기준은 개별 문구 표현보다 `최종 진실이 각 대표 방에 되돌아온다`는 구조 자체를 지키기 위한 데이터 불변식이다.
- 따라서 이후 문구를 다듬더라도, 대표 방 어디에서도 final payoff surface가 통째로 사라지면 회귀로 간주한다.

## 구현 변경

- [tests/test_game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd)
  - 대표 방 전부가 `inverted_spire_covenant` 기반 repeat payoff를 최소 1개 이상 보유하는지 검증하는 데이터 회귀를 추가한다.

## 검증

- `test_representative_rooms_keep_final_covenant_repeat_payoff_coverage`

## 보류

- room별 payoff density 수치 정책
- admin summary 문구 세부 튜닝
- cutscene/direct encounter 계열 verification

---
title: 맵 증분 48 - 9층 왕좌 복도 final payoff 보강
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_35_throne_echo_payoff.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_44_final_room_overturned_furnishings_payoff.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 48 - 9층 왕좌 복도 final payoff 보강

## 목표

`throne_approach`의 중심 복도 echo가 9층 단서 회수에서만 멈추지 않고, 10층 계약 확인 뒤에는 `계약을 왕국 법처럼 예행한 공간`으로 더 강하게 읽히도록 확장한다.

## 이번에 잠그는 내용

- 9층 중심 복도는 기본적으로 `시선을 모으고 복종을 배열하는 구조`다.
- `throne_approach_companion_trace`와 `throne_approach_decree`가 잠기면 이 복도는 `복종을 학습시키는 기계`처럼 읽힌다.
- `inverted_spire_covenant` 이후에는 같은 복도가 더 넓게 `왕좌가 계약을 법처럼 통과시키기 위해 미리 복종을 훈련한 rehearsal space`처럼 읽혀야 한다.
- 이 증분은 10층 최종 진실이 9층 왕좌 접근을 다시 설명한다는 현재 검증 체인을 room-side payoff로 고정한다.

## 구현 변경

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `throne_approach`의 중심 복도 echo에 `inverted_spire_covenant`용 repeat payoff 문장을 추가한다.
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
  - 9층 중심 복도 echo가 final covenant 이후 다른 repeat 문장을 반환하는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_combined_throne_flags`
- `test_echo_marker_repeat_text_can_react_to_throne_final_covenant_flag`

## 보류

- 왕좌 회상 컷신
- 친구 B 직접 조우
- 왕좌실 NPC 대사

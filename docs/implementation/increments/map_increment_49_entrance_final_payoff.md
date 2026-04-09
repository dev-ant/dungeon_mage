---
title: 맵 증분 49 - 4층 외곽 시작 final payoff 보강
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_41_entrance_echo_payoff.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_44_final_room_overturned_furnishings_payoff.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 49 - 4층 외곽 시작 final payoff 보강

## 목표

`entrance`의 성벽 문장 echo가 4층 역전 규칙 학습에서만 멈추지 않고, 10층 계약 확인 뒤에는 외곽 구조물 자체가 처음부터 `왕국을 아래로 가르치던 표식`처럼 더 강하게 읽히도록 확장한다.

## 이번에 잠그는 내용

- 4층 성벽 문장 echo는 기본적으로 `외곽 구조물조차 아래를 가리킨다`는 역전 규칙을 알려준다.
- `echo_entrance_2` 이후에는 이 구조가 `깊은 도심을 향해 여전히 복종하는 외곽 석재`처럼 읽힌다.
- `inverted_spire_covenant` 이후에는 같은 구조가 더 넓게 `미궁이 처음부터 왕국 전체를 아래로 가르치고 있었다는 earliest confession`처럼 읽혀야 한다.
- 이 증분은 10층 최종 진실이 4층 시작 구간까지 되돌아온다는 현재 payoff 원칙을 room-side 반응으로 고정한다.

## 구현 변경

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `entrance`의 wall-crest echo에 `inverted_spire_covenant`용 repeat payoff 문장을 추가한다.
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
  - 4층 wall-crest echo가 final covenant 이후 다른 repeat 문장을 반환하는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_entrance_second_flag`
- `test_echo_marker_repeat_text_can_react_to_entrance_final_covenant_flag`

## 보류

- 4층 추락 컷신
- 시험장 사고 회상
- 시작 구간 연속 카메라 연출

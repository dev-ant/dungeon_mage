---
title: 맵 증분 44 - 최심층 뒤집힌 생활 흔적 payoff
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_34_final_room_echo_payoff.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 44 - 최심층 뒤집힌 생활 흔적 payoff

## 목표

`inverted_spire`가 계약 문양 하나만 반응하는 방에 머무르지 않게 하고, 같은 방의 생활 흔적 echo도 계약 확인 뒤 다른 의미로 읽히도록 확장한다.

## 이번에 잠그는 내용

- 최심층의 `뒤집힌 왕실 가구` echo는 계약 확인 전에는 단순한 파손 흔적으로 읽힌다.
- `inverted_spire_covenant` 이후에는 이 흔적이 단순 붕괴가 아니라 `왕실 생활 자체가 의식 구조 안으로 강제로 회전된 증거`처럼 읽혀야 한다.
- 이 증분은 컷신, 직접 조우, 보스 페이즈 연출 없이도 `계약 진실이 방 전체의 생활 감각을 다시 해석하게 만드는 payoff`를 제공한다.

## 구현 변경

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `inverted_spire`의 뒤집힌 가구 echo에 `repeat_stage_messages`를 추가한다.
  - 같은 최종 room conversion 감각을 되돌려주는 buried observing-alcove echo 1개를 추가해 최심층을 echo 3 + gate 1 구조로 유지한다.
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
  - `inverted_spire_covenant` 이후 반복 문장이 바뀌는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_progression_flags`
- `test_echo_marker_repeat_text_can_react_to_inverted_spire_furnishing_flag`

## 보류

- 최종 방 컷신
- Friend B 직접 조우
- 보스전 페이즈별 방 연출 전환

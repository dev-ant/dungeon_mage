---
title: 맵 증분 47 - 8층 내부 홀 final payoff 보강
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_39_inner_hall_echo_payoff.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_44_final_room_overturned_furnishings_payoff.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 47 - 8층 내부 홀 final payoff 보강

## 목표

`royal_inner_hall`의 빈 초상 프레임 echo가 8층 archive 단서에서만 멈추지 않고, 10층 계약 확인 뒤에는 `왕실 삭제 자체가 계약 준비였다`는 의미로 더 강하게 읽히도록 확장한다.

## 이번에 잠그는 내용

- 8층 빈 초상 프레임은 기본적으로 `왕가 삭제`를 암시한다.
- `royal_inner_hall_archive` 이후에는 이 삭제가 `생활 공간 내부에서 먼저 집행된 정책`처럼 읽힌다.
- `inverted_spire_covenant` 이후에는 같은 흔적이 더 넓게 `인간 왕실을 지우고도 왕국을 존속시키려 한 계약 준비`처럼 읽혀야 한다.
- 이 증분은 10층 진실이 8층 생활 공간을 다시 설명한다는 현재 검증 체인을 room-side payoff로 고정한다.

## 구현 변경

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `royal_inner_hall`의 portrait-frame echo에 `inverted_spire_covenant`용 repeat payoff 문장을 추가한다.
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
  - 8층 portrait-frame echo가 final covenant 이후 다른 repeat 문장을 반환하는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_inner_hall_archive_flag`
- `test_echo_marker_repeat_text_can_react_to_inner_hall_final_covenant_flag`

## 보류

- 왕실 회상 컷신
- 친구 B 직접 조우
- 생존자 NPC 대사

---
title: 맵 증분 46 - 7층 성문 final payoff 보강
doc_type: increment
status: active
section: implementation
owner: runtime
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_40_gate_echo_payoff.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_44_final_room_overturned_furnishings_payoff.md
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 증분 46 - 7층 성문 final payoff 보강

## 목표

`gate_threshold`의 혈통 판정 echo가 7층 단서 회수에서만 멈추지 않고, 10층 계약 확인 뒤에는 이 gate 자체가 `계약의 첫 약속`처럼 읽히도록 확장한다.

## 이번에 잠그는 내용

- 7층 arch echo는 기본적으로 `거짓 상승`과 `혈통 판정`을 암시한다.
- `gate_threshold_bloodline_hint` 이후에는 이 구조가 `누가 아래에 속하는지 고르는 selector`처럼 읽힌다.
- `inverted_spire_covenant` 이후에는 같은 구조가 더 넓게 `성을 위에 보여주고 선택된 혈통을 아래로 보내는 bargain의 첫 약속`처럼 읽혀야 한다.
- 이 증분은 10층 최종 진실이 7층 문턱을 다시 설명한다는 현재 검증 체인을 room-side payoff로 고정한다.

## 구현 변경

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
  - `gate_threshold`의 arch echo에 `inverted_spire_covenant`용 repeat payoff 문장을 추가한다.
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
  - 7층 arch echo가 final covenant 이후 다른 repeat 문장을 반환하는 회귀를 추가한다.

## 검증

- `test_echo_marker_repeat_text_can_react_to_gate_bloodline_flag`
- `test_echo_marker_repeat_text_can_react_to_gate_final_covenant_flag`

## 보류

- 7층 컷신형 판정 연출
- 생존자 직접 등장
- 문지기/NPC 대사

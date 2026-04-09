---
title: 맵 21차 작업 체크리스트 - 허브 7층 반응 연결
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_13_hub_reactive_notice.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_20_gate_lore_chain.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 21차 작업 체크리스트 - 허브 7층 반응 연결

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `7층 문턱 단서`가 `6층 허브 공지판`에도 반영되도록 연결하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 허브 공지판이 7층의 생존자 경고와 혈통 떡밥을 받아 적는 구조가 보여야 한다.
- 플레이어가 7층에서 얻은 불안이 6층 허브 텍스트에도 남아야 한다.
- 허브가 단순 회복 공간이 아니라 `확인된 진실이 누적되는 상황판`처럼 느껴져야 한다.

## 수용 기준

- `gate_threshold_survivor_trace` 플래그가 있으면 허브 공지판이 생존자 경고 버전을 보여야 한다.
- `gate_threshold_bloodline_hint` 플래그가 있으면 허브 공지판이 혈통 떡밥 버전을 보여야 한다.
- 더 깊은 층 플래그가 있으면 기존 우선순위 규칙이 유지되어야 한다.
- player interaction 회귀와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
- [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)

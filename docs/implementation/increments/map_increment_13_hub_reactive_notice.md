---
title: 맵 13차 작업 체크리스트 - 허브 반응형 공지판
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_07_hub_anchor.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_11_final_covenant_anchor.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 13차 작업 체크리스트 - 허브 반응형 공지판

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `seal_sanctum` 허브가 플레이 진행 상황에 반응하도록 만드는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 허브 안에 진행 상태를 읽어 주는 공지판 상호작용을 둔다.
- 8층, 9층, 10층에서 확인한 진실이 허브 텍스트에 반영되어야 한다.
- 플레이어가 `읽고 온 내용이 허브에 남는다`는 감각을 받을 수 있어야 한다.

## 수용 기준

- `seal_sanctum` 에 반응형 공지판 오브젝트가 배치되어야 한다.
- `royal_inner_hall_archive`, `throne_approach_decree`, `inverted_spire_covenant` 플래그에 따라 공지판 텍스트가 달라져야 한다.
- 아직 관련 플래그가 없을 때는 기본 허브 안내문을 보여야 한다.
- player interaction 회귀와 headless 실행 검증이 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/refuge_notice.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/refuge_notice.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [tests/test_player_controller.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)

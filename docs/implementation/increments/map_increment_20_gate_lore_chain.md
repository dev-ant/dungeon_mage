---
title: 맵 20차 작업 체크리스트 - 7층 문턱 단서 체인
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/story_arc.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_19_admin_companion_trace_chain.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-06
last_verified: 2026-04-06
---

# 맵 20차 작업 체크리스트 - 7층 문턱 단서 체인

상태: 진행 중  
최종 갱신: 2026-04-06  
섹션: 구현 기준

## 목표

이 문서는 `7층 전후: 미궁 주인과 혈통 떡밥, 생존자 증언`을 환경 단서와 관리자 검증 체인으로 먼저 잠그기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 7층에는 `생존자 경고`와 `혈통 선택의 흔적`을 각각 하나씩 둔다.
- 플레이어가 8층/9층로 들어가기 전, 자신의 하강이 우연이 아니라는 감각을 먼저 받아야 한다.
- admin progression chain에서도 이 문턱 단서가 다른 층 단서들과 함께 보이게 한다.

## 현재 잠금 범위

- 실제 생존자 NPC 등장, 이름, 대화 분기는 아직 사용자 결정이 필요한 항목으로 남긴다.
- 이번 증분에서는 환경 trace, progression flag, admin progression chain까지만 잠근다.

## 수용 기준

- `gate_threshold` 에 생존자 경고용 trace가 1개 있어야 한다.
- `gate_threshold` 에 혈통 떡밥용 trace가 1개 있어야 한다.
- admin progression chain에 `7F Survivor`, `7F Bloodline` 이 반영되어야 한다.
- admin 검증과 headless 실행이 통과해야 한다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [tests/test_admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)

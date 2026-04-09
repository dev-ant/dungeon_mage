---
title: 맵 5차 작업 체크리스트 - 대표 구간 프로토타입 플로우
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_04_floor_10_core.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 5차 작업 체크리스트 - 대표 구간 프로토타입 플로우

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 representative anchor만 연결하던 초기 prototype flow를, 실제 floor-count를 가진 multi-room dungeon flow로 확장한 현재 계약을 추적하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- `4층 13개 -> 5층 11개 -> 6층 9개 -> 7층 7개 -> 8층 5개 -> 9층 3개 -> 10층 1개` 흐름을 실제 room shift로 이동 가능하게 만든다.
- 기존 레거시 전투 샌드박스 흐름은 직접 로드 시 계속 유지한다.
- 하드코딩된 room transition 조건을 최소한의 범용 구조로 정리한다.

## 플레이 경험 목표

- 기본 시작은 대표 구간 프로토타입 흐름을 탄다.
- 각 floor room을 클리어하거나 통과하면서 `외곽 폐허 -> 전이 회랑 -> 쉼터 -> 문턱 -> 내전 -> 옥좌 접근 -> 최심층` 감각이 이어져야 한다.
- 레거시 `conduit/deep_gate` 흐름은 기존 검증 경로를 깨지 않아야 한다.

## 이번 범위

### 포함

- `GameDatabase._expand_prototype_rooms()` 기반 prototype room generation
- 5층 `transition_corridor` floor 추가
- generated route room metadata와 floor count source of truth 추가
- `GameState` catalog/order 소비 구조 추가
- 대표 구간용 전진/후진 room shift 연결
- admin selector의 paged room window 소비
- 레거시 room order fallback 유지
- Main integration 회귀 테스트 추가
- 현재 prototype room generation source of truth는 `scripts/autoload/game_database.gd`의 `GameDatabase._expand_prototype_rooms()`다. `data/rooms.json`은 story anchor/legacy room 입력이며, 49-room flow 전체를 직접 적는 단독 truth가 아니다.
- 현재 prototype room order의 source of truth는 `GameState.get_prototype_room_order()`이며, 관리자 selector와 main runtime은 같은 catalog 기반 순서를 공유한다.

### 제외

- 전체 스토리 동선 완성
- admin selector의 full redesign
- save migration
- 최종 이벤트 스크립팅

## 필수 구현 포인트

- 기본 `entrance` 시작은 prototype flow를 우선 사용한다.
- `entrance` 클리어 후에는 더 이상 곧바로 6층으로 가지 않고, 확장된 4층 route room으로 먼저 이동한다.
- 4층 마지막 room은 5층 첫 room으로, 5층 마지막 room은 6층 첫 room으로 연결된다.
- `conduit`, `deep_gate` 직접 로드 시에는 레거시 flow가 유지되어야 한다.
- 전진 조건은 가능한 범용화하되, `conduit`의 core activation 예외는 유지한다.
- 마지막 대표 구간에서는 더 깊은 다음 룸이 없다는 메시지를 준다.

## 파일 터치포인트

- [scripts/autoload/game_database.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_database.gd)
- [scripts/autoload/game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [scripts/admin/admin_menu.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [scripts/main/main.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/main/main.gd)
- [tests/test_main_integration.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_main_integration.gd)
- 필요 시 [docs/implementation/plans/dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)

## 수용 기준

- prototype room catalog는 총 49개 room을 제공해야 한다.
- floor count는 `4층 13개 / 5층 11개 / 6층 9개 / 7층 7개 / 8층 5개 / 9층 3개 / 10층 1개`를 유지해야 한다.
- `entrance`에서 room clear 후 오른쪽 이동 시 expanded 4층 다음 room으로 간다.
- 4층 마지막 room에서 room clear 후 오른쪽 이동 시 5층 첫 room으로 간다.
- 6층 첫 room에서 왼쪽 이동 시 5층 마지막 room으로 돌아갈 수 있어야 한다.
- `gate_threshold`에서 room clear 후 오른쪽 이동 시 `royal_inner_hall`로 간다.
- `throne_approach`에서 room clear 후 오른쪽 이동 시 `inverted_spire`로 간다.
- `conduit` 직접 로드 시 기존 core activation 기반 전진이 유지된다.
- Main integration 회귀가 통과한다.

## 검증 순서

1. room order/transition 로직 수정
2. integration test 추가
3. GUT 검증
4. headless 실행 확인

## 다음 구현용 메모

- 이 증분의 49-room flow와 paged selector는 현재 기준선으로 잠겼다. 다음은 floor별 generated route room에 더 뚜렷한 landmark/spawn/echo 차이를 누적하거나, paged selector 위에 search/filter 같은 추가 탐색 보조를 얹는 쪽으로 갈 수 있다.

## 연관 문서

- [dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [map_increment_04_floor_10_core.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_04_floor_10_core.md)

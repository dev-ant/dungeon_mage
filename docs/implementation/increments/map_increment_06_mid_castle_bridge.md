---
title: 맵 6차 작업 체크리스트 - 8층/9층 중간 구간
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_05_prototype_flow.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 6차 작업 체크리스트 - 8층/9층 중간 구간

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 대표 구간 사이의 점프를 줄이기 위해 `8층 성 안 내부`와 `9층 알현실 전구간` 프로토타입을 추가하는 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- `gate_threshold`와 `inverted_spire` 사이에 2개 중간 룸을 추가한다.
- `문턱 -> 내부 생활/의식 공간 -> 왕권 과시 구역 -> 최심층` 흐름을 더 자연스럽게 만든다.
- 현재 prototype flow를 유지하면서 체험 완성도를 높인다.

## 플레이 경험 목표

- 8층은 `권력 공간 내부`로 들어왔다는 감각이 먼저 읽혀야 한다.
- 9층은 `왕좌와 심판`에 가까워졌다는 무게감이 먼저 읽혀야 한다.
- 10층 최심층은 여전히 가장 잘못되고 응축된 공간으로 남아야 한다.
- 현재 배치 기준으로 8층/9층의 key interaction object는 같은 lane의 enemy spawn과 겹치지 않도록 유지한다. 기억 오브젝트를 읽는 자리와 전투 진입 자리는 분리하는 것이 현 기준이다.
- 같은 기준으로 8층 portrait echo와 9층 center corridor echo도 ranged spawn과 같은 접근 lane을 직접 공유하지 않도록 유지한다.
- 같은 기준으로 9층 procession stair floor segments는 오른쪽으로 갈수록 엄격히 높아지는 계단 리듬을 유지한다. 왕좌 접근은 평지보다 `판결대로 끌려 올라가는 감각`이 먼저 읽혀야 한다.
- 현재 lock 기준으로 8층/9층 room width도 이전 소형 샌드박스보다 최소 1.5배 이상 넓히고, 8층은 branch-and-rejoin living hall, 9층은 긴 procession ascent로 유지한다.
- 같은 기준으로 8층은 side living pocket, 9층은 waiting pocket을 각각 1개 이상 유지해, 본선에서 잠깐 벗어났다가 다시 심판 동선으로 합류하는 detour 감각도 남긴다.
- 8층 living pocket에는 지워진 생활 흔적 echo를, 9층 waiting pocket에는 심판 전 대기 자국 echo를 붙여, 두 우회 공간 모두 `잠깐 들어가서 읽을 이유`가 있는 side branch로 유지한다.

## 이번 범위

### 포함

- 8층 내부 전용 room data 추가
- 9층 알현실 전구간 room data 추가
- inner/throne 테마 장식 추가
- prototype room order 확장
- builder/integration 회귀 테스트 추가
- 8층은 archive cabinet과 ward tether 실루엣으로 `생활 공간 내부의 삭제/왜곡`, 9층은 decree pillar와 procession rune 실루엣으로 `판결 예행 통로` 감각을 더 먼저 읽히게 고정

### 제외

- 친구 B 조우 이벤트
- 실제 왕좌 상호작용
- 8층/9층 스토리 컷신
- 메인 시네마틱 연출

## 수용 기준

- `gate_threshold` 이후 `royal_inner_hall`로 이동할 수 있어야 한다.
- `royal_inner_hall` 이후 `throne_approach`로 이동할 수 있어야 한다.
- `throne_approach` 이후 `inverted_spire`로 이동할 수 있어야 한다.
- 8층은 성 내부 생활/의식 공간처럼, 9층은 왕좌/심판 구역처럼 읽혀야 한다.
- 현재 builder 기준으로 8층은 `portrait row + archive cabinet + ward tether`, 9층은 `throne dais + decree pillar + procession rune` 묶음이 먼저 읽히면 충분하다.

## 검증 순서

1. room data/theme 추가
2. builder 장식 추가
3. prototype flow 확장
4. builder/integration GUT 검증
5. headless 실행 확인

## 다음 구현용 메모

- 이 증분이 안정화되면 다음은 room selector, prototype preview, 또는 6층 허브 상호작용 확장으로 갈 수 있다.

## 연관 문서

- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [map_increment_05_prototype_flow.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_05_prototype_flow.md)

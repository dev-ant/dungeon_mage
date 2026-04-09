---
title: 맵 1차 작업 체크리스트 - 4층 시작 구간
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_premise.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 맵 1차 작업 체크리스트 - 4층 시작 구간

상태: 진행 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 `4층 시작 구간` 프로토타입을 현재 world runtime 위에서 가장 작은 안전한 증분으로 구현하기 위한 체크리스트입니다.

핵심 목표는 아래와 같습니다.

- 기존 `entrance` 룸을 4층 시작 구간 해석으로 승격한다.
- 플레이어가 첫 방에서 `무너진 외곽 폐허`와 `생존 시작` 감각을 받도록 만든다.
- 현재 전투 테스트 루프와 room shift 구조를 깨지 않는다.

## 플레이 경험 목표

- 첫 룸은 `시험장`보다 `왕성 밖으로 추락한 폐허`처럼 보여야 한다.
- 플레이어는 여전히 이동, 로프, 평지 전투, 짧은 발판 전투를 테스트할 수 있어야 한다.
- 룸을 클리어하면 `앞으로 가면 탈출할 수 있을 것 같지만 실제로는 더 깊어진다`는 감각이 유지되어야 한다.

## 현재 구현 범위

### 포함

- `entrance` 룸의 제목, entry text, echo text 재작성
- 4층 외곽 폐허에 맞는 바닥/발판 구조 재배치
- room builder에 4층용 최소 장식 레이어 추가
- 4층 실루엣이 읽히는 시각 테스트 회귀 추가
- 외곽 감시 mast와 무너진 gate span을 추가해 `추락 전 외성 방어선` 실루엣을 더 또렷하게 고정
- 상단 debris platform을 조금 더 높고 넓게 유지해 `올라갈 수 있을 것 같은데 결국 더 깊게 읽히는` false-ascent 리듬을 floor segment 차원에서도 고정
- 현재 lock 기준으로 room width도 이전 소형 샌드박스보다 최소 1.5배 이상 넓히고, false-ascent lane을 3단 이상 이어서 `짧은 시험장`이 아니라 `외곽 진입 구간`처럼 읽히게 유지한다.
- 같은 기준으로 4층은 상단 잔해 pocket을 하나 더 가져, 잠깐 탈출로처럼 벗어났다가 다시 본선으로 돌아오게 만드는 detour 감각을 유지한다.
- 상단 잔해 pocket에는 외곽 신호 흔적 echo를 붙여, 우회가 단순 점프 시험이 아니라 `잘못된 탈출 신호`를 한 번 더 읽는 payoff가 되도록 유지한다.

### 제외

- 4층 전체 완성
- 새 적 아키타입 추가
- 컷신/대사 이벤트 추가
- 6층 이후 룸 재구성

## 필수 구현 포인트

- 룸 제목은 `Collapsed Test Wing` 같은 추상 표현보다 4층 외곽 정체성을 드러내야 한다.
- 배경색과 entry text는 `추락`, `외성 밖`, `생존 시작` 감각을 직접 전달해야 한다.
- 평지 전투 테스트 구간은 유지하되, 발판/로프는 `폐허 잔해를 타고 이동하는 감각`으로 읽혀야 한다.
- room builder는 새 theme가 없더라도 기존 룸을 깨지 않아야 한다.
- 새 장식은 충돌보다 시각 실루엣 역할에 집중한다.
- 현재 기준으로 4층 랜드마크는 `collapsed buttress / broken watchtower / signal mast / fallen gate span` 묶음으로 읽히면 충분하다.

## 파일 터치포인트

- [data/rooms.json](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/data/rooms.json)
- [scripts/world/room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/world/room_builder.gd)
- [tests/test_room_builder.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_room_builder.gd)

## 수용 기준

- `entrance`를 로드했을 때 4층 외곽 폐허처럼 읽혀야 한다.
- 기존 로프/전투/이동 테스트 경로가 유지되어야 한다.
- room builder GUT 회귀가 통과해야 한다.
- entrance 전용 테마 장식은 다른 룸을 건드리지 않아야 한다.

## 검증 순서

1. 문서 기준 확인
2. room data 수정
3. room builder parse/GUT 검증
4. headless 또는 통합 실행 확인

## 다음 구현용 메모

- 이 증분이 안정화되면 다음은 `6층 허브` 증분으로 간다.
- 6층에서는 봉인상, 결계 경계, 휴식 거점 구조가 핵심이다.

## 연관 문서

- [dungeon_premise.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_premise.md)
- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)

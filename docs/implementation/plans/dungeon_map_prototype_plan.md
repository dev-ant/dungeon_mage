---
title: 미궁 맵 프로토타입 구현 계획
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_premise.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - rule_changed
  - runtime_changed
  - handoff_changed
last_updated: 2026-04-07
last_verified: 2026-04-07
---

# 미궁 맵 프로토타입 구현 계획

상태: 사용 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목표

이 문서는 강화된 미궁 기획을 실제 Godot 맵 프로토타입으로 옮기기 위한 1차 구현 계획입니다.

이번 단계의 목표는 아래와 같습니다.

- 10개 층 전체를 한 번에 구현하지 않는다.
- 층 정체성이 가장 분명한 대표 구간 4개를 먼저 만든다.
- 현재 전투 런타임을 깨지 않으면서 `맵 정체성`, `동선 유도`, `전투 가독성`을 함께 검증한다.

## 플레이 경험 목표

- 플레이어는 한 장면만 봐도 `외곽 폐허`, `허브`, `성문`, `최심층`의 차이를 느껴야 한다.
- 이동과 전투를 해치는 장식보다, 공간 정체성을 설명하는 실루엣과 동선이 우선해야 한다.
- 위로 올라가거나 출구에 가까워지는 듯한 착시가 들더라도, 실제로는 더 깊은 핵심부로 유도되는 감각이 있어야 한다.
- 현재 장르 참고 기준으로는 대표 방도 `짧은 테스트방`이 아니라 `모험 거리`가 느껴지는 폭을 가져야 한다. 따라서 prototype 대표 방 폭은 이전 미니 샌드박스 대비 최소 `1.5x` 이상을 기본값으로 삼는다.

## 미궁 구조 잠금

- 장르 공통 dungeon/labyrinth 구조 참고 기준은 `넓은 탐색 폭`, `branch-and-rejoin`, `강한 랜드마크 시야 유도`, `가짜 상승/탈출 유도`, `짧은 side pocket/loop-back`, `안전지대 완충`, `최종전 전 넓은 압축 평면` 일곱 가지다.
- 현재 prototype room은 완전한 랜덤 미궁이나 타일형 퍼즐 구조를 바로 구현하지 않는다. 대신 각 대표 방 내부에 `여러 lane과 재합류 지점`을 만들어 side-scrolling runtime에서도 던전 탐색 감각이 들도록 만든다.
- 각 대표 방은 `본선에서 잠깐 벗어났다 다시 합류하는 detour pocket`을 최소 1개 이상 가진다. 이 pocket은 퍼즐룸이 아니라 환경 읽기와 압박 리듬 완충을 위한 짧은 우회 공간으로 해석한다.
- detour pocket은 비어 있는 발판으로 두지 않는다. 현재 lock 기준으로 각 pocket에는 최소 1개의 `환경 payoff surface`를 둬서, 잠깐 우회했을 때도 읽고 돌아올 이유가 생기도록 만든다.
- 4층은 `올라갈 수 있을 것 같은 false ascent lane + 상단 잔해 pocket`, 6층은 `중앙 refuge를 감싸는 좌우 side lane + shelter pocket`, 7층은 `검문 광장 -> upper checkpoint -> bloodline gate lane + holding pocket`, 8층은 `생활 공간 branch lane + side living pocket`, 9층은 `procession stair cadence + waiting pocket`, 10층은 `넓은 final floor + flank perch + upper flank pocket` 구조를 기본 모티브로 잠근다.

## 이번 범위

### 포함

- 4층 시작 구간 프로토타입
- 6층 허브 구간 프로토타입
- 7층 성문 구간 프로토타입
- 10층 최심층 구간 프로토타입
- 각 구간에 필요한 최소 배경/지형/오브젝트 모티브
- 플레이어 이동, 점프, 전투, 적 배치가 가능한 최소 전투 동선

### 제외

- 1~3층 시험장 리빌드
- 컷신 전용 연출
- NPC 대사 시스템
- 퍼즐형 특수 기믹 확장

## 현재 잠긴 prototype floor 확장

- 이 문서의 초기 `대표 구간 4개` 서술은 anchor 설계 의도를 설명하는 scaffold로 남겨 두고, 실제 runtime 판단은 아래 49-room 확장 섹션과 기준선 문서를 우선한다.
- prototype flow는 더 이상 `대표 방 6개`만 쓰지 않는다.
- 현재 runtime 기준 floor count lock은 `4층 13개 / 5층 11개 / 6층 9개 / 7층 7개 / 8층 5개 / 9층 3개 / 10층 1개`, 총 49개다.
- story anchor placement는 `entrance(4층-01)`, `seal_sanctum(6층-01)`, `gate_threshold(7층-07)`, `royal_inner_hall(8층-01)`, `throne_approach(9층-03)`, `inverted_spire(10층-01)`로 잠겼다.
- room generation source of truth는 `scripts/autoload/game_database.gd`의 `GameDatabase._expand_prototype_rooms()`다. `data/rooms.json`은 story anchor/legacy room의 base input이며, 49-room flow 전체를 직접 적는 단독 truth가 아니다.
- catalog/order source of truth는 `scripts/autoload/game_state.gd`의 `GameState.get_prototype_room_catalog()`와 `GameState.get_prototype_room_order()`다.
- runtime shift/load source of truth는 `scripts/main/main.gd`, admin selector 소비 source of truth는 `scripts/admin/admin_menu.gd`다.
- 5층은 이제 실제 구현 floor로 본다. theme source of truth는 `GameDatabase`가 generated route room에 주입하는 `transition_corridor`이며, `반파된 검문소 / 반복 아치 / 엇갈린 계단 / 구조 신호가 더 깊은 곳으로 이어지는 loop-back pocket` 조합을 유지한다.
- generated route room은 story anchor의 progression flag를 새로 늘리지 않고, floor identity / detour pocket / branch-and-rejoin traversal을 먼저 담당한다.
- 레거시 `conduit / deep_gate / vault_sector / arcane_core / void_rift`는 아직 direct-load 회귀와 기존 테스트가 참조하므로 이번 턴에서는 제거하지 않는다.

## 대표 구간 정의

### 1. 4층 시작 구간

- 목표:
  - 외곽 폐허와 생존 시작 감각을 고정한다.
- 플레이 경험:
  - 추락 직후의 단절감
  - 아직은 탐험 가능한 폐허라는 감각
- 필수 요소:
  - 추락 지점
  - 무너진 외성 또는 주거 폐허 실루엣
  - 기본 전투 테스트 평지
  - 외곽 감시 시설 잔해

### 2. 6층 허브 구간

- 목표:
  - 친구 A 봉인상과 안전지대 구조를 검증한다.
- 플레이 경험:
  - 어렵게 얻은 성역
  - 폐허 위에 유지되는 임시 거점
- 필수 요소:
  - 봉인상 중심 룸
  - 휴식 포인트
  - 결계 경계가 읽히는 전환부
  - 생존자 거점으로 확장 가능한 빈 공간

### 3. 7층 성문 구간

- 목표:
  - 권력 중심부 진입 감각을 공간으로 먼저 읽히게 한다.
- 플레이 경험:
  - 거대한 문을 통과하는 압박
  - 심판 영역에 발을 들이는 감각
- 필수 요소:
  - 대형 게이트 또는 수문형 실루엣
  - 검문 광장형 전투 구간
  - 문지기/방어선 모티브
  - 상하 역전 감각을 암시하는 구조물

### 4. 10층 최심층 구간

- 목표:
  - 가장 높았던 공간이 가장 깊어진 역전 감각을 보스 공간으로 고정한다.
- 플레이 경험:
  - 잘못된 성역
  - 왕의 사적 공간과 계약 제단이 겹친 불경함
- 필수 요소:
  - 제단 또는 계약 문양 중심부
  - 보스전 평면
  - 전조 회랑 또는 접근 공간
  - 마탑/왕실 흔적이 함께 읽히는 배경

## 파일 및 구현 터치포인트

- 씬 후보:
  - `scenes/main/` 하위 신규 prototype scene
  - 또는 기존 world/main scene에 대표 구간 연결
- 스크립트 후보:
  - `scripts/autoload/game_database.gd`
  - `scripts/autoload/game_state.gd`
  - `scripts/admin/admin_menu.gd`
  - `scripts/main/main.gd`
  - `scripts/world/room_builder.gd`
  - 대표 구간 전용 world helper script가 필요하면 분리
- 데이터 후보:
  - `data/rooms.json` base anchor/legacy data
  - `GameDatabase._expand_prototype_rooms()`가 생성하는 generated route room metadata
- 테스트 후보:
  - `tests/test_room_builder.gd`
  - 대표 구간 parse/headless 검증

## 권장 구현 순서

1. 4층 시작 구간 프로토타입 생성
2. 6층 허브 구간 추가
3. 7층 성문 구간 추가
4. 10층 최심층 구간 추가
5. 구간 간 시각 언어 차이와 전투 가독성 회귀 검증

## 수용 기준

- 각 대표 구간은 스크린샷 한 장으로도 층 성격이 구분되어야 한다.
- 플레이어 이동, 점프, 대시, 적 추격, 투사체 전투가 새 지형에서 깨지지 않아야 한다.
- 전투 이펙트와 적 실루엣이 배경에 묻히지 않아야 한다.
- 4층과 10층은 같은 왕국 유적 계열이면서도 완전히 다른 감정을 줘야 한다.
- 6층 허브는 전투장이 아니라 정비/안전지대로 해석되어야 한다.
- 7층은 진입 문턱과 권력 중심부 전환 감각이 시각적으로 읽혀야 한다.

## 현재 잠긴 검증 체인

- 현재 구현 기준으로 대표 구간 검증 체인은 `7층 생존자 경고 확인 -> 7층 혈통 떡밥 확인 -> 6층 허브 반응 갱신 -> 8층 친구 B 전조 확인 -> 8층 기록 확인 -> 9층 친구 B 전조 확인 -> 9층 칙령 확인 -> 10층 계약 확인 -> 6층 허브 반응 심화 -> 관리자 메뉴 프리뷰 검증`까지 잠겼다.
- 이 체인은 room interaction, progression flag, hub reactive text, admin preview를 한 줄로 연결하는 현재 source-of-truth 흐름이다.
- 관리자 검증에서는 이 체인을 `Threshold / Companion / Final` 세 단계 요약과 세부 chain line으로 함께 본다.
- 6층 허브 공지판도 같은 세 단계 묶음을 직접 반영한다. 따라서 `Threshold`, `Companion`, `Final`은 관리자 메뉴 요약뿐 아니라 실제 세계 반응 텍스트에서도 재확인 가능해야 한다.
- 10층 최심층 차단 경고도 같은 세 단계 해석을 따른다. 따라서 이미 읽은 단서가 많을수록 최종전 문턱의 경고 문구는 더 구체적이어야 한다.
- 관리자 메뉴는 허브 반응과 최심층 경고를 같은 phase 기준으로 교차 표시할 수 있어야 한다. 따라서 요약 line만이 아니라 `hub notice / final state / final gate line`의 동기화도 검증 범위에 포함한다.
- 관리자 메뉴는 이 세 단계가 서사적으로 무엇을 뜻하는지도 짧은 handoff 문장으로 보여줄 수 있어야 한다. 따라서 이후 구현 증분은 상태 마커뿐 아니라 `이미 잠긴 해석 문장`도 함께 유지해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방이 이 체인에서 맡는 역할도 `room note`로 보여줄 수 있어야 한다. 따라서 방 단위 구현은 이 역할 메모와 충돌하지 않는 선에서 확장해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방이 다음 대표 방으로 무엇을 넘기는지도 `path note`로 보여줄 수 있어야 한다. 따라서 prototype flow 확장은 이 연결 메모와 충돌하지 않는 선에서 진행해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방에서 확인 가능한 핵심 단서도 `clue check`로 보여줄 수 있어야 한다. 따라서 이후 구현은 방 역할/연결 메모뿐 아니라 단서 체크리스트와도 정합해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방의 검증 상태를 `verification status` 한 줄로 압축해서 보여줄 수 있어야 한다. 따라서 이후 구현은 상세 단서뿐 아니라 방별 잠금 수준 요약과도 정합해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방의 다음 안전 작업 순서도 `next priority`로 제안할 수 있어야 한다. 따라서 이후 구현은 잠금 상태와 우선순위 가이드가 서로 어긋나지 않게 유지해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방에서 바로 수행 가능한 `action candidate`도 제안할 수 있어야 한다. 따라서 이후 구현은 우선순위 요약뿐 아니라 실제 안전 작업 문장과도 정합해야 한다.
- 직접 조우를 잠그지 않는 범위에서도, 이미 확인한 진실은 같은 방의 반복 상호작용이 다르게 읽히는 payoff로 되돌아와야 한다. 따라서 phase-confirmed truth는 echo/repeat interaction에도 재반영 가능해야 한다.
- 이 payoff 원칙은 10층 계약뿐 아니라 9층 왕좌 접근처럼 직접 조우 이전의 상위 단서 구간에도 적용 가능해야 한다. 따라서 이미 잠긴 8층/9층 단서는 반복 상호작용에서 재해석 가능한 상태로 남겨둘 수 있어야 한다.
- 같은 원칙으로 8층 왕실 내부도 `기록 삭제`와 `지원 마법 왜곡`이 반복 상호작용에서 다시 읽혀야 한다. 따라서 8층은 단서를 한 번 발견하는 구간을 넘어서, 생활 공간 자체가 `지워진 혈통`과 `복종으로 꺾인 지원 마법`을 재확인하는 payoff room으로 유지한다.
- 같은 원칙으로 7층 성문도 `생존자 경고`와 `혈통 판정`이 반복 상호작용에서 다시 읽혀야 한다. 따라서 7층은 문턱 단서를 한 번 전달하고 끝나는 방이 아니라, 게이트 자체가 `누가 통과를 허락받는가`를 되새기는 payoff room으로 유지한다.
- 같은 원칙으로 4층 외곽 시작 구간도 `잘못된 상승 감각`과 `깊이를 가리키는 외곽 구조`가 반복 상호작용에서 다시 읽혀야 한다. 따라서 4층은 단순 튜토리얼 폐허가 아니라, 미궁의 공간 역전 규칙을 가장 먼저 학습시키는 payoff room으로 유지한다.
- 같은 원칙으로 6층 허브도 공지판뿐 아니라 일반 echo를 통해 업데이트된 해석을 되돌려줄 수 있어야 한다. 따라서 허브는 반응형 board와 반응형 residue를 함께 가진 공간으로 유지한다.
- 관리자 메뉴는 이런 board/echo/gate 반응을 `reactive residue summary`로 압축해서 보여줄 수 있어야 한다. 따라서 반응형 공간 payoff는 관리자 검증 화면에서도 직접 추적 가능해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방의 반응형 공간 요소 밀도도 `payoff density`로 요약할 수 있어야 한다. 따라서 이후 구현은 개별 reaction 추가뿐 아니라 방별 payoff 균형도 함께 관리해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방의 반응형 payoff가 `board / echo / gate` 중 무엇으로 구성되는지도 `surface mix`로 보여줄 수 있어야 한다. 따라서 이후 구현은 총량뿐 아니라 어떤 종류의 반응이 방을 지탱하는지도 함께 검증 가능해야 한다.
- 관리자 메뉴는 현재 선택된 대표 방의 검증 체인에서 가장 약한 고리도 `weakest link`로 요약할 수 있어야 한다. 따라서 이후 구현은 상태/총량/구성 정보를 바탕으로 다음 실제 위험이 무엇인지 한 줄로 압축 가능해야 한다.
- 따라서 이후 맵 상호작용 추가는 `room object -> progression flag -> hub or final-state reaction -> admin preview` 순서를 기본 패턴으로 따른다.

## 보류 결정

- `8층 친구 B 직접 조우 장면`과 `10층 친구 B 보스전 페이즈별 직접 연출`은 아직 사용자 결정이 필요한 영역으로 남긴다.
- 현재 문서 기준으로는 `환경 서사와 상태 변화`까지만 잠겼고, 실제 조우 대사/컷신/버프 타이밍은 후속 전투 문서에서 따로 잠가야 한다.
- 이 보류 항목은 이번 턴에서 스킵하고, 구현 가능한 맵/검증 루프 강화 작업을 우선 이어간다.

## 후속 잠금 메모

- 직접 조우 전에도 잠글 수 있는 범위로 `친숙하지만 어긋난 지원 마법 흔적`은 8층/9층 환경 상호작용으로 먼저 구현한다.
- 이 흔적은 친구 B의 버프/지원 정체성을 유지하되, 이미 미궁 주인의 영향 아래에서 왜곡되었다는 감각을 주는 것을 기준으로 삼는다.
- 따라서 `직접 등장 연출`이 미정이어도 `환경 전조`는 현재 구현 기준으로 안전하게 확장 가능하다.

## 검증 순서

1. 문서 검증
   - `dungeon_premise.md`, `dungeon_floor_structure.md`, `story_arc.md`, `art_direction.md`와 충돌이 없는지 확인
2. 파싱 검증
   - headless parse가 통과해야 함
3. 룸/빌더 검증
   - `room_builder` 계열 테스트가 통과해야 함
4. 수동 플레이 검증
   - 이동
   - 전투
   - 가독성
   - 층 정체성

## 비목표

- 본편 전체 맵 완성 선언
- 10층 분량의 완성형 탐색 루프 구현
- 최종 스토리 이벤트 연결 완료

## 다음 구현용 메모

- 이 문서 다음 단계는 `implementation/increments/` 아래에 실제 맵 구현 증분 문서를 만드는 것입니다.
- 그 증분 문서에서는 대표 구간별 정확한 씬 구조, 타일 레이어, 오브젝트 목록, 테스트 체크리스트를 더 세밀하게 고정합니다.

## 연관 문서

- [dungeon_premise.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_premise.md)
- [dungeon_floor_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/dungeon_floor_structure.md)
- [art_direction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/art_direction.md)
- [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)

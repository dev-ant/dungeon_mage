---
title: 10문항 기획 구체화 프로토콜
doc_type: rule
status: active
section: governance
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md
update_when:
  - rule_changed
  - handoff_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 10문항 기획 구체화 프로토콜

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 문서는 기획 문서가 모호해서 안전하게 개발하기 어려울 때, AI가 사용자와 `10문항 단위 라운드`로 질의응답을 반복하며 기획을 완성하는 규칙을 정의한다.

## 언제 이 프로토콜을 시작하는가

- `plan` 문서는 있는데 acceptance criteria가 구현 수준으로 잠기지 않았을 때
- `rule` 문서에 이름은 있지만 수치, 상호작용, UI 흐름, edge case가 비어 있을 때
- 여러 canonical 후보 중 무엇이 최신 기준인지 확정되지 않았을 때
- 사용자가 "질문해서 기획 완성해줘"라고 요청했을 때
- [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)의 상위 항목을 선제 구체화할 때

## 1라운드 기본 규칙

- 한 라운드는 정확히 `10개 질문`으로 구성한다.
- 질문은 구현 가능성에 직접 영향을 주는 항목만 묻는다.
- 한 라운드 안에서 `목표 경험 -> 입력/상태 -> 수치/규칙 -> 예외 -> 검증` 순서를 유지한다.
- 같은 의미의 질문을 표현만 바꿔 반복하지 않는다.
- 답변이 일부만 왔어도, 받은 내용으로 문서를 먼저 갱신하고 다음 10문항을 만든다.

## 질문 카테고리

10개 질문은 아래 5개 축을 기준으로 배분한다.

1. 목표 경험
2. 상호작용 흐름
3. 데이터/수치 규칙
4. 예외와 충돌 처리
5. 검증 기준

권장 분배는 아래와 같다.

- 목표 경험: 2문항
- 상호작용 흐름: 3문항
- 데이터/수치 규칙: 2문항
- 예외와 충돌 처리: 2문항
- 검증 기준: 1문항

## 질문 작성 규칙

- 질문은 최대한 구체적인 선택을 끌어내야 한다.
- "어떻게 할까요?"보다 "A와 B 중 어느 경험을 원하나요?" 수준으로 좁힌다.
- 이미 문서에 있는 사실을 다시 묻지 않는다.
- 구현과 무관한 lore 확장 질문은 하지 않는다.
- 다음 라운드에서 바뀔 수 있는 질문보다 `지금 막는 결정을 먼저` 묻는다.

## 라운드 종료 후 AI가 해야 할 일

1. 답변을 `rule` 또는 `plan` 문서에 반영한다.
2. 필드 정의가 바뀌었으면 `schema`를 함께 갱신한다.
3. backlog 항목의 `명확도 상태`를 갱신한다.
4. 아직 비어 있는 결정만 추려 다음 10문항을 만든다.

## 구현 시작 조건

아래 5개가 잠기면 AI는 구현 모드로 넘어갈 수 있다.

- 목표 경험이 한 문장으로 고정됨
- 플레이어 입력 또는 조작 흐름이 고정됨
- 핵심 수치 또는 상태 전이가 고정됨
- 대표 edge case 처리 기준이 고정됨
- 최소 검증 기준이 고정됨

위 조건이 충족되지 않으면 AI는 계속 질문 라운드를 우선한다.

## "알아서 가장 시급한 기획을 질문" 모드 규칙

사용자가 직접 대상을 지정하지 않으면 AI는 아래 순서로 질문 대상을 고른다.

1. [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)의 최상위 `open` 항목
2. 현재 `plan` 문서에서 가장 가까운 구현 블로커
3. `baseline`과 `rule`의 불일치가 큰 항목

## 질문 10개 템플릿

아래 템플릿은 매 라운드의 기본 뼈대다.

1. 이 기능이 플레이어에게 주어야 하는 핵심 경험은 무엇인가
2. 이 기능이 실패했을 때 가장 눈에 띄는 나쁜 경험은 무엇인가
3. 시작 입력 또는 진입 조건은 무엇인가
4. 활성 중 플레이어가 바꿀 수 있는 선택지는 무엇인가
5. 종료 조건 또는 취소 조건은 무엇인가
6. 핵심 수치 1개는 무엇이며 허용 범위는 어디까지인가
7. 관련 시스템과의 상호작용 규칙은 무엇인가
8. 대표 예외 상황 1은 어떻게 처리하는가
9. 대표 예외 상황 2는 어떻게 처리하는가
10. 구현 완료로 볼 최소 검증 장면 또는 테스트는 무엇인가

## 문서 반영 규칙

- 답변이 규칙을 바꾸면 `rule` 문서에 먼저 적는다.
- 답변이 구현 범위를 바꾸면 `plan` 문서에 반영한다.
- 답변이 enum, 필드, 상태를 추가하면 `schema`를 반영한다.
- 아직 구현되지 않은 상태 변화만 있으면 `tracker`는 바꾸지 않는다.

## 금지 규칙

- 10개를 넘는 질문을 한 번에 던지지 않는다.
- 질문 라운드를 하면서 동시에 큰 구현을 시작하지 않는다.
- 사용자 답변 없이 빈칸을 임의로 채워 넣고 `확정`으로 쓰지 않는다.
- 같은 backlog 항목에서 이미 잠근 결정을 다음 라운드에서 다시 뒤집지 않는다.

---
title: AI 문서 업데이트 규칙
doc_type: rule
status: active
section: governance
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - handoff_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# AI 문서 업데이트 규칙

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 문서는 AI가 Dungeon Mage 문서를 읽고, 수정하고, 새 문서를 추가할 때 따라야 할 공통 규칙을 정의한다.

이 문서의 목표는 아래와 같다.

- AI가 문서 타입을 혼동하지 않게 한다.
- 코드 변경과 문서 변경이 엇갈릴 때 우선순위를 고정한다.
- 문서 변경 이력이 사람이 추적 가능한 형태로 남게 한다.

## AI 기본 읽기 순서

AI는 문서를 수정하기 전에 아래 순서로 읽는다.

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. 해당 섹션의 `README.md`
8. 구조, 인덱스, 프롬프트 체계를 바꿀 때만 [target_doc_structure.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md)
9. 관련 기준 문서
10. 필요할 때만 tracker, plan, archive 문서

기본 읽기 체인에서는 `docs/superpowers/`를 읽지 않는다.  
이 경로는 레거시 스냅샷 보존 영역이며, 과거 판단 근거가 필요할 때만 `archive`처럼 제한적으로 참고한다.

## 작업 요청 처리 규칙

### 사용자가 구현을 요청한 경우

- 먼저 관련 `plan` 문서를 찾는다.
- 그다음 `baseline`, `rule`, `schema`, `tracker` 순으로 필요한 문서를 읽는다.
- 구현 가능한 가장 작은 안전 증분만 수행한다.
- 작업 종료 시 관련 문서를 같은 턴에 함께 갱신한다.
- 병렬 역할 분리 중에는 구현 파일 권한과 문서 권한을 분리해서 해석한다.
- 같은 턴 문서 동기화는 역할 프롬프트와 역할 계약에 정의된 최소 조건부 문서 범위 안에서만 수행한다.

### 사용자가 "알아서 다음 작업"을 요청한 경우

- [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 먼저 본다.
- 관련 `plan`이나 `increment`는 backlog 확인 뒤에만 읽는다.
- 가장 시급한 항목이 구현 가능 상태면 구현한다.
- 가장 시급한 항목이 아직 모호하면 질문 라운드로 전환한다.

### 기획이 모호한 경우

- 구현보다 질문 라운드를 우선한다.
- 질문 방식은 [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)를 따르며, 한 라운드는 정확히 `10문항`으로 고정한다.

## Skills / MCP 연결 규칙

- 반복 작업은 먼저 등록된 skill을 사용한다.
- scene/node/script wiring 확인 작업은 Godot MCP를 먼저 시도한다.
- 세부 규칙은 [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)를 따른다.

## 문서 타입별 책임

- `index`: 어디를 읽어야 하는지 안내한다. 세부 규칙을 길게 중복하지 않는다.
- `rule`: 최신 기획 또는 운영 규칙을 정의한다.
- `catalog`: 콘텐츠 roster와 목록을 관리한다.
- `schema`: 데이터 필드와 허용값을 정의한다.
- `tracker`: 구현/에셋/검증 상태만 기록한다.
- `baseline`: 현재 코드와 실제 런타임 사실을 정리한다.
- `plan`: 앞으로의 작업 계획과 증분 범위를 정리한다.
- `archive`: 과거 기준이나 스냅샷을 보존한다.

## 소스 오브 트루스 우선순위

문서와 코드가 충돌할 때는 아래 순서를 따른다.

1. 실제 코드와 데이터
2. `baseline`
3. `rule`
4. `schema`
5. `tracker`
6. `plan`
7. `archive`

단, `최신 기획 의도`를 묻는 질문은 `rule` 문서를 우선한다.  
단, `현재 빌드에서 실제로 되는 것`을 묻는 질문은 코드와 `baseline`을 우선한다.

## 수정 판단 규칙

### 규칙이 바뀐 경우

- `rule` 문서를 먼저 수정한다.
- 필드나 허용값이 바뀌면 `schema`를 함께 수정한다.
- 구현 상태에 영향이 있으면 `tracker`를 갱신한다.
- 현재 빌드 설명이 바뀌면 `baseline`을 갱신한다.
- 후속 작업이 생기면 `plan`에만 추가한다.

### 코드가 먼저 바뀐 경우

- 코드 기준으로 사실을 확인한다.
- `baseline`을 먼저 맞춘다.
- 그다음 `tracker`를 갱신한다.
- 코드 변경이 기획 의도와 불일치하면 `rule` 수정 대신 차이를 명시하고 추가 판단을 남긴다.

### 새 콘텐츠를 추가한 경우

1. `rule` 또는 `catalog`에 새 항목을 추가한다.
2. 필요한 경우 `schema` 허용값을 확인한다.
3. `tracker`에 상태 row를 추가한다.
4. 구현 후 `baseline` 또는 관련 코드 설명을 갱신한다.
5. 후속 작업이 남으면 `plan`에 기록한다.

## 새 문서 생성 규칙

- 같은 역할의 문서가 이미 있으면 새 문서를 만들지 않고 기존 문서를 우선 갱신한다.
- 새 문서는 반드시 상위 인덱스에서 진입 가능해야 한다.
- 새 문서가 추가되면 최소한 상위 `README.md` 하나는 함께 갱신한다.
- 루트 `docs/README.md`는 전체 포털만 유지하고, 새 세부 문서의 등록은 해당 섹션 `README.md`를 우선 갱신한다.
- 실행 프롬프트의 읽기 순서를 바꾸면 루트 `README`, 거버넌스 문서, 관련 섹션 `README`를 같은 턴에 함께 맞춘다.
- 살아 있는 운영 문서에는 날짜를 파일명으로 넣지 않는다.
- 날짜형 파일명은 `archive` 또는 스냅샷 문서에만 사용한다.

## 금지 규칙

- `tracker` 문서에서 최신 기획을 새로 정의하지 않는다.
- `plan` 문서에서 현재 런타임 사실을 확정하지 않는다.
- `archive` 문서를 최신 기준 문서처럼 갱신하지 않는다.
- 한 변경에 대해 서로 다른 문서에 같은 설명을 길게 복제하지 않는다.
- 섹션 인덱스 없이 고아 문서를 만들지 않는다.

## 변경 추적 규칙

AI가 운영 문서를 수정할 때는 아래를 지킨다.

- 문서 상단의 `최종 갱신`을 함께 갱신한다.
- 큰 구조 변경이면 관련 상위 `README.md`도 갱신한다.
- 문서 안에 긴 실행 로그를 누적하지 않는다.
- 반복적으로 바뀌는 상태 정보는 `tracker`나 `workstream` 문서로 보낸다.
- 과거 기준을 남겨야 하면 본문에 덧붙이지 말고 `archive` 문서로 분리한다.
- `workstream` 문서는 활성 문서와 아카이브를 분리하고, 활성 문서는 현재 상태 요약만 남긴다.
- `workstream` 아카이브 파일명은 기본적으로 `<workstream_name>_archive_<start_date>_to_<end_date>_session_<last_session>.md` 형식을 따른다.

## 문서 길이 관리 규칙

- 300줄을 넘는 문서는 분할 가능성을 먼저 검토한다.
- `workstream` 문서는 200줄 전후부터 롤오버 후보로 보고, 장기 누적 로그를 활성 문서에 계속 쌓지 않는다.
- 아래 항목이 3개 이상 한 문서에 함께 있으면 분리 후보다.
  - 기준 규칙
  - 현재 상태
  - 구현 로그
  - 에셋 가이드
  - 검증 체크리스트
  - 장기 계획

## 문서 수정 체크리스트

- [ ] 수정 대상 문서의 타입을 먼저 확인했다.
- [ ] 상위 인덱스와 관련 기준 문서를 먼저 읽었다.
- [ ] 코드와 문서가 충돌하는지 확인했다.
- [ ] 필요한 경우 `baseline`, `tracker`, `plan`까지 영향 범위를 점검했다.
- [ ] 새 문서를 만들었다면 상위 `README.md` 링크를 추가했다.
- [ ] `최종 갱신` 표기를 갱신했다.

## 실무 적용 예시

### 스킬 수치 규칙이 바뀐 경우

- `skill_system_design.md` 또는 관련 `rule` 문서를 수정한다.
- JSON 필드나 enum 변경이 있으면 `skill_data_schema.md`를 수정한다.
- 현재 구현 상태에 영향이 있으면 `skill_implementation_tracker.md`를 갱신한다.
- 실제 런타임 설명이 달라졌으면 `current_runtime_baseline.md`를 갱신한다.

### 적 구현이 코드에서 먼저 늘어난 경우

- 코드와 데이터 파일을 기준으로 사실을 확인한다.
- `current_runtime_baseline.md`를 먼저 맞춘다.
- `enemy_content_tracker.md`를 갱신한다.
- roster 기준 변화가 있으면 `enemy_catalog.md`를 함께 갱신한다.

### workstream 로그가 너무 커진 경우

- 활성 `workstream` 문서에서 현재 상태, 다음 작업, 교차 의존 요청만 남긴다.
- 누적 로그는 `archive/`로 롤오버한다.
- 상위 `README.md`와 활성 `workstream` 문서에 아카이브 링크를 추가한다.

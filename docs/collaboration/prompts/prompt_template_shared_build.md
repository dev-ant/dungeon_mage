---
title: 통합 작업 시작 프롬프트
doc_type: prompt
status: active
section: collaboration
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/single_stream_collaboration.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md
update_when:
  - handoff_changed
  - policy_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 통합 작업 시작 프롬프트

## 읽기 순서

1. `docs/README.md`
2. `docs/governance/README.md`
3. `docs/governance/ai_update_protocol.md`
4. `docs/implementation/README.md`
5. `docs/collaboration/README.md`
6. `docs/collaboration/policies/single_stream_collaboration.md`
7. `docs/collaboration/workstreams/shared_ui_runtime_workstream.md`
8. 현재 요청과 직접 관련된 `baseline / plan / increment`

## 작업 규칙

- 기본 모드는 `single-stream` 이다.
- 구현이 바뀌면 같은 턴에 관련 `baseline`, 필요 시 `plan`까지 동기화한다.
- 진행 로그는 `docs/collaboration/workstreams/shared_ui_runtime_workstream.md`에만 남긴다.
- 레거시 owner/friend 문서는 읽기 전용 참고 자료로만 사용한다.
- 넓은 요청이면 `spec_clarification_backlog.md`를 plan보다 먼저 읽는다.
- scene/node/script wiring은 가능하면 Godot MCP를 먼저 시도한다.

## 출력 규칙

- 가장 작은 안전 증분 하나를 실제로 구현한다.
- 구현 후 `headless startup`, 관련 GUT, 필요한 문서 동기화까지 닫는다.
- 남은 리스크와 다음 가장 작은 후속 작업을 shared workstream 기준으로 정리한다.


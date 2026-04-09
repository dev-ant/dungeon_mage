---
title: 단일 작업 흐름 협업 정책
doc_type: rule
status: active
section: collaboration
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
update_when:
  - ownership_changed
  - handoff_changed
  - status_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 단일 작업 흐름 협업 정책

상태: 사용 중  
최종 갱신: 2026-04-10

## 목표

이 정책은 `owner_core / friend_gui` 역할 분리 운영이 끝난 뒤, 한 개의 활성 workstream과 한 개의 기본 prompt 흐름으로 프로젝트를 계속 진행하기 위한 기준 문서다.

## 적용 범위

- 기본 협업 모드는 이제 `single-stream` 이다.
- 새 진행 로그는 [shared_ui_runtime_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md)에만 남긴다.
- 기존 `role_split_contract.md`, `owner_core_workstream.md`, `friend_gui_workstream.md` 는 레거시 참조 문서로 유지하되 새 진행 기준으로는 사용하지 않는다.

## 운영 원칙

- 구현 파일 권한과 문서 권한을 인위적으로 나누지 않는다.
- 같은 턴 구현이 바뀌면 관련 `baseline -> rule/schema/tracker -> plan` 순서로 실제 문서를 바로 동기화한다.
- 진행 로그는 활성 shared workstream 하나에만 남긴다.
- 레거시 문서는 삭제하지 않고 읽기 전용 역사 기록으로 둔다.
- 새 prompt가 필요한 경우 shared prompt를 우선 사용하고, owner/friend prompt는 레거시 참조로만 남긴다.

## 기본 문서 읽기 순서

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
4. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
5. [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md)
6. [shared_ui_runtime_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/shared_ui_runtime_workstream.md)

## 문서 해석 규칙

- 현재 구현 사실은 항상 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)를 우선한다.
- 장기 마이그레이션 목표와 acceptance criteria는 [maple_style_ui_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/maple_style_ui_migration_plan.md)를 따른다.
- 과거 역할 분리 중 생성된 handoff와 prompt는 역사 참고용으로만 읽고, 새 작업 권한 판단의 기준으로는 쓰지 않는다.

## 레거시 문서 처리 규칙

- [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)는 `superseded` 상태의 기록 문서로 유지한다.
- [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)와 [friend_gui_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md)는 새 로그를 받지 않는다.
- owner/friend prompt는 레거시 실행 예시로만 남기고, 새 단일 작업 흐름에서는 shared prompt를 기본으로 쓴다.

## acceptance criteria

- collaboration README의 기본 진입점이 shared policy/workstream 기준으로 바뀐다.
- 새 진행 로그가 owner/friend 문서가 아니라 shared workstream에만 기록된다.
- role split 관련 문서는 보존되지만 active source of truth로는 읽히지 않는다.


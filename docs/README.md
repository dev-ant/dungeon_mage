---
title: 문서 인덱스
doc_type: index
status: active
section: root
owner: shared
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - structure_changed
  - handoff_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 문서 인덱스

이 문서는 전체 문서 체계의 최상위 탐색 포털입니다. 상세 문서 등록 책임은 각 섹션 `README.md`가 가집니다.

## AI 기본 시작 체인

모든 실행 프롬프트와 문서 작업은 아래 순서를 같은 기본 체인으로 사용합니다.

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. 관련 섹션 `README.md`

그다음 작업별 확장 규칙은 아래를 고정합니다.

- 요청 범위가 넓으면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 `plan`보다 먼저 읽습니다.
- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환합니다.
- 반복 작업은 등록된 skill을 먼저 사용합니다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도합니다.

## 섹션

- [문서 운영](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
- [기초 설정](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/README.md)
- [성장 시스템](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/README.md)
- [구현 기준](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
- [협업 작업](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md)

## 거버넌스 핵심 문서

- [문서 운영 인덱스](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
- [AI 네이티브 운영 모델](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
- [AI 문서 업데이트 규칙](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
- [10문항 기획 구체화 프로토콜](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
- [Skills 및 Godot MCP 사용 정책](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)

## 섹션별 대표 기준 문서

- `foundation`: [world_and_power.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/world_and_power.md), [protagonist.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/foundation/rules/protagonist.md)
- `progression`: [skill_system_design.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/skill_system_design.md), [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
- `implementation`: [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md), [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md), [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)
- `collaboration`: [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md), [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)

상세 문서 목록과 세부 등록표는 각 섹션 `README.md`에서 유지합니다.

## 폐기된 진입 문서

- [game_narrative_foundation.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/game_narrative_foundation.md)
- [skill_and_equipment_progression.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/skill_and_equipment_progression.md)
- [development_stack.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/development_stack.md)

## 아카이브 문서 진입

- [progression/archive/](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/)
- [spell_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_catalog.md)
- [spell_concept_rework_2026-04-02.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/archive/spell_concept_rework_2026-04-02.md)
- [collaboration/archive/](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/)

## 레거시 보존 영역

- `docs/superpowers/`는 과거 설계/세팅 스냅샷을 보존하는 레거시 아카이브 영역입니다.
- 기본 읽기 체인에서는 제외하고, 과거 판단 근거가 필요할 때만 참고합니다.

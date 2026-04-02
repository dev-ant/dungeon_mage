---
title: AI 네이티브 문서 운영 모델
doc_type: rule
status: active
section: governance
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - handoff_changed
  - ownership_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# AI 네이티브 문서 운영 모델

상태: 사용 중  
최종 갱신: 2026-04-02  
섹션: 문서 거버넌스

## 목적

이 문서는 Dungeon Mage를 `AI가 스스로 읽고, 안전 범위로 구현하고, 필요한 문서를 다시 갱신할 수 있는 프로젝트`로 운영하기 위한 실제 문서 구조 개선안을 정의한다.

이 문서는 추상 원칙이 아니라, 현재 저장소 기준으로 어떤 문서 체인을 만들고 어떤 흐름으로 AI가 움직여야 하는지까지 고정한다.

## 이 모델이 해결하려는 문제

- 사용자가 구현 요청만 줘도 AI가 먼저 읽어야 할 문서 체인을 자동으로 찾기 어렵다.
- 기획이 덜 잠긴 상태에서 AI가 성급히 구현을 시작하면 안전 범위를 넘을 수 있다.
- 반복 작업에서 skills, MCP, 문서 갱신 규칙이 한 문서에 묶여 있지 않아 매번 판단 비용이 크다.
- 루트 `docs/README.md`에 세부 문서 등록표가 과도하게 쌓이면 새 문서 추가 때마다 누락과 드리프트가 생기기 쉽다.
- 장기적으로 문서가 커지면 `현재 사실`, `최신 기획`, `상태 추적`, `향후 계획`이 다시 섞일 위험이 있다.

## 목표 상태

### 1. 구현 요청을 받았을 때

사용자가 "이거 구현해", "다음 작업 진행해", "전투 작업 이어서 해" 같은 프롬프트를 주면 AI는 아래 순서로 움직인다.

1. 루트 인덱스 [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. 거버넌스 인덱스 [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. 이 문서 [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. 관련 섹션 `README.md`
8. 그다음에만 관련 `plan -> baseline -> rule -> catalog -> schema -> tracker`

그 뒤 AI는 `현재 구현 가능한 가장 작은 안전 증분`만 수행한다.

### 2. 기획이 모호할 때

- AI는 바로 구현하지 않는다.
- [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)에 따라 `정확히 10문항` 인터뷰 모드로 전환한다.
- 각 라운드 뒤에는 관련 `rule`, `plan`, `tracker` 문서를 갱신한다.

### 3. 사용자가 "알아서 질문해서 기획 완성해"라고 할 때

- AI는 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 읽고 가장 긴급하고 가장 덜 잠긴 항목을 고른다.
- 그 항목에 대해 정확히 10문항 라운드를 시작한다.
- 답변을 반영해 backlog 우선순위와 linked docs를 갱신한다.

### 4. 반복 작업일 때

- 에셋 적용, 문서 동기화, 진행도 점검, MCP 기반 장면 조사처럼 반복되는 작업은 먼저 등록된 skill을 사용한다.
- skill이 자주 부족하면 관련 skill을 먼저 개선하고, 그다음 본 작업을 계속한다.

### 5. Godot 장면/노드 확인이 필요할 때

- scene/node/script wiring 확인이 필요하면 먼저 Godot MCP를 시도한다.
- MCP가 안 되면 `rg`, 파일 읽기, headless 검증으로 안전하게 대체한다.

## 이 프로젝트의 실제 목표 구조

현재 저장소 기준으로 목표 구조는 아래처럼 굳힌다.

```text
docs/
  README.md
  governance/
    README.md
    ai_native_operating_model.md
    ai_update_protocol.md
    clarification_loop_protocol.md
    skills_and_mcp_policy.md
    target_doc_structure.md
    templates/
  foundation/
    README.md
    rules/
    catalogs/
    archive/
  progression/
    README.md
    rules/
    catalogs/
    schemas/
    trackers/
    plans/
    archive/
  implementation/
    README.md
    baselines/
    plans/
    increments/
    runbooks/
    spec_clarification_backlog.md
    archive/
  collaboration/
    README.md
    policies/
    workstreams/
    prompts/
    archive/
```

2026-04-02 기준으로 `progression`, `implementation`, `foundation`, `collaboration`의 1차 하위 폴더 분리는 실제 저장소에 적용 완료되었다.
같은 날짜 기준으로 활성 운영 문서, archive 문서, 레거시 리다이렉트, `docs/superpowers/` 보존 문서까지 공통 frontmatter가 적용되어 문서 타입과 생명주기를 기계적으로 판별할 수 있다.
루트 `docs/README.md`는 전체 탐색 포털로만 유지하고, 세부 문서 등록 책임은 각 섹션 `README.md`가 가진다.

## 현재 문서의 적용 상태와 다음 목표

### `foundation/` 1차 적용 완료

| 이전 문서 | 현재 적용 위치 | 타입 |
| --- | --- | --- |
| `foundation/world_and_power.md` | `foundation/rules/world_and_power.md` | `rule` |
| `foundation/protagonist.md` | `foundation/rules/protagonist.md` | `rule` |
| `foundation/dungeon_premise.md` | `foundation/rules/dungeon_premise.md` | `rule` |
| `foundation/story_arc.md` | `foundation/rules/story_arc.md` | `rule` |

### `progression/` 1차 적용 완료

| 이전 문서 | 현재 적용 위치 | 타입 |
| --- | --- | --- |
| `progression/progression_overview.md` | `progression/rules/progression_overview.md` | `rule` |
| `progression/skill_system_design.md` | `progression/rules/skill_system_design.md` | `rule` |
| `progression/skill_level_rules.md` | `progression/rules/skill_level_rules.md` | `rule` |
| `progression/enemy_stat_and_damage_rules.md` | `progression/rules/enemy_stat_and_damage_rules.md` | `rule` |
| `progression/circle_progression.md` | `progression/rules/circle_progression.md` | `rule` |
| `progression/buff_system.md` | `progression/rules/buff_system.md` | `rule` |
| `progression/enemy_catalog.md` | `progression/catalogs/enemy_catalog.md` | `catalog` |
| `progression/spell_catalog.md` | `progression/archive/spell_catalog.md` | `archive` |
| `progression/buff_skill_catalog.md` | `progression/catalogs/buff_skill_catalog.md` | `catalog` |
| `progression/buff_combo_catalog.md` | `progression/catalogs/buff_combo_catalog.md` | `catalog` |
| `progression/mastery_skills.md` | `progression/catalogs/mastery_skills.md` | `catalog` |
| `progression/skill_data_schema.md` | `progression/schemas/skill_data_schema.md` | `schema` |
| `progression/enemy_data_schema.md` | `progression/schemas/enemy_data_schema.md` | `schema` |
| `progression/buff_combo_data_schema.md` | `progression/schemas/buff_combo_data_schema.md` | `schema` |
| `progression/skill_implementation_tracker.md` | `progression/trackers/skill_implementation_tracker.md` | `tracker` |
| `progression/enemy_content_tracker.md` | `progression/trackers/enemy_content_tracker.md` | `tracker` |
| `progression/skills_json_canonical_migration_plan.md` | `progression/plans/skills_json_canonical_migration_plan.md` | `plan` |
| `progression/spell_concept_rework_2026-04-02.md` | `progression/archive/spell_concept_rework_2026-04-02.md` | `archive` |

### `implementation/` 1차 적용 완료

| 이전 문서 | 현재 적용 위치 | 타입 |
| --- | --- | --- |
| `implementation/current_runtime_baseline.md` | `implementation/baselines/current_runtime_baseline.md` | `baseline` |
| `implementation/development_stack.md` | `implementation/baselines/development_stack.md` | `baseline` |
| `implementation/combat_first_build_plan.md` | `implementation/plans/combat_first_build_plan.md` | `plan` |
| `implementation/enemy_data_runtime_migration_plan.md` | `implementation/plans/enemy_data_runtime_migration_plan.md` | `plan` |
| `implementation/godot_mcp_setup.md` | `implementation/runbooks/godot_mcp_setup.md` | `runbook` |
| `implementation/combat_increment_01_player_controller.md` | `implementation/increments/combat_increment_01_player_controller.md` | `plan` |
| `implementation/combat_increment_02_spell_runtime.md` | `implementation/increments/combat_increment_02_spell_runtime.md` | `plan` |
| `implementation/combat_increment_03_buff_action_loop.md` | `implementation/increments/combat_increment_03_buff_action_loop.md` | `plan` |
| `implementation/combat_increment_04_enemy_combat_set.md` | `implementation/increments/combat_increment_04_enemy_combat_set.md` | `plan` |
| `implementation/combat_increment_05_equipment_minimum.md` | `implementation/increments/combat_increment_05_equipment_minimum.md` | `plan` |
| `implementation/combat_increment_06_combat_ui.md` | `implementation/increments/combat_increment_06_combat_ui.md` | `plan` |
| `implementation/combat_increment_07_admin_sandbox.md` | `implementation/increments/combat_increment_07_admin_sandbox.md` | `plan` |
| `implementation/combat_increment_08_admin_tabs_and_inventory.md` | `implementation/increments/combat_increment_08_admin_tabs_and_inventory.md` | `plan` |
| `implementation/combat_increment_09_soul_dominion_risk.md` | `implementation/increments/combat_increment_09_soul_dominion_risk.md` | `plan` |

### `collaboration/` 1차 적용 완료

| 이전 문서 | 현재 적용 위치 | 타입 |
| --- | --- | --- |
| `collaboration/role_split_contract.md` | `collaboration/policies/role_split_contract.md` | `rule` |
| `collaboration/owner_core_workstream.md` | `collaboration/workstreams/owner_core_workstream.md` | `tracker` |
| `collaboration/friend_gui_workstream.md` | `collaboration/workstreams/friend_gui_workstream.md` | `tracker` |
| `collaboration/prompt_template_owner_core.md` | `collaboration/prompts/prompt_template_owner_core.md` | `prompt` |
| `collaboration/prompt_template_friend_gui.md` | `collaboration/prompts/prompt_template_friend_gui.md` | `prompt` |
| `collaboration/prompt_codex_owner_core.md` | `collaboration/prompts/prompt_codex_owner_core.md` | `prompt` |
| `collaboration/ai_cli_handoff_for_gemini.md` | `collaboration/prompts/ai_cli_handoff_for_gemini.md` | `prompt` |
| `collaboration/progress_check_prompt.md` | `collaboration/prompts/progress_check_prompt.md` | `prompt` |

## 메타데이터 적용 상태

- 활성 운영 문서 frontmatter 적용: 완료
- archive 문서 frontmatter 적용: 완료
- 루트 폐기 진입점 frontmatter 적용: 완료
- `docs/superpowers/` 레거시 보존 문서 frontmatter 적용: 완료

이제 이 운영 모델의 남은 일은 구조 개편이 아니라 `새 문서가 생길 때 같은 규칙을 유지하는 것`이다.

## AI가 구현 요청을 받았을 때의 기본 실행 체인

아래 1~7은 모든 실행 프롬프트가 그대로 포함해야 하는 공통 시작 체인이다.

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. 관련 섹션 `README.md`

### A. 사용자가 범위를 구체적으로 말한 경우

예:

- "전투 UI 진행해"
- "7서클 스킬 구현해"
- "적 데이터 마이그레이션 이어서 해"

AI는 공통 시작 체인을 끝낸 뒤 아래 순서로 읽는다.

1. 관련 `implementation/increments` 또는 `implementation/plans`
2. 관련 `baseline`
3. 관련 `rule`
4. 관련 `schema`
5. 관련 `tracker`
6. 반복 작업이면 관련 skill
7. scene/node/script wiring 확인이 필요하면 Godot MCP

### B. 사용자가 범위를 넓게 말한 경우

예:

- "다음 작업 진행해"
- "알아서 이어서 작업해"
- "현재 가장 중요한 거 해줘"

AI는 공통 시작 체인을 끝낸 뒤 아래 순서로 읽는다.

1. [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)
2. [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
3. 관련 increment 문서
4. [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
5. 관련 `progression` 기준 문서

그 뒤 아래 둘 중 하나를 선택한다.

- 바로 구현 가능한 작은 안전 증분이면 구현
- 기획이 모호하면 정확히 10문항 인터뷰 모드 시작

## 안전 범위 규칙

- AI는 항상 현재 계획 문서가 허용한 가장 작은 범위만 구현한다.
- `plan` 문서에 없는 대형 리팩터링은 먼저 문서 갱신이나 질문 라운드를 거친다.
- `baseline`과 다른 구조를 새로 제안할 때는 먼저 문서를 맞추거나 질문을 통해 잠근다.
- GUI, 전투 코어, 데이터 구조처럼 충돌 위험이 큰 영역은 workstream 소유 범위를 먼저 확인한다.

## 문서 체인 규칙

AI가 작업을 닫으려면 아래 체인 중 필요한 문서를 같은 턴에 함께 점검한다.

### 구현 작업

`plan -> baseline -> rule -> schema -> tracker`

### 기획 확정 작업

`rule -> catalog -> schema -> plan`

### 런타임 사실 정리 작업

`code -> baseline -> tracker -> plan`

## 이번 구조 개선의 1차 완료 항목

- [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md) 추가 완료
- [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md) 추가 완료
- [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md) 추가 완료
- `docs/progression/` 하위 폴더 분리 완료
- `docs/implementation/` 하위 폴더 분리 완료
- `docs/foundation/` 하위 폴더 분리 완료
- `docs/collaboration/` 하위 폴더 분리 완료

## 단계별 적용 우선순위

1. 새 작업은 먼저 이 운영 모델을 따른다.
2. `collaboration/workstreams/`는 활성 상태 문서와 아카이브를 분리해 유지하고, 누적 로그가 커지면 주간/마일스톤 단위로 롤오버한다.
3. `docs/` 루트의 legacy 진입 문서는 짧은 리다이렉트 문서로만 유지한다.
4. `spec_clarification_backlog.md`를 기준으로 모호한 기획을 질문 라운드로 잠근다.
5. 반복 작업은 skill 우선으로 흘리고, 필요하면 skill을 먼저 개선한다.
6. scene/node/script wiring 확인이 필요한 작업은 Godot MCP 우선으로 바꾼다.

## 비목표

- 이번 턴에 `workstreams` 로그 롤오버까지 한 번에 하지는 않는다.
- 기존 링크를 한 번에 깨는 대규모 리네임은 지금 턴의 목표가 아니다.
- lore 확장이나 새 시스템 제안 자체는 이 문서의 범위가 아니다.

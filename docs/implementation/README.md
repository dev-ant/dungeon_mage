---
title: 구현 기준 인덱스
doc_type: index
status: active
section: implementation
owner: runtime
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - runtime_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 구현 기준 인덱스

상태: 사용 중  
최종 갱신: 2026-04-03

## 범위

이 섹션은 프로젝트 구현 제약과 기술 스택 규칙을 추적합니다.

2026-04-02 기준으로 이 섹션은 `baselines / plans / increments / runbooks` 하위 폴더 1차 분리를 완료했습니다.

이 섹션의 상세 문서 등록 책임은 이 `README.md`가 가집니다. 루트 `docs/README.md`에는 대표 진입점만 유지합니다.

## 섹션 확장 읽기 순서

이 섹션은 [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md) 와 거버넌스 시작 체인을 먼저 읽은 뒤에 해석합니다.

1. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
2. 넓은 요청이면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)
3. 관련 `plans/` 또는 `increments/`
4. 관련 `baselines/`
5. 관련 `progression` 기준 문서

## 섹션 운영 잠금 규칙

- 넓은 요청에서는 `plan`보다 backlog를 먼저 본다.
- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.

## 문서 목록

### `baselines`

- 현재 구현 기준선: [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
- [development_stack.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/development_stack.md)

### `plans`

- [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
- [enemy_data_runtime_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/enemy_data_runtime_migration_plan.md)

### `increments`

- 병렬 작업 중에는 [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md) 와 역할별 workstream 문서를 함께 읽는다.
- [combat_increment_01_player_controller.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_01_player_controller.md)
- [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)
- [combat_increment_03_buff_action_loop.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_03_buff_action_loop.md)
- [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)
- [combat_increment_05_equipment_minimum.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_05_equipment_minimum.md)
- [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)
- [combat_increment_07_admin_sandbox.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_07_admin_sandbox.md)
- [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md)
- [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_09_soul_dominion_risk.md)

### `runbooks`

- [godot_mcp_setup.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/godot_mcp_setup.md)

### 루트 schema

- [combat_hud_gui_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_hud_gui_schema.md)
  - 전투 HUD 그래픽 GUI의 레이아웃 상태, 상호작용 상태, 설정 토글 필드 기준

### 루트 tracker

- [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)
  - 구현 전에 더 잠가야 하는 기획 질문 큐

### 연결되는 progression 기준 문서

- 전투 수치 기준선: [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
- 몬스터 roster / 역할 기준: [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)
- 몬스터 데이터 필드 기준: [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)
- 몬스터 구현 / 에셋 / 테스트 상태: [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)

## 해석 우선순위

- 구현 판단은 항상 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md) 를 먼저 따른다.
- 몬스터가 무엇을 담당하는지, 어떤 적이 정식 편입 대상인지 판단할 때는 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md) 를 함께 따른다.
- 적 스탯, 데미지 감쇠, 속성 저항, 상태이상 저항, 슈퍼아머, 브레이크 규칙은 반드시 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 함께 따른다.
- `data/enemies/enemies.json` 필드 추가/변경은 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md) 를 함께 따른다.
- 몬스터 구현 / 에셋 / 테스트 반영 상태를 확인할 때는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md) 를 함께 따른다.
- 위 규칙이 바뀌면 구현만 바꾸지 말고 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 함께 수정한다.
- `combat_first_build_plan.md` 같은 장기 문서에 남아 있는 과거 전제는 히스토리로 취급한다.
- 특히 `SpellResource`, `player_state_chart.tres`, `scenes/player/Player.tscn` 전제는 현재 코드 기준이 아니다.

## 수정 규칙

- 현재 사실을 설명하는 문서는 `baselines/`를 먼저 수정한다.
- 장기 작업 범위와 acceptance criteria는 `plans/`를 수정한다.
- 즉시 구현 핸드오프와 체크리스트는 `increments/`를 수정한다.
- Godot MCP, 검증 절차, setup 절차는 `runbooks/`를 수정한다.

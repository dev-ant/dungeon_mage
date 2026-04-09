---
title: AI CLI 핸드오프 가이드
doc_type: prompt
status: active
section: collaboration
owner: friend_gui
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md
update_when:
  - handoff_changed
  - ownership_changed
  - structure_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# AI CLI 핸드오프 가이드

상태: 사용 중  
최종 갱신: 2026-04-02  
대상: 친구의 Gemini 또는 다른 AI CLI

## 이 문서의 우선순위

이 문서는 `사람용 설명`보다 `AI가 바로 작업 흐름을 파악하는 것`을 우선한다.

AI는 작업 시작 시 아래 순서대로 해석한다.

1. 공통 거버넌스 시작 체인 읽기
2. 관련 섹션 README 읽기
3. 역할 분리 계약 읽기
4. 본인 workstream 문서 읽기
5. 관련 구현 문서 읽기
6. 본인 역할의 허용 구현 파일과 허용 문서 범위만 수정

## 프로젝트 핵심 규칙

- 엔진: Godot 4.6
- 카메라: `PhantomCamera2D` / `PhantomCameraHost`만 사용
- 상태 관리: `Godot State Charts` 우선
- 테스트: 새 동작에는 `GUT` 테스트 추가
- 헤드리스 검증 필수

## 이 프로젝트에서 AI가 따라야 할 읽기 순서

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/governance/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/README.md)
3. [ai_native_operating_model.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_native_operating_model.md)
4. [ai_update_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md)
5. [clarification_loop_protocol.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/clarification_loop_protocol.md)
6. [skills_and_mcp_policy.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/skills_and_mcp_policy.md)
7. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
8. [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md)
9. [CLAUDE.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/CLAUDE.md)
10. [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)
11. 자기 역할 workstream 문서
12. 넓은 요청이면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)를 관련 `plan`보다 먼저 읽는다.
13. 그다음 관련 `plan`, `baseline`, `rule`, `schema`, `tracker`를 읽는다.

## 거버넌스 잠금 규칙

- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.
- 위 규칙은 역할 분리 계약보다 앞선 공통 시작 체인으로 취급한다.

## Skills 사용 방식 핵심

이 프로젝트는 이미 `skills` 중심 작업 흐름을 전제로 굴러가고 있다.

### 1. `dungeon-mage-spec-to-godot`

언제 쓰나:

- `docs/` 문서를 읽고 실제 구현 태스크로 바꿀 때

핵심 효과:

- 문서의 Goal -> 기능 목표
- Likely Files Or Systems -> 수정 파일
- Acceptance Criteria -> 테스트 항목
- Non-Goals -> 이번 작업에서 건드리면 안 되는 범위

### 2. `dungeon-mage-godot-mcp`

언제 쓰나:

- `.tscn` 구조 파악
- 씬 생성/수정
- 런타임 디버그
- 프로젝트 구조 확인

핵심 효과:

- 씬을 직접 감으로 수정하지 않고 현재 구조를 먼저 확인
- 런타임 에러를 빠르게 재현

### 3. `dungeon-mage-asset-import`

언제 쓰나:

- `asset_sample/` 에 있는 PNG를 실제 UI/캐릭터에 연결할 때

핵심 효과:

- 이미지 분석
- 프레임/스케일 확인
- Godot 씬 반영 기준 고정

### 4. `dungeon-mage-godot-combat`

언제 쓰나:

- 전투 로직
- 상태 전이
- 피격감
- 마나/쿨타임
- 적 스탯, 저항, 슈퍼아머, 브레이크, 데미지 파이프라인

친구 GUI 역할에서는 우선순위가 낮지만, 전투 상태와 연결되는 버튼/표시를 해석할 때 참고 가능하다.

전투 수치 규칙을 실제로 변경하는 작업이면
[enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
를 함께 갱신해야 한다.

## 프롬프트 작성 핵심

좋은 시작 프롬프트는 아래 항목을 반드시 포함한다.

- 현재 역할
- 읽어야 할 문서
- Allowed implementation files
- Allowed documentation files
- Conditionally allowed implementation-facing docs for same-turn sync
- Forbidden files
- 작업 후 업데이트할 문서

## 이 프로젝트에서 좋은 프롬프트의 형태

- 역할이 먼저 나온다.
- 파일 경계가 명시된다.
- 읽기 순서가 명시된다.
- 검증 명령이 포함된다.
- 진행 로그를 어디에 남길지 명시된다.

## AI가 작업 시작 전에 반드시 확인할 것

- 지금 맡은 역할이 `owner_core`인지 `friend_gui`인지
- 수정하려는 파일이 자기 소유 파일인지
- 관련 문서를 읽었는지
- 테스트 파일까지 자기 범위 안인지

## 작업 중 규칙

- 상대 소유 파일은 절대 수정하지 않는다.
- 구현 파일 권한과 문서 권한을 분리해서 해석한다.
- 진행 로그는 자기 workstream 문서에만 남기되, 같은 턴 문서 동기화에 필요한 최소 문서만 조건부로 수정한다.
- 막히면 자기 workstream 문서의 `교차 의존 요청` 섹션에 남긴다.
- 구현 중간에도 자기 workstream 문서의 `현재 상태`, `다음 우선 작업`, `교차 의존 요청`을 먼저 갱신한다.
- 활성 workstream 문서는 가볍게 유지하고, 로그가 200줄 전후로 커지면 `archive/`로 롤오버한다.
- 대규모 리팩터링보다 작은 단위의 안전한 진행을 우선한다.

## friend_gui 권한 잠금

### Allowed implementation files

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/**` 내 GUI 신규 파일
- `scenes/ui/**`
- `scenes/main/Main.tscn`
- `tests/test_admin_menu.gd`
- GUI 전용 신규 테스트 파일

### Allowed documentation files

- `docs/collaboration/workstreams/friend_gui_workstream.md`

### Conditionally allowed implementation-facing docs for same-turn sync

- `docs/implementation/increments/combat_increment_06_combat_ui.md`
- `docs/implementation/increments/combat_increment_07_admin_sandbox.md`
- `docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md`
- `docs/implementation/baselines/current_runtime_baseline.md` when owned GUI runtime behavior changed in the same turn
- `docs/implementation/spec_clarification_backlog.md` when a GUI-related clarification item changed status in the same turn
- `docs/collaboration/archive/friend_gui_workstream_archive_*.md` only when rolling over the active friend workstream

### Forbidden files

- `data/**`
- `scripts/player/**`
- `scripts/enemies/**`
- `scripts/world/**`
- `scripts/autoload/**`
- `tests/test_player_controller.gd`
- `tests/test_spell_manager.gd`
- `tests/test_game_state.gd`
- `tests/test_enemy_base.gd`
- `tests/test_equipment_system.gd`
- `docs/collaboration/workstreams/owner_core_workstream.md`
- `docs/progression/**`
- `docs/foundation/**`
- `docs/governance/**`
- `docs/collaboration/prompts/**`
- `docs/collaboration/policies/**`
- `docs/collaboration/archive/**` outside the owned workstream rollover file
- `docs/implementation/plans/**`
- `docs/implementation/runbooks/**`
- `docs/implementation/archive/**`
- other `docs/implementation/**` outside the listed conditional sync docs

## 검증 명령

```bash
godot --headless --path . --quit
godot --headless --path . --quit-after 120
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

## 친구 AI를 위한 가장 중요한 한 줄 규칙

`docs/collaboration/policies/role_split_contract.md` 와 `docs/collaboration/workstreams/friend_gui_workstream.md`를 먼저 읽고, friend_gui의 허용 구현 파일과 허용 문서 범위 안에서만 수정하라.

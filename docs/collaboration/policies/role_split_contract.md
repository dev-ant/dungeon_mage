---
title: 역할 분리 계약서
doc_type: rule
status: active
section: collaboration
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - ownership_changed
  - handoff_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 역할 분리 계약서

상태: 사용 중
최종 갱신: 2026-04-02
섹션: 파일 소유권 기준

## 목표

현재 전투 우선 구현 계획을 두 갈래로 분리한다.

- 내 담당: `아이템창`, `스킬창`, `설정창`, `장비창` GUI 구현을 제외한 나머지 전부
- 친구 담당: `아이템창`, `스킬창`, `설정창`, `장비창` GUI 구현 전부

이 문서의 목적은 `역할 구분`보다 `수정 가능한 파일 경계`를 먼저 고정하는 데 있다.

## 공통 해석 규칙

- `GUI 구현`은 레이아웃, 입력 처리, 패널 상태, 탭 이동, 버튼 클릭, 드래그/드롭, 아이콘/슬롯 렌더링, 창 열기/닫기, 해당 테스트를 포함한다.
- `GUI 관련 코드`는 이름에 `inventory`, `equipment`, `skill_window`, `settings`, `menu`, `ui`가 들어가는 신규 파일과 아래 지정 파일을 뜻한다.
- 이 계약은 `2026-03-30` 기준으로 즉시 적용한다.

## 내 역할

담당 범위:

- 플레이어 조작
- 스킬 런타임
- 버프/조합/전투 수치
- 몬스터/전투 AI
- 월드/맵/전투 샌드박스
- 데이터 JSON
- 전투 연출과 비 GUI 로직
- GUI 창과 직접 연결되지 않는 테스트

절대 수정 금지:

- 친구 소유 파일 전체
- 아이템창/스킬창/설정창/장비창 GUI 동작을 직접 바꾸는 코드

## 친구 역할

담당 범위:

- 아이템창 GUI
- 스킬창 GUI
- 설정창 GUI
- 장비창 GUI
- GUI 진입/종료 입력
- GUI 패널 간 포커스 이동
- GUI 버튼/마우스 상호작용
- GUI 시각 자산 연결
- GUI 관련 테스트

절대 수정 금지:

- 플레이어/스킬/버프/장비 수치 로직
- 데이터 밸런스 조정
- 적 AI 및 월드 로직
- 내 소유 파일 전체

## 파일 소유권

### 내 소유 파일

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
- `docs/collaboration/prompts/prompt_template_owner_core.md`

위 목록의 `prompt` 파일은 프롬프트 유지보수 작업일 때만 소유 파일로 해석한다. 일반 구현 턴의 수정 권한은 아래 `문서 권한 해석`을 따른다.

### 친구 소유 파일

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/**` 내 신규 GUI 창 파일 전부
- `scenes/ui/**`
- `scenes/main/Main.tscn`
- `tests/test_admin_menu.gd`
- GUI 전용 신규 테스트 파일 전부
- `docs/collaboration/workstreams/friend_gui_workstream.md`
- `docs/collaboration/prompts/prompt_template_friend_gui.md`

위 목록의 `prompt` 파일은 프롬프트 유지보수 작업일 때만 소유 파일로 해석한다. 일반 구현 턴의 수정 권한은 아래 `문서 권한 해석`을 따른다.

## 문서 권한 해석

역할 분리 기간에는 `구현 파일 권한`과 `문서 권한`을 분리해서 해석한다.

### owner_core 문서 권한

- 항상 수정 가능:
  - `docs/implementation/**`
  - `docs/collaboration/workstreams/owner_core_workstream.md`
- 같은 턴 문서 동기화에 한해 조건부 수정 가능:
  - 자신이 바꾼 시스템과 직접 연결된 `docs/progression/rules/**`
  - 자신이 바꾼 시스템과 직접 연결된 `docs/progression/schemas/**`
  - 자신이 바꾼 시스템과 직접 연결된 `docs/progression/trackers/**`
  - 자신이 바꾼 시스템과 직접 연결된 `docs/progression/catalogs/**`
  - 자신이 바꾼 시스템과 직접 연결된 `docs/progression/plans/**`
  - `docs/collaboration/archive/owner_core_workstream_archive_*.md` when rolling over the active owner workstream
- 일반 작업에서 수정 금지:
  - `docs/collaboration/workstreams/friend_gui_workstream.md`
  - `docs/collaboration/prompts/**`
  - `docs/collaboration/policies/**`
  - `docs/governance/**`
  - `docs/foundation/**`
  - `docs/implementation/archive/**`

### friend_gui 문서 권한

- 항상 수정 가능:
  - `docs/collaboration/workstreams/friend_gui_workstream.md`
- 같은 턴 문서 동기화에 한해 조건부 수정 가능:
  - `docs/implementation/increments/combat_increment_06_combat_ui.md`
  - `docs/implementation/increments/combat_increment_07_admin_sandbox.md`
  - `docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md`
  - `docs/implementation/baselines/current_runtime_baseline.md` when owned GUI runtime behavior changed
  - `docs/implementation/spec_clarification_backlog.md` when a GUI-related clarification item changed status
  - `docs/collaboration/archive/friend_gui_workstream_archive_*.md` when rolling over the active friend workstream
- 일반 작업에서 수정 금지:
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

## 주의 파일

아래 파일은 충돌 가능성이 큰 파일이므로 이번 병렬 작업 기간에는 소유자 외 수정 금지다.

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scenes/main/Main.tscn`

## 권장 신규 파일 경로

친구는 가능하면 GUI 구현을 아래 경로에 몰아 넣는다.

- `scripts/ui/windows/`
- `scripts/ui/widgets/`
- `scenes/ui/windows/`
- `scenes/ui/widgets/`
- `tests/test_ui_windows_*.gd`

내 작업은 아래 경로를 우선 사용한다.

- `scripts/player/`
- `scripts/enemies/`
- `scripts/world/`
- `scripts/autoload/`
- `data/`

## 교차 의존 처리 규칙

- 상대 소유 파일 수정이 필요해 보이면 직접 수정하지 않는다.
- 자기 workstream 문서의 `교차 의존 요청` 섹션에 `이유`, `필요 입력`, `예상 파일`을 적는다.
- 소유자가 직접 처리하거나, 역할 분리 종료 후 별도 통합 단계에서 반영한다.

## 진행 기록 규칙

- 나는 [owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)만 갱신한다.
- 친구는 [friend_gui_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md)만 갱신한다.
- `combat_first_build_plan.md`는 기준 문서로 읽되, 수시 진행 로그는 남기지 않는다.

## 같은 턴 소스 오브 트루스 동기화 예외

- 위 진행 기록 규칙은 `진행 로그` 위치를 제한하는 규칙이다.
- 이 규칙은 같은 턴 문서 동기화에 필요한 `baseline`, `rule`, `schema`, `tracker`, `plan`, `catalog` 갱신을 금지하지 않는다.
- 단, 같은 턴 소스 오브 트루스 동기화는 위 `문서 권한 해석`에 정의한 최소 허용 범위 안에서만 수행한다.
- 상대 역할의 workstream, prompt, policy, governance 문서는 일반 구현 턴의 문서 동기화 예외에 포함되지 않는다.

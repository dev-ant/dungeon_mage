---
title: 친구 GUI 작업 스트림
doc_type: tracker
status: active
section: collaboration
owner: friend_gui
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
update_when:
  - handoff_changed
  - ownership_changed
  - status_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 친구 GUI 작업 스트림

상태: 사용 중  
최종 갱신: 2026-04-02  
담당자: 친구  
AI 역할: 아이템창 / 스킬창 / 설정창 / 장비창 GUI 구현

## 역할 요약

이 문서는 친구와 친구의 AI가 맡는 GUI 작업만 추적한다.

친구는 `아이템창`, `스킬창`, `설정창`, `장비창` GUI 구현만 담당한다.  
프로젝트 오너가 맡는 전투 코어, 데이터, 적 AI, 월드 로직 파일은 수정하지 않는다.

2026-04-02 기준으로 이 문서는 `현재 상태`, `다음 우선 작업`, `교차 의존 요청`을 빠르게 읽을 수 있는 활성 workstream 형식을 따른다. 아직 장기 누적 로그가 크지 않아 별도 아카이브 롤오버는 하지 않았다.

## 먼저 읽을 문서

1. [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md)
2. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
3. [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
4. [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)
5. [combat_increment_07_admin_sandbox.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_07_admin_sandbox.md)
6. [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md)
7. [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)
8. [ai_cli_handoff_for_gemini.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/prompts/ai_cli_handoff_for_gemini.md)

## 친구 작업 목표

이번 병렬 작업에서 친구는 아래 네 창을 실제 GUI로 구현한다.

- 아이템창
- 스킬창
- 설정창
- 장비창

필수 조건:

- 키보드와 마우스 둘 다 지원한다.
- 기존 프로젝트 문서의 메이플스토리식 UX 기준을 따른다.
- 그래픽 패널, 슬롯, 버튼, 포커스 이동, 상태 표시를 갖춘다.
- 진행 상황은 이 문서에만 갱신한다.

## 친구가 수정 가능한 파일

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/**` 내 GUI 창 관련 신규 파일 전부
- `scenes/ui/**`
- `scenes/main/Main.tscn`
- `tests/test_admin_menu.gd`
- GUI 전용 신규 테스트 파일 전부
- 구현 문서와 조건부 implementation-facing 문서 권한은 [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)의 `문서 권한 해석`과 friend_gui 프롬프트를 따른다.

## 친구가 수정하면 안 되는 파일

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
- `docs/progression/**`, `docs/foundation/**`, 상대 workstream, prompt, policy, governance 문서는 일반 구현 턴에서 수정하지 않는다.

## 권장 구현 방식

- 기존 UI 전체를 한 파일에 몰아넣지 않는다.
- 가능한 한 아래 구조로 분리한다.

- `scripts/ui/windows/inventory_window.gd`
- `scripts/ui/windows/skill_window.gd`
- `scripts/ui/windows/settings_window.gd`
- `scripts/ui/windows/equipment_window.gd`
- `scripts/ui/widgets/` 공용 슬롯, 버튼, 패널
- `scenes/ui/windows/` 대응 씬

## 구현 범위 체크리스트

### 1. GUI 구조

- [ ] 네 개 창을 독립 노드 또는 독립 씬으로 분리
- [ ] 창 열기/닫기 상태 분리
- [ ] 창 전환 규칙 정의
- [ ] 키보드 포커스와 마우스 클릭 둘 다 지원

### 2. 아이템창

- [ ] 슬롯 기반 배치
- [ ] 아이콘 표시
- [ ] 선택 상태 표시
- [ ] 상세 정보 패널 또는 상태 줄

### 3. 스킬창

- [ ] 스킬 목록 표시
- [ ] 현재 장착/비장착 또는 슬롯 연결 상태 표시
- [ ] 선택 상태 표시
- [ ] 키보드/마우스 양쪽 조작 지원

### 4. 설정창

- [ ] 최소 설정 패널 구조
- [ ] 토글/선택 UI
- [ ] 나중에 확장 가능한 항목 그룹 구조

### 5. 장비창

- [ ] 그래픽 슬롯 GUI
- [ ] 아이템 아이콘 표시
- [ ] 점유 크기 또는 위치 표현 구조
- [ ] 장착/해제/이동 상호작용
- [ ] 드래그 앤 드롭 또는 동등한 조작 경로

### 6. 검증

- [ ] headless startup check 통과
- [ ] 관련 GUT 통과
- [ ] 기존 관리자 기능이 깨지지 않음

## 작업 원칙

- 전투 수치나 장비 스탯 계산 로직은 건드리지 않는다.
- 필요한 데이터가 없으면 직접 로직을 새로 만들지 말고 아래 `교차 의존 요청`에 남긴다.
- 기존 파일을 확장하더라도 GUI 책임만 추가한다.
- 문서에 없는 대규모 리팩터링은 하지 않는다.

## 현재 상태

- 역할 분리 기준은 [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)를 따른다.
- GUI 구현 범위는 `아이템창`, `스킬창`, `설정창`, `장비창` 네 축으로 고정돼 있다.
- owner_core 쪽에서 friend GUI가 읽을 수 있는 read-only 데이터 구조를 점진적으로 정리 중이므로, GUI는 그 공개 API를 우선 소비하는 방향이 안전하다.
- 아직 이 문서에는 2026-03-30 시작 로그만 있고, 별도 아카이브 문서는 없다.

## 활성 진행 로그

### 2026-03-30

- 역할 분리 문서 생성.
- GUI 창 작업 전용 workstream 시작.

## 아카이브

- 아직 별도 아카이브 없음.
- 누적 로그가 커지면 [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md)의 workstream 롤오버 규칙에 따라 `archive/`로 이동한다.

## 다음 우선 작업

1. 네 개 GUI 창을 독립 노드 또는 독립 씬으로 분리하는 구조를 먼저 잠근다.
2. 창 전환 규칙과 키보드/마우스 공통 입력 경로를 문서 기준에 맞춰 정리한다.
3. 필요한 런타임 데이터가 부족하면 직접 로직을 만들지 말고 아래 `교차 의존 요청`에 추가한다.

## 교차 의존 요청

현재 없음.

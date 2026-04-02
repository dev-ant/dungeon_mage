---
title: 내 작업 스트림
doc_type: tracker
status: active
section: collaboration
owner: owner_core
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
update_when:
  - runtime_changed
  - handoff_changed
  - ownership_changed
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 내 작업 스트림

상태: 사용 중  
최종 갱신: 2026-04-02  
담당자: 프로젝트 오너  
AI 역할: 전투 코어 / 데이터 / 비 GUI 구현

## 역할 요약

이 문서는 `아이템창`, `스킬창`, `설정창`, `장비창` GUI 구현을 제외한 내 작업만 추적한다.

친구가 맡은 GUI 창 관련 파일은 수정하지 않는다.

2026-04-02 기준으로 장기 누적 로그는 아카이브로 롤오버했고, 이 문서는 `현재 우선순위`, `현재 상태`, `활성 교차 의존 요청`만 유지하는 경량 workstream 문서로 사용한다.

## 읽어야 할 기준 문서

- [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
- [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
- [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)
- [combat_increment_03_buff_action_loop.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_03_buff_action_loop.md)
- [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)
- [combat_increment_05_equipment_minimum.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_05_equipment_minimum.md)
- [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_09_soul_dominion_risk.md)
- [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)

## 내 작업 범위

- 전투 런타임 구조 보강
- 스킬 추가 구현
- 버프 조합과 리스크 시스템
- 몬스터 확장
- 샌드박스 전투 흐름
- 데이터 정리와 로더 유지보수
- GUI 창과 직접 관련되지 않은 테스트 보강

## 제외 범위

- 아이템창 GUI
- 스킬창 GUI
- 설정창 GUI
- 장비창 GUI
- 위 창들의 입력, 버튼, 패널, 드래그/드롭, 마우스 상호작용
- 친구 소유 파일 전체

## 수정 가능한 파일

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
- 구현 문서와 조건부 소스 오브 트루스 문서 권한은 [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)의 `문서 권한 해석`과 owner_core 프롬프트를 따른다.

## 수정 금지 파일

- `scripts/admin/admin_menu.gd`
- `scripts/ui/game_ui.gd`
- `scripts/ui/**` 의 GUI 창 관련 파일
- `scenes/ui/**`
- `scenes/main/Main.tscn`
- `tests/test_admin_menu.gd`
- 상대 workstream, prompt, policy, governance 문서는 일반 구현 턴에서 수정하지 않는다.

## 현재 우선순위

1. GUI 창과 독립적인 전투 로직을 계속 전진시킨다.
2. 친구 GUI 작업이 요구할 수 있는 읽기 전용 데이터 구조를 안정적으로 유지한다.
3. GUI가 붙었을 때 바로 연결 가능한 런타임 상태를 문서와 테스트로 고정한다.

## 진행 체크리스트

- [ ] 다음 전투 코어 목표를 한 번에 하나씩 선택한다.
- [ ] 수정 파일이 내 소유 파일인지 먼저 확인한다.
- [ ] 적 스탯, 데미지 감쇠, 저항, 슈퍼아머, 브레이크 규칙을 바꿀 때 `enemy_stat_and_damage_rules.md`를 함께 수정한다.
- [ ] 구현 전 관련 GUT 테스트를 만들거나 보강한다.
- [ ] 구현 후 headless 체크와 GUT를 돌린다.
- [ ] 활성 상태와 교차 의존 요청만 이 문서에 갱신한다.

## 현재 상태

- 대표 장비 회귀 축은 `fire_burst`, `wind_tempo`, `earth_deploy`, `sanctum_sustain`, `holy_guard`, `dark_shadow`, `arcane_pulse`까지 실제 런타임 GUT 기준으로 고정된 상태다.
- enemy/drop/room read-only API 축은 validation report, spawn summary, drop preview, deterministic drop resolver, drop profile summary, room spawn enemy roster summary까지 닫혀 있다.
- 최근 검증 기준선은 headless startup 통과와 GUT `564/564` 통과다.
- 알려진 잔여 리스크는 `scripts/main/main.gd`의 `create_timer()` 기반 종료 시 leak warning이며, 현재 workstream 소유 범위 밖이라 직접 수정하지 않는다.

## 활성 진행 로그

### 2026-04-02

- 장기 누적 로그를 [owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md)로 롤오버했다.
- 현재 운영용 workstream은 `현재 상태`, `다음 우선 작업`, `교차 의존 요청`만 유지하도록 경량화했다.

## 아카이브

- 전체 누적 로그: [owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/archive/owner_core_workstream_archive_2026-03-30_to_2026-04-02_session_57.md)

## 다음 우선 작업

1. `drop/room` 축에서 더 넓은 통계 회귀를 볼지, 다시 전투 코어의 다른 빈 축으로 이동할지 재선정한다.
2. friend GUI가 사용할 read-only API에 추가 summary가 필요한지, 현재 공개 구조만으로 충분한지 확인한다.
3. `scripts/main/main.gd` timer leak warning은 소유 경계 안에서 우회 가능한 검증만 남기고, 직접 수정은 계속 피한다.

## 교차 의존 요청

### [2026-03-31] admin spawn 탭에 bat/worm 타입 추가 요청

- **이유:** `scripts/admin/admin_menu.gd`는 친구 소유 파일. bat과 worm이 `enemies.json`에 추가되었으나 admin spawn 탭의 소환 가능 타입 목록이 자동 갱신되는지 확인이 필요.
- **필요 입력:** admin_menu.gd에서 소환 타입 목록을 hardcode하고 있다면 "bat", "worm" 추가 필요.
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (게임 진행은 가능, admin 편의성 문제)

### [2026-03-31] admin spawn 탭에 mushroom 타입 추가 요청

- **이유:** mushroom이 enemy_base.gd와 enemies.json에 독립 타입으로 추가되었으나 admin spawn 탭 소환 키 미할당.
- **필요 입력:** admin_menu.gd의 spawn 타입 목록과 키 바인딩에 "mushroom" 추가.
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (게임 내 방 배치를 통해 소환 가능)

### [2026-03-31] admin spawn 탭에 5종 신규 몬스터 추가 요청

- **이유:** 6차 세션에서 rat, tooth_walker, eyeball, trash_monster, sword가 enemy_base.gd와 enemies.json에 추가되었으나 admin spawn 탭의 소환 가능 타입 목록에 없음.
- **필요 입력:** admin_menu.gd의 spawn 타입 목록에 다음 추가: "rat", "tooth_walker", "eyeball", "trash_monster", "sword"
- **예상 파일:** `scripts/admin/admin_menu.gd`
- **우선순위:** 낮음 (rooms.json에 spawn 배치로 인게임 등장 가능)

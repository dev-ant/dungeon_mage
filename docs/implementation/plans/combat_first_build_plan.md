---
title: 전투 우선 구현 계획
doc_type: plan
status: active
section: implementation
owner: runtime
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
update_when:
  - rule_changed
  - runtime_changed
  - handoff_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 전투 우선 구현 계획

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 구현 기준

## 목표

이 문서는 `스토리`, `NPC`, `배경 연출`, `퀘스트`를 모두 제외한 상태에서 전투 중심 2D 횡스크롤 액션 RPG를 먼저 완성하기 위한 기준 구현 계획입니다.

이번 단계의 목표는 아래 두 가지입니다.

- 플레이어, 몬스터, 스킬, 전투 UI, 성장 수치, 장비, 입력 시스템만으로 충분히 반복 플레이 가능한 전투 샌드박스를 만든다.
- 이후 배경, 스토리, NPC, 미궁 구조를 얹을 수 있도록 전투 관련 런타임 구조를 먼저 고정한다.

이 문서는 [CLAUDE.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/CLAUDE.md)의 필수 규칙을 전제로 작성한다.

병렬 작업으로 나눠 진행할 때는 이 문서를 `기준 계획`으로만 읽고, 실제 일일 진행 관리는 아래 협업 문서를 사용한다.

- [docs/collaboration/policies/role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)
- [docs/collaboration/workstreams/owner_core_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/owner_core_workstream.md)
- [docs/collaboration/workstreams/friend_gui_workstream.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md)

## 플레이 경험 목표

- 키보드만으로 빠르고 시원한 마법 액션을 굴릴 수 있어야 한다.
- 전투 HUD와 메뉴형 UI는 키보드만이 아니라 마우스로도 직접 상호작용할 수 있어야 한다.
- UI 상호작용 감각은 메이플스토리에 최대한 가깝게 맞추며, `단축키 조작`과 `마우스 클릭 조작`이 같은 기능에 대해 함께 성립해야 한다.
- 스킬을 눌렀을 때 즉시 반응하고, 연계와 캔슬, 버프 폭발 구간에서 뽕맛이 느껴져야 한다.
- 플레이어가 스킬을 눌렀을 때는 몸쪽에서 발생하는 `attack effect`, 몬스터가 맞았을 때는 피격 지점에 발생하는 `hit effect`가 분리되어 읽혀야 한다.
- 관리자 모드에서 몬스터, 스킬, 장비, 자원, UI 상태를 즉시 조작하며 전투를 반복 테스트할 수 있어야 한다.
- 밸런스 조정과 시스템 검증이 스토리 없이도 가능해야 한다.

## 구현 원칙

- 카메라는 반드시 `Phantom Camera`를 사용한다.
- 플레이어와 적 상태 흐름은 반드시 `Godot State Charts`를 사용한다.
- 새 전투 동작에는 반드시 `GUT` 테스트를 추가한다.
- 새로운 시스템은 `문서 규칙 -> 데이터 구조 -> 로더 -> 런타임 연결 -> UI 반영 -> 테스트` 순서로 붙인다.
- `asset_sample/`에 들어온 에셋은 `임시 참고자료`가 아니라 실제 빌드에 붙일 후보로 취급하며, GUI/캐릭터 체감에 직접 연결되는 에셋은 늦추지 않는다.
- UI는 `키보드 전용`으로 끝내지 않고, 동일 기능에 대한 `키보드 단축키 + 마우스 클릭` 경로를 함께 설계한다.
- UI 포커스, hover, 선택, 드래그 가능 영역, 더블클릭 장착/사용 같은 상호작용 규칙은 메이플스토리식 UX를 기준선으로 삼는다.
- 모든 검증은 헤드리스 환경에서 통과해야 한다.
- 스토리성 오브젝트와 임시 연출은 이번 범위에 넣지 않는다.
- 스킬 이펙트는 `projectile/fly`, `attack/cast`, `hit/impact`를 분리해서 붙이며, 같은 스킬이라도 최소 두 종류(`attack effect`, `hit effect`)를 서로 다른 에셋 실루엣으로 유지한다.

## 이번 범위

### 포함

- 플레이어 조작
- 플레이어 전투 상태
- 마나, 쿨타임, 피격, 사망
- 스킬 15종 사용 구조
- 스킬 레벨과 마스터리 반영
- 버프 중첩, 버프 조합, 필살 버프 리스크
- 장비 장착 및 전투 능력치 반영
- 몬스터 AI 최소 세트
- 전투 전용 HUD
- 데미지 숫자, 피격 반응, 카메라 반응
- 관리자 샌드박스 맵
- 관리자 메뉴
- 몬스터 소환, 아이템 지급, 스킬 설정, 무한 자원 토글

### 제외

- 스토리 이벤트
- NPC
- 퀘스트
- 본편 맵 구조
- 컷신
- 대사 시스템
- 저장 슬롯 UI
- 상점, 제작, 채집

## 전투 샌드박스 빌드 개요

이번 빌드는 `admin_map.tscn` 하나를 중심으로 움직인다.

- 평지 전투 구간
- 공중 발판 구간
- 낙하 테스트 구간
- 로프 또는 사다리 테스트 구간
- 보스 테스트 구간
- 관리자 메뉴 호출 구간

스토리 대신 `전투 상황을 빠르게 재현하는 테스트 동선`이 핵심이다.

## 현재 전투 MVP 종료 조건

현재 전투 MVP는 `전투 샌드박스 한 장` 안에서 아래가 모두 안정적으로 반복 재현되면 종료로 간주한다.

- 플레이어 이동, 점프, 대시, 피격, 사망, 로프 상호작용이 흔들리지 않는다.
- 액티브, 버프, 설치, 토글 스킬이 같은 런타임 구조 안에서 시전되고 자원/쿨타임이 반영된다.
- 최소 적 아키타입 4종 이상이 플레이어 스킬 타입과 정상 상호작용한다.
- 장비와 버프 조합이 실제 전투 수치와 운용감에 영향을 준다.
- 관리자 샌드박스만으로 스킬, 적, 자원, 장비, 버프 상태를 빠르게 재현할 수 있다.
- 헤드리스 스타트업과 전체 GUT가 계속 통과한다.

## 진행 현황

| 증분 | 상태 | 메모 |
| --- | --- | --- |
| 1. 플레이어 컨트롤러 고정 | 완료 | 더블점프, 대시, 피격/사망 입력 잠금, `State Charts` 연결, 로프 상호작용(grab/climb/exit) 모두 구현 완료. 259개 GUT 통과 |
| 2. 스킬 런타임 구조 정리 | 진행 중 | `spell_manager` 추가, 6슬롯 1차 구조, 버프 3종 핫바 통합, 설치형/토글형 런타임, 마나 자원, `무한 MP/쿨타임 무시`, `Glacial Dominion` 둔화, `Tempest Crown` 관통, `Soul Dominion` 리스크(MP 재생 차단, 피해 배수, 후유증, HUD) 완료. `volt_spear`, `fire_bolt`, `holy_radiant_burst`, `water_aqua_bullet`, `wind_gale_cutter`, `earth_tremor`, `dark_void_bolt`는 `asset_sample/Effect/Free` 기반 `attack effect`/`hit effect` 분리까지 실제 연결 완료. 다음 연출 목표는 동일 구조를 다른 액티브 스킬로 확장하는 것 |
| 3. 버프 중심 액션 루프 구축 | 진행 중 | Prismatic Guard(배리어), Time Collapse(할인 시전 3회), Ashen Rite(스택·폭발·종료 페널티: 마나 소진·방어 약화 10초·재시전 봉인 6초), Overclock Circuit(번개 연계·활성화 메시지), Funeral Bloom(배치킬 감지·ICD·corruption_burst 폭발) 모두 런타임 구현 완료. notify_deploy_kill() 연결 완료(main.gd, player.gd). 관리자 버프 강제 발동 탭은 남아 있음 |
| 4. 몬스터 전투 세트 구축 | 완료 | `enemy_base.gd`에 10종 구현 완료. `enemies.json` 분리·JSON 기반 수치 로드, `has_super_armor_attack` 플래그(JSON `super_armor_tags` 연결), leaper 착지 예고 마커 완료. bomber는 곡선 감속 폭탄 + 타깃 고정 warning marker + 터미널 burst 이펙트까지 보강됨. admin spawn 탭 자동 표시. `EnemyBase.tscn` 씬 파일 생성 및 `main.gd`가 씬 기반 인스턴스화로 전환 완료. 다음 우선 구현은 신규 에셋 5종(`Rat`, `tooth walker`, `Eye ball Monster`, `Trash Monster`, `Sword`)의 정식 몬스터 편입과 에셋 적용으로 고정한다 |
| 5. 장비 시스템 최소 버전 | 진행 중 | 장비 데이터, 프리셋, 런타임 반영, HUD/관리자 연결 완료. 지급→인벤토리→장착/해제 루프, 정렬/필터/페이지, `Candidate Detail/Selection/Nav/List` 구조, 비교 섹션, 후보 패널 페이지 구조 전환(EQUIPMENT_PAGE_SIZE 통일) 완료 |
| 6. 전투 UI 구축 | 진행 중 | HP/MP 그래픽 바(빨강/파랑) + 수치 레이블, 핫바 스킨(`Buttons.png`/`Action_panel.png`), 부유 데미지 숫자(`DamageLabel`), 플레이어 스프라이트(male_hero, scale=1.4), 버섯 적 스프라이트(Mushroom), 카메라 흔들림, 히트스탑(0.06s)까지 반영. **[Cycle A 런타임 셸 완료]** `game_ui.gd`가 상단 좌측 primary target panel, 하단 중앙 resource cluster, 상단 좌측 buff chip row, visible `10슬롯` hotbar, hover tooltip, 좌클릭 cast, 우클릭 clear, drag swap, unavailable dim state, runtime local row hide toggle을 실제로 렌더한다. 현재 target panel의 target source는 `플레이어와 가장 가까운 살아 있는 적` 휴리스틱이다. **[완료]** 몬스터 체력바 구현 완료 (초록/주황/빨강 3단계, 전 적 타입 공통 적용). **[시범 확장]** 스킬 이펙트 에셋 적용 완료: `fire_bolt` (`assets/effects/fire_bolt/`, 15프레임 루프), `volt_spear` (`assets/effects/volt_spear/`, 15프레임 루프, 방향 자동 반전), `frost_nova` (`assets/effects/frost_nova/`, 8프레임 burst, 비반전). **[실제 분리 연결]** `volt_spear`, `fire_bolt`, `holy_radiant_burst`, `water_aqua_bullet`, `wind_gale_cutter`, `earth_tremor`, `dark_void_bolt`는 각각 `assets/effects/<skill>_attack/` + `assets/effects/<skill>_hit/`로 시전 시작점과 명중 지점을 서로 다른 one-shot 이펙트로 읽히게 했다. **[현재 잔여]** explicit target source, icon atlas, settings persistence, keyboard selection border, 수동 플레이 검증 |
| 7. 관리자 모드 구축 | 완료 | 5탭 구조(hotbar/resources/equipment/spawn/buffs), 장비 탭 2패널 side-by-side 완성, buffs 탭 조합 요건 `[v]`/`[ ]` 표시. 탭/장비 슬롯/핫바 슬롯/owned 목록 아이템/candidate 목록 아이템/소환 타입/자원 토글/버프 항목/프리셋/스킬 라이브러리 항목/장착-해제 액션 모두 마우스 클릭 버튼 추가(2026-03-29). 306개 GUT 통과 |
| 9. Soul Dominion 리스크 | 완료 | MP 재생 차단, 피해 배수 증가, 종료 후 후유증, HUD 표시 모두 구현 완료 |

## 몬스터 데이터/런타임 마이그레이션 진행 현황 (2026-04-02)

- 기준 문서:
  - [enemy_data_runtime_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/enemy_data_runtime_migration_plan.md)
- 현재 완료:
  - Phase 0의 문서 기준선 정리 완료
  - `enemy_data_schema.md`에서 `role` 대표값을 체크인된 `enemies.json` 기준으로 동기화
  - `drop_profile`의 대표값 / 허용값 구분을 문서에 반영
  - `game_database.gd`가 `role`, `attack_damage_type`, `attack_element` enum validation을 수행하도록 확장
  - `tests/test_game_state.gd`에 invalid role/type/element 회귀 테스트 추가
  - `game_database.gd`가 `role`, `attack_damage_type`, `attack_element`, `attack_period`, `drop_profile`, `knockback_resistance` 필수 필드 확장을 수행하도록 반영
  - `tests/test_game_state.gd`에 Phase 1 필수 필드 누락 회귀 테스트 추가
  - `game_database.gd`가 `super_armor_tags`의 `Array[String]` 구조 검증을 수행하도록 반영
  - `tests/test_game_state.gd`에 non-array / non-string `super_armor_tags` 회귀 테스트 추가
  - `game_database.gd`가 속성 저항 10종 / 상태이상 저항 8종 필수 존재 검증을 수행하도록 반영
  - `tests/test_game_state.gd`에 저항 필드 누락 회귀 테스트 추가
  - `enemy_base.gd`가 unknown `attack_damage_type` / `attack_element`를 경고와 함께 안전한 기본값으로 정규화하도록 hardening
  - `tests/test_enemy_base.gd`에 attack contract fallback 회귀 테스트 추가
  - `enemy_base.gd`가 empty `display_name` / invalid `enemy_grade`를 경고와 함께 안전한 기본값으로 정규화하도록 hardening
  - `tests/test_enemy_base.gd`에 loaded identity fallback 회귀 테스트 추가
  - `enemy_content_tracker.md`에 `verification_type`, `last_verified`, 공통 validation 근거를 추가
  - `bat`, `worm`의 테스트 상태를 직접 GUT 근거 기준으로 `covered`로 정정
  - `enemy_catalog.md`에 `runtime role` 열과 신규 5종 `runtime role` 메모를 추가해 스키마 용어와 직접 연결
- 현재 미완료:
  - 없음
- 다음 안전 단위:
  - 몬스터 데이터/런타임 마이그레이션 문서 기준 잔여 없음
- 비고:
  - 이번 단계는 로더 validation, runtime hardening, tracker 근거 정리, 카탈로그 용어 정리만 강화했으므로 전투 감각이나 적 행동 자체는 변경하지 않았다.

## 개발 우선순위 재조정 (2026-04-01)

2026-03-29 문서 갱신에서는 `에셋 적용 + 그래픽 GUI 전환`을 크게 앞세웠지만, 2026-04-01 기준 현재 빌드는 다시 `전투 코어를 먼저 닫고 그 위에 그래픽/연출을 얹는 순서`로 읽는 것이 더 안전하다.

### 재조정 이유

- 플레이어, 스킬, 적, 장비, 관리자 샌드박스는 이미 상당 부분 구현됐지만, 모든 액티브 스킬과 적 상호작용이 완전히 닫힌 상태는 아니다.
- 전투 샌드박스 프로젝트에서 에셋과 GUI는 중요하지만, 코어 루프 검증보다 먼저 앞서가면 일정과 문서 기준선이 흔들리기 쉽다.
- 따라서 현재 단계의 주 우선순위는 `코어 루프 커버리지 확대`와 `교차 검증`이고, 그래픽 확장은 읽기성과 체감 향상 범위에서 병행한다.

### 현재 권장 구현 우선순위

1. 남은 액티브 스킬 런타임과 split effect 연결을 계속 닫는다.
2. 적 아키타입과 스킬 타입의 교차 검증을 먼저 끝낸다.
3. 버프/장비/리스크를 포함한 실제 전투 루프 밸런싱을 진행한다.
4. 그래픽 HUD와 관리자 GUI는 코어 검증을 방해하지 않는 범위에서 확장한다.
5. 스토리/NPC/서사/퀘스트는 전투 MVP 종료 뒤로 유지한다.

## 우선순위 재정렬 (2026-03-29)

이 프로젝트는 지금부터 `전투 코어 검증 중심` 우선순위에서 `에셋 적용 + 그래픽 GUI 전환` 우선순위로 옮긴다.

### 재정렬 이유

- 플레이어 조작, 기본 전투 루프, 관리자 샌드박스, 최소 장비/스킬 구조는 이미 충분히 검증됐다.
- 현재 병목은 전투 수식이 아니라 `게임처럼 보이는 출력`, `에셋 적용`, `그래픽 GUI 완성도`다.
- 따라서 다음 구현은 텍스트 보강보다 `실제 스프라이트`, `실제 UI 스킨`, `실제 슬롯 GUI`를 우선한다.

### 다음 구현 우선순위

1. 플레이어 스프라이트 적용
2. 전투 HUD 그래픽 GUI 전환
3. 관리자 메뉴 그래픽 GUI 전환
4. 장비/인벤토리 그래픽 GUI 전환
5. 이후 세부 전투 연출과 적/배경 에셋 확장

### 에셋 적용 기준

- 플레이어 기본 비주얼은 [male_hero-idle.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Character/male_hero_free/individual_sheets/male_hero-idle.png) 및 동일 폴더의 `male_hero-*.png` 시트들을 사용한다.
- 스킬 이펙트는 `asset_sample/Effect/Free/`의 Preview GIF 기준으로 실루엣과 motion readability를 먼저 고르고, 실제 런타임 참조는 반드시 `assets/effects/<skill>/<attack|hit>/`로 복사한 뒤 사용한다.
- `attack effect`는 플레이어의 손/몸 중심 근처에서 짧게 재생되는 시전 시작 이펙트로 사용하고, `hit effect`는 적 피격 지점에서 짧게 재생되는 충돌 이펙트로 분리한다.
- 같은 스킬이라도 `projectile/fly`, `attack/cast`, `hit/impact`는 가능하면 서로 다른 Free 세트를 배정해 silhouette가 겹치지 않게 한다.
- 맵 배경/지형 에셋은 아래 6개 PNG를 `admin_map.tscn` 1차 기준 세트로 고정한다.
- [BG Dirt1.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Background/GandalfHardcore%20FREE%20Platformer%20Assets/BG%20Dirt1.png)
- [BG Dirt2.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Background/GandalfHardcore%20FREE%20Platformer%20Assets/BG%20Dirt2.png)
- [Floor Tiles1.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Background/GandalfHardcore%20FREE%20Platformer%20Assets/Floor%20Tiles1.png)
- [Floor Tiles2.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Background/GandalfHardcore%20FREE%20Platformer%20Assets/Floor%20Tiles2.png)
- [Other Tiles1.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Background/GandalfHardcore%20FREE%20Platformer%20Assets/Other%20Tiles1.png)
- [Other Tiles2.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/Background/GandalfHardcore%20FREE%20Platformer%20Assets/Other%20Tiles2.png)
- 위 6개 PNG의 실제 런타임 경로는 `asset_sample/` 이 아니라 `assets/background/gandalf_hardcore/` 로 복사한 뒤 사용한다.
- `BG Dirt1`, `BG Dirt2` 는 반복 배경 레이어 소스이고, `Floor Tiles1`, `Floor Tiles2` 는 메인 충돌 지형 소스, `Other Tiles1`, `Other Tiles2` 는 경사면/공중 발판/보조 블록 소스로 분리한다.
- UI 기본 스킨은 아래 PNG를 우선 사용한다.
- [Equipment.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Equipment.png)
- [Buttons.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png)
- [Action_panel.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Action_panel.png)
- [Inventory.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Inventory.png)
- [Settings.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png)

### 구현 상태 메모

- 위 에셋 적용 우선순위는 이번 문서 갱신에서 새로 고정한 작업 기준이다.
- 아직 빌드 전반에 일관되게 적용된 상태로 간주하지 않으며, 다음 Claude Code 구현에서 실제 씬과 UI에 붙여야 한다.
- 2026-04-01 기준 맵 배경 적용 문서 기준선도 함께 고정했다.
  - `BG Dirt1/2` 는 192x128 반복 배경 청크로 본다.
  - `Floor Tiles1/2` 는 288x576 지형 시트로 본다.
  - `Other Tiles1/2` 는 288x224 보조 지형 시트로 본다.
  - 문서상 첫 구현 목표는 `정교한 월드 구성` 이 아니라 `전투 샌드박스 가독성 확보` 다.
- `asset_sample/Effect/Free` 1차 분석 결과, 현재 활성 공격 스킬들은 스킬별 `attack effect`와 `hit effect`를 따로 배정할 수 있을 만큼 후보 세트가 확보되어 있다.
- 상세 매핑과 파일 번호는 [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)의 `Free effect 1차 배정안`을 기준으로 유지한다.
- 2026-04-01 기준 실제 분리 연결은 `volt_spear`, `fire_bolt`, `holy_radiant_burst`, `water_aqua_bullet`, `wind_gale_cutter`, `earth_tremor`, `dark_void_bolt`까지 진행됐고, 일곱 스킬 모두 생성 시 body-side `attack effect`, 적중 시 `hit effect`를 따로 재생한다.
- 현재 일곱 스킬은 큰 Free 시트를 그대로 보여 주지 않고, 대표 시트 내부의 단일 sequence만 64×64 프레임으로 crop한 뒤 runtime에 사용한다.
- split effect 매핑은 런타임 registry(`spell_manager.gd`, `spell_projectile.gd`)로 정리되어 있고, GUT가 모든 연결 스킬의 `attack/hit` 프레임 크기가 64×64 cropped tile인지 회귀 검증한다.
- payload registry와 visual registry의 effect id 목록도 GUT가 양방향으로 비교해 sync 상태를 유지한다.
- 2026-04-01 기준 전투 커버리지 매트릭스의 첫 실제 회귀로, 대표 단일 투사체(`fire_bolt`)와 대표 관통 투사체(`wind_gale_cutter`)가 근접/원거리/압박/엘리트 적 아키타입에 모두 실제 명중 경로로 들어가는지 GUT로 고정했다.

## 현재 핫바 기준선 (2026-04-01)

초기 문서의 `6슬롯 전투 구조`는 첫 프로토타입 기준으로는 유효했지만, 현재 빌드의 실제 기준선은 더 넓다.

- 전투 주문 슬롯: 10칸
  - `Z`, `C`, `V`, `U`, `I`, `P`, `O`, `K`, `L`, `M`
- 버프 슬롯: 3칸
  - `Q`, `R`, `F`
- 총 기본 핫바: 13칸

이 문서와 하위 구현 문서에서는 아래처럼 해석한다.

- `6슬롯`은 초기 런타임 구조를 설명하는 역사적 표현이다.
- 현재 빌드의 기준선은 `10개 주문 + 3개 버프` 핫바다.
- 이후 신규 스킬 추가는 가능하더라도, 전투 MVP 종료 전에는 이 13칸 구조를 기준선으로 고정한다.

## 전투 커버리지 매트릭스 (MVP 검증 기준)

전투 MVP는 스킬 수가 많다는 이유만으로 완료로 보지 않고, 아래 교차 검증이 끝났을 때 닫힌 것으로 본다.

| 검증 항목 | 근접 추격형 | 원거리 견제형 | 돌진/점프 압박형 | 엘리트/준보스 | 비고 |
| --- | --- | --- | --- | --- | --- |
| 단일 투사체 액티브 | 필요 | 필요 | 필요 | 필요 | `fire_bolt`, `volt_spear` 계열 |
| 관통/직선 압박 액티브 | 필요 | 필요 | 필요 | 필요 | `wind_gale_cutter`, `dark_void_bolt` 계열 |
| 설치형 스킬 | 필요 | 필요 | 필요 | 필요 | 설치물 유지시간, 적 통과, 타격 빈도 검증 |
| 토글형 스킬 | 필요 | 필요 | 필요 | 필요 | 유지 마나와 자동 해제 포함 |
| 버프 폭발/조합 | 필요 | 필요 | 필요 | 필요 | 버프 종료 페널티와 burst 창 체감 검증 |
| attack effect 가독성 | 필요 | 필요 | 필요 | 필요 | 플레이어 몸쪽 cast start 가독성 |
| hit effect 가독성 | 필요 | 필요 | 필요 | 필요 | 적 피격 지점 impact 가독성 |
| 피격 반응/넉백/슈퍼아머 | 필요 | 필요 | 필요 | 필요 | stagger, super armor tag, hit stop |
| 장비 반영 | 필요 | 필요 | 필요 | 필요 | 속성 강화, projectile, cooldown, duration |

문서상 다음 구현은 “새 스킬 1개 추가”보다 “빈 칸이 남은 행/열을 닫는 작업”을 우선한다.

### 우선 구체화된 대표 검증 명세 (2026-04-01)

#### 설치형 스킬

- 대표 스킬: `stone_spire`
- 핵심 역할: `지역 통제`보다 `지속 누적 딜 장치`를 먼저 검증한다.
- 우선 검증 적: `brute`
  - 이유: 기본 근접 추격형을 상대로 설치형의 기본 성능과 안정성을 먼저 확인해야, 이후 `leaper`나 `elite` 상대로도 누적 딜 장치로서의 의미를 비교하기 쉽다.
- 타격 방식:
  - 범위 안 적에게 `고정 간격 반복 타격`을 적용한다.
  - 적이 범위를 짧게 스쳐도 최소 1회 타격 기회를 보장한다.
- 수치 방향:
  - 낮은 순간 화력 + 높은 누적 기대값
  - 장비/버프 반영 우선순위는 `tick damage` 증가
- 완료 기준:
  - `stone_spire`가 정상 생성되고 유지시간 후 자동 제거된다.
  - 유지시간 동안 적에게 반복 타격이 들어간다.
  - `brute`가 범위를 짧게 스쳐도 최소 1회 타격이 보장된다.
  - `brute`가 범위 안에 오래 머물면 누적 피해 총합이 증가한다.
  - `bomber`, `leaper`, `elite`도 최소 1회 이상 정상 타격된다.
  - 설치물 타격은 세션 전투 통계와 적 피격 반응에 반영된다.
  - 생성 순간 연출과 지속 타격 연출이 분리되어 읽힌다.

#### 토글형 스킬

- 대표 스킬: `ice_glacial_dominion`
- 핵심 체감: `유지형 화력 강화`보다 `유틸/상태이상 오라`를 먼저 검증한다.
- 우선 검증 적: `leaper`
  - 이유: 토글형의 핵심 체감은 적 접근 템포를 늦춰 플레이어가 후퇴/카이팅 시간을 버는 데 있으므로, 돌진/점프 압박형을 상대로 먼저 검증하는 것이 가장 의미가 크다.
- 우선 검증 상황:
  - 플레이어가 후퇴하며 시간을 버는 `카이팅 상황`
  - 켜는 순간 적 접근 템포가 눈에 띄게 느려져야 한다.
- 수치 방향:
  - 유지 마나 소모는 `꽤 부담되지만 짧은 교전에서는 유지 가능한 수준`으로 둔다.
  - 자동 해제는 `다음 tick 유지 비용을 지불할 수 없는 순간` 즉시 발생해야 한다.
- slow 기대 효과:
  - 이동 속도와 행동 템포를 둘 다 낮춘다.
- 완료 기준:
  - 활성화 중 유지 마나가 tick 단위로 감소한다.
  - 현재 MP가 다음 tick 유지 비용보다 낮아지는 순간 자동 해제된다.
  - 활성 중 적에게 `slow` utility effect가 실제로 적용된다.
  - `slow`는 이동 속도와 행동 템포를 모두 낮추는 형태로 읽혀야 한다.
  - 비활성화 후에는 신규 `slow` 적용이 멈춘다.
  - `leaper`가 플레이어에게 파고드는 카이팅 상황에서 접근 템포 둔화가 실제로 느껴진다.
  - 켜짐/꺼짐 순간과 유지 중 적 피드백이 분리되어 읽힌다.
  - 4개 적 아키타입 전체에 대해 유지/해제/slow/연출 반응이 검증된다.

#### 상태이상 시스템 v1

- 대표 검증 스킬:
  - `ice_glacial_dominion`
  - `plant_vine_snare`
  - `frost_nova`
- 핵심 역할:
  - 상태이상은 `직접 딜 보조`보다 `공간 통제와 접근 차단`을 우선 역할로 둔다.
- 첫 검증 적/상황:
  - `leaper`가 플레이어에게 파고드는 압박 상황을 1순위로 고정한다.
- v1에서 완전 연결할 상태이상:
  - `slow`
  - `root`
  - `freeze`
- 후속 증분으로 미루는 상태이상:
  - `shock`
  - `burn`
  - `poison`
  - `silence`
  - 이번 단계에서는 데이터, 저항, 타이머, 문서 규칙까지만 고정한다.
- 공통 운용 규칙:
  - `slow`는 이동 속도와 공격 준비/행동 템포를 함께 늦춘다.
  - `root`는 이동만 봉인하고 공격/시전은 허용한다.
  - `freeze`는 짧은 완전 정지와 다음 피해 연계 창을 연다.
  - 같은 상태이상은 `더 강한 수치 우선 + 지속시간 갱신` 규칙을 사용한다.
- 완료 기준:
  - 대표 3스킬이 `brute`, `bomber`, `leaper`, `elite` 4개 적 아키타입에 대해 상태이상 적용, 저항, 갱신 규칙, 엘리트 차이까지 함께 검증된다.

#### 버프 폭발/조합

- 대표 케이스: `Ashen Rite`
- 핵심 재미: 준비가 긴 버프보다 `짧은 타이밍 폭딜`을 우선 검증한다.
- 완료 기준:
  - 스택이 누적된다.
  - 조건 충족 시 burst가 전투 결과로 명확하게 발동한다.
  - burst 이후 `마나 소진`, `방어 약화`, `재시전 봉인` 같은 후속 페널티가 반드시 붙는다.
  - burst window와 penalty window가 HUD/요약 또는 전투 로그에서 읽힌다.
  - 종료 후 정상 상태로 복귀하는 경로까지 검증된다.

#### attack / hit effect 가독성

- 완료 기준:
  - `attack effect`는 플레이어 몸/손 근처에서 시작된다.
  - `hit effect`는 적 피격 지점 중심에서 시작된다.
  - 기본 one-shot 길이는 `6~8프레임` 범위로 유지한다.
  - 런타임 프레임은 `64x64` cropped tile을 기준선으로 유지한다.
  - 속성별 색감 방향은 아래를 기준으로 통일한다.
    - fire: orange/red
    - ice: cyan/blue
    - lightning: yellow/white
    - holy: gold/white
    - dark: purple/black
    - earth: brown/orange
    - wind: pale green/white
    - water: blue/cyan
    - arcane: magenta/blue-white

#### 장비 반영

- 대표 검증 축:
  - `속성 특화 장비가 대표 스킬 화력과 운용을 즉시 바꾸는지`를 먼저 닫는다.
- 대표 장비 3빌드:
  - `속성 특화 1세트`
  - `운용 특화 1세트`
  - `생존/자원 1세트`
- 우선 고정 옵션 묶음:
  - `element damage`
  - `projectile speed / projectile count`
  - `cooldown`
  - `installation duration`
- 대표 검증 스킬:
  - 1순위: `fire_bolt`
  - 대표 3종: `fire_bolt`, `wind_gale_cutter`, `stone_spire`
- 대표 검증 상황:
  - `brute`: 기본 화력 차이 확인
  - `leaper`: 운용/제어 차이 확인
  - `elite`: 긴 교전에서 누적 효율 차이 확인
- 핵심 체감:
  - 이번 단계에서는 장비가 빌드를 완전히 갈라놓기보다 `수치 차이가 확실히 오르는지`를 먼저 검증한다.
  - 스킬/버프가 여전히 중심이고, 장비는 그 위에 미세 조정층으로 붙는다.
- 가독성 기준:
  - 이번 단계에서는 장비 비교 텍스트와 요약 문자열만 명확하면 충분하다.
- 완료 기준:
  - 장착 즉시 실제 전투 결과가 달라져야 한다.
  - `fire_bolt`는 속성 특화 장비에 따라 `brute` 상대로 피해 차이가 즉시 확인된다.
  - `wind_gale_cutter`는 운용 특화 장비에 따라 탄속/관통 운용 차이가 실제 전투 결과로 드러난다.
  - `stone_spire`는 설치 특화 장비에 따라 유지시간 또는 누적 피해 기대값 차이가 실제 전투 결과로 드러난다.
  - 대표 장비 3빌드는 `brute`, `leaper`, `elite` 3상황에서 최소 한 가지 이상 분명한 차이를 만들어야 한다.
  - 위 차이는 모두 GUT 기준으로 고정 가능해야 한다.

#### hitstop 정책

- 기본 철학:
  - 지속형 비투사체 스킬은 전역 전투 템포를 끊지 않아야 한다.
  - 대신 `결정적인 순간`만 분명하게 읽히도록 강한 hitstop을 배정한다.
- 대표 스킬:
  - 설치형: `stone_spire`
  - 토글형: `ice_glacial_dominion`
  - 순간 area burst: `frost_nova`
- 설치형 규칙:
  - `stone_spire` 같은 반복 tick 설치형은 첫 적중 또는 충분한 간격이 지난 tick에만 아주 짧은 hitstop을 허용한다.
  - 나머지 tick은 hitstop 없이 누적 딜과 이펙트로 읽히게 한다.
- 토글형 규칙:
  - `ice_glacial_dominion` 같은 오라 tick은 기본적으로 hitstop 없이 `slow`와 적 피드백으로 읽히게 한다.
- 순간 area burst 규칙:
  - `frost_nova` 같은 순간 area burst는 단일 투사체보다 강한 짧은 hitstop을 사용한다.
  - 단, 전투 루프 전체를 끊을 정도로 길어지면 안 된다.
- 순간 area burst 대표 명세:
  - 대표 스킬: `frost_nova`
  - 핵심 역할: 접근해 오는 적의 템포를 끊으면서 다음 냉기 연계를 여는 `상태이상 시동 burst`
  - 우선 검증 적: `leaper`
    - 이유: 점프/돌진 압박을 끊어내는 순간 손맛이 가장 분명하게 드러난다.
  - 우선 검증 상황:
    - 여러 적을 한 번에 긁는 광역 정리 상황
    - 그중에서도 `leaper`가 파고드는 압박 상황에서 끊어내는 장면을 먼저 본다.
  - 핵심 체감:
    - 터지는 순간 화면이 시원하게 정리되며, 다음 냉기 연계를 열었다는 감각이 있어야 한다.
  - 수치 방향:
    - 범위는 넓지만 단일 대상 폭딜보다는 중상급 burst
    - 직접 피해만으로 끝내기보다 상태이상 시동 가치가 함께 있어야 한다.
  - 상태이상 기대 효과:
    - 짧고 강한 `slow` 또는 짧은 경직으로 접근을 끊는다.
  - camera 반응:
    - 짧은 근거리 burst shake 1회
  - 연출 규칙:
    - 시전 직전의 cast seed와 폭발 순간의 bloom이 명확히 분리되어 읽혀야 한다.
- 우선 검증 상황:
  - `leaper`가 플레이어에게 파고드는 압박 상황에서 설치형/토글형/순간 area burst가 각각 어떻게 읽히는지 먼저 확인한다.
- 완료 기준:
  - 강한 순간만 분명히 읽히고, 지속형 tick은 전투 템포를 망치지 않는다.
  - 3개 대표 스킬(`stone_spire`, `ice_glacial_dominion`, `frost_nova`)이 4개 적 아키타입 기준으로 hitstop, effect, camera 반응까지 함께 검증된다.
  - `frost_nova`는 `leaper` 우선 + 4개 적 아키타입 전체에 대해 damage / hitstop / effect / camera 반응이 함께 검증된다.

### Stage A의 즉시 구현 순서 (2026-04-01)

1. `stone_spire`를 대표 설치형으로 삼아 `brute` 우선 교차 검증을 GUT로 고정한다.
   - spawn / duration / repeated tick / graze minimum hit / other archetype minimum hit 순서로 닫는다.
2. `ice_glacial_dominion`을 대표 토글형으로 삼아 `leaper` 카이팅 상황 기준의 유지 마나/자동 해제/slow 적용을 먼저 고정한다.
3. `plant_vine_snare`를 대표 설치형 제어기로 삼아 `root`의 이동 봉인, 재적용, duration 갱신을 먼저 고정한다.
4. `frost_nova`를 대표 순간 area burst로 삼아 `freeze` 시동, `leaper` 접근 차단, 후속 연계 창을 고정한다.
5. `Ashen Rite`를 대표 burst 조합으로 삼아 스택 누적, burst 발동, 종료 페널티를 GUT 기준으로 고정한다.
6. 장비 반영은 `속성 특화 / 운용 특화 / 생존·자원` 3빌드 기준으로 `fire_bolt / wind_gale_cutter / stone_spire`를 우선 교차 검증한다.
7. 위 여섯 행이 닫힌 뒤 남은 split effect 확장과 세부 장비 옵션 확장으로 넘어간다.

## 다음 개발 스테이지

### Stage A. 코어 전투 커버리지 닫기

- 남은 액티브 스킬 런타임 정리
- split `attack effect` / `hit effect` 확장
- 적 아키타입과 스킬 타입 교차 검증 마무리

### Stage B. 전투 루프 안정화

- 버프 조합, 장비 반영, Soul Dominion 계열 리스크를 포함한 실전 루프 점검
- 자원, 쿨타임, 실패 피드백, 피격 반응 밸런싱

### Stage C. 전투 테스트 생산성 강화

- 관리자 샌드박스 프리셋, 소환, 장비, 버프 강제 재현 능력 보강
- 회귀 테스트와 헤드리스 검증 유지

### Stage D. 그래픽/UI 폴리싱

- 플레이어/적 에셋 확장
- 그래픽 HUD, 관리자 GUI, 장비/인벤토리 GUI 정교화
- hit feel, camera, effect polish

### Stage E. 콘텐츠 확장

- 스토리
- NPC
- 퀘스트
- 본편 맵 구조
- 서사 연출

## 구현 단계

## 1. 플레이어 컨트롤러 고정

### 목표

전투 손맛의 기준이 되는 이동과 입력 반응을 먼저 고정한다.

### 세부 범위

- 좌우 이동
- 점프
- 더블 점프
- 대시
- 공중 시전
- 피격 경직
- 무적 프레임
- 사망 상태
- 로프 또는 사다리 상호작용

### 입력 기본안

| 액션 | 기본 키 |
| --- | --- |
| 이동 좌 | `Left` |
| 이동 우 | `Right` |
| 점프 | `Alt` |
| 대시 | `Shift` |
| 위 | `Up` |
| 아래 | `Down` |
| 스킬 1~6 | `Z`, `X`, `C`, `A`, `S`, `D` |
| 버프 1~6 | `Q`, `W`, `E`, `R`, `F`, `G` |
| 관리자 메뉴 | `Escape` |

### 상태 흐름

- `Idle`
- `Walk`
- `Jump`
- `DoubleJump`
- `Fall`
- `Dash`
- `OnRope`
- `Cast`
- `Hit`
- `Dead`

### 구현 대상 파일

- `scripts/player/player.gd`
- `scripts/player/player_state_chart.tres` 또는 대응 상태 차트 리소스
- `scenes/player/Player.tscn`
- `asset_sample/Character/male_hero_free/individual_sheets/male_hero-*.png`

### 완료 기준

- 키보드만으로 이동, 공중 이동, 시전, 피격, 사망이 모두 동작한다.
- 상태 전환은 `Godot State Charts` 이벤트를 통해 일어난다.
- 대시와 점프 타이밍이 전투 입력을 방해하지 않는다.

## 2. 스킬 런타임 구조 정리

### 목표

기존 스킬 데이터와 실제 전투 사용 구조를 분리하고, 슬롯 기반 시전 체계를 만든다.

### 세부 범위

- `skills.json` 기반 스킬 로드
- 스킬 슬롯 장착
- 액티브, 버프, 설치, 온앤오프, 패시브 타입 분리
- 마나 소모
- 쿨타임
- 시전 실패 피드백
- 방향성 투사체/근거리 판정

### 구현 대상 파일

- `data/skills/skills.json`
- `scripts/autoload/game_database.gd`
- `scripts/player/spell_manager.gd`
- `scripts/player/spell_runtime.gd` 또는 타입별 런타임 스크립트
- `scripts/player/spell_projectile.gd`

### 완료 기준

- 6개 전투 슬롯에 스킬을 배치할 수 있다.
- 스킬 발동 시 마나와 쿨타임이 정확히 반영된다.
- 시전 가능 여부가 플레이어 상태와 자원 상태를 반영한다.

## 3. 버프 중심 액션 루프 구축

### 목표

이 게임의 차별점인 강력한 버프 중첩과 조합 폭발 구간을 전투 핵심으로 만든다.

### 세부 범위

- 버프 중첩
- 동일 버프 중복 허용
- 서클 기반 동시 유지 수 제한
- 버프 조합 감지
- 조합 효과 적용
- 필살 버프의 종료 페널티
- 조합 UI 반영

### 우선 구현 조합

- `Prismatic Guard`
- `Overclock Circuit`
- `Time Collapse`
- `Ashen Rite`

### 구현 대상 파일

- `scripts/autoload/game_state.gd`
- `data/skills/buff_combos.json`
- `scripts/ui/game_ui.gd`

### 완료 기준

- 버프 2중첩부터 시작해 서클 상승에 따라 슬롯이 늘어난다.
- 같은 버프를 중복 시전할 수 있다.
- 특정 조합이 실제 전투 수치와 히트 감각을 바꾼다.

## 4. 몬스터 전투 세트 구축

### 목표

플레이어의 스킬과 버프를 시험할 수 있는 최소 전투 생태계를 만든다.

### 최소 적 세트

- 근접 추격형 1종
- 원거리 견제형 1종
- 돌진 또는 점프 압박형 1종
- 엘리트 또는 준보스 1종

### 다음 몬스터 에셋 우선 적용 대상

- `미궁박쥐`
- `웜`
- `미궁버섯`

적용 기준:

- 사용자가 지정한 PNG 한 장만 적용하지 않는다.
- 각 몬스터는 해당 PNG가 속한 폴더의 `idle / run(or walk) / attack / hurt(hit) / die(death)` 전체 세트를 우선 적용 대상으로 본다.

자세한 기준, 역할 제안, 폴더 경로, 세트 구성은 [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)를 따른다.

### 적 공통 기능

- HP
- 슈퍼아머 유무
- 피격 경직
- 넉백
- 상태이상 저항 태그
- 사망 처리
- 드롭 테이블 연결용 슬롯

### 상태 흐름

- `Idle`
- `Patrol`
- `Chase`
- `Attack`
- `Hit`
- `Stagger`
- `Dead`

### 구현 대상 파일

- `scripts/enemies/enemy_base.gd`
- `scripts/enemies/enemy_melee.gd`
- `scripts/enemies/enemy_ranged.gd`
- `scripts/enemies/enemy_elite.gd`
- 대응 씬 파일

### 완료 기준

- 적이 순찰, 감지, 추격, 공격, 피격, 사망을 정상 수행한다.
- 플레이어의 모든 기본 스킬 타입이 적에게 유효하게 반응한다.

## 5. 장비 시스템 최소 버전

### 목표

레벨 시스템이 없는 대신, 장비가 전투 수치와 운용 방식에 즉시 영향을 주도록 만든다.

### 장비 슬롯

- 무기
- 보조 마도구
- 머리
- 상의
- 하의
- 장신구 2칸

### 반영 수치

- 마법 공격력
- 최대 MP
- MP 회복 속도
- 쿨타임 감소
- 특정 속성 강화
- 버프 지속시간 증가
- 설치물 유지시간 증가

### 구현 방식

- 장비 데이터는 JSON으로 관리한다.
- 장비 장착 결과는 `GameState` 또는 전용 장비 매니저에서 계산한다.
- 스킬 계산식은 장비 수치와 마스터리 최종 배수를 모두 반영한다.

### 구현 대상 파일

- `data/items/equipment.json`
- `scripts/autoload/game_state.gd`
- `scripts/player/equipment_manager.gd`
- `scripts/ui/equipment_panel.gd`

### 완료 기준

- 관리자 메뉴에서 장비를 즉시 지급하고 장착할 수 있다.
- 장착 전후 스킬 피해, 마나, 쿨타임 차이가 실제로 발생한다.

## 6. 전투 UI 구축

### 목표

현재 전투 상태를 빠르게 읽을 수 있고, 테스트 중 조정 지점을 바로 파악할 수 있어야 한다.
전투 중 조작 가능한 UI는 `키보드 100% 플레이 가능`을 기준선으로 삼고, 마우스는 같은 기능을 보조하는 경로로 제공해야 한다.
최종 목표는 숫자와 텍스트만 나열하는 HUD가 아니라, 메이플스토리나 마비노기처럼 그래픽 바, 슬롯, 아이콘, 패널 프레임이 실제로 보이는 GUI다.

### 2026-04-03 구체화 잠금

- 전투 중 시선 우선순위는 `대상 HP -> 플레이어 자원/캐릭터 정보 -> 핫바`로 고정한다.
- 상단 좌측에는 `활성 버프 / 디버프 row`, 하단 중앙에는 `HP / MP / 캐릭터 정보` 묶음을 둔다.
- 플레이어 노출용 핫바는 `사용자 등록형 1행 10칸 액션 row`를 기준으로 하고, 스킬/버프/토글/설치형/아이템을 같은 row에서 자유 혼합해 다룬다.
- 활성 버프 row는 액션 핫바와 별도 상태 row로 유지한다.
- `액션 row`와 `활성 버프 row`는 설정에서 각각 on/off 토글 가능해야 한다.
- 화면에는 언제나 10개 슬롯만 보이고, 슬롯 키는 설정에서 사용자가 자유롭게 다시 바인딩할 수 있어야 한다.
- 기존 텍스트 HUD는 최종 출력이 아니라 디버그 / 테스트 fallback 으로만 남긴다.
- `13키 바인딩` 기준선은 레거시 메모로만 남기고, 입력 canonical 과 저장 canonical 은 모두 `10슬롯` 기준으로 이행한다.

### 필수 UI

- 대상 몬스터 HP 패널
- HP 바
- MP 바
- 캐릭터 핵심 정보 묶음
- 플레이어 노출용 사용자 등록형 액션 슬롯 10칸 row
- 활성 버프 / 디버프 row
- 버프 아이콘 및 중첩 수
- 조합 효과 표시
- 현재 서클
- 주요 전투 스탯 요약
- 데미지 숫자
- 관리자 모드 활성 표시
- 스킬/버프/장비 아이콘
- 그래픽 패널 프레임과 배경
- 툴팁 패널

### 상호작용 기준

- 키보드 단축키만으로 전투를 끝까지 진행할 수 있어야 하고, 마우스는 같은 기능을 보조 경로로만 제공한다.
- 액션 슬롯, 버프 슬롯, 장비 슬롯, 탭 버튼은 마우스 hover 를 지원한다.
- 액션 슬롯은 좌클릭 즉시 실행, 우클릭 단축키 해제, click-hold drag-rebind 를 지원한다.
- 전투 HUD는 더블클릭을 기본 상호작용으로 요구하지 않는다.
- 마우스로 슬롯 hover 시 이름, 쿨타임, 비용, 설명, 현재 상태, 레벨, 마스터리가 즉시 읽혀야 한다.
- 핫바, 장비, 인벤토리, 관리자 탭의 선택 상태는 `키보드 선택 테두리 유지 + 마우스 hover 오버레이` 규칙으로 동기화되어야 한다.
- 사용 불가 슬롯은 평상시에도 dim 처리하고, 입력 시 짧은 실패 문구를 보여 줘야 한다.
- drag-rebind 대상 칸이 이미 차 있으면 두 칸을 swap 한다.
- HP/MP는 텍스트 수치만 단독 노출하는 방식이 아니라, 그래픽 바와 수치가 함께 보이는 형태를 기본 기준으로 삼는다.
- 장비창과 인벤토리는 텍스트 목록이 아니라 슬롯, 아이콘, 점유 크기, 위치 이동을 시각적으로 보여주는 GUI를 목표로 한다.
- 스킬, 버프, 장비, 관리자 탭도 텍스트 전용 디버그 패널이 아니라 그래픽 슬롯/버튼/패널 기반 GUI로 확장되어야 한다.
- HUD를 숨겨도 키보드 전투 입력은 유지해야 하며, 숨겨진 HUD row는 마우스 상호작용 대상에서 제외한다.
- 이 기준은 현재 구현 완료 항목이 아니라, 이번 계획 문서에서 새로 확정한 구현 목표다.

### 구현 대상 파일

- `scripts/ui/game_ui.gd`
- `scripts/ui/combat_hud.gd`
- `scripts/ui/damage_label.gd`
- `scenes/ui/CombatHUD.tscn`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Action_panel.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png`

### 완료 기준

- 플레이 중 필요한 전투 정보가 HUD에서 모두 보인다.
- 스킬 쿨타임과 버프 유지 시간이 직관적으로 확인된다.
- 키보드 단축키만으로도 조작 가능하고, 동일한 UI 기능이 마우스 클릭/hover/drag 로도 동작한다.
- 메이플스토리식 UI 사용감에 맞는 슬롯 선택, 툴팁, 패널 상호작용이 실제 런타임에 구현된다.
- 전투 정보와 조작 UI가 텍스트 위주가 아니라 그래픽 바, 아이콘, 패널 프레임이 보이는 GUI로 제공된다.
- HP/MP, 핫바, 버프, 장비, 관리자 UI가 모두 그래픽 기반으로 표시된다.
- 지정된 `Action_panel / Buttons / Settings` PNG가 HUD 스타일링의 기본 리소스로 실제 연결된다.
- 사용 불가 슬롯이 dim 처리되고, 실패 입력 시 짧은 이유 문구가 표시된다.
- headless 테스트와 최소 1회 수동 플레이 검증을 모두 통과한다.
- HUD 숨김 on/off 상태에서도 키보드 전투가 유지된다.
- 위 마우스 상호작용 기준은 현재 문서에만 추가되었고 아직 구현 완료로 간주하지 않는다.
- 위 그래픽 GUI 기준 역시 현재 문서에 새로 추가된 요구사항이며 아직 미구현이다.

## 7. 관리자 모드 구축

### 목표

전투 샌드박스에서 밸런스와 시스템을 즉시 실험하는 개발자용 인터페이스를 만든다.
이 인터페이스는 기존 키보드 단축키 흐름을 유지하면서도, 메이플스토리식으로 탭과 목록과 슬롯을 마우스로 직접 클릭 가능한 상태까지 포함한다.
또한 관리자 UI도 최종적으로는 텍스트 본문이 아니라 그래픽 탭, 버튼, 슬롯, 인벤토리 패널로 구성된 GUI를 목표로 한다.

### 진입 방식

- `Escape`로 관리자 메뉴 토글
- 메뉴 활성화 시 게임 일시정지 여부를 옵션으로 제공
- 탭, 버튼, 슬롯, 목록 항목은 마우스로 직접 선택/실행 가능해야 한다.
- 키보드 탐색 포커스와 마우스 클릭 선택은 같은 상태를 공유해야 한다.
- 현재의 텍스트 중심 관리자 메뉴는 임시 구현으로 취급하고, 최종적으로는 그래픽 GUI로 대체한다.

### 탭 구성

#### 스킬 탭

- 전체 스킬 목록
- 현재 레벨 표시
- 레벨 강제 조정
- 슬롯 장착/해제
- 쿨타임 초기화
- 숙련도 직접 지급

#### 버프 탭

- 버프 수동 활성화
- 중첩 수 직접 지정
- 조합 강제 발동
- 조합 종료 페널티 테스트

#### 몬스터 탭

- 근접/원거리/엘리트/보스 소환
- 현재 커서 위치 소환
- 전체 제거
- AI 정지
- 무적 더미 소환

## 7.5 샌드박스 맵 배경/타일 적용 계획

### 목표

`admin_map.tscn` 을 더 이상 단순 플레이스홀더 맵으로 두지 않고, 전투 테스트에 필요한 배경/지면/발판 가독성을 갖춘 첫 번째 실전형 샌드박스 맵으로 올린다.

### 플레이 경험 목표

- 플레이어가 바닥 경계, 공중 발판, 경사면 진입 지점을 즉시 읽을 수 있어야 한다.
- 몬스터 실루엣, 투사체, hit effect 가 배경에 묻히지 않아야 한다.
- 반복 전투를 오래 돌려도 검은 빈 배경이나 임시 사각형 맵처럼 보이지 않아야 한다.

### 이번 증분 범위

- `BG Dirt1`, `BG Dirt2` 를 배경 반복 레이어로 적용
- `Floor Tiles1`, `Floor Tiles2` 를 메인 지형 `TileSet` 소스로 정리
- `Other Tiles1`, `Other Tiles2` 를 경사면/얇은 발판/보조 지형 `TileSet` 소스로 정리
- `admin_map.tscn` 또는 현재 메인 샌드박스 씬에 `배경 레이어` 와 `지형 레이어` 를 분리 적용
- 최소 충돌 세트를 다시 맞춰 전투 동선이 흔들리지 않게 보정

### 적용 방법

1. 원본 6개 PNG를 `assets/background/gandalf_hardcore/` 아래로 복사한다.
2. Godot import 를 다시 돌려 `.import` 생성과 필터 설정을 확인한다.
3. 배경용 텍스처와 타일용 아틀라스를 분리한다.
4. 배경은 `ParallaxBackground` 또는 반복 가능한 `Sprite2D` 묶음으로 배치한다.
5. 지면은 메인 `TileMapLayer_Ground`, 보조 구조물은 `TileMapLayer_Support` 로 나눠 칠한다.
6. 충돌은 타일 모양을 그대로 모두 따르기보다, 전투 테스트에 필요한 단순 충돌부터 우선 고정한다.

### 레이어 기준

- 배경 레이어
  - 소스: `BG Dirt1`, `BG Dirt2`
  - 역할: 카메라 뒤 공간 채우기, 흙 동굴 톤 유지
  - 규칙: 좌우 반복, 검은 여백 금지, 충돌 없음
- 메인 지면 레이어
  - 소스: `Floor Tiles1`, `Floor Tiles2`
  - 역할: 평지, 큰 블록, 기본 전투 발판
  - 규칙: 한 화면에는 하나의 주 팔레트를 우선 사용하고, 다른 팔레트는 구역 강조 수준으로만 섞는다.
- 보조 지형 레이어
  - 소스: `Other Tiles1`, `Other Tiles2`
  - 역할: 경사면, 얇은 공중 발판, 가장자리 마감
  - 규칙: 이동 테스트에 중요한 경사면과 낙차 지점부터 우선 배치한다.

### 우선 맵 구성안

- 시작 평지
  - 가장 넓은 직선 지형
  - 기본 몬스터 소환과 투사체 검증용
- 중앙 발판 구간
  - 짧은 공중 발판 2~3개
  - 점프, 대시, 설치형 스킬 검증용
- 경사면 구간
  - `Other Tiles` 경사면 포함
  - 이동감, 추격 AI, slow 상태 가독성 검증용
- 낙하 가장자리
  - 발판 끝점이 배경과 명확히 분리되어 보여야 함

### 파일/시스템 예상 접점

- `assets/background/gandalf_hardcore/`
- `scenes/main/admin_map.tscn` 또는 현재 샌드박스가 붙어 있는 메인 씬
- `scripts/main/main.gd`
- 필요 시 맵 전용 `TileSet` 리소스 (`scenes/main/` 또는 `assets/background/` 하위)

### 완료 기준

- 맵이 `asset_sample/` 직접 참조 없이 `assets/` 경로로만 동작한다.
- `BG Dirt1/2` 가 실제 반복 배경으로 보인다.
- `Floor Tiles` 기반 메인 지면과 `Other Tiles` 기반 발판/경사면이 분리 적용된다.
- 플레이어 이동, 점프, 대시, 로프, 적 추격이 새 지형에서 깨지지 않는다.
- 전투 중 바닥 외곽선과 발판 실루엣이 명확하게 읽힌다.
- 헤드리스 스타트업에서 import/scene parse 오류가 없다.

### 비목표

- 본편 지역 아트 방향 확정
- 장식용 수목, 구름, 건물 레이어 대량 반영
- 맵별 고유 타일 테마 다변화

### 다음 후속 증분

첫 샌드박스 맵 배경/지형 적용이 안정화되면, 그 다음에는 장식 오브젝트와 원거리 배경 레이어를 추가하되 전투 가독성을 해치지 않는 범위에서만 확장한다.

### 현재 구현 메모 (2026-04-01)

- 원본 6개 PNG는 `assets/background/gandalf_hardcore/` 로 복사 완료.
- 1차 런타임 적용은 `scripts/world/room_builder.gd` 에서 진행했다.
  - 반복 배경 레이어 추가
  - 메인 지면 타일 데코 추가
  - 얇은 발판 타일 데코 추가
  - 기존 `floor_segments` 충돌 구조는 유지
- 1차 구현은 `TileMap` 전면 전환이 아니라 `현재 room data 구조를 보존하는 비주얼 적용` 이다.
- 회귀 확인용 `tests/test_room_builder.gd` 추가 완료.

#### 아이템 탭

- 장비 지급
- 희귀도별 장비 랜덤 지급
- 즉시 장착
- 전 장비 해제
- 인벤토리 슬롯과 아이템 아이콘 표시
- 아이템 점유 크기(`가로 x 세로`) 표시
- 드래그 앤 드롭 또는 동등한 그래픽 위치 이동

#### 자원 탭

- 무한 HP
- 무한 MP
- 무한 쿨타임 해제
- 무적
- HP/MP 즉시 회복

#### UI 탭

- 데미지 숫자 표시 토글
- 히트스톱 표시 토글
- 디버그 패널 토글
- FPS 및 상태 표시 토글

### 구현 대상 파일

- `scripts/admin/admin_menu.gd`
- `scripts/admin/admin_state.gd`
- `scenes/admin/AdminMenu.tscn`
- `scenes/admin/AdminMap.tscn`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Inventory.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Equipment.png`
- `asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png`

### 완료 기준

- 관리자 메뉴만으로 전투 상황을 반복 재현할 수 있다.
- 스킬, 적, 장비, 자원, UI 테스트가 외부 편집 없이 가능하다.
- 관리자 메뉴의 핵심 기능은 단축키뿐 아니라 마우스 클릭으로도 접근 가능하다.
- 이 마우스 상호작용 목표는 2026-03-29 문서 갱신에서 추가된 요구사항이며, 현재 빌드에서 아직 구현되지 않은 작업으로 취급한다.
- 관리자 탭, 장비창, 스킬창, 버프창이 그래픽 패널과 아이콘을 가진 GUI로 제공된다.
- 장비/인벤토리 조작은 텍스트 목록이 아니라 실제 슬롯 기반 GUI에서 수행된다.
- 지정된 `Equipment / Inventory / Buttons / Settings` PNG가 관리자 GUI 스킨의 기본 리소스로 실제 연결된다.
- 이 그래픽 GUI 목표도 현재 문서에 새로 추가된 요구사항이며 아직 구현되지 않은 작업으로 취급한다.

## 8. 전투 수치와 데이터 정비

### 목표

실행 코드와 데이터가 분리된 상태에서 튜닝이 가능해야 한다.

### 데이터 우선 대상

- 스킬
- 버프 조합
- 장비
- 적 스탯
- 드롭 테이블
- 관리자 기본 프리셋

### 권장 데이터 파일

- `data/skills/skills.json`
- `data/skills/buff_combos.json`
- `data/items/equipment.json`
- `data/enemies/enemies.json`
- `data/admin/loadouts.json`

### 완료 기준

- 핵심 전투 수치는 JSON 수정만으로 조정 가능하다.
- 로더는 타입 오류 없이 헤드리스에서 안전하게 파싱된다.

## 9. 테스트와 검증 계획

### 헤드리스 필수 검증

- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

### GUT 우선 테스트

- 플레이어 점프, 더블점프, 대시 상태 전환
- 스킬 마나 소모와 쿨타임
- 스킬 레벨 반영 계산
- 버프 중첩과 조합 발동
- 장비 장착 시 최종 스탯 계산
- 적 피격과 사망
- 관리자 토글과 핵심 명령 처리

### 수동 확인 체크리스트

- 입력 반응성이 즉각적인가
- 스킬 연계 시 막히는 후딜이 없는가
- 버프 조합의 순간 폭발력이 체감되는가
- 관리자 메뉴에서 재현이 쉬운가
- HUD 정보가 과하지 않으면서 충분한가

## Claude 구현 순서 제안

`CLAUDE.md` 규칙을 기준으로 Claude는 아래 순서로 작업하는 것이 가장 안전하다.

1. `spec-to-godot` 기준으로 이 문서를 작업 단위로 분해한다.
2. `godot-combat` 규칙에 따라 플레이어 상태와 스킬 매니저부터 만든다.
3. 적 최소 세트를 붙인다.
4. HUD를 붙인다.
5. 관리자 메뉴를 붙인다.
6. 장비 시스템 최소 버전을 붙인다.
7. 모든 단계마다 `GUT` 테스트와 헤드리스 검증을 통과시킨다.

## 구현 핸드오프

### 목표

스토리 없는 전투 샌드박스 빌드를 먼저 완성한다.

### 플레이 감각 목표

- 메이플식 횡스크롤 가독성
- 빠른 마법 연계
- 강한 버프 중첩 폭발력
- 테스트하기 쉬운 관리자 모드

### 이번 증분 범위

- 플레이어
- 스킬 슬롯
- 버프 조합
- 적 최소 세트
- 전투 HUD
- 관리자 메뉴
- 장비 최소 버전

### 예상 주요 파일

- `scripts/player/player.gd`
- `scripts/player/spell_manager.gd`
- `scripts/enemies/enemy_base.gd`
- `scripts/ui/game_ui.gd`
- `scripts/admin/admin_menu.gd`
- `scripts/autoload/game_state.gd`
- `scripts/autoload/game_database.gd`
- `data/skills/skills.json`
- `data/skills/buff_combos.json`
- `data/items/equipment.json`
- `data/enemies/enemies.json`

### 인수 기준

- 전투 샌드박스 맵에서 모든 전투 기능을 테스트할 수 있다.
- 관리자 메뉴에서 스킬, 적, 장비, 자원을 즉시 조작할 수 있다.
- 헤드리스 실행과 GUT 테스트가 모두 통과한다.

### 비목표

- 스토리 진행
- 본편 맵 구조
- NPC 상호작용
- 연출 중심 컷신

### 다음 증분

전투 샌드박스가 완성되면, 그 다음에는 이 전투 시스템 위에 지역 구조, 탐색 동선, 스토리 단서, NPC, 미궁 연출을 얹는다.

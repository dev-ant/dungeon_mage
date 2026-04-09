---
title: 전투 6차 작업 체크리스트 - 전투 UI 구축
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/workstreams/friend_gui_workstream.md
update_when:
  - handoff_changed
  - runtime_changed
  - status_changed
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 전투 6차 작업 체크리스트 - 전투 UI 구축

상태: 사용 중
최종 갱신: 2026-04-03
섹션: 구현 기준

## 목표

이 문서는 전투 샌드박스 HUD를 Claude가 단계적으로 확장할 수 있도록 정리한 체크리스트다.

핵심 목표는 `전투 중 필요한 정보가 한 화면에서 빠르게 읽히는 것`이다.

추가 목표로, 전투 UI는 `키보드로 완전 조작 가능`해야 할 뿐 아니라 `메이플스토리처럼 마우스로도 직접 상호작용 가능`해야 한다. 이 요구사항은 이번 문서 갱신에서 명시적으로 확정되었고, 아직 구현 완료 항목으로 옮기지 않는다.
또한 전투 UI는 텍스트 요약 위주가 아니라, 메이플스토리나 마비노기처럼 체력바/마나바/아이콘/슬롯/패널 프레임이 실제로 보이는 그래픽 GUI를 목표로 한다.

## 이번 증분의 에셋 기준

- HUD 기본 패널은 [Action_panel.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Action_panel.png) 를 우선 사용한다.
- HUD 버튼/슬롯 공통 스타일은 [Buttons.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Buttons.png) 를 우선 사용한다.
- 설정/보조 프레임은 [Settings.png](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/asset_sample/UI/Free-Basic-Pixel-Art-UI-for-RPG/PNG/Settings.png) 를 보조 스킨으로 사용한다.
- 이 에셋 기준은 이번 문서 갱신에서 추가된 것이며 아직 일관된 런타임 GUI로 완성되지 않았다.

## 2026-04-03 구체화로 잠긴 HUD 명세

이번 10문항 라운드로 아래 기준이 구현용 명세로 잠겼다.

### 목표 경험 우선순위

- 플레이어가 전투 중 가장 먼저 읽어야 하는 정보 우선순위는 `대상 HP -> 플레이어 자원/캐릭터 정보 -> 핫바`다.
- HUD는 텍스트 줄을 늘리는 방식보다 아이콘, 그래픽 바, 프레임, 상태 오버레이로 읽히는 것을 우선한다.
- 전투 조작의 기준선은 `키보드 100% 플레이 가능`이며, 마우스 조작은 이를 대체하는 주 경로가 아니라 보조 경로다.

### 레이아웃 잠금

- 화면 상단 좌측에는 `활성 버프 / 디버프` 행을 둔다.
- 화면 하단 중앙에는 `HP / MP / 캐릭터 정보` 묶음을 둔다.
- 플레이어 액션 슬롯은 `사용자가 등록 가능한 1행 10칸` 그래픽 핫바를 기준선으로 삼고, 스킬/버프/토글/설치형/아이템을 같은 액션 row 안에서 자유 혼합해 다룬다.
- 현재 활성 상태를 보여 주는 `활성 버프 row`는 액션 핫바와 별도 행으로 유지한다.
- `액션 핫바 row`와 `활성 버프 row`는 설정에서 각각 `show / hide` 토글 가능해야 한다.
- 화면에는 언제나 `10개 슬롯`만 보이고, 사용자는 설정에서 원하는 키를 이 10개 슬롯에 자유롭게 바인딩할 수 있어야 한다.
- `13키 바인딩`은 현재 문서와 런타임에 남아 있는 레거시 흔적으로만 취급하고, 최종 HUD canonical 로직으로 유지하지 않는다.

### 상호작용 잠금

- 좌클릭은 즉시 시전 또는 즉시 토글 실행이다.
- 우클릭은 슬롯 해제 또는 단축키 언바인드로 사용한다. 이는 2차 라운드의 더 구체적인 답변을 우선 반영한 해석이다.
- 클릭 유지하기는 슬롯을 잡아 다른 핫바 칸으로 옮기는 drag-rebind 동작으로 사용한다.
- 더블클릭은 전투 HUD의 기본 상호작용으로 요구하지 않는다.
- 슬롯 hover 툴팁은 `이름 / 쿨타임 / 비용 / 설명 / 현재 상태 / 레벨 / 마스터리`를 모두 보여 준다.
- 사용 불가 슬롯은 평상시에도 어둡게 보여서 실행 불가 상태를 미리 읽을 수 있어야 한다.
- 사용 불가 상태에서 입력이 들어오면 짧은 실패 문구를 띄운다.
- 키보드 선택 테두리는 유지하고, 마우스는 hover 오버레이만 덮어쓴다.
- drag-rebind 중 대상 칸이 이미 사용 중이면 두 칸을 swap 한다.

### 디버그 fallback 및 검증 잠금

- 기존 텍스트 요약 HUD는 최종 플레이어용 출력이 아니라 디버그 / 테스트 fallback으로만 남긴다.
- HUD row를 숨겨도 키보드 전투 입력은 계속 유지하고, 숨겨진 row는 화면에 없으므로 마우스 조작 대상에서도 제외한다.
- 액션 바 저장 canonical 은 `10슬롯 저장`으로 완전 이행한다.
- 구현 완료 판정은 `headless 테스트 통과 + 1회 수동 플레이 검증`이 모두 필요하다.
- 현재 문서는 위 명세를 구현 목표로 잠근 것이며, 아직 구현 완료 상태를 의미하지 않는다.

## 현재 구현 상태

### 완료

- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 HP/MP 표시
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 상단 좌측 primary target HP panel 구축
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 하단 중앙 resource cluster 셸 구축
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 상단 좌측 active buff chip row 구축
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 `Buttons.png` / `Action_panel.png` 기반 visible 10-slot hotbar shell 구축
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 hover tooltip, 좌클릭 cast, 우클릭 clear, drag swap 연결
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 unavailable dim state와 tooltip/current-state 기반 slot label 갱신
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 runtime local hide toggle `set_show_primary_action_row()` / `set_show_active_buff_row()` 연결
- [test_game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_ui.gd)에서 visible 10-slot row, tooltip, clear, swap, dim state, hide toggle 회귀 추가
- 방 제목, 현재 서클, 종합 점수 표시
- 기본 숙련도/숙련 수치 표시
- 공명 수치와 지배 속성 표시
- 핫바 요약 표시
- 시전 피드백 고정 표시
- 장비 요약 표시
- 활성 버프와 버프 쿨타임 표시
- 활성 조합 요약 표시
- 관리자 상태 요약 표시
- 관리자 탭 요약에 장비 탭의 `Focus / Slot / Nav / Target` 상태 표시
- 활성 토글형의 `이름 / 다음 틱 / 유지 마나 소모` 요약 표시
- 활성 토글형의 `slow / pierce / risk` 태그 표시
- 관리자 상태를 `Resources / Combat / Gear` 묶음으로 표시

### 아직 남은 작업

- hotbar/버프 row show/hide를 설정창과 persistence payload에 연결
- target panel의 target source를 nearest-alive 휴리스틱에서 explicit lock-on / keyboard selection 기준으로 승격
- 메이플스토리식 키보드 선택 테두리와 마우스 hover overlay의 시각 분리 연출
- 실제 스킬/아이템 아이콘 atlas 연결과 cooldown overlay 정리
- 버프/디버프 row를 텍스트 라벨이 아닌 아이콘 중심 GUI로 전환
- 최근 피격 원인, Soul Dominion 리스크, 관리자 상태를 그래픽 HUD 영역으로 재배치
- 수동 플레이 1회 검증으로 keyboard-only 전투와 마우스 보조 경로 체감 확인

### 새로 확정된 기준 중 현재 구현 반영 메모 (2026-04-03)

- 대상 HP는 화면에서 가장 먼저 읽히는 정보여야 한다.
- 현재 runtime GUI는 상단 좌측에 primary target HP panel을 렌더하고, target source는 `플레이어와 가장 가까운 살아 있는 적` 휴리스틱을 사용한다.
- 하단 중앙 자원 묶음은 HP/MP 그래픽 바와 현재/최대 수치, 캐릭터 핵심 정보를 함께 보여 준다.
- 플레이어 조작 row는 현재 runtime GUI에서 `사용자 등록형 1행 10칸 액션 핫바` 셸로 구현됐다.
- 액션 핫바 row와 활성 버프 row는 현재 `game_ui.gd` local toggle로 on/off 할 수 있고, 설정 persistence는 후속이다.
- 화면에는 10개 슬롯만 보이고, 단축키는 설정에서 자유롭게 다시 바인딩할 수 있어야 한다.
- `13키 바인딩`은 레거시 기준선일 뿐, 최종 canonical 로직이 아니다.
- 슬롯 hover 툴팁은 현재 이름, 쿨타임, 비용, 설명, 현재 상태, 레벨, 마스터리를 모두 담아 보여 준다.
- 좌클릭 즉시 실행, 우클릭 슬롯 해제, click-hold drag-rebind는 현재 runtime GUI에 연결됐다.
- 사용 불가 슬롯 dim 처리는 현재 runtime GUI에 연결됐다. 실패 문구는 owner_core message path를 재사용한다.
- 키보드 선택 테두리는 유지하고, 마우스는 hover 오버레이만 덮어쓴다.
- drag-rebind 충돌 시에는 현재 runtime GUI에서 두 칸을 swap 한다.
- HUD row가 숨겨져도 keyboard combat input은 유지되고, 숨겨진 row는 마우스 경로에서 빠진다.
- 액션 바 저장 canonical 은 10슬롯 저장으로 전환한다.
- 텍스트 fallback은 디버그/테스트 전용으로만 유지한다.
- 완료 판정은 headless 테스트와 수동 플레이 검증을 함께 요구한다.

### owner_core 선행 완료 메모 (2026-04-03)

- `GameState.save_to_disk()` payload는 이제 canonical `spell_hotbar` 10슬롯과 호환용 `legacy_spell_hotbar_tail` 3슬롯으로 분리 저장한다.
- `load_save()`는 신규 `10 + 3` payload와 과거 `13슬롯 spell_hotbar` save를 모두 읽는다.
- explicit `visible_hotbar_shortcuts` payload가 없는 old save도 첫 10슬롯의 `action + label`을 읽어 visible shortcut profile을 복원한다.
- `GameState.get_visible_spell_hotbar()`, `get_hotbar_slot()`, `clear_hotbar_skill()`, `swap_hotbar_skills()`와 `player/spell_manager` wrapper가 이미 존재하므로 GUI 구현은 이 경로를 바로 연결하면 된다.
- `GameState.get_visible_hotbar_shortcuts()`, `set_visible_hotbar_shortcut()`, `reset_visible_hotbar_shortcuts_to_default()`와 `player` wrapper까지 닫혀 있으므로 GUI는 설정 기반 rebind persistence도 바로 연결할 수 있다.
- `spell_manager` 전투 입력은 이제 visible 10슬롯만 combat canonical 로 읽는다. hidden legacy tail slot은 호환 save/배열에는 남지만 keyboard combat primary path에서는 직접 시전되지 않는다.
- 이번 증분 기준 owner_core 측 남은 후속은 사실상 GUI 통합 중 발견되는 추가 payload 요구나 완전한 legacy tail 제거 여부 재판정뿐이다.

## 우선 구현 순서 재정렬 (2026-03-29)

1. `Action_panel / Buttons / Settings` 에셋을 실제 HUD 씬에 붙인다.
2. HP/MP를 텍스트 요약이 아닌 그래픽 바 + 수치 GUI로 고정한다.
3. 핫바를 텍스트 버튼이 아닌 스킨 적용 슬롯 GUI로 교체한다.
4. 버프/디버프를 아이콘 기반 GUI로 옮긴다.
5. 텍스트 fallback은 테스트용 또는 디버그용으로만 남긴다.

### 10차 증분 완료 상태 (2026-03-28)

버프/콤보 HUD 가독성 강화:
- `get_active_buff_summary()`: 같은 버프를 중복 시전하면 `x2`, `x3` 스택 수 표시. 남은 시간이 2초 미만이면 ` !` 만료 경고 마커 추가.
- `get_combo_summary()`: Time Collapse 또는 Ashen Rite 가 활성화된 폭딜 창 상태에서 `[BURST]` 프리픽스 추가.
- 새 테스트 7개 추가: 스택 표시, 만료 마커, 버스트 마커 (Time Collapse / Ashen Rite), 패시브 조합 마커 없음 확인.
- 전체 테스트 96/96 통과.

### 11차 증분 완료 상태 (2026-03-28)

HUD 가독성 개선 — Soul Dominion 리스크 위치 이동 + 핫바 쿨타임 포맷:

**1. HP/MP 라인에 Soul Dominion 리스크 통합**
- `game_state.gd` — `get_resource_status_line()` 함수 추가
  - 정상: `HP 100/100   MP 180/180`
  - 활성 중: `HP 100/100   MP 45/180  [!MP-LOCK +35% DMG]`
  - 후유증 중: `HP 100/100   MP 45/180  [!SHOCK 3.2s +20% DMG]`
- `game_ui.gd` — `hp_label.text`가 `get_resource_status_line()`을 사용하도록 변경
- 리스크 마커가 피해를 받는 자원(MP/DMG)과 같은 줄에 노출됨 → 더 빠르게 인식 가능
- 기존 `buff_label` 끝 `soul_risk_line` 제거 (중복 제거)

**2. 핫바 쿨타임 포맷 개선**
- `spell_manager.gd get_hotbar_summary()` — 쿨타임 0.0일 때 `---`, 쿨타임 > 0일 때 `cd:X.X` 표시
- 이전: `Z Fire Bolt 0.0 | C Frost Nova 0.0 | V Volt Spear 0.2`
- 이후: `Z Fire Bolt --- | C Frost Nova --- | V Volt Spear cd:0.2`
- 즉시 사용 가능한 슬롯을 한눈에 구분 가능

**변경 파일**
- `scripts/autoload/game_state.gd` (`get_resource_status_line()` 추가)
- `scripts/ui/game_ui.gd` (hp_label 갱신, buff_label 정리)
- `scripts/player/spell_manager.gd` (`get_hotbar_summary()` 포맷)
- `tests/test_game_state.gd` (+3 테스트)
- `tests/test_spell_manager.gd` (+2 테스트)
- 전체 120/120 통과

### 12차 증분 완료 상태 (2026-03-28)

HUD 가독성 개선 — 토글 리스크 인라인 + 핫바 빈 슬롯 표시:

**1. 토글 요약에 Soul Dominion 리스크 수치 직접 표시**
- `spell_manager.gd get_toggle_summary()` — `dark_soul_dominion` 활성 시 `[MP-LOCK DMG+35%]` 인라인 추가
- 이전: `Soul Dominion [risk] tick 0.8 drain 22.0`
- 이후: `Soul Dominion [risk] [MP-LOCK DMG+35%] tick 0.8 drain 22.0`
- 다른 토글형(`ice_glacial_dominion` 등)에는 표시되지 않음
- `GameState.SOUL_DOMINION_DAMAGE_TAKEN_MULT`로부터 %를 계산하므로 상수 변경 시 자동 반영

**2. 핫바 빈 슬롯 표시**
- `spell_manager.gd get_hotbar_summary()` — `skill_id == ""` 시 `Z [empty]` 형태로 출력
- 이전: `Z  ---` (빈 이름 + ready 마커)
- 이후: `Z [empty]`
- 슬롯이 비어있는지 vs 쿨타임 중인지 즉시 구분 가능

**변경 파일**
- `scripts/player/spell_manager.gd` (get_toggle_summary + get_hotbar_summary)
- `tests/test_spell_manager.gd` (+3 테스트: empty 슬롯 마커, Soul Dominion 인라인 리스크, 타 토글형 오염 없음)
- 전체 129/129 통과

### 13차 증분 완료 상태 (2026-03-28)

HUD 가독성 개선 — 최근 피격 원인 표시 + 버스트 창 카운트다운:

**1. 최근 피격 원인 HUD 표시**
- `game_state.gd`: `last_damage_amount`, `last_damage_school`, `last_damage_display_timer` 변수 추가
- `damage(amount, school: String = "")` — optional school 파라미터로 피격 학파 기록. 4초 표시 타이머 시작
- `_process()` — `last_damage_display_timer` 틱
- `get_resource_status_line()` — 타이머 활성 시 `HP 80/100 [←12 fire]   MP 120/180` 포맷
- `player.gd receive_hit()` — `_school`을 `GameState.damage(amount, _school)`로 전달
- `reset_progress_for_tests()` — 세 변수 초기화 추가

**2. 버스트 창 만료 카운트다운 표시**
- `get_combo_summary()` — Time Collapse 활성 시 관련 버프(`arcane_astral_compression`, `arcane_world_hourglass`)의 최소 remaining 시간 계산
- `TimeCharges %d  Closes %.1fs` 포맷으로 표시

**변경 파일**
- `scripts/autoload/game_state.gd`
- `scripts/player/player.gd`
- `tests/test_game_state.gd` (+4 테스트: Closes 표시, 피격 학파 포함, 피격 학파 미포함, 타이머 만료 후 없음)
- 전체 164/164 통과

## Claude 바로 다음 작업

### 2026-04-03 구현 handoff — Combat HUD Cycle A

이 handoff는 전투 HUD 전체를 한 번에 끝내려 하지 않고, `첫 안전 증분`만 구현 대상으로 자른다.

**한 줄 목표**
- 현재 텍스트 중심 HUD 위에 `10슬롯 가시 액션 row + 상단 좌측 활성 버프 row + 하단 중앙 자원 클러스터`를 갖춘 그래픽 HUD 셸을 만든다.

**체감 목표**
- 전투 중 가장 먼저 `대상 HP`, 그다음 `HP/MP + 캐릭터 정보`, 마지막에 `10슬롯 액션 row`가 읽혀야 한다.
- 키보드 100% 전투를 깨지 않으면서, 마우스 hover/좌클릭/우클릭/drag가 보조 경로로 읽혀야 한다.
- 텍스트 요약은 유지보수용 fallback으로만 남고, 플레이어 노출 출력은 그래픽 패널/아이콘/슬롯 위주로 넘어가기 시작해야 한다.

**이번 증분 범위**
- 기존 hotbar source를 읽되, HUD에는 `처음 10슬롯만` 가시 row로 렌더한다.
- 상단 좌측에 활성 버프/디버프 row를 별도 배치한다.
- 하단 중앙에 HP/MP bar + 현재/최대 수치 + 캐릭터 핵심 정보 클러스터를 재배치한다.
- 액션 슬롯에 hover tooltip, 좌클릭 즉시 실행, 우클릭 언바인드, click-hold drag-rebind 입력 껍데기를 연결한다.
- 사용 불가 슬롯 dim 처리와 짧은 실패 문구 표시를 붙인다.
- HUD row hide 플래그가 켜지면 해당 row는 화면과 마우스 hit target에서 빠지되, 키보드 전투는 유지한다.

**2026-04-03 현재 구현 판정**
- 위 범위 중 `target HP primary panel`, `visible 10-slot row`, `active buff row`, `resource cluster`, `tooltip`, `좌클릭 cast`, `우클릭 clear`, `drag swap`, `dim state`, `row hide 시 mouse path 제거`는 실제 runtime과 GUT로 반영됐다.
- 이번 증분에서 아직 비어 있는 핵심은 `target source를 explicit selection/lock-on으로 승격`, `icon atlas`, `settings persistence`, `keyboard selection border 연출`, `manual play pass`다.

**정확히 읽을 파일**
- [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)
- [combat_hud_gui_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_hud_gui_schema.md)
- [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
- [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
- [role_split_contract.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md)
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)

**이번 증분에서 편집 허용 파일**
- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- `scripts/ui/widgets/**` 신규 HUD widget 파일
- `scenes/ui/**` 신규 HUD widget / scene 파일
- `tests/test_ui_combat_hud.gd` 같은 GUI 전용 신규 테스트 파일
- 같은 턴 문서 동기화가 필요하면 이 문서와 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)

**이번 증분에서 편집 금지**
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- save payload, canonical hotbar persistence, 입력 canonical 마이그레이션을 건드리는 owner_core 소유 파일 전체

**테스트 추가 / 갱신**
- 신규 GUI 테스트:
  - `10슬롯만 가시 row에 렌더되는지`
  - `HUD hide 플래그 시 row가 숨겨지고 마우스 대상에서도 빠지는지`
  - `hover tooltip이 name/cooldown/cost/description/current_state/level/mastery를 모두 담는지`
  - `occupied drop 시 swap 분기가 호출되는지`
- 기존 테스트는 이 증분에서 직접 건드리지 않아도 되지만, GUI 연결상 필요하면 GUI 전용 신규 테스트로 흡수한다.

**검증 명령**
- `godot --headless --path . --quit`
- `godot --headless --path . --quit-after 120`
- `godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
- 수동 검증 1회:
  - HUD 표시 상태에서 10슬롯 row, 상단 버프 row, 하단 자원 클러스터 위치 확인
  - HUD 숨김 on/off 상태에서도 키보드 전투 유지 확인

**같은 턴 문서 동기화**
- GUI 런타임 동작이 바뀌면 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md) 를 함께 갱신
- 구현 범위가 바뀌면 이 문서만 갱신

**이번 증분의 명시적 non-goal**
- `10슬롯 저장 canonical` 실제 코드 이행
- `13키` 레거시 데이터 마이그레이션
- 설정창에서 키 재바인딩 UI 구현
- 아이템 데이터/소비 로직 추가
- owner_core 소유 파일 수정

**다음 가장 작은 후속 증분**
- owner_core가 `10슬롯 저장 canonical` 과 hotbar rebind persistence API를 노출
- 그 다음 friend_gui가 설정창과 HUD를 연결해 실제 사용자 key rebind UX를 닫는다

### 16차 증분 완료 상태 (2026-03-28)

토글형별 특수 상태 수치 인라인 표시:
- `spell_manager.gd get_toggle_summary()` — 토글 종류별 특수 상태 수치를 태그와 함께 인라인 표시
- `ice_glacial_dominion`: `[slow 28%]` — `utility_effects`의 slow value에서 %로 계산
- `lightning_tempest_crown`: `[pierce x2]` — `active_toggles`의 pierce 필드에서 계산
- `dark_soul_dominion`: 기존 `[MP-LOCK DMG+35%]` 유지
- GUT 3개 추가: 빙결 slow%, 번개 pierce x, 빙결에 pierceDetail 없음 확인
- 전체 197/197 통과

### 15차 증분 완료 상태 (2026-03-28)

버프 쿨타임 HUD 콤팩트 포맷:
- `game_state.gd get_buff_cooldown_summary()` — 쿨타임 0인 버프는 생략, 전부 준비 시 `"Cooldowns  all ready"`, 쿨타임 > 0인 버프만 `"Name cd:X.Xs"` 포맷으로 표시
- 이전: `Cooldowns  Mana Veil 0.0 | Pyre Heart 0.0 | Frostblood Ward 0.0 | ...` (항상 10개 표시)
- 이후: `Cooldowns  all ready` 또는 `Cooldowns  Mana Veil cd:8.2s | Pyre Heart cd:3.1s` (쿨타임 있는 것만)
- GUT 3개 추가: all ready 표시, cd: 포맷, 준비된 버프 제외 확인
- 전체 191/191 통과

### 14차 증분 완료 상태 (2026-03-28)

HUD 마스터리 레이블 동적화:
- `game_ui.gd`의 `mastery_label`이 `fire_bolt/frost_nova/volt_spear` 3종 하드코딩에서 **실제 핫바 6슬롯 기반 동적 표시**로 전환됨
- `spell_manager.gd` — `get_hotbar_mastery_summary()` 추가: `slot_bindings` 순회 → `display_name` 첫 단어 + `Lv.X (XP)` 포맷. 빈 슬롯은 `[empty]` 표시
- `player.gd` — `get_hotbar_mastery_summary()` 래퍼 추가
- `game_ui.gd` — `_get_player_hotbar_mastery_summary()` 헬퍼 추가, `mastery_label.text` 를 동적 호출로 교체
- 효과: 관리자 메뉴에서 핫바 스킬을 바꾸면 HUD 마스터리 줄도 즉시 갱신됨
- GUT 3개 추가: 기본 슬롯 Lv/XP 표시, 핫바 변경 반영, 빈 슬롯 [empty] 마커
- 전체 188/188 통과

### 17차 증분 완료 상태 (2026-03-29)

마우스 클릭 가능한 핫바 버튼 + HP/MP ProgressBar + 버튼 CD 상태 표시:

**1. 핫바 클릭 버튼 추가 (Cycle 1)**
- `game_ui.gd` — `_build_hotbar_buttons()` / `_refresh_hotbar_buttons()` / `_on_hud_hotbar_button_pressed()` 추가
- `$Margin/Bottom`에 HBoxContainer로 버튼 6개 동적 생성, 각 버튼이 `player.cast_hotbar_slot(i)` 호출
- `player.gd` — `cast_hotbar_slot(slot_index)` 추가: dead/hitstun/castlock/null 검사 후 `spell_manager.attempt_cast()` 위임
- `player.gd` — `debug_setup_spell_manager()` 추가: headless 테스트용 spell_manager 수동 초기화
- `tests/test_player_controller.gd` — 5개 테스트 추가 (dead/null/범위초과/빈슬롯/버프스킬 발동)
- 전체 311/311 통과

**2. HP/MP ProgressBar 위젯 추가 (Cycle 2)**
- `game_ui.gd` — `_build_resource_bars()` / `_refresh_resource_bars()` 추가
- `$Margin/Top`에 HP label + ProgressBar(120px) + MP label + ProgressBar(120px) 동적 생성
- `refresh()` 에서 `_refresh_resource_bars()` 호출로 매 프레임 갱신
- 전체 311/311 통과 (새 GUT 테스트 없음 — game_ui는 독립 인스턴스화 불가)

**3. 핫바 버튼에 CD 상태 인라인 표시 (Cycle 3)**
- `_refresh_hotbar_buttons()` — `GameState.buff_cooldowns.get(skill_id, 0.0)` 조회
- CD > 0일 때: `"Q Veil [CD8.2]"`, CD 없을 때: `"Q Veil"` 포맷
- 마우스로 슬롯을 봤을 때 쿨타임 여부를 즉시 확인 가능
- 전체 311/311 통과

**변경 파일**
- `scripts/player/player.gd` (cast_hotbar_slot, debug_setup_spell_manager)
- `scripts/ui/game_ui.gd` (버튼, 바, CD 표시 전체)
- `tests/test_player_controller.gd` (+5 테스트)

### 18차 증분 완료 상태 (2026-03-29)

UI 에셋 적용 — 핫바 버튼 스킨 + 패널 배경 + 플레이어 스프라이트 애니메이션 로직:

**1. 핫바 버튼 스킨 적용 (`Buttons.png`)**
- `game_ui.gd` — `_apply_hotbar_button_skin(btn)` 추가
  - `Buttons.png`의 22×22px 녹색 사각 버튼을 `StyleBoxTexture`로 적용
  - Normal(x=13), Hover(x=109), Pressed(x=61), Disabled(x=157) 상태별 별도 region
  - `btn.texture_filter = TEXTURE_FILTER_NEAREST` (픽셀아트 크리스프 스케일)
  - 버튼 크기: `44×44px`, 흰색 폰트, hover 시 노란 강조
- 버튼 레이블 포맷 개선: slot_label + short_name + CD를 3행으로 표시

**2. 핫바 패널 배경 적용 (`Action_panel.png`)**
- `game_ui.gd` — `_make_action_panel_style()` 추가
  - `Action_panel.png`의 band 1 (y=8-34, 176×27px)을 9-patch StyleBoxTexture로 적용
  - `texture_margin=5`, `expand_margin=4` (프레임 경계 + 내부 여백)
  - HBoxContainer를 `PanelContainer`로 감싸고 action panel 텍스처를 배경으로 적용
- 에셋 경로 상수화: `BUTTONS_TEX`, `ACTION_PANEL_TEX` 클래스 상수 추가

**3. 플레이어 스프라이트 애니메이션 로직 (`male_hero-*.png`)**
- `player.gd` — `sprite: AnimatedSprite2D = null` 변수 추가 (에디터 import 후 `$Sprite`로 연결)
- `player.gd` — `_ready()` 에서 `has_node("Sprite")` 체크 후 sprite 참조 설정
- `player.gd` — `_update_anim()` 추가:
  - `sprite.scale.x = facing` (방향 전환)
  - `sprite.modulate` alpha flicker (무적 프레임 깜빡임)
  - `state_name` → animation 매핑 (idle/run/jump/fall_loop/dash/hurt/death)
  - animation 전환 시에만 `sprite.play()` 호출 (mid-loop 재시작 방지)
- `_update_visual()` 에서 `_update_anim()` 호출
- **현재 상태**: 코드 구조 완성. 스프라이트 시각화는 Godot 에디터에서 `.import` 처리 후 활성화됨

**스프라이트 import 처리 방법 (Claude가 headless에서 처리 불가)**
- 캐릭터 스프라이트 `.import` 파일은 이미 생성됨 (`asset_sample/Character/male_hero_free/individual_sheets/*.png.import`)
- Godot 에디터를 한 번 실행하면 자동으로 `.ctex` 파일 생성됨
- 이후 `Main.tscn`에 `AnimatedSprite2D`를 씬 파일에 추가하면 시각적으로 동작
- 에디터 없이 headless에서는 `sprite = null`로 fallback되어 Polygon2D 플레이스홀더가 계속 보임

**변경 파일**
- `scripts/ui/game_ui.gd` (에셋 상수, 패널 컨테이너, 버튼 스킨, 레이블 포맷)
- `scripts/player/player.gd` (sprite 변수, has_node 체크, `_update_anim()`)
- `asset_sample/Character/male_hero_free/individual_sheets/*.png.import` (8개 새 import 파일)
- 전체 311/311 통과

### 28차 증분 완료 상태 (2026-03-30)

히트스탑 강도 동적화 (damage 비례):

- `spell_projectile.gd` — `_trigger_hitstop(clampf(0.03 + damage * 0.002, 0.03, 0.12))`
  - damage=5 → 0.04s (약한 타격감)
  - damage=15 → 0.06s (기본 타격감)
  - damage=30 → 0.09s (강한 타격감)
  - damage=50+ → 0.12s (최대 타격감)
- 이전: 모든 스킬 일률 0.06s
- 전체 313/313 통과

### 27차 증분 완료 상태 (2026-03-30)

플레이어 사망 페이드아웃 연출:

- `main.gd` — `_fade_screen(from_alpha, to_alpha, duration)` 추가
  - `ColorRect`를 `canvas_layer` 위에 동적 생성, `set_anchors_preset(FULL_RECT)`로 전체 화면 덮음
  - 매 프레임 `lerpf`로 alpha 보간
  - 페이드인(to_alpha=0) 완료 시 `queue_free()`로 자동 제거
- `_on_player_died()` 개선:
  - **사망 → 페이드아웃(0.6s)** → 0.3s 대기 → 룸 복원 → **페이드인(0.5s)**
  - 이전: `await 0.8s → restore` (즉시 전환)
- 전체 313/313 통과

### 26차 증분 완료 상태 (2026-03-30)

Soul Dominion 리스크 MP 바 색상 시각화:

- `game_ui.gd` — `_refresh_mp_bar_color()` 추가, `_refresh_resource_bars()`에서 호출
  - `soul_dominion_active`: 짙은 빨강 (MP 잠김 상태 직관적 표현)
  - `soul_dominion_aftershock_timer > 0`: 주황 (후유증 경고)
  - 정상: 파랑 (기본값)
- 매 프레임 갱신 → 실시간으로 Soul Dominion 상태 전환이 MP 바 색상에 즉시 반영
- 전체 313/313 통과

### 24차 증분 완료 상태 (2026-03-30)

히트스탑 (타격 정지감):

- `spell_projectile.gd` — `_trigger_hitstop(duration: float)` 추가
  - `Engine.time_scale = 0.05` (거의 정지)
  - `get_tree().create_timer(duration, true, false, true)` — `ignore_time_scale=true`로 실제 시간 기준 타이머
  - 타이머 만료 시 `Engine.time_scale = 1.0` 복원
- `_hit_enemy()` — player팀 명중 시 `_trigger_hitstop(0.06)` 호출
- 결과: 모든 플레이어 스킬이 적에게 명중할 때 0.06초 히트스탑 연출
- 전체 313/313 통과

### 29차 증분 완료 상태 (2026-03-30)

버프 색상 칩 행 (HUD 시각적 버프 표시):

- `game_ui.gd` — `_buff_chip_row: HBoxContainer`, `SCHOOL_CHIP_COLORS` 상수 딕셔너리 추가
  - 계열 색상: fire=주황빨강, ice=하늘색, lightning=노랑, dark=보라, plant=초록, 기본=회색
- `_build_buff_chips()` — `$Margin/Top`에 `HBoxContainer` 행 추가 (이름: BuffChipRow)
- `_refresh_buff_chips()` — `GameState.active_buffs`를 순회
  - 각 버프의 `skill_id`로 `GameDatabase.get_skill_data()` 호출 → school 값 획득
  - `ColorRect` (10×10) + `Label` ("이름 남은시간s", font_size=10, chip 색상 lightened) 조합
  - 기존 칩 모두 `queue_free()` 후 재생성
- `refresh()` 에서 `_refresh_buff_chips()` 호출 (매 프레임 갱신)
- 전체 313/313 통과

### 23차 증분 완료 상태 (2026-03-30)

HP/MP 바 수치 레이블 통합:

- `game_ui.gd` — `_hp_value_label: Label`, `_mp_value_label: Label` 변수 추가
- `_build_resource_bars()` — 각 바 우측에 수치 레이블 삽입
  - HP: `_hp_value_label`, 연분홍 색상(1, 0.8, 0.8), font_size=11
  - MP: `_mp_value_label`, 연파랑 색상(0.8, 0.85, 1.0), font_size=11
- `_refresh_resource_bars()` — `"%d/%d" % [current, max]` 포맷으로 매 프레임 갱신
- 결과: `HP [========] 100/100  MP [========] 180/180` 형태의 그래픽 바 + 수치 동시 표시
- 전체 313/313 통과

### 22차 증분 완료 상태 (2026-03-30)

피격 카메라 흔들림 (히트 필):

- `player.gd` — `_cam_shake_timer: float`, `_cam_shake_intensity: float` 변수 추가
- `receive_hit()` — `_cam_shake_timer = 0.3`, `_cam_shake_intensity = 8.0` 설정
- `_tick_timers(delta)` — 타이머 감소, `$Camera2D.offset`에 랜덤 오프셋 적용 (강도는 남은 시간에 비례)
- 타이머 만료 시 `offset = Vector2.ZERO`로 복원
- 전체 313/313 통과

### 20차 증분 완료 상태 (2026-03-30)

HP/MP 바 색상 스타일 적용:

- `game_ui.gd` — `_apply_bar_style(bar, fill_color, bg_color)` 헬퍼 추가
  - `StyleBoxFlat` fill + background를 각각 생성, corner_radius=2 (둥근 모서리)
  - HP 바: fill=진빨강(0.85, 0.18, 0.18), bg=어두운빨강(0.25, 0.08, 0.08)
  - MP 바: fill=파랑(0.18, 0.45, 0.88), bg=어두운파랑(0.06, 0.12, 0.28)
- `_build_resource_bars()` 에서 바 생성 직후 `_apply_bar_style()` 호출
- 전체 313/313 통과 (game_ui는 headless 독립 인스턴스 불가, 시각 확인은 실행 시)

### 19차 증분 완료 상태 (2026-03-30)

메이플스토리식 부유 데미지 숫자 (DamageLabel):

**1. `scripts/ui/damage_label.gd` 신규 생성**
- `Label`을 상속하는 간단한 부유 레이블
- `setup(amount, pos, school)` — 위치 랜덤 오프셋, 크기 20px, school별 색상 적용
  - `fire`: 주황(1.0, 0.55, 0.15), `ice`: 하늘(0.45, 0.85, 1.0), `lightning`: 노랑(1.0, 0.95, 0.2), `dark`: 보라(0.75, 0.3, 1.0)
- `_physics_process(delta)` — 초당 60px 위로 이동, alpha 1.5/s 감소, alpha ≤ 0 시 `queue_free()`

**2. `enemy_base.gd` — `damage_label_requested` 시그널 추가**
- 시그널: `damage_label_requested(amount: int, position: Vector2, school: String)`
- `receive_hit()` 에서 `health -= amount` 직후 `_spawn_damage_label()` 호출
- `_spawn_damage_label()` 은 시그널을 emit하는 단순 래퍼 (CanvasItem 직접 생성 없음 → headless 안전)

**3. `main.gd` — DamageLayer 생성 및 시그널 연결**
- `_ready()` 에서 `DamageLayer` Node2D를 동적 생성하고 변수로 보관
- `_spawn_enemy()` 에서 `enemy.damage_label_requested.connect(_spawn_damage_label)` 연결
- `_spawn_damage_label(amount, position, school)` — `DAMAGE_LABEL_SCRIPT.new()`, `label.setup()` 호출

**변경 파일**
- `scripts/ui/damage_label.gd` (신규)
- `scripts/enemies/enemy_base.gd` (시그널 추가, `_spawn_damage_label()` 추가)
- `scripts/main/main.gd` (DamageLayer, 시그널 연결, `_spawn_damage_label()` 핸들러)
- `tests/test_enemy_base.gd` (+2 테스트: 시그널 emit 확인, school 값 확인)
- 전체 313/313 통과

## 관련 파일

- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [player.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/player.gd)
- [spell_manager.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/player/spell_manager.gd)
- [game_state.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)

## 수용 기준

- 플레이어가 켠 토글형의 핵심 상태를 HUD에서 즉시 읽을 수 있다.
- 관리자 샌드박스에서 전투 상태와 자원 상태를 에디터 없이 확인할 수 있다.
- 새 HUD 정보가 기존 전투 루프를 가리지 않고, headless 테스트를 깨지 않는다.

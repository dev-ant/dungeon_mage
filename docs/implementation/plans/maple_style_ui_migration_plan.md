---
title: 메이플식 UI 및 협업 문서 통합 마이그레이션 계획
doc_type: plan
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_hud_gui_schema.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/policies/role_split_contract.md
update_when:
  - handoff_changed
  - runtime_changed
  - ownership_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 메이플식 UI 및 협업 문서 통합 마이그레이션 계획

상태: 사용 중  
최종 갱신: 2026-04-10  
섹션: 구현 계획

## 목표

이 문서는 현재 `HUD + 관리자 메뉴` 중심 UI를 `메이플스토리식의 깔끔한 창 UI + 마우스 클릭 상호작용 + 고정 단축키 등록 구조`로 옮기기 위한 실행 계획이다.

이번 계획은 아래 두 축을 한 번에 다룬다.

- 플레이어 창 UI 마이그레이션
- `owner_core / friend_gui` 분리 문서를 단일 작업 흐름으로 합치는 협업 문서 마이그레이션

## 현재 기준

### 이미 구현된 기반

- 메인 HUD는 [`scripts/ui/game_ui.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd) 가 `Control` 기반으로 직접 조립한다.
- 관리자 메뉴는 [`scripts/admin/admin_menu.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd) 에서 일부 텍스처 에셋을 사용해 장비/인벤토리 시각 패널을 구성하고, 최근 follow-up으로 shared `UiWindowFrame` helper 를 재사용해 outer shell / tab shell / action button skin 도 player UI와 일부 수렴했다.
- 런타임에는 `10 visible hotbar` 와 `visible_hotbar_shortcuts` 저장 구조가 이미 있다.
- 장비 인벤토리, 장비 프리셋, hotbar 프리셋, tooltip payload, drag swap용 API는 이미 `GameState` 와 `spell_manager` 쪽에 일부 존재한다.
- `UiState` autoload, `WindowManager`, `WindowLayer / ModalLayer / TooltipLayer`, `InventoryWindow / SkillWindow / KeyBindingsWindow / SettingsWindow / EquipmentWindow / StatWindow / QuestWindow` shell 이 실제로 추가됐다.
- `ESC = Settings / topmost close`, `I = Inventory`, `K = Skill`, `E = Equipment`, `T = Stat`, `Q = Quest`, `admin_menu = F8`, visible hotbar 기본값 `1~0` 전환이 실제 입력 맵에 반영됐다.
- `Q/T` 와 충돌하던 기존 버프 기본 키는 `Z/X/C/V` 쪽으로 옮겨졌고, 이후 Maple식 우선순위 결정에 따라 전투 입력 기본값도 `방향키 이동 / Space 점프 / Tab 대시 / A/S/D/F/Shift/Ctrl/Alt 확장 버프열`로 정리됐다.
- `SettingsWindow` 는 `오디오 / 그래픽 / 효과` 탭과 `music_volume`, `sfx_volume`, `brightness`, `ui_opacity`, `effect_opacity`, `special_effects`, `screen_shake` control 을 가진다.
- `SettingsWindow` 는 `HUD` 탭과 `show_primary_action_row`, `show_active_buff_row` control 을 실제로 가진다.
- `InventoryWindow` 는 `장비 / 소비 / 기타` 3탭과 탭별 `5x4 = 20칸` grid, 장비/소비/기타 실데이터 셀 바인딩, 상세 패널, `정리 / 장착/사용 / 장비창` action row 를 가진다.
- `EquipmentWindow` 는 paper-doll slot shell, 슬롯별 보유 장비 목록, 장착/해제 button, drag 장착/해제, hover 기반 compare panel/tooltip, 자동 비교 요약까지 실제로 가진다.
- `StatWindow` 는 현재 HP/MP/마나 재생/서클과 장비 반영 파생 요약, 공명 요약을 실제로 보여 준다.
- `QuestWindow` 는 `진행 가능 / 진행 중 / 완료` 3탭, 검색, `현재 지역만` 필터, empty state + future hook shell 을 실제로 가진다.
- `SkillWindow` 는 `왼쪽 학교 카테고리 / 중앙 목록 / 오른쪽 상세`, 현재 등록 키 요약, `키 등록` 진입 버튼, direct drag payload 까지 실제로 가진다.
- `KeyBindingsWindow` 는 `1~0, Z/X/C/V, A/S/D/F, Shift/Ctrl/Alt` 21개 고정 슬롯, pending skill 등록, 우클릭 해제, direct drop bind, 허용 키 직접 입력 등록, 선택/hover 구분 테두리를 실제로 가진다.
- 실제 icon atlas 는 아직 없지만, `SkillWindow`, `KeyBindingsWindow`, HUD quickslot 은 학교별 pseudo-icon 과 drag ghost preview 를 현재 runtime에 가진다.
- HUD quickslot tooltip 은 이제 hover 슬롯 근처에 붙고, viewport edge를 넘기면 좌/하 방향으로 자동 flip 된다.
- HUD quickslot 은 occupied / hover / drag-source 상태를 구분하는 얇은 overlay border 를 실제 runtime에 가진다.
- HUD quickslot shell 은 이제 `assets/ui/pixel_rpg/Action_panel.png` atlas region 을 직접 읽는 outer frame + slot frame 을 실제로 가진다.
- `UiWindowFrame` 는 Maple-like warm hover/pressed close button skin 을 공유 프레임 레벨에서 실제로 가진다.
- `UiWindowFrame` 는 창별 accent color를 읽는 상단 accent strip 과 title label outline 을 공유 프레임 레벨에서 실제로 가진다.
- `InventoryWindow`, `QuestWindow`, `SettingsWindow` 탭은 창별 accent color 를 가진 shared Maple-like tab skin 으로 실제 런타임에 적용된다.
- `InventoryWindow` action row 는 `정리 / 장착·사용 / 장비창` 버튼에 accent 기반 shared action button skin 을 실제로 사용한다.
- `InventoryWindow` header 는 현재 accent badge 기반 `count pill` 을 실제로 사용한다.
- `InventoryWindow` slot shell 은 이제 `assets/ui/pixel_rpg/Action_panel.png` atlas region 기반 `StyleBoxTexture` 를 실제로 사용한다.
- `SettingsWindow` slider / checkbox row 는 accent 기반 panel surface, custom slider track/knob, custom checkbox icon skin 을 실제로 사용한다.
- `UiState` 는 현재 `Music / SFX / Effect` audio bus 를 런타임에서 보장하고, `music_volume / sfx_volume` slider 가 해당 bus volume에 즉시 적용된다.
- `UiWindowFrame` 는 procedural textured shell helper 를 실제로 가지며, `InventoryWindow`, `EquipmentWindow`, `SkillWindow`, `KeyBindingsWindow`, `SettingsWindow` row card 가 메이플식 광택/stripe/shadow panel skin 을 공유한다.
- `InventoryWindow`, `EquipmentWindow` slot shell 과 `SkillWindow`, `KeyBindingsWindow` 핵심 panel 은 이제 `StyleBoxTexture` 기반 procedural skin 으로 통일됐다.
- `UiWindowFrame` shared shell 은 이제 `assets/ui/pixel_rpg/Settings.png` atlas region 을 공통 창 프레임으로 직접 사용하고, close button 은 `assets/ui/pixel_rpg/Buttons.png` atlas state 를 직접 사용한다.
- `admin_menu` 는 `UiWindowFrame` helper 를 재사용해 atlas-backed outer shell, compact tab shell, accent-aware action button skin 을 실제로 사용한다. 장비 패널의 atlas crop contract는 유지하되, 바깥 시각 언어는 player UI 쪽과 더 가깝게 수렴했다.
- `SkillWindow`, `KeyBindingsWindow`, `InventoryWindow` 핵심 panel shell 도 이제 `Settings.png` / `Action_panel.png` atlas 계열을 직접 읽는 asset-backed shell 로 올라왔다.

### 아직 없는 것

- owner/friend 분리 종료 후의 단일 협업 문서 체계
- `소비 / 기타` 아이템의 실제 전장 드롭/경제 루프

## 2026-04-10 구현 진행 상태

- `추정 진행률`: 약 `91%`

- `완료`: Phase 1 기반 계층
  - `UiState`, `WindowManager`, `Main.tscn` window layers, draggable shell, z-order, close button, window persistence가 실제로 동작한다.
- `완료`: Phase 2 입력 기본값 전환의 1차 범위
  - visible hotbar default `1~0`, `ESC/I/K/E/T/Q`, `admin_menu=F8` 가 코드와 테스트에 반영됐다.
  - `Q/T` 충돌 버프 기본키는 `Z/X/C/V` 로 옮겨 창 예약 키와 분리했다.
  - Maple식 키바인딩 우선 결정에 따라 기본 조작은 `방향키 이동 / Space 점프 / Tab 대시`, 확장 전투 키는 `A/S/D/F/Shift/Ctrl/Alt` 로 잠겼다.
- `부분 완료`: Phase 4 인벤토리창
  - `장비 / 소비 / 기타` 3탭, `20칸` grid shell, 장비 카운트 라벨, 장비 탭 실데이터 셀 바인딩이 구현됐다.
  - `InventoryWindow` 는 현재 장비 탭에서 선택 상세, `정리`, direct equip, occupied-cell drag swap, explicit empty-slot move 를 실제로 지원한다.
  - `소비 / 기타` 탭도 `20칸 fixed sparse stack inventory` 저장 구조, 셀 바인딩, 상세 패널, organize, drag swap/move/stack merge, 소비 탭 double-click/use action 까지 실제로 지원한다.
  - 같은 날짜 follow-up으로 `InventoryWindow` grid panel 은 shared compact atlas shell 로, inventory slot button 은 `Action_panel.png` atlas-backed slot shell 로 전환됐다.
  - `EquipmentWindow` 1차 shell도 함께 들어가서 slot 선택, 보유 장비 목록, 장착/해제, drag 장착/해제, hover compare/tooltip, 비교 요약, 더블클릭 장착/해제까지 현재 런타임 데이터로 동작한다.
  - `GameState.equipment_inventory` 는 `20칸 fixed sparse slot` 모델로 정규화돼 organize 후 좌상단 압축과 빈칸 유지 재배치가 현재 코드/테스트로 잠겼다.
  - follow-up 시각 폴리시로 `InventoryWindow` 탭과 action row 버튼이 shared Maple-like skin 으로 정리됐다.
  - 추가 폴리시로 `InventoryWindow` header 는 accent `count pill` 과 공통 title accent strip 을 사용한다.
- `부분 완료`: Phase 5 스킬/스텟/퀘스트
  - `StatWindow` 와 `QuestWindow` shell 이 실제 입력/윈도우 계층에 연결됐다.
  - `QuestWindow` 는 empty state + future hook 범위까지 닫혔다.
  - `SkillWindow` 는 school/category tab, 목록, 상세 패널, 현재 등록 키 요약, `키 등록` 진입, direct drag payload 까지 실제로 닫혔다.
- `KeyBindingsWindow` 는 fixed whitelist 21슬롯, pending skill 등록, 우클릭 해제, direct drop bind, 허용 키 직접 입력 등록, selected-vs-hover border 분리까지 실제로 닫혔다.
- HUD primary quickslot row 는 기존 `좌클릭 cast / 우클릭 clear / drag swap` 흐름 위에 `SkillWindow -> HUD quickslot` direct drop bind, hover-near tooltip edge flip, occupied/hover/drag-source state overlay, `Action_panel.png` atlas-backed quickslot shell 까지 실제로 닫혔다.
  - `skill_visual_helper.gd` 기반 학교별 pseudo-icon 과 drag ghost preview 가 `SkillWindow`, `KeyBindingsWindow`, HUD quickslot 에 실제로 들어갔다.
  - `QuestWindow` 탭과 공통 `UiWindowFrame` close button, title accent strip 도 shared Maple-like skin 으로 정리됐다.
- `부분 완료`: Phase 6 설정창
  - `ui_opacity`, `brightness`, `effect_opacity`, `special_effects`, `screen_shake` 는 런타임 적용 경로가 연결됐다.
  - `music/sfx` 는 persistence뿐 아니라 `Music / SFX / Effect` runtime bus 보장과 즉시 volume apply까지 닫혔다.
  - `show_primary_action_row`, `show_active_buff_row` 는 `SettingsWindow` 의 `HUD` 탭과 `UiState` persistence를 통해 실제 `GameUI` row visibility에 연결됐다.
  - `SettingsWindow` 탭과 title accent strip 도 shared Maple-like skin 으로 정리됐다.
  - follow-up 시각 폴리시로 `SettingsWindow` slider / checkbox row 도 card-like panel surface, custom slider track/knob, custom checkbox icon skin 까지 shared helper 기반으로 정리됐다.
- `부분 완료`: Phase 7 비주얼 스킨
- `UiWindowFrame` shared helper 는 이제 gloss/stripe/shadow가 들어간 procedural textured shell style 을 제공한다.
- `InventoryWindow`, `EquipmentWindow` 는 panel shell 과 slot shell 에 같은 textured visual language 를 공유한다.
- `SkillWindow`, `KeyBindingsWindow` 는 핵심 panel shell 을 textured skin 으로 통일했고, key slot state border 는 기존 selection/hover 구분 계약을 유지하기 위해 flat state box 를 계속 사용한다.
- `SettingsWindow` row card 도 procedural textured panel surface 로 올라와 기존 custom slider/checkbox skin 과 함께 사용된다.
- `admin_menu` 도 outer shell, tab shell, action button layer에서 같은 helper 를 재사용해 player 창과 visual language 를 일부 공유한다.
- 같은 날짜 follow-up으로 `UiWindowFrame` main shell 은 `assets/ui/pixel_rpg/Settings.png` atlas-backed frame region 으로 올라왔고, shared close button 은 `assets/ui/pixel_rpg/Buttons.png` atlas state 를 직접 사용한다.
- 같은 follow-up으로 `scripts/admin/admin_menu.gd` outer shell 과 tab shell 도 shared atlas-backed frame style 로 전환됐다.
- 같은 날짜 follow-up으로 `scripts/ui/game_ui.gd` 의 HUD quickslot outer panel / slot shell 도 `assets/ui/pixel_rpg/Action_panel.png` atlas region 을 직접 읽는 asset-backed shell 로 전환됐다.
- 같은 날짜 다음 follow-up으로 `scripts/ui/windows/skill_window.gd`, `scripts/ui/windows/key_bindings_window.gd` 핵심 panel shell 과 `scripts/ui/windows/inventory_window.gd` grid/slot shell 도 atlas-backed shell 로 전환됐다.
- 다만 `tab/button/icon` 전체를 atlas 기반으로 치환하는 최종 pass 는 아직 남아 있으므로 `asset-backed final skin` 단계는 계속 후속이다.
- `부분 완료`: Phase 8 owner/friend 문서 통합 전환
  - `shared_ui_runtime_workstream.md`, `single_stream_collaboration.md`, `prompt_template_shared_build.md` 를 실제로 추가했다.
  - `collaboration/README.md`, `docs/README.md`, `implementation/README.md` 의 기본 진입점은 shared policy/workstream 기준으로 갱신됐다.
  - 기존 `role_split_contract.md`, `owner_core_workstream.md`, `friend_gui_workstream.md` 는 삭제하지 않고 `superseded` legacy 문서로 낮췄다.
  - legacy prompt 자체의 archive 이동과 세부 cross-link 정리는 후속 문서 정리 사이클로 남겨 둔다.

## 플레이 경험 목표

- 플레이어는 `ESC`, `I`, `K`, `E`, `T`, `Q` 로 주요 창을 즉시 열고 닫을 수 있어야 한다.
- 창은 마우스로 클릭, hover, drag, tab 전환, close 버튼 조작이 가능해야 한다.
- 창 비주얼은 메이플식으로 `밝은 프레임`, `명확한 탭`, `가독성 높은 슬롯`, `깔끔한 hover/selected state` 를 가져야 한다.
- 전투 HUD는 지금처럼 화면을 많이 가리지 않되, 메뉴형 창은 메이플처럼 독립적인 `floating window` 감각을 가져야 한다.
- 전투 입력과 창 입력은 서로 꼬이지 않아야 한다.
- 단축키 등록은 자유 텍스트 리매핑이 아니라 `허용된 키 목록` 안에서만 이뤄져야 한다.

## 이번 계획에서 고정하는 UI 계약

### 창 열기 키

| 창 | 고정 키 | 동작 |
| --- | --- | --- |
| 설정창 | `ESC` | modal 우선. 열려 있으면 닫고, modal 자식이 열려 있으면 자식부터 닫음 |
| 아이템창 | `I` | toggle |
| 스킬창 | `K` | toggle |
| 장비창 | `E` | toggle |
| 스텟창 | `T` | toggle |
| 퀘스트창 | `Q` | toggle |

### 단축키 등록 키

허용 키 화이트리스트는 아래로 고정한다.

- 숫자: `1 2 3 4 5 6 7 8 9 0`
- 문자: `Z X C V A S D F`
- 특수 키: `SHIFT CTRL ALT`

추가 규칙:

- `ESC`, `I`, `K`, `E`, `T`, `Q` 는 창 전용 예약 키로 두고 action hotkey 등록 대상에서 제외한다.
- HUD의 기본 가시 quickslot row 는 `1~0` 10칸을 canonical primary row 로 사용한다.
- `Z X C V A S D F SHIFT CTRL ALT` 는 extended action registry 로 사용한다.
- `SHIFT`, `CTRL`, `ALT` 는 단독 입력만 허용하고 조합 입력은 이번 범위에 넣지 않는다.
- 현재 `Z/C/V/U/I/P/O/K/L/M` 기반 default visible hotbar 구조는 레거시로 간주하고 신규 canonical 기본값으로 교체한다.

## 2026-04-09 잠금된 세부 기본값

아래 값은 별도 사용자 재확인 없이 구현 기본값으로 사용한다.

### 창 열기/닫기

- 같은 창 단축키를 다시 누르면 해당 창은 `toggle close` 된다.
- `ESC` 를 눌렀을 때 닫을 수 있는 창이 하나라도 열려 있으면, `가장 최근에 열었거나 마지막으로 클릭해 최상단이 된 창` 부터 닫는다.
- `ESC` 를 눌렀을 때 열린 창이 없으면 `SettingsWindow` 를 연다.
- `SettingsWindow` 가 열린 동안만 게임은 pause 된다.
- `SettingsWindow` 를 `ESC` 또는 닫기 버튼으로 닫으면 pause 가 해제된다.
- 모든 주요 창은 우상단 `X` 닫기 버튼을 가진다.
- 창 제목 바를 클릭하면 해당 창이 최상단으로 올라온다.

### 창 위치와 투명도

- 창은 drag 로 이동 가능하다.
- 창 위치는 세션 간 유지한다.
- 저장된 위치가 화면 밖이면 다음 실행 시 화면 중앙으로 보정한다.
- UI 투명도는 `60% ~ 100%` 범위의 전역 slider 로 제공한다.
- 투명도 조절은 창 배경과 프레임에 우선 적용하고, 텍스트/아이콘은 가독성 보장을 위해 완전 동일 비율로 낮추지 않는다.
- focus 를 받은 창은 다른 창보다 약간 더 불투명하게 보여 읽기 우선순위를 준다.

### 인벤토리

- `InventoryWindow` 는 `장비 / 소비 / 기타` 세 탭만 먼저 구현한다.
- 각 탭은 기본 `20칸` 으로 시작한다.
- 초기 레이아웃은 `5 x 4` grid 로 고정한다.
- 아이템은 획득 시 타입에 맞는 탭으로 자동 라우팅된다.
- 사용자는 같은 탭 안에서 drag and drop 으로 자유 재배치할 수 있다.
- 빈칸으로 드롭하면 이동, 다른 아이템 위에 드롭하면 스왑, 허용되지 않는 위치면 원위치로 되돌린다.
- `장비` 아이템은 비스택이다.
- `소비`, `기타` 아이템은 같은 `item_id` 와 동일 메타데이터일 때 스택 가능으로 본다.
- 기본 스택 상한은 item 데이터에 값이 없으면 `9999` 를 기본값으로 사용한다.
- `정리(Organize)` 버튼을 제공해 탭 내부 빈칸을 당겨 왼쪽 위부터 압축한다.
- `더블클릭` 기본 동작은 `장비 아이템 = 장착`, `소비 아이템 = 사용`, `기타 아이템 = 상세 확인만` 으로 잠근다.

### 장비창

- `EquipmentWindow` 는 메이플식 paper-doll 구조를 따른다.
- 좌측에는 캐릭터 실루엣 또는 paper-doll 슬롯, 우측 또는 하단에는 장비 비교/요약 패널을 둔다.
- 장비 슬롯 hover 시 현재 장착 장비 정보가 먼저 보이고, 인벤토리 장비 hover 시 같은 슬롯의 장착 장비와 자동 비교한다.
- 인벤토리의 장비 아이템을 장비 슬롯으로 drag 하면 장착된다.
- 장착 중인 아이템을 인벤토리로 drag 하면 해제된다.
- 장비 슬롯 더블클릭은 해제, 인벤토리 장비 더블클릭은 장착으로 맞춘다.

### 스킬창

- `SkillWindow` 는 메이플처럼 `왼쪽 카테고리`, `중앙 목록`, `오른쪽 상세` 구조를 기본으로 한다.
- 던전 메이지에서는 직업 차수 탭 대신 `school tab + circle/role section` 으로 재해석한다.
- 스킬 hover/선택 시 `이름`, `설명`, `현재 레벨`, `mastery`, `마나`, `쿨다운`, `현재 등록 단축키` 를 보여 준다.
- 등록 가능한 액티브/버프/토글/설치 스킬은 hotkey 등록 버튼과 drag-to-bind 둘 다 지원한다.
- 현재 구현은 `SkillWindow -> KeyBindingsWindow`, `SkillWindow -> HUD quickslot` direct drop bind 까지 닫혔다.

### 스텟창

- `StatWindow` 는 메이플의 character info/detail 감각을 따르되, 현재 프로젝트에는 수동 AP 분배를 넣지 않는다.
- 기본 표시 항목은 `max_hp`, `max_mp`, `magic_attack`, `defense`, `mana_regen`, `cooldown_recovery`, `cast_speed 관련 수치`, `element/resonance 요약` 이다.
- 기본은 요약 모드로 열고, 상세 패널에서 파생 수치를 추가로 본다.

### 퀘스트창

- `QuestWindow` 는 메이플식 `진행 가능 / 진행 중 / 완료` 3탭을 기본으로 한다.
- 상단에는 검색창을 둔다.
- `현재 지역 관련 퀘스트만 보기` 필터를 둔다.
- 현재 프로젝트에 full quest runtime 이 없으므로, 초기 구현은 빈 상태 문구와 future hook 까지만 제공한다.

### 단축키 등록 UX

- 메이플식 관례를 따라 `Key Bindings` 창을 별도로 두고 drag-and-drop 등록을 지원한다.
- 현재 구현은 `선택 등록 버튼 + direct drop + 허용 키 직접 입력` 을 canonical UX로 둔다.
- hotkey slot 우클릭은 등록 해제로 사용한다.
- 충돌 키에 등록하면 기존 키와 `swap` 하는 정책을 기본으로 한다.
- key binding preset 저장은 Maple reference 에는 존재하지만, 이번 범위에서는 `단일 preset` 만 먼저 지원한다.

### 기타 UI 상호작용

- 창에는 기본적으로 minimize 대신 `close` 를 우선 제공한다.
- 인벤토리처럼 화면 점유가 큰 창은 후속 증분에서 `fold/unfold` 를 지원할 수 있게 구조를 열어 둔다.
- HUD tooltip 은 hover 슬롯 근처에 띄우고, 화면 밖으로 나가면 좌/하 방향으로 뒤집는다.
- drag 중인 아이템은 반투명 ghost icon 으로 보여 준다.
- modal dialog 는 `hotkey 등록 대기`, `아이템 버리기`, `설정 초기화` 같은 위험 동작에만 사용한다.

## 자산 전략

메이플식 UI는 `기능만` 보면 Godot 기본 `Control` 로 충분하지만, `완성도 높은 비주얼` 을 만들려면 결국 UI 스킨 에셋이 필요하다.

이번 계획의 자산 전략은 아래 순서를 따른다.

1. 기능 우선 단계에서는 기존 `pixel_rpg` UI 텍스처와 임시 `StyleBoxFlat` 으로 레이아웃/상호작용을 먼저 잠근다.
2. 비주얼 통합 단계에서 전용 `9-slice` 창 프레임, 탭, 버튼, 슬롯, slider, checkbox, close icon 에셋을 교체한다.
3. 아이템/스킬 아이콘은 기존 placeholder를 유지할 수 있지만, 창 프레임 계열은 전용 에셋으로 교체해야 메이플식 읽힘이 나온다.

### 최소 필요 UI 에셋 목록

- `window_frame_9slice`
- `window_title_bar`
- `tab_active`, `tab_inactive`, `tab_hover`
- `button_normal`, `button_hover`, `button_pressed`, `button_disabled`
- `slot_empty`, `slot_hover`, `slot_selected`, `slot_locked`
- `scroll_track`, `scroll_thumb`
- `checkbox_on`, `checkbox_off`
- `slider_track`, `slider_fill`, `slider_knob`
- `close_button`
- `hotkey_badge`
- `cursor_pointer`
- UI 전용 비트맵 폰트 또는 현재 폰트 대체안

## 기술 방향

### 씬 구조

현재 [`scenes/main/Main.tscn`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn) 의 `CanvasLayer/GameUI` 단일 구조를 아래 3계층으로 재편한다.

1. `HudLayer`
2. `WindowLayer`
3. `ModalLayer`

권장 루트 구조:

```text
CanvasLayer
  GameUIRoot
    HudLayer
    WindowLayer
    ModalLayer
    TooltipLayer
```

### 코드 책임 분리

- `game_ui.gd` 는 HUD coordinator 역할만 남긴다.
- 새 `window_manager.gd` 가 창 open/close, z-order, drag, focus, modal block를 담당한다.
- 창별 로직은 `windows/` 로 분리한다.
- 공용 버튼/슬롯/탭/설정행은 `widgets/` 로 분리한다.
- 렌더링 상태와 persistence는 UI 전용 상태 객체가 담당한다.

### 상태 저장 방향

- `GameState` 는 플레이어 진행도, 장비, hotbar, action registry 저장을 계속 담당한다.
- 새 `UiState` autoload 를 추가해 창 상태와 설정 상태를 분리한다.
- 오디오/밝기/창 위치 같은 환경 설정은 `user://ui_settings.cfg` 같은 `ConfigFile` 로 분리 저장한다.
- 캐릭터 의존 정보인 action hotkey registry 와 quickslot assignment 는 savegame 쪽에 둔다.

### 오디오/밝기/이펙트 설정 방향

- 음악/효과음은 Godot `AudioServer` bus 분리로 제어한다.
- 밝기는 2D 전용 fullscreen 조절 레이어로 구현한다.
- 이펙트 투명도는 projectile/effect spawn 시 읽는 공통 multiplier 로 구현한다.
- 특수효과 on/off 는 `screen shake`, `flash`, `fullscreen overlay`, `afterimage` 계열 toggle을 포함하는 묶음 옵션으로 정의한다.

### 메이플식 구현 참고 메모

외부 자료를 확인한 뒤 이번 문서에 반영한 기준은 아래와 같다.

- 공식/공인 가이드에서 `Q = Quest Log`, `I = Item Inventory`, `S = Character Info`, `K = Skill` 같은 창 접근 규칙을 확인했다.
- 공식 지원/가이드에서 `Key Bindings` 는 drag-and-drop 으로 스킬과 사용 아이템을 배치하고, 우클릭 또는 재배치로 비우는 흐름을 사용한다.
- 메이플 계열 가이드에서 인벤토리는 `Equipment / Use / Etc` 를 포함한 타입별 탭과 `organize / expand` 계열 하단 버튼 흐름을 사용한다.
- 커뮤니티/패치 노트 계열 참고에서는 `skill transparency`, `window off-screen recenter`, `quickslot relocate/fold` 같은 운영 관례를 확인했다.
- `ESC` 가 항상 완전히 일관된 전역 close 로 동작하는지는 버전 차이가 있어, 이 문서의 `ESC topmost close` 규칙은 Maple-like UX 를 위해 의도적으로 더 엄격하게 잠근 구현 결정이다.

## 권장 파일 구조

### 신규 파일

- `scripts/autoload/ui_state.gd`
- `scripts/ui/window_manager.gd`
- `scripts/ui/windows/settings_window.gd`
- `scripts/ui/windows/inventory_window.gd`
- `scripts/ui/windows/skill_window.gd`
- `scripts/ui/windows/equipment_window.gd`
- `scripts/ui/windows/stat_window.gd`
- `scripts/ui/windows/quest_window.gd`
- `scripts/ui/widgets/ui_window_frame.gd`
- `scripts/ui/widgets/ui_slot_button.gd`
- `scripts/ui/widgets/ui_tab_button.gd`
- `scripts/ui/widgets/ui_setting_slider_row.gd`
- `scripts/ui/widgets/ui_hotkey_assign_dialog.gd`
- `scenes/ui/windows/SettingsWindow.tscn`
- `scenes/ui/windows/InventoryWindow.tscn`
- `scenes/ui/windows/SkillWindow.tscn`
- `scenes/ui/windows/EquipmentWindow.tscn`
- `scenes/ui/windows/StatWindow.tscn`
- `scenes/ui/windows/QuestWindow.tscn`
- `scenes/ui/widgets/*.tscn`
- `tests/test_ui_window_manager.gd`
- `tests/test_ui_settings_window.gd`
- `tests/test_ui_inventory_window.gd`
- `tests/test_ui_skill_window.gd`
- `tests/test_ui_equipment_window.gd`
- `tests/test_ui_stat_window.gd`
- `tests/test_ui_quest_window.gd`

### 기존 파일 수정 예정

- [`project.godot`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/project.godot)
- [`scenes/main/Main.tscn`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scenes/main/Main.tscn)
- [`scripts/ui/game_ui.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)
- [`scripts/admin/admin_menu.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/admin/admin_menu.gd)
- [`scripts/autoload/game_state.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/autoload/game_state.gd)
- [`tests/test_game_ui.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_ui.gd)
- [`tests/test_game_state.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_state.gd)
- [`tests/test_player_controller.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd)
- [`tests/test_admin_menu.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd)

## 단계별 작업 계획

## Phase 0. 기준선 잠금

### 목표

현재 HUD, admin menu, hotbar/input/save 구조를 문서 기준으로 한 번 더 잠그고 신규 UI 이행 경계를 확정한다.

### 작업

- 현재 `HUD`, `admin menu`, `visible hotbar`, `equipment inventory` 의 실제 런타임 상태를 baseline 으로 정리한다.
- 새 창 시스템으로 이동해도 `admin sandbox` 는 유지하고, 플레이어용 UI와 관리자 UI를 혼동하지 않도록 책임을 분리한다.
- `quest` 는 아직 full quest runtime 이 없으므로 이번 마이그레이션에서 `window shell + empty state + future hook` 까지만 목표로 잠근다.
- `stat` 은 캐릭터 수치 집계 창으로 먼저 정의하고, 별도 성장 시스템 확장은 후속으로 미룬다.

### 산출물

- 현재 문서 유지
- 신규 계획 문서 본문 잠금

## Phase 1. UI 기반 계층 만들기

상태: 완료

### 목표

다중 창 UI 를 붙일 수 있는 공통 기반을 먼저 만든다.

### 작업

- `UiState` autoload 추가
- `WindowManager` 추가
- `Main.tscn` 의 `CanvasLayer` 를 `HudLayer / WindowLayer / ModalLayer / TooltipLayer` 로 분리
- 창 공통 shell widget, 공통 tab button, 공통 slot button, 공통 tooltip 구성
- 드래그 가능한 title bar 와 close button 공통 처리

### acceptance criteria

- 빈 창 2개 이상을 동시에 띄울 수 있다.
- 클릭한 창이 앞으로 올라온다.
- modal 창이 뜨면 뒤 창 입력이 막힌다.
- drag 로 창 위치를 바꿀 수 있다.

### 2026-04-09 구현 메모

- `UiState` 가 `user://ui_settings.cfg` 에 창 위치와 UI 설정을 저장한다.
- `WindowManager` 가 `InventoryWindow`, `SkillWindow`, `SettingsWindow` open/close, topmost close, focus, opacity를 관리한다.
- `CanvasLayer` 에 `GameUI`, `WindowLayer`, `ModalLayer`, `TooltipLayer` 가 실제로 분리됐다.
- acceptance 기준 검증은 [`tests/test_ui_window_manager.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_window_manager.gd) 로 잠갔다.

## Phase 2. 입력 체계와 저장 구조 마이그레이션

상태: 진행 중

### 목표

현재 visible hotbar shortcut 구조를 `고정 허용 키 화이트리스트 + primary quickslot + extended registry` 모델로 재구성한다.

### 작업

- `GameState.DEFAULT_VISIBLE_HOTBAR_KEYCODES` 교체
- 신규 canonical key order 정의
- `action_hotkey_registry` 저장 구조 추가
- 기존 `13슬롯 hotbar` 위에 `V/A/S/D/F/Shift/Ctrl/Alt` 8슬롯 확장 registry를 얹고, `get_action_hotkey_registry()`가 최종 21슬롯 view를 노출하게 정리
- reserved window key guard 추가
- `SHIFT`, `CTRL`, `ALT` 단독 입력 처리 guard 추가

### acceptance criteria

- 신규 세이브는 `1~0` 을 primary quickslot 기본값으로 쓴다.
- 허용되지 않은 키는 등록되지 않는다.
- 기존 save 는 로드 시 깨지지 않는다.
- 충돌 키 등록 시 swap 또는 reject 정책이 문서대로 일관되게 동작한다.

### 2026-04-09 구현 메모

- visible hotbar 기본값 `1~0`, window reserved key `ESC / I / K / E / T / Q`, `admin_menu = F8` 가 실제 입력 맵에 반영됐다.
- `Q/T` 충돌을 피하기 위해 기본 buff row 일부는 `Z / X / C / V` 로 재배치됐고, 이후 `A / S / D / F / Shift / Ctrl / Alt` 확장 row까지 고정됐다.
- `GameState` 는 `action_hotkey_registry` 저장 필드를 추가했고, `spell_manager` 의 keyboard combat primary input 은 이제 visible 10슬롯 + hidden `Z/X/C` + 확장 8슬롯을 합친 `21슬롯 fixed action registry` 를 읽는다.
- `SkillWindow`/`KeyBindingsWindow` 가 허용 키 화이트리스트 UI를 실제로 제공한다.

## Phase 3. HUD 를 창 시스템과 분리

### 목표

전투 HUD 를 유지하면서 메뉴형 UI 와 독립 동작하도록 분리한다.

### 작업

- `game_ui.gd` 에서 메뉴형 창 관련 책임 제거
- HUD 는 `warning row`, `resource cluster`, `primary quickslot`, `buff row`, `tooltip anchor` 만 유지
- 창 UI 와 HUD tooltip/drag path 가 섞이지 않도록 입력 경로 분리
- HUD 숨김 상태와 창 UI 노출 상태를 별도 토글로 관리

### acceptance criteria

- 전투 HUD 는 기존 기능을 유지한다.
- 창을 연 상태에서도 HUD 업데이트는 정상 동작한다.
- 창 hover 와 HUD hover 가 동시에 활성화되지 않는다.

## Phase 4. 인벤토리창과 장비창 마이그레이션

상태: 진행 중

### 목표

현재 admin 중심 장비/인벤토리 표현을 플레이어 창으로 승격한다.

### 작업

- `InventoryWindow` 에 grid inventory, 탭, tooltip, 선택/hover 상태 추가
- `EquipmentWindow` 에 장비 슬롯 시각 배치, 장착/해제/비교 요약 추가
- admin menu 에 있던 장비 시각 패널/선택 로직 중 재사용 가능한 부분을 widget 으로 추출
- `double click equip/use`, `drag and drop`, `right click quick action` 규칙 정의
- 장비창과 인벤토리창 간 아이템 이동 경로 연결

### acceptance criteria

- `I` 와 `E` 로 각각 독립 창을 띄울 수 있다.
- 아이템 선택, slot/owned-item hover compare + tooltip, drag/drop, double click equip/use 가 동작한다.
- 장비 비교 요약이 현재 `GameState` 장비 수치와 일치한다.

### 2026-04-09 구현 메모

- `InventoryWindow` 는 `장비 / 소비 / 기타` 3탭과 `5x4 = 20칸` grid shell 위에 장비/소비/기타 인벤토리 실데이터 셀 바인딩, 상세 패널, `정리 / 장착/사용 / 장비창` action row 가 추가됐다.
- 장비 탭은 현재 `20칸 fixed sparse equipment_inventory` 모델을 직접 읽으므로 drag-and-drop 은 `occupied cell swap + explicit empty-slot move` 범위까지 닫혔다.
- `소비 / 기타` 탭은 `consumables.json`, `other_items.json`, `GameDatabase` catalog, `GameState` stack inventory save field를 통해 런타임 셀을 읽고, stack merge / organize / 사용 / 상세 확인까지 현재 코드와 테스트로 잠겼다.
- 검증은 [`tests/test_ui_inventory_window.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_inventory_window.gd) 에서 탭/슬롯/카운트/사용/stack merge 기준으로 잠갔다.

## Phase 5. 스킬창, 스텟창, 퀘스트창 마이그레이션

상태: 진행 중

### 목표

플레이어 정보 창 3종을 메이플식 구조로 분리한다.

### 작업

- `SkillWindow`: school/category tab, skill list, 상세 패널, level/mastery read, hotkey 등록 버튼, drag payload
- `StatWindow`: 현재 스탯 요약, 장비 반영 수치, 핵심 파생 수치, 현재 빌드 요약
- `QuestWindow`: 진행 중 / 완료 / 비활성 탭 구조, 현재는 empty state + future quest hook 포함
- `SkillWindow` 에서 extended action key 등록 UI와 `Key Bindings` / `HUD quickslot` direct drag source 제공

### acceptance criteria

- `K`, `T`, `Q` 로 창을 독립 토글할 수 있다.
- 스킬창에서 hotkey 등록 UI 가 열린다.
- 스텟창이 현재 장비/버프 기반 집계 수치를 보여 준다.
- 퀘스트창은 최소한 깨지지 않는 placeholder shell 을 제공한다.

### 2026-04-09 구현 메모

- `StatWindow` 는 현재 HP/MP/마나 재생/서클, 장비 반영 파생 수치, 공명 요약을 실제 렌더링한다.
- `QuestWindow` 는 `진행 가능 / 진행 중 / 완료` 3탭, 검색, `현재 지역만` 필터, empty state + future hook shell 을 실제 제공한다.
- `SkillWindow` 는 학교 카테고리, 전투 스킬 목록, 상세 패널, 현재 등록 키 요약, `키 등록` 진입 버튼, direct drag payload 를 실제 제공한다.
- `KeyBindingsWindow` 는 21개 고정 슬롯과 pending skill 등록/우클릭 해제, direct drop bind, 허용 키 직접 입력 등록을 실제 제공한다.
- HUD primary quickslot row 는 기존 `좌클릭 cast / 우클릭 clear / drag swap` 에 더해 `SkillWindow` direct drop bind 와 hover-near tooltip edge flip 을 실제 제공한다.
- `skill_visual_helper.gd` 가 학교별 pseudo-icon texture 와 drag ghost preview 를 제공하고, 현재 `SkillWindow`, `KeyBindingsWindow`, HUD quickslot 이 이를 공통 사용한다.
- 검증은 [`tests/test_ui_player_windows.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_player_windows.gd) 와 [`tests/test_ui_window_manager.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_window_manager.gd) 로 잠갔다.

## Phase 6. 설정창과 환경 설정 persistence

상태: 진행 중

### 목표

메이플식 설정창과 실제 적용되는 옵션 경로를 완성한다.

### 작업

- `SettingsWindow` 에 audio, graphics, effects, HUD 탭 추가
- 최소 옵션:
  - `music_volume`
  - `sfx_volume`
  - `effect_visibility`
  - `effect_opacity`
  - `ui_opacity`
  - `brightness`
  - `screen_shake_enabled`
  - `show_primary_action_row`
  - `show_active_buff_row`
- `AudioServer` bus 연결
- 밝기 overlay 연결
- effect opacity multiplier 를 projectile/effect 생성 경로에 연결
- `ConfigFile` 저장/로드 구현

### acceptance criteria

- `ESC` 로 설정창을 열고 닫을 수 있다.
- 옵션 변경이 즉시 적용된다.
- 재실행 후 옵션이 유지된다.

### 2026-04-09 구현 메모

- `SettingsWindow` 에 `오디오 / 그래픽 / 효과` 탭과 슬라이더/체크박스 row가 실제로 추가됐다.
- `ui_opacity` 는 창 프레임 opacity에, `brightness` 는 `Main` 의 world dim overlay에, `effect_opacity` 는 projectile/buff/toggle visual alpha에 연결됐다.
- `special_effects` 는 soul risk overlay / world release overlay 억제에, `screen_shake` 는 player camera shake 억제에 연결됐다.
- `music_volume`, `sfx_volume` 는 `UiState` persistence와 bus-if-present 적용만 먼저 닫혔다.
- 검증은 [`tests/test_ui_settings_window.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_settings_window.gd), [`tests/test_game_ui.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_ui.gd), [`tests/test_main_integration.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_main_integration.gd), [`tests/test_player_controller.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_player_controller.gd), [`tests/test_spell_manager.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_spell_manager.gd) 로 잠갔다.

## Phase 7. 비주얼 스킨 교체와 폴리시

### 목표

임시 Control 기반 UI를 실제 메이플식 스킨으로 치환한다.

### 작업

- 임시 `StyleBoxFlat` 을 전용 UI 에셋으로 교체
- `Theme` 리소스 또는 공통 theme builder 로 스타일 통합
- hover, selected, disabled, locked, active tab 상태 색/두께 규칙 통일
- 창 열기/닫기, 탭 전환, 슬롯 강조 애니메이션은 짧고 명확한 motion 으로 제한

### acceptance criteria

- 창 프레임/탭/슬롯이 같은 비주얼 언어를 공유한다.
- 관리자 메뉴만 튀는 별도 스타일로 남지 않는다.
- placeholder 느낌 없이 일관된 마감이 난다.

### 2026-04-10 구현 메모

- `scripts/ui/widgets/ui_window_frame.gd` 는 procedural textured shell helper 를 추가해 gloss/stripe/shadow가 들어간 `StyleBoxTexture` panel style 을 공통 생성한다.
- `scripts/ui/windows/inventory_window.gd`, `scripts/ui/windows/equipment_window.gd` 는 panel shell 과 slot shell 을 textured style 로 통일했다.
- `scripts/ui/windows/skill_window.gd`, `scripts/ui/windows/key_bindings_window.gd` 는 핵심 panel 을 textured shell 로 통일했다.
- `scripts/ui/windows/settings_window.gd` row card 도 textured panel surface 로 올라왔고, 기존 custom slider/checkbox skin 계약은 유지된다.
- 같은 날짜 follow-up으로 `scripts/admin/admin_menu.gd` 도 `UiWindowFrame` helper 를 재사용해 textured outer shell, tab shell, accent-aware action button skin 을 적용했다.
- 같은 날짜 follow-up으로 `scripts/ui/widgets/ui_window_frame.gd` 는 `assets/ui/pixel_rpg/Settings.png` frame region 과 `assets/ui/pixel_rpg/Buttons.png` close-button state atlas 를 직접 읽는 asset-backed shared shell 로 올라왔다.
- 같은 follow-up으로 `scripts/admin/admin_menu.gd` outer shell 과 tab shell 도 같은 atlas-backed shared frame style 을 사용한다.
- 같은 날짜 follow-up으로 `scripts/ui/game_ui.gd` 는 HUD quickslot outer frame 과 slot shell 을 `assets/ui/pixel_rpg/Action_panel.png` atlas region 기반 `StyleBoxTexture` 로 전환했다.
- 같은 날짜 다음 follow-up으로 `scripts/ui/windows/inventory_window.gd` 는 inventory grid panel 을 compact atlas shell 로, slot shell 을 `Action_panel.png` atlas 기반 `StyleBoxTexture` 로 전환했다.
- 같은 follow-up으로 `scripts/ui/windows/skill_window.gd`, `scripts/ui/windows/key_bindings_window.gd` 의 핵심 panel shell 도 shared compact atlas shell 로 전환했다.
- `KeyBindingsWindow` slot state는 hover/selected border 회귀를 깨지 않기 위해 flat border state box 를 유지한다.
- 검증은 [`tests/test_admin_menu.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_admin_menu.gd), [`tests/test_ui_inventory_window.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_inventory_window.gd), [`tests/test_ui_equipment_window.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_equipment_window.gd), [`tests/test_ui_player_windows.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_player_windows.gd), [`tests/test_ui_settings_window.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_ui_settings_window.gd), [`tests/test_game_ui.gd`](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/tests/test_game_ui.gd), 전체 GUT `1291/1291`, `godot --headless --path . --quit` 로 잠갔다.

## Phase 8. owner / friend 문서 통합 마이그레이션

### 목표

기존 병렬 분리 문서를 종료하고 단일 작업 흐름 문서로 전환한다.

### 전환 시점

아래 두 조건이 모두 충족된 뒤에 전환한다.

- `Phase 2` 까지 끝나서 UI 입력/저장 구조가 single-owner 구현으로 굴릴 수 있다.
- 더 이상 `owner_core` 와 `friend_gui` 가 파일 충돌 회피를 위해 분리될 필요가 없다고 판단된다.

### 신규 문서 제안

- `docs/collaboration/workstreams/shared_ui_runtime_workstream.md`
- `docs/collaboration/policies/single_stream_collaboration.md`
- `docs/collaboration/prompts/prompt_template_shared_build.md`

### 마이그레이션 절차

1. 새 shared workstream 문서를 만든다.
2. 첫 전환일에는 기존 `owner_core_workstream.md`, `friend_gui_workstream.md` 를 읽기 전용으로 두고 shared 문서에만 새 로그를 기록한다.
3. `role_split_contract.md` 는 바로 삭제하지 않고 `archived` 또는 `superseded` 상태로 바꾸고 새 policy 로 연결한다.
4. `collaboration/README.md` 의 기본 진입점을 shared 문서 기준으로 갱신한다.
5. `prompt_template_owner_core.md`, `prompt_template_friend_gui.md` 는 archive 또는 legacy prompt 로 내린다.
6. 기존 workstream 문서는 `archive/` 로 롤오버한다.

### shared 문서에 남겨야 할 핵심 항목

- 현재 우선순위
- 현재 런타임 상태
- UI/HUD/데이터 교차 의존
- 다음 구현 handoff
- 검증 상태
- known risk

### 통합 후 삭제하지 말아야 할 것

- owner/friend 시절 아카이브 기록
- 분리 작업 당시의 handoff 흔적
- 기존 prompt 원본

## 구현 우선순위

1. `Phase 1` UI 기반 계층
2. `Phase 2` 입력/저장 구조
3. `Phase 3` HUD 분리
4. `Phase 4` 인벤토리/장비
5. `Phase 5` 스킬/스텟/퀘스트
6. `Phase 6` 설정창
7. `Phase 7` 비주얼 스킨
8. `Phase 8` 협업 문서 통합

## 검증 계획

### 자동 검증

- `godot --headless --path . --quit`
- 관련 GUT:
  - `tests/test_game_ui.gd`
  - `tests/test_game_state.gd`
  - `tests/test_player_controller.gd`
  - `tests/test_admin_menu.gd`
  - 신규 `tests/test_ui_*.gd`

### 수동 검증

- 전투 중 창 열기/닫기
- 창 drag/focus/z-order
- 인벤토리 drag/drop
- 스킬 hotkey 등록
- 설정 저장 후 재실행 복구
- HUD 숨김 상태와 창 UI 동시 동작
- boss combat 중 창 open 시 입력 충돌 여부

## 리스크와 대응

### 1. 현재 `GameState` 비대화

- 리스크: UI 상태까지 계속 `GameState` 에 밀어 넣으면 저장/입력/UI 책임이 뒤섞인다.
- 대응: `UiState` 로 분리하고, `GameState` 는 캐릭터/세이브 canonical 데이터만 유지한다.

### 2. `SHIFT / CTRL / ALT` 단독 입력 불안정성

- 리스크: modifier 키는 OS 포커스, 다른 단축키, editor 환경에서 충돌할 수 있다.
- 대응: standalone press 처리만 허용하고 조합 단축키는 후속 범위로 미룬다.

### 3. 퀘스트 시스템 미구현

- 리스크: `QuestWindow` 가 실제 데이터 없이 껍데기만 남을 수 있다.
- 대응: 이번 범위는 `placeholder shell + future hook` 로 명시하고 full quest runtime 은 별도 plan 으로 분리한다.

### 4. 관리자 메뉴와 플레이어 UI 중복 구현

- 리스크: 같은 장비/인벤토리 표시 로직이 admin 과 player 에서 이중화될 수 있다.
- 대응: 공용 widget 과 공용 view-model helper 를 추출하고 admin/player 가 함께 사용하게 만든다.

### 5. 에셋 지연

- 리스크: 기능은 끝났는데 비주얼 일관성이 늦어질 수 있다.
- 대응: `Phase 1~6` 은 임시 theme 로 먼저 잠그고, `Phase 7` 에서 한 번에 치환한다.

## 외부 참고 링크

- [Keyboard Shortcuts | MapleStory | Grandis Library](https://grandislibrary.com/content/keyboard-shortcuts)
- [How to play MapleStory with a compact keyboard or gamepad | Nexon Support](https://support-maplestory.nexon.com/hc/en-us/articles/6288398730900-How-to-play-MapleStory-with-a-compact-keyboard-or-gamepad)
- [MapleStorySEA Guide: Control](https://www.maplesea.com/guide/control/)
- [MapleStorySEA Guide: User Interface](https://www.maplesea.com/guide/user_interface/)
- [Character Inventory & Wallet Inventory | MapleStory N](https://docs.maplestoryn.io/msn-101/beginners-guide/item-and-equipment/character-inventory-and-wallet-inventory)
- [Controls and Key Settings | MapleStory N](https://docs.maplestoryn.io/msn-101/beginners-guide/get-started/controls-and-key-settings)

## 비목표

- full quest gameplay authoring
- NPC 대화창/상점/제작 UI
- 마우스만으로 모든 전투를 조작하는 시스템 전환
- 자유 텍스트 기반 임의 키 바인딩
- 모바일 UI 대응

## 다음 최소 구현 단위

현재 가장 작은 후속 구현 단위는 `Phase 7` 의 남은 `asset-backed final skin` 을 더 넓혀 `tab/button/slot/hotbar` 까지 확장하는 것이다.

권장 다음 증분:

- `tab/button` atlas 또는 9-slice 후보를 실제 runtime skin contract에 더 넓게 연결
- `SkillWindow` / `KeyBindingsWindow` / `InventoryWindow` 내부 button/tab state 를 atlas-backed final shell 로 치환
- hotbar text-first shell 위에 올라가는 final icon atlas pass 를 연결
- 남은 수동 검증 항목 중 `boss combat 중 창 open 입력 충돌` 을 실제 플레이 체크리스트로 닫기

이 후속 증분이 끝나면 UI 마이그레이션은 사실상 `final asset pass + QA polish` 단계로 넘어간다.

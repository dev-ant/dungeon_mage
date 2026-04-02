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
last_updated: 2026-04-02
last_verified: 2026-04-02
---

# 전투 6차 작업 체크리스트 - 전투 UI 구축

상태: 사용 중
최종 갱신: 2026-03-30
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

## 현재 구현 상태

### 완료

- [game_ui.gd](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/scripts/ui/game_ui.gd)에서 HP/MP 표시
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

- 슬롯별 쿨타임을 더 시각적으로 읽히게 정리
- 관리자 상태를 `자원 / 전투 / 장비`처럼 영역별로 분리
- `Soul Dominion` 리스크 전용 HUD 추가
- 데미지 로그 또는 최근 피격 원인 표시
- 핫바/버프/장비 슬롯에 대한 마우스 hover, click, double-click 상호작용 추가
- 키보드 단축키와 동일 기능을 수행하는 마우스 조작 경로 추가
- 메이플스토리식 슬롯 선택, 툴팁, 오버레이 반응 규칙 정리 및 구현
- HP/MP를 그래픽 바 + 수치 조합으로 표시하는 HUD 확정
- 텍스트 나열형 핫바를 아이콘/쿨타임 오버레이/선택 테두리가 있는 그래픽 핫바로 전환
- 버프/디버프를 아이콘 기반 GUI로 전환
- 현재 텍스트 중심 HUD를 최종 GUI HUD로 교체
- `Action_panel.png`를 기준으로 핫바/리소스 패널 프레임을 실제 HUD 씬에 연결
- `Buttons.png`를 기준으로 핫바 버튼, 슬롯 버튼, 상태 버튼의 스타일 박스를 정리

### 새로 확정된 기준 (2026-03-29, 아직 미구현)

- 전투 HUD에서 조작 가능한 슬롯은 키보드 단축키와 별개로 마우스로도 클릭 가능해야 한다.
- 슬롯 hover 시 스킬명, 쿨타임, 자원 비용, 현재 상태를 읽을 수 있는 툴팁 또는 동등한 상세 표시가 떠야 한다.
- 더블클릭 또는 우클릭처럼 메이플스토리식 슬롯 상호작용이 필요한 경우, 키보드 경로와 충돌 없이 병행되어야 한다.
- HP/MP는 숫자만 따로 보여주는 방식이 아니라, 그래픽 바와 현재/최대 수치가 함께 보이는 GUI여야 한다.
- 스킬, 버프, 장비 관련 HUD는 텍스트 줄이 아니라 아이콘과 프레임이 보이는 그래픽 슬롯 기반 GUI여야 한다.
- 현재의 텍스트형 HUD 요소들은 최종 형태가 아니라 임시 구현으로 간주한다.
- 현재 HUD는 부분적으로 클릭 가능해도, 지정된 UI PNG를 사용한 완성형 GUI로는 아직 간주하지 않는다.
- 현재 문서의 완료 목록에는 이 기능이 포함되어 있지 않으며, 다음 구현 작업에서 실제로 만들어야 한다.

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

### UI 상호작용 요구사항 추가 반영분 (우선 구현 필요)

- 현재 텍스트 요약 위주의 HUD를 유지하더라도, 상호작용이 필요한 슬롯은 `Control` 기반 hit area를 가져야 한다.
- 핫바와 버프 영역에 마우스 hover / click / double-click 기준을 추가하고, 키보드 단축키와 같은 실행 결과를 보장한다.
- 툴팁, 선택 상태, hover 상태가 키보드 포커스와 충돌하지 않도록 상태 동기화 규칙을 만든다.
- 다음 단계에서는 텍스트 표시를 유지보수용 fallback으로만 두고, 실제 플레이어용 출력은 그래픽 바/아이콘/프레임 GUI로 옮기는 것을 목표로 한다.
- 이 항목들은 2026-03-29에 문서에 먼저 추가된 요구사항이며 아직 구현되지 않았음을 전제로 작업한다.

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

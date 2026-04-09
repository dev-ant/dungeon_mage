---
title: 전투 HUD GUI 상태 스키마
doc_type: schema
status: active
section: implementation
owner: shared
source_of_truth: true
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md
update_when:
  - handoff_changed
  - rule_changed
  - validation_changed
last_updated: 2026-04-09
last_verified: 2026-04-09
---

# 전투 HUD GUI 상태 스키마

상태: 사용 중  
최종 갱신: 2026-04-07  
섹션: 구현 기준

## 목적

이 문서는 전투 HUD 그래픽 GUI 구현에서 고정해야 하는 레이아웃 상태, 상호작용 상태, 설정 토글 필드를 기계적으로 정리한다.

## 레이아웃 계약

| 키 | 타입 | 허용값 / 구조 | 의미 |
| --- | --- | --- | --- |
| `read_priority` | enum | `target_first_resources_second_hotbar_third` | 플레이어 시선 우선순위 |
| `target_panel.priority` | enum | `primary` | 대상 HP 패널은 가장 먼저 읽히는 정보여야 한다 |
| `player_resource_cluster.anchor` | enum | `bottom_center` | HP/MP/캐릭터 정보 묶음 위치 |
| `player_resource_cluster.contents` | list | `hp_bar`, `mp_bar` | 하단 중앙 자원 묶음 구성 |
| `player_resource_cluster.orientation` | enum | `vertical_hp_then_mp` | HP 위, MP 아래 2열 배치 |
| `player_resource_cluster.visual_style` | enum | `no_card_slim_bars` | 카드 프레임 없이 얇은 HP/MP 바만 유지 |
| `player_resource_cluster.warning_rule` | enum | `mp_bar_contextual_tint` | Soul Dominion 상태일 때 MP 바 색으로 위험도 보강 |
| `warning_status_row.anchor` | enum | `top_left` | 최근 피격 / Soul Dominion 같은 즉시 경고 위치 |
| `warning_status_row.contents` | list | `recent_damage`, `soul_risk` | 상단 경고 줄 구성 |
| `warning_status_row.visual_rule` | enum | `soul_risk_contextual_tint_and_aftershock_pulse` | Soul Dominion active / aftershock 상태에 따라 경고 줄 색과 맥동이 달라짐 |
| `screen_edge_overlay.anchor` | enum | `full_screen_border` | Soul Dominion 리스크용 화면 가장자리 오버레이 위치 |
| `screen_edge_overlay.visual_rule` | enum | `active_red_border_aftershock_amber_pulse` | active는 진한 red border, aftershock는 amber pulse border |
| `active_status_row.anchor` | enum | `bottom_left` | 공명 / 버프 / 콤보 / 활성 버프 chip 묶음 위치 |
| `active_status_row.width_policy` | enum | `narrow_quarter_panel` | 좌하단 좁은 폭 패널로 시야 가림 최소화 |
| `primary_action_row.slot_count` | int | `10` | 플레이어 노출용 액션 핫바 칸 수 |
| `primary_action_row.semantic` | enum | `user_registerable_action_row` | 사용자가 원하는 엔트리를 등록하는 row |
| `primary_action_row.allowed_content_types` | list | `active`, `buff`, `toggle`, `deploy`, `item` | 같은 row에 올라갈 수 있는 엔트리 타입 |
| `primary_action_row.visible_only_count` | int | `10` | HUD에 실제로 보이는 슬롯 수 |
| `primary_action_row.binding_policy` | enum | `fixed_whitelist_with_registry` | HUD primary row는 `1~0` 고정, 전체 전투 키는 whitelist registry에서만 등록 |
| `extended_action_registry.slot_count` | int | `21` | `1~0, Z/X/C/V, A/S/D/F, Shift/Ctrl/Alt` 전체 fixed action slot 수 |
| `extended_action_registry.save_field` | string | `action_hotkey_registry` | hidden/extended action row canonical payload key |
| `legacy_binding_model` | enum | `legacy_13_hotbar_plus_8_extended_registry` | 13슬롯 hotbar + 8슬롯 확장 registry가 현재 canonical runtime |
| `save_model` | enum | `canonical_10_slot_save` | 액션 바 저장 기준은 10슬롯 |
| `save_model.visible_shortcuts_field` | string | `visible_hotbar_shortcuts` | visible 10슬롯 shortcut canonical payload key |

## HUD 설정 토글

| 키 | 타입 | 기본값 | 의미 |
| --- | --- | --- | --- |
| `show_primary_action_row` | bool | `true` | 10칸 액션 핫바 row 표시 여부 |
| `show_active_buff_row` | bool | `true` | 활성 버프/디버프 row 표시 여부 |
| `hide_row_keeps_keyboard_input` | bool | `true` | HUD를 숨겨도 키보드 전투 입력은 유지 |

## 현재 런타임 메모

- `scripts/ui/game_ui.gd`는 현재 상단 좌측에 primary target panel을 렌더하지만, source는 `상단 보스 체력바를 써야 하는 살아 있는 적`으로 제한한다. 현재 canonical rule은 `boss -> 상단 panel`, `non-boss -> 월드 체력바`다.
- 상단 좌측 텍스트 줄은 이제 `방 제목`, `즉시 경고`, `관리자 디버그`만 유지하고, 중복 `HP/MP 숫자`와 `스킬 mastery` 줄은 숨긴다.
- 즉시 경고 줄은 `최근 피격`과 `Soul Dominion 리스크`만 노출하고, 경고가 없으면 줄 자체를 숨긴다.
- `Soul Dominion`이 활성일 때 즉시 경고 줄은 더 붉은 tint를 사용하고, `aftershock`일 때는 더 밝은 amber tint가 미세하게 pulse한다.
- 하단 중앙 자원 묶음은 카드 프레임과 상단 정보 텍스트를 제거하고, 얇은 HP/MP 바만 남긴다.
- 얇은 자원 바는 `HP 위 / MP 아래` 세로 2열로 두고, 화면 중앙 맨아래에 고정한다.
- MP 바는 평소 blue, `Soul Dominion active`일 때 deep red, `aftershock`일 때 amber pulse로 바뀌어 리스크 상태를 보조하고, 리스크 종료 직후에는 짧은 amber-to-blue clear beat로 복귀를 닫는다.
- `Soul Dominion` 리스크가 있으면 화면 가장자리 `border overlay`도 함께 켜진다. active는 더 두껍고 진한 red border, aftershock는 더 얇은 amber border가 미세 pulse하는 쪽을 current runtime read로 잠그고, 안전 상태로 돌아갈 때는 아주 짧은 fade-out beat 뒤에 꺼진다.
- 같은 해제 타이밍에 `scripts/main/main.gd`는 HUD 뒤쪽 canvas layer에서 아주 약한 cool-blue full-screen wash를 짧게 깜빡여, UI와 플레이어 오라 밖에서도 위험 해제 감각을 한 번 더 닫는다.
- 같은 `scripts/main/main.gd`는 player camera zoom도 active/aftershock/clear에 따라 아주 얕게 바꾼다. active는 소폭 인줌, aftershock는 기본값 쪽으로 천천히 이완, clear는 짧은 아웃줌 복귀를 써서 시선 템포도 위험 단계와 같이 읽히게 한다.
- 같은 2026-04-07 후속 기준으로 `scripts/enemies/enemy_base.gd`의 enemy hit flash도 `Soul Dominion` 리스크 단계를 읽는다. active 중 적 피격 flash는 더 차갑고 violet 쪽으로, aftershock 중에는 더 따뜻하고 부드러운 flash 쪽으로 이동해 월드 전투 read가 HUD / camera / damage label과 같은 위계를 따른다.
- 공명 / 버프 / 콤보 텍스트와 활성 버프 chip row는 하단 좌측의 좁은 패널로 옮긴다.
- `scripts/ui/game_ui.gd`는 현재 local runtime toggle 메서드 `set_show_primary_action_row(bool)`와 `set_show_active_buff_row(bool)`를 제공한다.
- primary action row가 숨겨지면 해당 row는 `visible = false` 상태가 되고, hover tooltip / 우클릭 clear / drag swap 같은 마우스 경로도 같이 빠진다.
- active buff row가 숨겨지면 buff chip panel만 숨기고, active buff 런타임 자체나 keyboard combat input은 바꾸지 않는다.
- 설정창 persistence field나 저장 payload는 아직 연결되지 않았으므로, 현재 hide toggle은 런타임 세션 한정 GUI 상태다.
- `scripts/enemies/enemy_base.gd`는 현재 적 등급 기준으로 월드 체력바 visibility를 분기한다. `boss`는 머리 위 체력바를 숨기고, 일반몹과 엘리트는 머리 위 체력바를 유지한다.

## 슬롯 상호작용 계약

| 키 | 타입 | 허용값 / 구조 | 의미 |
| --- | --- | --- | --- |
| `left_click_action` | enum | `immediate_execute` | 좌클릭 즉시 시전 / 즉시 토글 |
| `right_click_action` | enum | `unbind_shortcut` | 우클릭은 슬롯 해제 / 단축키 언바인드 |
| `hold_action` | enum | `drag_rebind` | 클릭 유지 시 다른 핫바 칸으로 이동 |
| `double_click_action` | enum | `none` | 전투 HUD 기본 동작으로 쓰지 않음 |
| `hover_tooltip_fields` | list | `name`, `cooldown`, `cost`, `description`, `current_state`, `level`, `mastery` | hover 툴팁 필수 정보 |
| `unavailable_visual_state` | enum | `dimmed` | 사용 불가 슬롯의 평상시 시각 상태 |
| `unavailable_feedback` | enum | `short_reason_text` | 실행 시 실패 문구 표시 |
| `selection_sync_policy` | enum | `keyboard_border_persistent_mouse_hover_overlay` | 키보드 선택과 마우스 hover 동기화 규칙 |
| `occupied_drop_resolution` | enum | `swap` | drag-rebind 대상 칸이 차 있으면 스왑 |

## 검증 계약

| 키 | 타입 | 허용값 / 구조 | 의미 |
| --- | --- | --- | --- |
| `verification.headless` | bool | `true` | headless 테스트 통과 필수 |
| `verification.manual_play_passes` | int | `1+` | 최소 1회 수동 플레이 검증 필요 |
| `verification.keyboard_combat_with_hidden_hud` | bool | `true` | HUD 숨김 on/off 상태에서도 키보드 전투 유지 검증 |

## 전환 메모

- 현재 코드와 장기 계획 문서 일부에는 `13키 바인딩` 기준선이 남아 있지만, 이는 레거시 메모다.
- 이번 라운드로 `플레이어 노출용 그래픽 HUD는 사용자 등록형 10칸 액션 row + 별도 활성 버프 row`까지 잠겼다.
- 현재 runtime GUI shell은 top-left primary target panel, visible 10-slot button row, top-left buff chip row, bottom-center resource cluster, tooltip, dimmed unavailable state, right-click clear, drag swap까지 실제 연결됐다.
- `Soul Dominion` 후속 HUD read 기준선은 `scripts/ui/game_ui.gd`가 경고 줄 tint와 MP bar tint를 active/aftershock에 따라 다르게 주고, `aftershock` 중에는 정적인 색이 아니라 미세 pulse를 주는 것이다.
- 같은 기준선에서 `scripts/ui/game_ui.gd`는 `aftershock -> safe` 전환 시 MP bar와 full-screen `border overlay`를 즉시 되돌리지 않고, 약 `0.30초` clear beat 뒤에 neutral blue / hidden 상태로 복귀시킨다.
- 같은 해제 구간에서 `scripts/main/main.gd`는 `SoulRiskReleaseOverlay`를 약 `0.22초` 동안만 보여 주고, alpha를 빠르게 감쇠시켜 화면 전체 release pulse를 남긴다.
- 같은 `scripts/main/main.gd`는 player camera zoom을 `active 0.985x`, `aftershock 0.989x -> 0.996x ease`, `clear 1.006x -> 1.0x`로 운용해 위험 진입과 해제의 시선 압력을 분리한다.
- 현재 save payload는 canonical `spell_hotbar` 10슬롯과 호환용 `legacy_spell_hotbar_tail` 3슬롯을 함께 쓴다.
- explicit `visible_hotbar_shortcuts` payload가 없는 old save는 첫 10슬롯의 legacy `action + label`로 shortcut profile을 복원한다.
- 런타임 내부 배열과 호환 save는 `13슬롯 hotbar + 8슬롯 action registry` 구조를 유지하고, keyboard combat primary input 은 `spell_manager` 기준 `21슬롯 fixed action registry` 전체를 읽는다.

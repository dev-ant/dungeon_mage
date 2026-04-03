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
last_updated: 2026-04-03
last_verified: 2026-04-03
---

# 전투 HUD GUI 상태 스키마

상태: 사용 중  
최종 갱신: 2026-04-03  
섹션: 구현 기준

## 목적

이 문서는 전투 HUD 그래픽 GUI 구현에서 고정해야 하는 레이아웃 상태, 상호작용 상태, 설정 토글 필드를 기계적으로 정리한다.

## 레이아웃 계약

| 키 | 타입 | 허용값 / 구조 | 의미 |
| --- | --- | --- | --- |
| `read_priority` | enum | `target_first_resources_second_hotbar_third` | 플레이어 시선 우선순위 |
| `target_panel.priority` | enum | `primary` | 대상 HP 패널은 가장 먼저 읽히는 정보여야 한다 |
| `player_resource_cluster.anchor` | enum | `bottom_center` | HP/MP/캐릭터 정보 묶음 위치 |
| `player_resource_cluster.contents` | list | `hp_bar`, `mp_bar`, `current_max_values`, `character_info` | 하단 중앙 자원 묶음 구성 |
| `active_status_row.anchor` | enum | `top_left` | 활성 버프/디버프 row 위치 |
| `primary_action_row.slot_count` | int | `10` | 플레이어 노출용 액션 핫바 칸 수 |
| `primary_action_row.semantic` | enum | `user_registerable_action_row` | 사용자가 원하는 엔트리를 등록하는 row |
| `primary_action_row.allowed_content_types` | list | `active`, `buff`, `toggle`, `deploy`, `item` | 같은 row에 올라갈 수 있는 엔트리 타입 |
| `primary_action_row.visible_only_count` | int | `10` | HUD에 실제로 보이는 슬롯 수 |
| `primary_action_row.binding_policy` | enum | `user_rebindable_any_key` | 사용자가 설정에서 원하는 키로 재바인드 가능 |
| `legacy_binding_model` | enum | `legacy_13_key_non_canonical` | 13키 바인딩은 더 이상 canonical 이 아님 |
| `save_model` | enum | `canonical_10_slot_save` | 액션 바 저장 기준은 10슬롯 |
| `save_model.visible_shortcuts_field` | string | `visible_hotbar_shortcuts` | visible 10슬롯 shortcut canonical payload key |

## HUD 설정 토글

| 키 | 타입 | 기본값 | 의미 |
| --- | --- | --- | --- |
| `show_primary_action_row` | bool | `true` | 10칸 액션 핫바 row 표시 여부 |
| `show_active_buff_row` | bool | `true` | 활성 버프/디버프 row 표시 여부 |
| `hide_row_keeps_keyboard_input` | bool | `true` | HUD를 숨겨도 키보드 전투 입력은 유지 |

## 현재 런타임 메모

- `scripts/ui/game_ui.gd`는 현재 상단 좌측에 primary target panel을 렌더하고, target source는 `플레이어와 가장 가까운 살아 있는 적` 휴리스틱을 사용한다.
- `scripts/ui/game_ui.gd`는 현재 local runtime toggle 메서드 `set_show_primary_action_row(bool)`와 `set_show_active_buff_row(bool)`를 제공한다.
- primary action row가 숨겨지면 해당 row는 `visible = false` 상태가 되고, hover tooltip / 우클릭 clear / drag swap 같은 마우스 경로도 같이 빠진다.
- active buff row가 숨겨지면 buff chip panel만 숨기고, active buff 런타임 자체나 keyboard combat input은 바꾸지 않는다.
- 설정창 persistence field나 저장 payload는 아직 연결되지 않았으므로, 현재 hide toggle은 런타임 세션 한정 GUI 상태다.

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
- 현재 save payload는 canonical `spell_hotbar` 10슬롯과 호환용 `legacy_spell_hotbar_tail` 3슬롯을 함께 쓴다.
- explicit `visible_hotbar_shortcuts` payload가 없는 old save는 첫 10슬롯의 legacy `action + label`로 shortcut profile을 복원한다.
- 런타임 내부 배열과 호환 save는 아직 13슬롯을 유지하지만, keyboard combat primary input 은 visible 10슬롯만 canonical 로 읽는다.

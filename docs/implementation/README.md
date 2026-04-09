---
title: 구현 기준 인덱스
doc_type: index
status: active
section: implementation
owner: runtime
source_of_truth: false
parent: /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md
depends_on:
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/ai_update_protocol.md
  - /Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/governance/target_doc_structure.md
update_when:
  - structure_changed
  - runtime_changed
last_updated: 2026-04-10
last_verified: 2026-04-10
---

# 구현 기준 인덱스

상태: 사용 중  
최종 갱신: 2026-04-10

## 범위

이 섹션은 프로젝트 구현 제약과 기술 스택 규칙을 추적합니다.

2026-04-02 기준으로 이 섹션은 `baselines / plans / increments / runbooks` 하위 폴더 1차 분리를 완료했습니다.

이 섹션의 상세 문서 등록 책임은 이 `README.md`가 가집니다. 루트 `docs/README.md`에는 대표 진입점만 유지합니다.

## 섹션 확장 읽기 순서

이 섹션은 [docs/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/README.md) 와 거버넌스 시작 체인을 먼저 읽은 뒤에 해석합니다.

1. [docs/implementation/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/README.md)
2. 넓은 요청이면 [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)
3. 관련 `plans/` 또는 `increments/`
4. 관련 `baselines/`
5. 관련 `progression` 기준 문서

## 섹션 운영 잠금 규칙

- 넓은 요청에서는 `plan`보다 backlog를 먼저 본다.
- 기획이 모호하면 구현보다 먼저 정확히 `10문항` 질문 라운드로 전환한다.
- 반복 작업은 등록된 skill을 먼저 사용한다.
- scene/node/script wiring 확인은 Godot MCP를 먼저 시도한다.

## 문서 목록

### `baselines`

- 현재 구현 기준선: [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md)
- [development_stack.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/development_stack.md)

### `plans`

- [combat_first_build_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/combat_first_build_plan.md)
- [maple_style_ui_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/maple_style_ui_migration_plan.md)
- [dungeon_map_prototype_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/dungeon_map_prototype_plan.md)
- [enemy_data_runtime_migration_plan.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/plans/enemy_data_runtime_migration_plan.md)

### `increments`

- 협업 문맥이 필요한 작업은 [docs/collaboration/README.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/collaboration/README.md) 와 활성 shared workstream 문서를 함께 읽는다.
- [combat_increment_01_player_controller.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_01_player_controller.md)
- [combat_increment_02_spell_runtime.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_02_spell_runtime.md)
- [combat_increment_03_buff_action_loop.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_03_buff_action_loop.md)
- [combat_increment_04_enemy_combat_set.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_04_enemy_combat_set.md)
- [combat_increment_05_equipment_minimum.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_05_equipment_minimum.md)
- [combat_increment_06_combat_ui.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_06_combat_ui.md)
- [combat_increment_07_admin_sandbox.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_07_admin_sandbox.md)
- [combat_increment_08_admin_tabs_and_inventory.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_08_admin_tabs_and_inventory.md)
- [combat_increment_09_soul_dominion_risk.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/combat_increment_09_soul_dominion_risk.md)
- [map_increment_01_floor_4_start_zone.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_01_floor_4_start_zone.md)
- [map_increment_02_floor_6_hub.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_02_floor_6_hub.md)
- [map_increment_03_floor_7_gate.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_03_floor_7_gate.md)
- [map_increment_04_floor_10_core.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_04_floor_10_core.md)
- [map_increment_05_prototype_flow.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_05_prototype_flow.md)
- [map_increment_06_mid_castle_bridge.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_06_mid_castle_bridge.md)
- [map_increment_07_hub_anchor.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_07_hub_anchor.md)
- [map_increment_08_prototype_room_selector.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_08_prototype_room_selector.md)
- [map_increment_09_prototype_flow_preview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_09_prototype_flow_preview.md)
- [map_increment_10_castle_memory_interactions.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_10_castle_memory_interactions.md)
- [map_increment_11_final_covenant_anchor.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_11_final_covenant_anchor.md)
- [map_increment_12_admin_interaction_preview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_12_admin_interaction_preview.md)
- [map_increment_13_hub_reactive_notice.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_13_hub_reactive_notice.md)
- [map_increment_14_admin_reactive_preview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_14_admin_reactive_preview.md)
- [map_increment_15_final_boss_warning_state.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_15_final_boss_warning_state.md)
- [map_increment_16_admin_final_warning_preview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_16_admin_final_warning_preview.md)
- [map_increment_17_admin_progression_chain.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_17_admin_progression_chain.md)
- [map_increment_18_companion_foreshadow_traces.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_18_companion_foreshadow_traces.md)
- [map_increment_19_admin_companion_trace_chain.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_19_admin_companion_trace_chain.md)
- [map_increment_20_gate_lore_chain.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_20_gate_lore_chain.md)
- [map_increment_21_hub_gate_reaction.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_21_hub_gate_reaction.md)
- [map_increment_22_admin_gate_reactive_preview.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_22_admin_gate_reactive_preview.md)
- [map_increment_23_admin_phase_summary.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_23_admin_phase_summary.md)
- [map_increment_24_hub_phase_reactive_notice.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_24_hub_phase_reactive_notice.md)
- [map_increment_25_final_warning_phase_link.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_25_final_warning_phase_link.md)
- [map_increment_26_admin_phase_cross_check.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_26_admin_phase_cross_check.md)
- [map_increment_27_admin_lore_handoff_summary.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_27_admin_lore_handoff_summary.md)
- [map_increment_28_admin_room_phase_notes.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_28_admin_room_phase_notes.md)
- [map_increment_29_admin_room_path_notes.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_29_admin_room_path_notes.md)
- [map_increment_30_admin_room_clue_check.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_30_admin_room_clue_check.md)
- [map_increment_31_admin_room_verification_status.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_31_admin_room_verification_status.md)
- [map_increment_32_admin_room_next_priority.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_32_admin_room_next_priority.md)
- [map_increment_33_admin_room_action_candidates.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_33_admin_room_action_candidates.md)
- [map_increment_34_final_room_echo_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_34_final_room_echo_payoff.md)
- [map_increment_35_throne_echo_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_35_throne_echo_payoff.md)
- [map_increment_36_hub_echo_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_36_hub_echo_payoff.md)
- [map_increment_37_admin_reactive_residue_summary.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_37_admin_reactive_residue_summary.md)
- [map_increment_38_admin_payoff_density.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_38_admin_payoff_density.md)
- [map_increment_39_inner_hall_echo_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_39_inner_hall_echo_payoff.md)
- [map_increment_40_gate_echo_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_40_gate_echo_payoff.md)
- [map_increment_41_entrance_echo_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_41_entrance_echo_payoff.md)
- [map_increment_42_admin_surface_mix.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_42_admin_surface_mix.md)
- [map_increment_43_admin_weakest_link_summary.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_43_admin_weakest_link_summary.md)
- [map_increment_44_final_room_overturned_furnishings_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_44_final_room_overturned_furnishings_payoff.md)
- [map_increment_45_hub_crest_final_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_45_hub_crest_final_payoff.md)
- [map_increment_46_gate_final_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_46_gate_final_payoff.md)
- [map_increment_47_inner_hall_final_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_47_inner_hall_final_payoff.md)
- [map_increment_48_throne_final_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_48_throne_final_payoff.md)
- [map_increment_49_entrance_final_payoff.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_49_entrance_final_payoff.md)
- [map_increment_50_final_payoff_data_regression.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_50_final_payoff_data_regression.md)
- [map_increment_51_room_reactive_surface_summary_api.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_51_room_reactive_surface_summary_api.md)
- [map_increment_52_room_weakest_link_summary_api.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_52_room_weakest_link_summary_api.md)
- [map_increment_53_platform_followups.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_53_platform_followups.md)
- [map_increment_54_floor_segment_override_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_54_floor_segment_override_schema.md)
- [map_increment_55_floor_segment_validation.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_55_floor_segment_validation.md)
- [map_increment_56_floor5_live_floor_segment_dict.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_56_floor5_live_floor_segment_dict.md)
- [map_increment_57_anchor_floor_segment_dict_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_57_anchor_floor_segment_dict_pilot.md)
- [map_increment_58_second_anchor_floor_segment_dict_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_58_second_anchor_floor_segment_dict_pilot.md)
- [map_increment_59_floor_segment_canonical_lock.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_59_floor_segment_canonical_lock.md)
- [map_increment_60_gate_threshold_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_60_gate_threshold_canonical_floor_segment_migration.md)
- [map_increment_61_royal_inner_hall_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_61_royal_inner_hall_canonical_floor_segment_migration.md)
- [map_increment_62_throne_approach_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_62_throne_approach_canonical_floor_segment_migration.md)
- [map_increment_63_inverted_spire_canonical_floor_segment_migration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_63_inverted_spire_canonical_floor_segment_migration.md)
- [map_increment_64_arcane_core_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_64_arcane_core_canonical_floor_segment_pilot.md)
- [map_increment_65_void_rift_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_65_void_rift_canonical_floor_segment_pilot.md)
- [map_increment_66_deep_gate_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_66_deep_gate_canonical_floor_segment_pilot.md)
- [map_increment_67_conduit_canonical_floor_segment_pilot.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_67_conduit_canonical_floor_segment_pilot.md)
- [map_increment_68_vault_sector_canonical_floor_segment_completion.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_68_vault_sector_canonical_floor_segment_completion.md)
- [map_increment_69_floor_segment_legacy_runtime_boundary.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_69_floor_segment_legacy_runtime_boundary.md)
- [map_increment_70_floor_segment_runtime_legacy_removal.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_70_floor_segment_runtime_legacy_removal.md)
- [map_increment_71_floor_segment_tooling_canonical_only.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_71_floor_segment_tooling_canonical_only.md)
- [map_increment_72_floor_segment_format_metadata_retirement.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_72_floor_segment_format_metadata_retirement.md)
- [map_increment_73_floor_segment_canonicalizer_metadata_write_removal.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_73_floor_segment_canonicalizer_metadata_write_removal.md)
- [map_increment_74_floor_segment_format_key_retirement.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_74_floor_segment_format_key_retirement.md)
- [map_increment_75_room_builder_metadata_independence.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_75_room_builder_metadata_independence.md)
- [map_increment_76_floor_segment_legacy_token_alignment.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_76_floor_segment_legacy_token_alignment.md)
- [map_increment_77_floor_segment_validator_parse_canonical_only.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_77_floor_segment_validator_parse_canonical_only.md)
- [map_increment_78_floor_segment_test_helper_canonical_only.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_78_floor_segment_test_helper_canonical_only.md)
- [map_increment_79_floor_segment_test_fixture_helper_lock.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_79_floor_segment_test_fixture_helper_lock.md)
- [map_increment_80_floor_segment_canonicalizer_helper_delegation.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_80_floor_segment_canonicalizer_helper_delegation.md)
- [map_increment_81_floor_segment_canonicalizer_execution_seam.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_81_floor_segment_canonicalizer_execution_seam.md)
- [map_increment_82_floor_segment_canonicalizer_cli_match_seam.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_82_floor_segment_canonicalizer_cli_match_seam.md)
- [map_increment_83_player_drop_through_hardening.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/increments/map_increment_83_player_drop_through_hardening.md)

### `runbooks`

- [godot_mcp_setup.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/godot_mcp_setup.md)
- [flux_klein_4b_asset_regeneration.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/flux_klein_4b_asset_regeneration.md)
- [skill_excel_report_workflow.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/runbooks/skill_excel_report_workflow.md)

### 루트 schema

- [combat_hud_gui_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/combat_hud_gui_schema.md)
  - 전투 HUD 그래픽 GUI의 레이아웃 상태, 상호작용 상태, 설정 토글 필드 기준

### 루트 tracker

- [spec_clarification_backlog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/spec_clarification_backlog.md)
  - 구현 전에 더 잠가야 하는 기획 질문 큐

### 연결되는 progression 기준 문서

- 전투 수치 기준선: [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md)
- 몬스터 roster / 역할 기준: [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md)
- 몬스터 데이터 필드 기준: [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md)
- 몬스터 구현 / 에셋 / 테스트 상태: [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md)

## 해석 우선순위

- 구현 판단은 항상 [current_runtime_baseline.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/implementation/baselines/current_runtime_baseline.md) 를 먼저 따른다.
- 몬스터가 무엇을 담당하는지, 어떤 적이 정식 편입 대상인지 판단할 때는 [enemy_catalog.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/catalogs/enemy_catalog.md) 를 함께 따른다.
- 적 스탯, 데미지 감쇠, 속성 저항, 상태이상 저항, 슈퍼아머, 브레이크 규칙은 반드시 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 함께 따른다.
- `data/enemies/enemies.json` 필드 추가/변경은 [enemy_data_schema.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/schemas/enemy_data_schema.md) 를 함께 따른다.
- 몬스터 구현 / 에셋 / 테스트 반영 상태를 확인할 때는 [enemy_content_tracker.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/trackers/enemy_content_tracker.md) 를 함께 따른다.
- 위 규칙이 바뀌면 구현만 바꾸지 말고 [enemy_stat_and_damage_rules.md](/Users/leesanghyun/git-projects/java-projects/old/dungeon_mage/docs/progression/rules/enemy_stat_and_damage_rules.md) 를 함께 수정한다.
- `combat_first_build_plan.md` 같은 장기 문서에 남아 있는 과거 전제는 히스토리로 취급한다.
- 특히 `SpellResource`, `player_state_chart.tres`, `scenes/player/Player.tscn` 전제는 현재 코드 기준이 아니다.

## 수정 규칙

- 현재 사실을 설명하는 문서는 `baselines/`를 먼저 수정한다.
- 장기 작업 범위와 acceptance criteria는 `plans/`를 수정한다.
- 즉시 구현 핸드오프와 체크리스트는 `increments/`를 수정한다.
- Godot MCP, 검증 절차, setup 절차는 `runbooks/`를 수정한다.

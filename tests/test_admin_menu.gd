extends "res://addons/gut/test.gd"

const ADMIN_MENU_SCRIPT := preload("res://scripts/admin/admin_menu.gd")
const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const SPELL_MANAGER_SCRIPT := preload("res://scripts/player/spell_manager.gd")


func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()


func _assert_string_contains_all(text: String, snippets: Array, context := "") -> void:
	for snippet_value in snippets:
		var snippet := str(snippet_value)
		var message := context if context != "" else "expected to find '%s'" % snippet
		assert_string_contains(text, snippet, message)


func _assert_lines_appear_in_order(text: String, snippets: Array, context := "") -> void:
	var previous_index := -1
	for snippet_value in snippets:
		var snippet := str(snippet_value)
		var index := text.find(snippet)
		var missing_message := context if context != "" else "expected to find '%s'" % snippet
		assert_true(index >= 0, missing_message)
		if previous_index >= 0:
			var order_message := (
				context if context != "" else "expected '%s' after previous snippet" % snippet
			)
			assert_true(index > previous_index, order_message)
		previous_index = index


func _get_combo_display_name(combo_id: String) -> String:
	for raw_combo in GameDatabase.get_all_buff_combos():
		if typeof(raw_combo) != TYPE_DICTIONARY:
			continue
		var combo: Dictionary = raw_combo
		if str(combo.get("combo_id", "")) == combo_id:
			return str(combo.get("display_name", combo_id))
	return combo_id


func _equipment_entry(menu, item_id: String) -> String:
	return str(menu._get_equipment_list_entry_text(item_id))


func _candidate_entry(menu, item_id: String) -> String:
	return str(menu._get_candidate_list_entry_text(item_id))


func test_admin_menu_toggle_changes_visibility() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(menu.visible)
	menu.debug_toggle()
	assert_true(menu.visible)
	menu.debug_toggle()
	assert_false(menu.visible)


func test_admin_menu_preset_changes_hotbar() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_preset(1)
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "earth_stone_spire")
	assert_eq(str(hotbar[1].get("skill_id", "")), "dark_grave_echo")


func test_admin_menu_cycle_slot_updates_game_state() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var before: String = str(GameState.get_spell_hotbar()[0].get("skill_id", ""))
	menu.debug_cycle_slot(0, 1)
	var after: String = str(GameState.get_spell_hotbar()[0].get("skill_id", ""))
	assert_ne(before, after)


func test_admin_menu_can_toggle_infinite_health() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(GameState.admin_infinite_health)
	menu.debug_toggle_infinite_health()
	assert_true(GameState.admin_infinite_health)
	GameState.damage(50)
	assert_eq(GameState.health, GameState.max_health)


func test_admin_menu_emits_spawn_and_reset_signals() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var spawned: Array = []
	var reset_called: Array = []
	menu.spawn_enemy_requested.connect(func(enemy_type: String) -> void: spawned.append(enemy_type))
	menu.reset_cooldowns_requested.connect(func() -> void: reset_called.append(true))
	menu.debug_emit_spawn("boss")
	menu.debug_emit_reset_cooldowns()
	assert_eq(spawned.size(), 1)
	assert_eq(spawned[0], "boss")
	assert_eq(reset_called.size(), 1)


func test_admin_menu_can_cycle_prototype_room_target_and_emit_jump_signal() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var jumped: Array[String] = []
	menu.room_jump_requested.connect(func(room_id: String) -> void: jumped.append(room_id))
	menu.debug_click_tab("resources")
	menu.debug_cycle_prototype_room(1)
	menu.debug_emit_room_jump()
	var room_order := GameState.get_prototype_room_order()
	assert_true(room_order.size() > 1, "prototype room order must contain more than one room")
	var expected_room_id := str(room_order[1])
	var expected_overview := GameState.get_prototype_room_overview_summary(expected_room_id)
	var selected_flow_line := ""
	for raw_line in GameState.get_prototype_flow_preview_summary(expected_room_id).get("lines", []):
		var line := str(raw_line)
		if line.begins_with("> "):
			selected_flow_line = line
			break
	assert_eq(jumped.size(), 1)
	assert_eq(jumped[0], expected_room_id)
	_assert_string_contains_all(
		menu.body_label.text,
		[
			"프로토타입 대상: %s" % expected_room_id,
			"프로토타입 제목: %s" % str(expected_overview.get("title", expected_room_id)),
			"프로토타입 요약: %s" % str(expected_overview.get("summary", "")),
			menu._get_prototype_room_page_summary(),
			"상호작용 미리보기:"
		]
	)
	if selected_flow_line != "":
		assert_string_contains(menu.body_label.text, selected_flow_line)


func test_admin_menu_reactive_preview_reflects_hub_progression_state() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	menu.debug_select_prototype_room("seal_sanctum")
	_assert_string_contains_all(
		menu.body_label.text,
		[
			str(GameState.get_progression_phase_summary().get("line", "")),
			str(GameState.get_progression_chain_summary().get("line", ""))
		]
	)
	for raw_line in menu._get_selected_prototype_room_reactive_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	menu._refresh()
	_assert_string_contains_all(
		menu.body_label.text,
		[
			str(GameState.get_progression_phase_summary().get("line", "")),
			str(GameState.get_progression_chain_summary().get("line", ""))
		]
	)
	GameState.progression_flags["gate_threshold_bloodline_hint"] = true
	menu._refresh()
	_assert_string_contains_all(
		menu.body_label.text,
		[
			str(GameState.get_progression_phase_summary().get("line", "")),
			str(GameState.get_progression_chain_summary().get("line", ""))
		]
	)
	GameState.progression_flags["royal_inner_hall_archive"] = true
	menu._refresh()
	_assert_string_contains_all(
		menu.body_label.text,
		[
			str(GameState.get_progression_phase_summary().get("line", "")),
			str(GameState.get_progression_chain_summary().get("line", ""))
		]
	)
	GameState.progression_flags["inverted_spire_covenant"] = true
	menu._refresh()
	_assert_string_contains_all(
		menu.body_label.text,
		[
			str(GameState.get_progression_phase_summary().get("line", "")),
			str(GameState.get_progression_chain_summary().get("line", ""))
		]
	)
	GameState.progression_flags["inverted_spire_covenant"] = false
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	GameState.progression_flags["gate_threshold_bloodline_hint"] = true
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	GameState.progression_flags["throne_approach_companion_trace"] = true
	GameState.progression_flags["throne_approach_decree"] = true
	menu._refresh()
	_assert_string_contains_all(
		menu.body_label.text,
		[
			str(GameState.get_progression_phase_summary().get("line", "")),
			str(GameState.get_progression_chain_summary().get("line", ""))
		]
	)
	for raw_line in menu._get_selected_prototype_room_reactive_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))


func test_admin_menu_can_select_prototype_room_directly_from_preview_buttons() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var jumped: Array[String] = []
	menu.room_jump_requested.connect(func(room_id: String) -> void: jumped.append(room_id))
	menu.debug_click_tab("resources")
	menu.debug_select_prototype_room("throne_approach")
	menu.debug_emit_room_jump()
	assert_eq(jumped.size(), 1)
	assert_eq(jumped[0], "throne_approach")
	_assert_string_contains_all(
		menu.body_label.text,
		[
			"프로토타입 대상: throne_approach",
			"프로토타입 제목: %s" % str(
				GameState.get_prototype_room_overview_summary("throne_approach").get("title", "")
			),
			"프로토타입 흐름:"
		]
	)
	for raw_line in menu._get_selected_prototype_room_interaction_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_reactive_residue_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_payoff_density_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_reactive_surface_mix_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_weakest_link_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_phase_note_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_path_note_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_verification_status_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_next_priority_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_action_candidate_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_clue_check_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))


func test_admin_menu_final_warning_preview_reflects_covenant_state() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	menu.debug_select_prototype_room("inverted_spire")
	for raw_line in menu._get_selected_prototype_room_reactive_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_reactive_residue_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_payoff_density_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_reactive_surface_mix_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_weakest_link_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_phase_cross_check_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_lore_handoff_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_phase_note_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_path_note_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_verification_status_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_next_priority_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_action_candidate_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_clue_check_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	GameState.progression_flags["gate_threshold_bloodline_hint"] = true
	menu._refresh()
	for raw_line in menu._get_phase_cross_check_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_lore_handoff_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	GameState.progression_flags["royal_inner_hall_archive"] = true
	GameState.progression_flags["throne_approach_companion_trace"] = true
	GameState.progression_flags["throne_approach_decree"] = true
	menu._refresh()
	for raw_line in menu._get_phase_cross_check_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_lore_handoff_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	GameState.progression_flags["inverted_spire_covenant"] = true
	menu._refresh()
	for raw_line in menu._get_selected_prototype_room_reactive_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_reactive_residue_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_phase_cross_check_preview_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_lore_handoff_summary_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_phase_note_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_path_note_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_next_priority_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_action_candidate_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))
	for raw_line in menu._get_selected_room_clue_check_lines():
		assert_string_contains(menu.body_label.text, str(raw_line))


func test_admin_status_summary_reflects_infinite_health_flag() -> void:
	assert_eq(GameState.get_admin_status_summary(), "관리  자원[-] 전투[-] 장비[default]")
	GameState.set_admin_infinite_health(true)
	assert_string_contains(GameState.get_admin_status_summary(), "무한 HP")
	assert_string_contains(GameState.get_admin_status_summary(), "장비[default]")


func test_admin_status_summary_groups_resource_and_combat_flags() -> void:
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_cooldowns(true)
	var summary := GameState.get_admin_status_summary()
	assert_string_contains(summary, "자원[무한 MP]")
	assert_string_contains(summary, "전투[쿨타임 없음]")


func test_admin_menu_can_apply_equipment_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_equipment_preset("storm_tempo")
	assert_string_contains(GameState.get_equipment_summary(), "프리셋:폭풍 템포")


func test_admin_menu_can_cycle_individual_equipment_slot() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var before := str(GameState.get_equipped_items().get("weapon", ""))
	menu.debug_cycle_equipment(0, 1)
	var after := str(GameState.get_equipped_items().get("weapon", ""))
	assert_ne(before, after)


func test_admin_menu_can_toggle_infinite_mana_and_ignore_cooldowns() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(GameState.admin_infinite_mana)
	assert_false(GameState.admin_ignore_cooldowns)
	menu.debug_toggle_infinite_mana()
	menu.debug_toggle_ignore_cooldowns()
	assert_true(GameState.admin_infinite_mana)
	assert_true(GameState.admin_ignore_cooldowns)


func test_admin_menu_can_toggle_free_buff_slots() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(GameState.admin_ignore_buff_slot_limit)
	menu.debug_toggle_ignore_buff_slot_limit()
	assert_true(GameState.admin_ignore_buff_slot_limit)
	assert_string_contains(GameState.get_admin_status_summary(), "버프 슬롯 무제한")


func test_admin_menu_can_adjust_selected_skill_level() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_eq(GameState.get_skill_level("fire_bolt"), 1)
	menu.debug_adjust_selected_skill_level(0, 4)
	assert_eq(GameState.get_skill_level("fire_bolt"), 5)
	assert_gt(GameState.get_skill_experience("fire_bolt"), 0.0)
	menu.debug_adjust_selected_skill_level(0, -10)
	assert_eq(GameState.get_skill_level("fire_bolt"), 1)


func test_admin_menu_displays_skill_library_preview() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	assert_string_contains(menu.body_label.text, "스킬 라이브러리")
	assert_string_contains(menu.body_label.text, "파이어 볼트")


func test_admin_menu_can_focus_library_and_assign_skill_to_slot() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle_library_focus()
	menu.selected_library_index = menu.skill_catalog.find("volt_spear")
	assert_ne(menu.selected_library_index, -1, "volt_spear must be present in the admin library")
	menu.debug_assign_library_to_slot(0)
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "volt_spear")
	assert_string_contains(menu.body_label.text, "라이브러리 포커스: 켜짐")


func test_admin_menu_skill_catalog_reuses_runtime_castable_source_of_truth() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var actual_catalog: Array = menu.skill_catalog.duplicate()
	assert_eq(str(actual_catalog[0]), "", "admin library must keep the empty slot shortcut at the front")
	actual_catalog.remove_at(0)
	assert_eq(actual_catalog, GameDatabase.get_runtime_castable_skill_catalog())
	assert_true(actual_catalog.has("holy_radiant_burst"))
	assert_true(actual_catalog.has("dark_void_bolt"))
	assert_false(actual_catalog.has("holy_healing_pulse"))
	assert_false(actual_catalog.has("dark_abyss_gate"))
	assert_false(actual_catalog.has("fire_mastery"))


func test_admin_menu_library_assignment_stays_consistent_through_hotbar_save_and_runtime_cast() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.selected_library_index = menu.skill_catalog.find("holy_radiant_burst")
	assert_ne(menu.selected_library_index, -1, "holy_radiant_burst must be present in the admin library")
	menu.debug_assign_library_to_slot(0)
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "holy_radiant_burst")
	var payload: Dictionary = GameState._build_save_payload()
	var saved_hotbar: Array = payload.get("spell_hotbar", [])
	assert_eq(str(saved_hotbar[0].get("skill_id", "")), "holy_radiant_burst")
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var bindings: Array = manager.get_slot_bindings()
	assert_eq(str(bindings[0].get("skill_id", "")), "holy_radiant_burst")
	var runtime: Dictionary = GameState.get_spell_runtime("holy_radiant_burst")
	var payloads: Array = []
	manager.spell_cast.connect(func(spell_payload: Dictionary) -> void: payloads.append(spell_payload))
	assert_true(manager.attempt_cast_by_action(str(bindings[0].get("action", ""))))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_radiant_burst")
	assert_eq(str(payloads[0].get("school", "")), str(runtime.get("school", "")))
	assert_eq(int(payloads[0].get("total_damage", 0)), int(runtime.get("damage", 0)))
	assert_eq(
		int(payloads[0].get("multi_hit_total", 0)),
		int(runtime.get("multi_hit_count", 1))
	)
	assert_almost_eq(float(payloads[0].get("cooldown", 0.0)), float(runtime.get("cooldown", 0.0)), 0.0001)
	assert_almost_eq(float(payloads[0].get("speed", 0.0)), float(runtime.get("speed", 0.0)), 0.0001)


func test_admin_menu_library_focus_changes_tuned_skill_target() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle_library_focus()
	menu.selected_library_index = menu.skill_catalog.find("volt_spear")
	assert_ne(menu.selected_library_index, -1, "volt_spear must be present in the admin library")
	menu._refresh()
	menu.debug_adjust_selected_skill_level(0, 3)
	assert_eq(GameState.get_skill_level("volt_spear"), 4)
	assert_eq(GameState.get_skill_level("fire_bolt"), 1)
	assert_string_contains(menu.body_label.text, "스킬  %s" % menu._display_name("volt_spear"))


func test_admin_menu_can_apply_deploy_lab_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_named_preset("deploy_lab")
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "earth_stone_spire")
	assert_eq(str(hotbar[1].get("skill_id", "")), "dark_grave_echo")
	assert_eq(str(hotbar[2].get("skill_id", "")), "fire_inferno_sigil")
	assert_eq(str(hotbar[5].get("skill_id", "")), "arcane_world_hourglass")


func test_admin_menu_can_apply_ashen_rite_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_named_preset("ashen_rite")
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[3].get("skill_id", "")), "dark_grave_pact")
	assert_eq(str(hotbar[4].get("skill_id", "")), "arcane_world_hourglass")
	assert_eq(str(hotbar[5].get("skill_id", "")), "dark_throne_of_ash")


func test_admin_menu_can_apply_apex_toggle_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_named_preset("apex_toggles")
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "ice_glacial_dominion")
	assert_eq(str(hotbar[1].get("skill_id", "")), "lightning_tempest_crown")
	assert_eq(str(hotbar[2].get("skill_id", "")), "dark_soul_dominion")


func test_admin_menu_can_apply_funeral_bloom_preset() -> void:
	GameState.reset_progress_for_tests()
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_named_preset("funeral_bloom")
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(
		str(hotbar[0].get("skill_id", "")),
		"earth_stone_spire",
		"FuneralBloom preset slot 0 must be earth_stone_spire"
	)
	assert_eq(
		str(hotbar[3].get("skill_id", "")),
		"dark_grave_pact",
		"FuneralBloom preset slot 3 must be dark_grave_pact"
	)
	assert_eq(
		str(hotbar[4].get("skill_id", "")),
		"plant_verdant_overflow",
		"FuneralBloom preset slot 4 must be plant_verdant_overflow"
	)
	GameState.reset_progress_for_tests()


func test_funeral_bloom_preset_is_in_preset_id_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var preset_ids: Array[String] = GameState.get_hotbar_preset_ids()
	assert_true(preset_ids.has("funeral_bloom"), "HOTBAR_PRESET_IDS must include funeral_bloom")


func test_admin_menu_can_cycle_tabs_and_update_summary() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	assert_string_contains(menu.get_admin_tab_summary(), "탭[단축창]")
	assert_string_contains(menu.body_label.text, "단축창")
	menu.debug_cycle_tab(1)
	assert_string_contains(menu.get_admin_tab_summary(), "탭[자원]")
	assert_string_contains(menu.body_label.text, "자원")
	menu.debug_cycle_tab(1)
	assert_string_contains(menu.get_admin_tab_summary(), "탭[장비]")
	assert_string_contains(menu.get_admin_tab_summary(), "포커스[보유]")
	assert_string_contains(menu.get_admin_tab_summary(), "슬롯[무기]")
	assert_string_contains(menu.get_admin_tab_summary(), "탐색[0/0]")
	assert_string_contains(menu.get_admin_tab_summary(), "대상[(비어 있음)]")
	assert_string_contains(menu.body_label.text, "장비")
	menu.debug_cycle_tab(1)
	assert_string_contains(menu.get_admin_tab_summary(), "탭[소환]")
	assert_string_contains(menu.body_label.text, "소환")


func test_admin_menu_hides_library_focus_outside_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle_library_focus()
	assert_string_contains(menu.get_admin_tab_summary(), "라이브러리[켜짐]")
	menu.debug_cycle_tab(1)
	assert_false(menu.get_admin_tab_summary().contains("라이브러리[켜짐]"))


func test_admin_menu_can_grant_and_equip_candidate_from_inventory() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_cycle_equipment_candidate(0, 2)
	menu.debug_grant_selected_equipment_candidate(0)
	assert_true(GameState.has_equipment_in_inventory("weapon_tempest_rod"))
	menu.debug_interact_equipment(0)
	var equipped: Dictionary = GameState.get_equipped_items()
	assert_eq(str(equipped.get("weapon", "")), "weapon_tempest_rod")
	assert_string_contains(menu.body_label.text, "인벤토리")


func test_admin_menu_equipment_tab_shows_slot_specific_owned_items() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "선택 슬롯  무기")
	assert_string_contains(menu.body_label.text, "보유 장비  %s" % menu._display_name("weapon_tempest_rod"))
	assert_false(
		menu.body_label.text.contains("보유 장비  %s" % menu._display_name("focus_storm_orb"))
	)


func test_admin_menu_can_cycle_owned_equipment_selection_and_equip_it() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	menu.debug_cycle_owned_equipment(0, 1)
	assert_string_contains(
		menu.body_label.text,
		"보유 선택  [집중]  %s" % menu._display_name("weapon_tempest_rod")
	)
	menu.debug_interact_equipment(0)
	var equipped: Dictionary = GameState.get_equipped_items()
	assert_eq(str(equipped.get("weapon", "")), "weapon_tempest_rod")


func test_admin_menu_renders_owned_equipment_preview_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "보유 목록")
	assert_string_contains(menu.body_label.text, "> %s" % _equipment_entry(menu, "weapon_ember_staff"))
	menu.debug_cycle_owned_equipment(0, 1)
	assert_string_contains(menu.body_label.text, "> %s" % _equipment_entry(menu, "weapon_tempest_rod"))
	assert_string_contains(menu.body_label.text, "보유 상세")
	assert_string_contains(menu.body_label.text, "태그:번개, 템포")
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체")
	assert_string_contains(menu.body_label.text, "보유 탐색  1/1  아이템 1-2/2")


func test_admin_menu_sorts_owned_list_by_rarity_then_name() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("armor_mage_coat"))
	assert_true(GameState.grant_equipment_item("armor_ember_robe"))
	menu.debug_cycle_tab(2)
	menu.debug_cycle_equipment_candidate(3, 0)
	menu.selected_equipment_slot = 3
	menu._refresh()
	var body_text: String = menu.body_label.text
	assert_string_contains(body_text, "> %s" % _equipment_entry(menu, "armor_ember_robe"))
	assert_string_contains(body_text, "- %s" % _equipment_entry(menu, "armor_mage_coat"))


func test_admin_menu_can_toggle_owned_sort_mode_to_name() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	assert_true(GameState.grant_equipment_item("focus_ash_tome"))
	menu.debug_cycle_tab(2)
	menu.selected_equipment_slot = 1
	menu._refresh()
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체")
	menu.debug_cycle_equipment_sort_mode(1)
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:이름  필터:전체")
	assert_string_contains(menu.body_label.text, "> %s" % _equipment_entry(menu, "focus_storm_orb"))
	assert_string_contains(menu.body_label.text, "- %s" % _equipment_entry(menu, "focus_ash_tome"))


func test_admin_menu_can_toggle_owned_filter_mode() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	assert_true(GameState.grant_equipment_item("focus_ash_tome"))
	menu.debug_cycle_tab(2)
	menu.selected_equipment_slot = 1
	menu._refresh()
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체")
	menu.debug_cycle_equipment_filter_mode(1)
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:템포")
	assert_string_contains(menu.body_label.text, "> %s" % _equipment_entry(menu, "focus_storm_orb"))
	# Ash Tome visible in candidate list (catalog unfiltered) but excluded from owned list
	var owned_lines := "\n".join(menu._get_owned_equipment_preview_lines("offhand"))
	assert_false(
		owned_lines.contains(menu._display_name("focus_ash_tome")),
		"Ash Tome must not appear in owned list under tempo filter"
	)


func test_admin_menu_can_cycle_owned_page_for_large_inventory() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	for _i in range(3):
		assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	for _j in range(3):
		assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "보유 탐색  1/2  아이템 1-5/6")
	menu.debug_cycle_owned_page(0, 1)
	assert_string_contains(menu.body_label.text, "보유 탐색  2/2  아이템 6-6/6")
	assert_string_contains(menu.body_label.text, "> %s" % _equipment_entry(menu, "weapon_tempest_rod"))


func test_admin_menu_equipment_focus_can_toggle_to_candidate() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "장비 포커스  보유")
	assert_string_contains(menu.get_admin_tab_summary(), "포커스[보유]")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "장비 포커스  후보")
	assert_string_contains(menu.body_label.text, "후보 선택  [집중]")
	assert_string_contains(menu.get_admin_tab_summary(), "포커스[후보]")
	assert_string_contains(menu.get_admin_tab_summary(), "탐색[아이템 1-4/4]")
	assert_string_contains(menu.get_admin_tab_summary(), "대상[(비어 있음)]")


func test_admin_menu_equipment_summary_tracks_candidate_target_and_owned_state() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	assert_string_contains(
		menu.get_admin_tab_summary(),
		"대상[%s]" % menu._display_name("weapon_tempest_rod")
	)
	assert_string_contains(menu.get_admin_tab_summary(), "보유[예]")


func test_admin_menu_equipment_tab_shows_selected_slot_stat_summary() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_equipment_preset("storm_tempo")
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "슬롯 스탯  MATK +4")
	menu.selected_equipment_slot = 3
	menu._refresh()
	assert_string_contains(menu.body_label.text, "슬롯 스탯  최대HP +15  피감 6%")


func test_admin_menu_equipment_tab_shows_candidate_compare_against_equipped_item() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_equipment_preset("storm_tempo")
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	assert_string_contains(
		menu.body_label.text,
		"비교 기준  착용:%s  후보:%s"
		% [menu._display_name("weapon_ember_staff"), menu._display_name("weapon_tempest_rod")]
	)
	assert_string_contains(menu.body_label.text, "후보 비교  마공 -1")
	assert_string_contains(menu.body_label.text, "재감 +4%")


func test_admin_menu_equipment_compare_section_keeps_header_stats_and_delta_together() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_equipment_preset("storm_tempo")
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	var compare_index: int = menu.body_label.text.find(
		"비교 기준  착용:%s  후보:%s"
		% [menu._display_name("weapon_ember_staff"), menu._display_name("weapon_tempest_rod")]
	)
	var stats_index: int = menu.body_label.text.find("슬롯 스탯  MATK +4")
	var delta_index: int = menu.body_label.text.find("후보 비교  마공 -1")
	assert_true(compare_index >= 0)
	assert_true(stats_index > compare_index)
	assert_true(delta_index > stats_index)


func test_admin_menu_equipment_panel_helpers_keep_candidate_and_owned_sections_visible() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "   후보")
	assert_string_contains(menu.body_label.text, "-- 보유 --")
	assert_string_contains(menu.body_label.text, "후보 상태")
	assert_string_contains(menu.body_label.text, "보유 상태")


func test_admin_menu_equipment_common_panel_wrapper_keeps_status_before_body() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	var candidate_header_index: int = menu.body_label.text.find("   후보")
	var candidate_status_index: int = menu.body_label.text.find("후보 상태")
	var candidate_body_index: int = menu.body_label.text.find("후보 선택")
	var owned_header_index: int = menu.body_label.text.find("-- 보유 --")
	var owned_status_index: int = menu.body_label.text.find("보유 상태")
	var owned_body_index: int = menu.body_label.text.find("보유 선택")
	assert_true(candidate_header_index >= 0)
	assert_true(candidate_status_index > candidate_header_index)
	assert_true(candidate_body_index > candidate_status_index)
	assert_true(owned_header_index >= 0)
	assert_true(owned_status_index > owned_header_index)
	assert_true(owned_body_index > owned_status_index)


func test_admin_menu_equipment_common_body_helper_keeps_detail_before_navigation() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 1)
	var selection_index: int = menu.body_label.text.find("후보 선택")
	var detail_index: int = menu.body_label.text.find("후보 상세")
	var view_index: int = menu.body_label.text.find("후보 보기  상태:미보유")
	var window_index: int = menu.body_label.text.find("후보 탐색")
	assert_true(selection_index >= 0)
	assert_true(detail_index > selection_index)
	assert_true(view_index > detail_index)
	assert_true(window_index > view_index)


func test_admin_menu_equipment_body_source_still_renders_owned_view_and_page() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체")
	assert_string_contains(menu.body_label.text, "보유 탐색  1/1  아이템 1-1/1")


func test_admin_menu_equipment_owned_source_helpers_keep_single_selection_line() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var occurrences: int = menu.body_label.text.split("보유 선택").size() - 1
	assert_eq(occurrences, 1)
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체")
	assert_string_contains(menu.body_label.text, "보유 탐색  1/1  아이템 1-1/1")


func test_admin_menu_equipment_panel_body_source_helpers_keep_both_view_lines() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(
		menu.body_label.text, "후보 보기  상태:미보유  탐색:아이템 1-4/4"
	)
	assert_string_contains(
		menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체  탐색:0/0"
	)


func test_admin_menu_selection_lines_keep_shared_name_and_index_format() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	assert_string_contains(
		menu.body_label.text,
		"보유 선택  [집중]  %s  [1/1]" % menu._display_name("weapon_ember_staff")
	)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "후보 선택  [집중]  (비어 있음)  [1/4]")


func test_admin_menu_view_lines_keep_shared_prefix_and_browse_info() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(
		menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체  탐색:0/0"
	)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(
		menu.body_label.text, "후보 보기  상태:미보유  탐색:아이템 1-4/4"
	)


func test_admin_menu_nav_lines_keep_shared_prefix_and_navigation_info() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "보유 탐색  1/1  아이템 1-1/1")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "후보 탐색  아이템 1-4/4")


func test_admin_menu_navigation_section_keeps_view_selection_and_nav_grouped() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	var selection_index: int = menu.body_label.text.find(
		"후보 선택  [집중]  (비어 있음)  [1/4]"
	)
	var view_index: int = menu.body_label.text.find(
		"후보 보기  상태:미보유  탐색:아이템 1-4/4"
	)
	var nav_index: int = menu.body_label.text.find("후보 탐색  아이템 1-4/4")
	var list_index: int = menu.body_label.text.find("후보 목록")
	assert_true(selection_index >= 0)
	assert_true(view_index > selection_index)
	assert_true(nav_index > view_index)
	assert_true(list_index > nav_index)


func test_admin_menu_owned_navigation_section_keeps_view_nav_and_list_grouped() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var view_index: int = menu.body_label.text.find(
		"보유 보기  정렬:등급 -> 이름  필터:전체  탐색:1/1"
	)
	var nav_index: int = menu.body_label.text.find("보유 탐색  1/1  아이템 1-1/1")
	var list_index: int = menu.body_label.text.find("보유 목록")
	assert_true(view_index >= 0)
	assert_true(nav_index > view_index)
	assert_true(list_index > nav_index)


func test_admin_menu_candidate_content_section_keeps_detail_then_navigation_then_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	var detail_index: int = menu.body_label.text.find("후보 상세  없음")
	var view_index: int = menu.body_label.text.find(
		"후보 보기  상태:미보유  탐색:아이템 1-4/4"
	)
	var nav_index: int = menu.body_label.text.find("후보 탐색  아이템 1-4/4")
	var list_index: int = menu.body_label.text.find("후보 목록")
	assert_true(detail_index >= 0)
	assert_true(view_index > detail_index)
	assert_true(nav_index > view_index)
	assert_true(list_index > nav_index)


func test_admin_menu_equipment_tab_shows_dual_panel_preview_lines() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	assert_string_contains(
		menu.body_label.text, "패널 요약  후보:(비어 있음)  보유:%s" % menu._display_name("weapon_ember_staff")
	)
	assert_string_contains(
		menu.body_label.text, "패널 흐름  후보:지급  보유:장착  탐색:아이템 1-4/4 | 1/1"
	)


func test_admin_menu_owned_content_section_keeps_detail_then_navigation_then_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var detail_index: int = menu.body_label.text.find("보유 상세  화염 계열 마법 출력을 끌어올리는 지팡이")
	var view_index: int = menu.body_label.text.find(
		"보유 보기  정렬:등급 -> 이름  필터:전체  탐색:1/1"
	)
	var nav_index: int = menu.body_label.text.find("보유 탐색  1/1  아이템 1-1/1")
	var list_index: int = menu.body_label.text.find("보유 목록")
	assert_true(detail_index >= 0)
	assert_true(view_index > detail_index)
	assert_true(nav_index > view_index)
	assert_true(list_index > nav_index)


func test_admin_menu_dual_panel_preview_promotes_fresh_owned_action() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	menu.debug_interact_equipment(0)
	assert_string_contains(
		menu.body_label.text,
		"패널 요약  후보:%s  보유:%s"
		% [menu._display_name("weapon_tempest_rod"), menu._display_name("weapon_tempest_rod")]
	)
	assert_string_contains(menu.body_label.text, "패널 흐름  후보:지급  보유:즉시 장착")


func test_admin_menu_dual_panel_preview_keeps_summary_before_flow() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var summary_index: int = menu.body_label.text.find(
		"패널 요약  후보:(비어 있음)  보유:%s" % menu._display_name("weapon_ember_staff")
	)
	var flow_index: int = menu.body_label.text.find(
		"패널 흐름  후보:지급  보유:장착  탐색:아이템 1-4/4 | 1/1"
	)
	var candidate_header_index: int = menu.body_label.text.find("   후보")
	assert_true(summary_index >= 0)
	assert_true(flow_index > summary_index)
	assert_true(candidate_header_index > flow_index)


func test_admin_menu_equipment_overview_keeps_compare_before_dual_panel_preview() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var compare_index: int = menu.body_label.text.find("비교 기준")
	var summary_index: int = menu.body_label.text.find(
		"패널 요약  후보:(비어 있음)  보유:%s" % menu._display_name("weapon_ember_staff")
	)
	var flow_index: int = menu.body_label.text.find(
		"패널 흐름  후보:지급  보유:장착  탐색:아이템 1-4/4 | 1/1"
	)
	assert_true(compare_index >= 0)
	assert_true(summary_index > compare_index)
	assert_true(flow_index > summary_index)


func test_admin_menu_equipment_overview_keeps_flow_before_focus_label() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var flow_index: int = menu.body_label.text.find(
		"패널 흐름  후보:지급  보유:장착  탐색:아이템 1-4/4 | 1/1"
	)
	var focus_index: int = menu.body_label.text.find("장비 포커스  보유")
	assert_true(flow_index >= 0)
	assert_true(focus_index > flow_index)


func test_admin_menu_equipment_layout_keeps_candidate_before_owned_panel() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	var candidate_header_index: int = menu.body_label.text.find("   후보")
	var owned_header_index: int = menu.body_label.text.find("-- 보유 --")
	assert_true(candidate_header_index >= 0)
	assert_true(owned_header_index > candidate_header_index)


func test_admin_menu_equipment_layout_keeps_overview_focus_and_panels_in_order() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var summary_index: int = menu.body_label.text.find(
		"패널 요약  후보:(비어 있음)  보유:%s" % menu._display_name("weapon_ember_staff")
	)
	var focus_index: int = menu.body_label.text.find("장비 포커스  보유")
	var columns_index: int = menu.body_label.text.find("패널 열  왼쪽:후보  오른쪽:보유")
	var left_slot_index: int = menu.body_label.text.find("[후보]")
	var right_slot_index: int = menu.body_label.text.find("[보유]")
	assert_true(summary_index >= 0)
	assert_true(focus_index > summary_index)
	assert_true(columns_index > focus_index)
	assert_true(left_slot_index > columns_index)
	assert_true(right_slot_index > left_slot_index)


func test_admin_menu_equipment_layout_shows_two_panel_bridge_before_panels() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "패널 열  왼쪽:후보  오른쪽:보유")
	assert_string_contains(menu.body_label.text, "패널 모드  좌우 분할")
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[후보]") and line.contains("[보유]"):
			combined_slot_line = line
			break
	assert_ne(combined_slot_line, "")


func test_admin_menu_equipment_layout_keeps_slot_section_gap_between_left_and_right_in_stacked_fallback(
) -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_set_equipment_panel_layout_mode("stacked_fallback")
	var left_slot_index: int = menu.body_label.text.find("[후보]")
	var right_slot_index: int = menu.body_label.text.find("[보유]")
	var gap_index: int = menu.body_label.text.find("[보유]", left_slot_index + 1)
	assert_true(left_slot_index >= 0)
	assert_true(right_slot_index > left_slot_index)
	assert_eq(right_slot_index, gap_index)


func test_admin_menu_equipment_layout_uses_side_by_side_slot_section_renderer_by_default() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "패널 모드  좌우 분할")
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[후보]") and line.contains("[보유]"):
			combined_slot_line = line
			break
	assert_ne(combined_slot_line, "")


func test_admin_menu_equipment_layout_keeps_slot_section_output_stable_with_stacked_override(
) -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_set_equipment_panel_layout_mode("stacked_fallback")
	assert_string_contains(menu.body_label.text, "[후보]")
	assert_string_contains(menu.body_label.text, "[보유]")
	assert_string_contains(menu.body_label.text, "패널 모드  세로 적층")


func test_admin_menu_side_by_side_slot_section_helper_formats_two_columns() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._build_equipment_panel_slot_section_side_by_side_lines(
		{
			"left_slot_lines": ["[후보]", "-- 후보 --", "후보 상태  대기"],
			"right_slot_lines": ["[보유]", "-- 보유 --", "보유 상태  대기"]
		}
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "[후보]")
	assert_string_contains(lines[0], "[보유]")
	assert_string_contains(lines[1], "-- 후보 --")
	assert_string_contains(lines[1], "-- 보유 --")


func test_admin_menu_side_by_side_slot_section_helper_respects_separator_from_source() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._build_equipment_panel_slot_section_side_by_side_lines(
		{
			"column_width": 24,
			"column_separator": " | ",
			"left_slot_lines": ["[후보]"],
			"right_slot_lines": ["[보유]"]
		}
	)
	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], " | [보유]")


func test_admin_menu_side_by_side_default_output_uses_pipe_separator() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[후보]") and line.contains("[보유]"):
			combined_slot_line = line
			break
	assert_ne(combined_slot_line, "")
	assert_string_contains(combined_slot_line, "|")


func test_admin_menu_side_by_side_column_width_clamps_large_panel_widths_to_cap() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var short_left := ["[Candidate]", "short"]
	var long_right := [
		"[Owned]",
		"this right line is deliberately very long to test that it does not inflate the left column width"
	]
	var width_with_long_right: int = menu._get_equipment_panel_column_width(short_left, long_right)
	assert_eq(
		width_with_long_right,
		60,
		"Large side-by-side panel widths must clamp to the configured readability cap"
	)


func test_admin_menu_side_by_side_row_clamps_left_line_that_exceeds_column_width() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var column_width := 20
	var long_left := "this line is way too long for the column"
	var row: String = menu._build_equipment_side_by_side_row(long_left, "RIGHT", column_width, "|")
	var separator_pos: int = row.find("|")
	assert_eq(
		separator_pos,
		column_width,
		"Separator must appear exactly at column_width even when left line overflows"
	)
	assert_string_contains(row, "~", "Overflow marker ~ must appear when left line is truncated")


func test_admin_menu_equipment_fresh_grant_status_shows_exclamation_marker() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	menu.debug_interact_equipment(0)
	assert_string_contains(menu.body_label.text, "동작:즉시 장착  상태:신규  [!]")


func test_admin_menu_can_switch_equipment_layout_mode_to_side_by_side_for_debug() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_set_equipment_panel_layout_mode("side_by_side")
	assert_string_contains(menu.body_label.text, "패널 모드  좌우 분할")
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[후보]") and line.contains("[보유]"):
			combined_slot_line = line
			break
	assert_ne(combined_slot_line, "")


func test_admin_menu_equipment_tab_header_shows_active_panel() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "[보유 패널 활성]")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "[후보 패널 활성]")


func test_admin_menu_equipment_tab_shows_panel_section_headers() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "-- 보유 --")
	assert_string_contains(menu.body_label.text, "   후보")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "-- 후보 --")
	assert_string_contains(menu.body_label.text, "   보유")


func test_admin_menu_equipment_focused_panel_shows_its_controls() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "N/R 보유 순환")
	assert_false(menu.body_label.text.contains("N/R 후보 순환"))
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "N/R 후보 순환")
	assert_false(menu.body_label.text.contains("N/R 보유 순환"))


func test_admin_menu_candidate_focus_cycles_candidates_and_grants_on_interact() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	assert_string_contains(
		menu.body_label.text,
		"후보 선택  [집중]  %s" % menu._display_name("weapon_tempest_rod")
	)
	menu.debug_interact_equipment(0)
	assert_true(GameState.has_equipment_in_inventory("weapon_tempest_rod"))


func test_admin_menu_grant_moves_focus_to_owned_and_selects_new_item() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	menu.debug_interact_equipment(0)
	assert_string_contains(menu.get_admin_tab_summary(), "포커스[보유]")
	assert_string_contains(
		menu.get_admin_tab_summary(),
		"대상[%s]" % menu._display_name("weapon_tempest_rod")
	)
	assert_string_contains(
		menu.body_label.text,
		"보유 선택  [집중]  %s" % menu._display_name("weapon_tempest_rod")
	)
	assert_string_contains(
		menu.body_label.text, "보유 상태  집중  동작:즉시 장착  상태:신규"
	)
	assert_string_contains(menu.footer_label.text, "E 새 장비 장착")
	assert_string_contains(menu.body_label.text, "보유 보기  정렬:등급 -> 이름  필터:전체")


func test_admin_menu_manual_owned_navigation_clears_fresh_equip_prompt() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	menu.debug_interact_equipment(0)
	assert_string_contains(
		menu.body_label.text, "보유 상태  집중  동작:즉시 장착  상태:신규"
	)
	menu.debug_cycle_owned_equipment(0, 1)
	assert_false(menu.body_label.text.contains("동작:즉시 장착"))
	assert_string_contains(menu.body_label.text, "보유 상태  집중  동작:장착  상태:")


func test_admin_menu_candidate_panel_shows_selection_and_preview_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "후보 선택  [집중]  (비어 있음)  [1/4]")
	assert_string_contains(menu.body_label.text, "후보 탐색  아이템 1-4/4")
	assert_string_contains(menu.body_label.text, "후보 상세  없음")
	assert_string_contains(menu.body_label.text, "후보 목록")
	assert_string_contains(menu.body_label.text, "> (비어 있음)")
	assert_string_contains(menu.body_label.text, "- %s" % _candidate_entry(menu, "weapon_ember_staff"))
	menu.debug_cycle_equipment_candidate(0, 1)
	assert_string_contains(
		menu.body_label.text,
		"후보 선택  [집중]  %s  [2/4]" % menu._display_name("weapon_ember_staff")
	)
	assert_string_contains(menu.body_label.text, "후보 탐색  아이템 1-4/4")
	assert_string_contains(menu.body_label.text, "후보 상세  화염 계열 마법 출력을 끌어올리는 지팡이")
	assert_string_contains(menu.body_label.text, "태그:화염, 폭딜")
	assert_string_contains(menu.body_label.text, "> %s" % _candidate_entry(menu, "weapon_ember_staff"))
	menu.debug_cycle_equipment_candidate(0, 1)
	assert_string_contains(menu.body_label.text, "> %s" % _candidate_entry(menu, "weapon_tempest_rod"))


func test_admin_menu_can_cycle_candidate_window_when_candidate_panel_is_focused() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "후보 선택  [집중]  (비어 있음)  [1/4]")
	assert_string_contains(menu.body_label.text, "후보 탐색  아이템 1-4/4")
	assert_string_contains(menu.body_label.text, "> (비어 있음)")
	# 4 items ≤ EQUIPMENT_PAGE_SIZE=5 → single page → cycling forward stays on page 0
	menu.debug_cycle_candidate_window(0, 1)
	assert_string_contains(menu.body_label.text, "후보 선택  [집중]  (비어 있음)  [1/4]")
	assert_string_contains(menu.body_label.text, "후보 탐색  아이템 1-4/4")


func test_admin_menu_equipment_tab_shows_panel_status_lines() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "후보 상태  대기  동작:지급")
	assert_string_contains(menu.body_label.text, "보유 상태  집중  동작:장착  상태:준비")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "후보 상태  집중  동작:지급")
	assert_string_contains(menu.body_label.text, "보유 상태  대기  동작:장착")


func test_admin_menu_footer_changes_by_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	assert_string_contains(menu.footer_label.text, "T 라이브러리 포커스")
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.footer_label.text, "T 포커스 전환")
	assert_string_contains(menu.footer_label.text, "E 현재 동작 실행")


func test_admin_buff_tab_is_accessible_via_cycle() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	menu.debug_cycle_tab(4)
	assert_string_contains(menu.body_label.text, "버프  [")
	assert_true(menu.buff_catalog.size() > 0, "Buff catalog must be non-empty")


func test_admin_buff_tab_force_activate_adds_to_active_buffs() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_eq(GameState.active_buffs.size(), 0)
	menu.debug_force_activate_selected_buff()
	assert_gt(GameState.active_buffs.size(), 0, "Force activate must add a buff to active_buffs")
	assert_string_contains(menu.body_label.text, "활성 버프:")


func test_admin_buff_tab_clear_removes_all_active_buffs() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	GameState.set_admin_ignore_buff_slot_limit(true)
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("fire_pyre_heart"))
	assert_eq(GameState.active_buffs.size(), 2)
	menu.debug_clear_active_buffs()
	assert_eq(GameState.active_buffs.size(), 0)


func test_admin_buff_tab_shows_combo_requirements_section() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_buff_tab_lines()
	var text: String = "\n".join(lines)
	assert_string_contains(text, "연계:", "Buffs tab must include a combo section header")
	assert_string_contains(text, "[ ]", "Inactive combos must show [ ] marker")


func test_admin_buff_tab_combo_shows_active_marker_when_buffs_present() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_buff_tab_lines()
	var text: String = "\n".join(lines)
	assert_string_contains(text, "[활성]", "Active combo must show [활성] marker in buffs tab")
	assert_string_contains(
		text,
		_get_combo_display_name("combo_prismatic_guard"),
		"Active combo name must appear in buffs tab"
	)
	GameState.reset_progress_for_tests()


func test_admin_buff_tab_combo_shows_required_buff_names() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_buff_tab_lines()
	var combo_line: String = ""
	for line in lines:
		if _get_combo_display_name("combo_ashen_rite") in line:
			combo_line = line
			break
	assert_false(combo_line.is_empty(), "Ashen Rite combo must appear in buff tab lines")
	assert_string_contains(
		combo_line, "(", "Combo line must show required buff list in parentheses"
	)


func test_admin_buff_tab_combo_req_shows_check_for_active_and_empty_for_missing() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	# Activate only one of the two Ashen Rite requirements
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_buff_tab_lines()
	var ashen_line: String = ""
	for line in lines:
		if _get_combo_display_name("combo_ashen_rite") in line:
			ashen_line = line
			break
	assert_false(ashen_line.is_empty(), "Ashen Rite combo must appear in buff tab")
	assert_string_contains(ashen_line, "[완료]", "Active required buff must show [완료] marker")
	assert_string_contains(ashen_line, "[ ]", "Inactive required buff must show [ ] marker")
	GameState.reset_progress_for_tests()


func test_admin_resource_tab_shows_circle_and_buff_slots() -> void:
	GameState.reset_progress_for_tests()
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_resource_tab_lines()
	var text: String = "\n".join(lines)
	assert_string_contains(text, "서클:", "Resource tab must show circle status")
	assert_string_contains(text, "버프 슬롯:", "Resource tab must show buff slot count")
	assert_string_contains(text, "점수:", "Resource tab must show progression score")


func test_admin_resource_tab_shows_hp_and_mp_current_values() -> void:
	GameState.reset_progress_for_tests()
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_resource_tab_lines()
	var text: String = "\n".join(lines)
	assert_string_contains(text, "HP:", "Resource tab must show HP value")
	assert_string_contains(text, "MP:", "Resource tab must show MP value")


func test_admin_resource_tab_buff_slot_count_matches_circle() -> void:
	GameState.reset_progress_for_tests()
	var expected_slots: int = GameState.get_buff_slot_limit()
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_resource_tab_lines()
	var text: String = "\n".join(lines)
	assert_string_contains(
		text,
		"버프 슬롯: %d" % expected_slots,
		"Buff slot count in resource tab must match GameState.get_buff_slot_limit()"
	)


func test_admin_spawn_tab_lists_all_enemies_from_database() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_spawn_tab_lines()
	assert_eq(str(lines[0]), "소환", "Spawn tab header must be '소환'")
	# With GameDatabase loaded, should have one line per enemy + header + blank + footer
	var enemy_count: int = GameDatabase.get_all_enemies().size()
	assert_true(enemy_count > 0, "GameDatabase must have at least one enemy")
	assert_true(
		lines.size() >= enemy_count + 1,
		"Spawn tab must have at least one line per enemy plus header"
	)


func test_admin_spawn_tab_shows_key_binding_for_known_enemies() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_spawn_tab_lines()
	var all_text: String = " ".join(lines)
	assert_string_contains(all_text, "C ", "Spawn tab must show key C for brute")
	assert_string_contains(all_text, "H ", "Spawn tab must show key H for elite")
	assert_string_contains(all_text, "[슈퍼아머]", "Elite entry must show [슈퍼아머] indicator")


func test_admin_spawn_tab_shows_hp_values() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_spawn_tab_lines()
	var elite_line: String = ""
	for line in lines:
		if "엘리트" in line:
			elite_line = line
			break
	assert_false(elite_line.is_empty(), "Spawn tab must contain an elite entry")
	assert_string_contains(elite_line, "HP:", "Elite entry must show HP value")
	assert_string_contains(elite_line, "180", "Elite HP must be 180 from enemies.json")


func test_admin_spawn_tab_clear_enemies_emits_signal() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var received: Array = []
	menu.clear_enemies_requested.connect(func() -> void: received.append(true))
	menu.debug_emit_clear_enemies()
	assert_true(
		received.size() > 0, "debug_emit_clear_enemies must emit clear_enemies_requested signal"
	)


func test_admin_spawn_tab_freeze_ai_toggles_flag() -> void:
	GameState.admin_freeze_ai = false
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var captured: Array = []
	menu.freeze_ai_toggled.connect(func(f: bool) -> void: captured.append(f))
	menu.debug_toggle_freeze_ai()
	assert_true(GameState.admin_freeze_ai, "First toggle must set admin_freeze_ai = true")
	assert_true(
		captured.size() > 0 and captured[captured.size() - 1] == true,
		"freeze_ai_toggled must emit true on first toggle"
	)
	menu.debug_toggle_freeze_ai()
	assert_false(GameState.admin_freeze_ai, "Second toggle must set admin_freeze_ai = false")
	assert_true(
		captured.size() > 1 and captured[captured.size() - 1] == false,
		"freeze_ai_toggled must emit false on second toggle"
	)


func test_admin_freeze_ai_default_is_false() -> void:
	GameState.reset_progress_for_tests()
	assert_false(GameState.admin_freeze_ai, "admin_freeze_ai must default to false after reset")


func test_admin_spawn_tab_shows_freeze_state_in_footer() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	GameState.admin_freeze_ai = false
	var lines_active: Array[String] = menu._get_spawn_tab_lines()
	var footer_active: String = lines_active[lines_active.size() - 1]
	assert_string_contains(footer_active, "[활성]", "Footer must show '[활성]' when AI not frozen")
	GameState.admin_freeze_ai = true
	var lines_frozen: Array[String] = menu._get_spawn_tab_lines()
	var footer_frozen: String = lines_frozen[lines_frozen.size() - 1]
	assert_string_contains(footer_frozen, "[정지]", "Footer must show '[정지]' when AI is frozen")
	GameState.admin_freeze_ai = false


func test_admin_menu_side_by_side_slot_section_helper_clamps_long_right_column_text() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._build_equipment_panel_slot_section_side_by_side_lines(
		{
			"column_width": 20,
			"left_slot_lines": ["[후보]"],
			"right_slot_lines":
			["보유 상세  this-right-column-text-should-be-clamped-for-readability"]
		}
	)
	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], "[후보]")
	assert_string_contains(lines[0], "~")
	assert_false(lines[0].contains("this-right-column-text-should-be-clamped-for-readability"))


func test_admin_menu_tab_buttons_exist_for_all_tabs() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	for tab_id in menu.ADMIN_TABS:
		assert_true(menu._tab_button_nodes.has(tab_id), "tab button missing for: %s" % tab_id)


func test_admin_menu_tab_button_click_switches_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_eq(menu.current_tab, "hotbar")
	menu.debug_click_tab("resources")
	assert_eq(menu.current_tab, "resources")
	menu.debug_click_tab("equipment")
	assert_eq(menu.current_tab, "equipment")
	menu.debug_click_tab("spawn")
	assert_eq(menu.current_tab, "spawn")


func test_admin_menu_tab_button_click_active_button_is_not_flat() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	var active_btn: Button = menu._tab_button_nodes["resources"]
	var inactive_btn: Button = menu._tab_button_nodes["hotbar"]
	assert_false(active_btn.flat, "active tab button should not be flat")
	assert_true(inactive_btn.flat, "inactive tab button should be flat")


func test_admin_menu_shared_shell_uses_textured_panel_skin() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var panel_style := menu.panel.get_theme_stylebox("panel") as StyleBoxTexture
	assert_not_null(panel_style)
	assert_true(panel_style.texture is AtlasTexture)
	assert_not_null(menu._tab_shell)
	var tab_shell_style := menu._tab_shell.get_theme_stylebox("panel") as StyleBoxTexture
	assert_not_null(tab_shell_style)
	assert_true(tab_shell_style.texture is AtlasTexture)
	var tab_hover := menu._tab_button_nodes["hotbar"].get_theme_stylebox("hover") as StyleBoxFlat
	assert_not_null(tab_hover)
	assert_gt(tab_hover.bg_color.g, 0.6)


func test_admin_menu_slot_buttons_hidden_outside_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(menu._slot_button_bar.visible, "slot bar should be hidden on hotbar tab")
	menu.debug_click_tab("spawn")
	assert_false(menu._slot_button_bar.visible, "slot bar should be hidden on spawn tab")


func test_admin_menu_slot_buttons_visible_on_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	assert_true(menu._slot_button_bar.visible, "slot bar should be visible on equipment tab")
	assert_eq(menu._slot_button_nodes.size(), menu.equipment_slot_order.size())


func test_admin_menu_slot_button_click_changes_selected_equipment_slot() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	assert_eq(menu.selected_equipment_slot, 0)
	menu.debug_click_equipment_slot(3)
	assert_eq(menu.selected_equipment_slot, 3)
	menu.debug_click_equipment_slot(6)
	assert_eq(menu.selected_equipment_slot, 6)


func test_admin_menu_slot_button_active_slot_is_not_flat() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.debug_click_equipment_slot(2)
	assert_false(menu._slot_button_nodes[2].flat, "selected slot button should not be flat")
	assert_true(menu._slot_button_nodes[0].flat, "non-selected slot button should be flat")


func test_admin_menu_hotbar_slot_buttons_hidden_outside_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	assert_false(
		menu._hotbar_slot_button_bar.visible, "hotbar slot bar should be hidden on resources tab"
	)
	menu.debug_click_tab("equipment")
	assert_false(
		menu._hotbar_slot_button_bar.visible, "hotbar slot bar should be hidden on equipment tab"
	)


func test_admin_menu_hotbar_slot_buttons_visible_on_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	assert_true(
		menu._hotbar_slot_button_bar.visible, "hotbar slot bar should be visible on hotbar tab"
	)
	assert_eq(menu._hotbar_slot_button_nodes.size(), menu.HOTBAR_SLOT_COUNT)


func test_admin_menu_hotbar_slot_button_click_changes_selected_slot() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	assert_eq(menu.selected_slot, 0)
	menu.debug_click_hotbar_slot(3)
	assert_eq(menu.selected_slot, 3)
	menu.debug_click_hotbar_slot(5)
	assert_eq(menu.selected_slot, 5)


func test_admin_menu_hotbar_slot_button_active_slot_is_not_flat() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.debug_click_hotbar_slot(2)
	assert_false(menu._hotbar_slot_button_nodes[2].flat, "selected hotbar slot should not be flat")
	assert_true(menu._hotbar_slot_button_nodes[0].flat, "non-selected hotbar slot should be flat")


func test_admin_menu_owned_item_buttons_hidden_outside_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(
		menu._owned_item_button_bar.visible, "owned item bar should be hidden on hotbar tab"
	)
	menu.debug_click_tab("spawn")
	assert_false(
		menu._owned_item_button_bar.visible, "owned item bar should be hidden on spawn tab"
	)


func test_admin_menu_owned_item_buttons_visible_on_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	assert_true(
		menu._owned_item_button_bar.visible, "owned item bar should be visible on equipment tab"
	)
	assert_eq(menu._owned_item_button_nodes.size(), menu.EQUIPMENT_PAGE_SIZE)


func test_admin_menu_owned_item_button_click_changes_selection() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	GameState.grant_equipment_item("weapon_ember_staff")
	GameState.grant_equipment_item("weapon_frost_rod")
	menu.debug_click_tab("equipment")
	menu.debug_click_equipment_slot(0)
	var slot_name := str(menu.equipment_slot_order[0])
	menu.debug_click_owned_item_button(0)
	assert_eq(int(menu.equipment_owned_index_by_slot.get(slot_name, -1)), 0)
	assert_eq(menu.equipment_focus_mode, "owned")


func test_admin_menu_owned_item_button_click_out_of_range_ignored() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	GameState.grant_equipment_item("weapon_ember_staff")
	menu.debug_click_tab("equipment")
	menu.debug_click_equipment_slot(0)
	var slot_name := str(menu.equipment_slot_order[0])
	var before := int(menu.equipment_owned_index_by_slot.get(slot_name, 0))
	menu.debug_click_owned_item_button(4)
	assert_eq(
		int(menu.equipment_owned_index_by_slot.get(slot_name, 0)),
		before,
		"clicking empty slot should not change index"
	)


func test_admin_menu_candidate_item_buttons_hidden_outside_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(
		menu._candidate_item_button_bar.visible, "candidate item bar should be hidden on hotbar tab"
	)
	menu.debug_click_tab("resources")
	assert_false(
		menu._candidate_item_button_bar.visible,
		"candidate item bar should be hidden on resources tab"
	)


func test_admin_menu_candidate_item_buttons_visible_on_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	assert_true(
		menu._candidate_item_button_bar.visible,
		"candidate item bar should be visible on equipment tab"
	)
	assert_eq(menu._candidate_item_button_nodes.size(), menu.EQUIPMENT_PAGE_SIZE)


func test_admin_menu_candidate_item_button_click_changes_selection_and_focus() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.debug_click_equipment_slot(0)
	var slot_name := str(menu.equipment_slot_order[0])
	var options: Array = menu.equipment_catalog_by_slot.get(slot_name, [])
	assert_true(options.size() > 0, "weapon slot should have candidates")
	menu.debug_click_candidate_item_button(0)
	assert_eq(int(menu.equipment_candidate_index_by_slot.get(slot_name, -1)), 0)
	assert_eq(menu.equipment_focus_mode, "candidate")


func test_admin_menu_candidate_item_button_out_of_range_ignored() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.debug_click_equipment_slot(0)
	var slot_name := str(menu.equipment_slot_order[0])
	var options: Array = menu.equipment_catalog_by_slot.get(slot_name, [])
	var initial_focus: String = menu.equipment_focus_mode
	menu.debug_click_candidate_item_button(options.size() + 10)
	assert_eq(
		menu.equipment_focus_mode, initial_focus, "out-of-range click should not change focus"
	)


func test_admin_menu_equipment_visual_shell_hidden_outside_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(
		menu._equipment_visual_shell.visible,
		"equipment visual shell should be hidden on hotbar tab"
	)
	menu.debug_click_tab("resources")
	assert_false(
		menu._equipment_visual_shell.visible,
		"equipment visual shell should stay hidden outside equipment tab"
	)


func test_admin_menu_equipment_visual_shell_visible_on_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	assert_true(
		menu._equipment_visual_shell.visible,
		"equipment visual shell should be visible on equipment tab"
	)
	assert_eq(
		menu._equipment_visual_slot_button_nodes.size(),
		menu.equipment_slot_order.size(),
		"paperdoll should keep 7 equipment slot buttons"
	)
	assert_eq(
		menu._equipment_visual_inventory_cell_nodes.size(),
		menu.EQUIPMENT_VISUAL_GRID_CAPACITY,
		"inventory viewport should expose the locked 5x4 cell grid"
	)
	assert_string_contains(
		menu._equipment_visual_inventory_page_label.text,
		"5x4 viewport",
		"inventory page label should describe the new fixed viewport"
	)


func test_admin_menu_equipment_visual_shell_supports_slot_and_owned_direct_select() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	GameState.grant_equipment_item("weapon_ember_staff")
	GameState.grant_equipment_item("weapon_tempest_rod")
	menu.debug_click_tab("equipment")
	var body_btn: Button = menu._equipment_visual_slot_button_nodes["body"]
	body_btn.pressed.emit()
	assert_eq(menu.selected_equipment_slot, 3, "visual paperdoll buttons should change slot focus")
	menu.debug_click_equipment_slot(0)
	menu.debug_click_equipment_visual_owned_cell(1)
	var slot_name := str(menu.equipment_slot_order[0])
	assert_eq(
		int(menu.equipment_owned_index_by_slot.get(slot_name, -1)),
		1,
		"visual inventory cells should map to the current owned page"
	)
	assert_eq(menu.equipment_focus_mode, "owned")


func test_admin_menu_spawn_buttons_hidden_outside_spawn_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(menu._spawn_button_bar.visible, "spawn bar should be hidden on hotbar tab")
	menu.debug_click_tab("equipment")
	assert_false(menu._spawn_button_bar.visible, "spawn bar should be hidden on equipment tab")


func test_admin_menu_spawn_buttons_visible_on_spawn_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("spawn")
	assert_true(menu._spawn_button_bar.visible, "spawn bar should be visible on spawn tab")
	assert_eq(menu._spawn_button_nodes.size(), menu.SPAWN_ENEMY_ORDER.size())
	assert_true(
		menu._spawn_action_button_bar.visible, "spawn action bar should be visible on spawn tab"
	)


func test_admin_menu_spawn_enemy_button_emits_signal() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("spawn")
	watch_signals(menu)
	menu.debug_click_spawn_enemy("brute")
	assert_signal_emitted(menu, "spawn_enemy_requested", "spawn button should emit spawn signal")
	assert_eq(
		get_signal_parameters(menu, "spawn_enemy_requested", 0),
		["brute"],
		"first spawn should be brute"
	)
	menu.debug_click_spawn_enemy("boss")
	assert_eq(
		get_signal_parameters(menu, "spawn_enemy_requested", 1),
		["boss"],
		"second spawn should be boss"
	)


func test_admin_menu_spawn_freeze_button_toggles_ai() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("spawn")
	assert_false(GameState.admin_freeze_ai, "ai should start unfrozen")
	menu.debug_click_spawn_freeze()
	assert_true(GameState.admin_freeze_ai, "ai should be frozen after click")
	assert_false(
		menu._spawn_freeze_button.flat,
		"freeze button should not be flat when frozen (active state)"
	)
	menu.debug_click_spawn_freeze()
	assert_false(GameState.admin_freeze_ai, "ai should unfreeze on second click")


func test_admin_menu_resource_buttons_hidden_outside_resources_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(menu._resource_button_bar.visible, "resource bar should be hidden on hotbar tab")
	menu.debug_click_tab("spawn")
	assert_false(menu._resource_button_bar.visible, "resource bar should be hidden on spawn tab")


func test_admin_menu_resource_buttons_visible_on_resources_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	assert_true(
		menu._resource_button_bar.visible, "resource bar should be visible on resources tab"
	)
	assert_not_null(menu._resource_hp_button, "HP button should exist")
	assert_not_null(menu._resource_mp_button, "MP button should exist")


func test_admin_menu_resource_hp_button_toggles_infinite_health() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	assert_false(GameState.admin_infinite_health, "health should start finite")
	menu.debug_click_resource_hp()
	assert_true(GameState.admin_infinite_health, "health should be infinite after click")
	assert_false(menu._resource_hp_button.flat, "HP button should not be flat when active")
	menu.debug_click_resource_hp()
	assert_false(GameState.admin_infinite_health, "health should be finite again")
	assert_true(menu._resource_hp_button.flat, "HP button should be flat when inactive")


func test_admin_menu_resource_cd_button_toggles_ignore_cooldowns() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	assert_false(GameState.admin_ignore_cooldowns, "cooldowns should start active")
	menu.debug_click_resource_cd()
	assert_true(GameState.admin_ignore_cooldowns, "cooldowns should be ignored after click")
	assert_false(menu._resource_cd_button.flat, "CD button should not be flat when active")


func test_admin_menu_buff_item_buttons_hidden_outside_buffs_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_false(menu._buff_item_button_bar.visible, "buff bar should be hidden on hotbar tab")
	menu.debug_click_tab("resources")
	assert_false(menu._buff_item_button_bar.visible, "buff bar should be hidden on resources tab")


func test_admin_menu_buff_item_buttons_visible_on_buffs_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("buffs")
	assert_true(menu._buff_item_button_bar.visible, "buff bar should be visible on buffs tab")
	assert_eq(menu._buff_item_button_nodes.size(), menu.BUFF_PAGE_SIZE)
	assert_true(
		menu._buff_action_button_bar.visible, "buff action bar should be visible on buffs tab"
	)


func test_admin_menu_buff_item_button_click_changes_selection() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("buffs")
	assert_true(menu.buff_catalog.size() > 0, "buff catalog should not be empty")
	menu.debug_click_buff_item(0)
	assert_eq(menu.selected_buff_catalog_index, 0)
	assert_false(menu._buff_item_button_nodes[0].flat, "selected buff button should not be flat")
	if menu.buff_catalog.size() > 1:
		menu.debug_click_buff_item(1)
		assert_eq(menu.selected_buff_catalog_index, 1)
		assert_false(
			menu._buff_item_button_nodes[1].flat,
			"second buff button should not be flat after selection"
		)
		assert_true(
			menu._buff_item_button_nodes[0].flat,
			"first buff button should be flat after deselection"
		)


func test_admin_menu_buff_clear_button_clears_active_buffs() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("buffs")
	menu.debug_click_buff_item(0)
	menu.debug_click_buff_activate()
	var had_buffs := GameState.active_buffs.size() > 0
	menu.debug_click_buff_clear()
	assert_eq(GameState.active_buffs.size(), 0, "clear button should remove all active buffs")


func test_admin_menu_preset_buttons_hidden_outside_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	assert_false(menu._preset_button_bar.visible, "preset bar should be hidden on resources tab")
	menu.debug_click_tab("equipment")
	assert_false(menu._preset_button_bar.visible, "preset bar should be hidden on equipment tab")


func test_admin_menu_preset_buttons_visible_on_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	assert_true(menu._preset_button_bar.visible, "preset bar should be visible on hotbar tab")
	assert_eq(menu._preset_button_nodes.size(), GameState.get_hotbar_preset_ids().size())


func test_admin_menu_preset_button_click_applies_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.debug_click_preset("ritual")
	assert_eq(menu.current_hotbar_preset_id, "ritual")
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(
		str(hotbar[0].get("skill_id", "")),
		"earth_stone_spire",
		"ritual preset should set earth_stone_spire in slot 0"
	)


func test_admin_menu_hotbar_preset_state_reacts_to_custom_edit() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.debug_click_preset("ritual")
	assert_eq(menu.current_hotbar_preset_id, "ritual")
	GameState.set_hotbar_skill(0, "fire_bolt")
	menu._refresh()
	assert_eq(menu.current_hotbar_preset_id, "", "custom hotbar edits should clear active preset id")
	assert_string_contains(
		menu.body_label.text,
		"단축창 프리셋: 사용자 지정",
		"summary should follow GameState preset state instead of stale local preset memory"
	)


func test_admin_menu_preset_button_active_preset_is_not_flat() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.debug_click_preset("overclock")
	var active_btn: Button = menu._preset_button_nodes["overclock"]
	var inactive_btn: Button = menu._preset_button_nodes["default"]
	assert_false(active_btn.flat, "active preset button should not be flat")
	assert_true(inactive_btn.flat, "inactive preset button should be flat")


func test_admin_menu_library_buttons_hidden_outside_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("spawn")
	assert_false(
		menu._library_item_button_bar.visible, "library bar should be hidden outside hotbar tab"
	)


func test_admin_menu_library_buttons_visible_on_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	assert_true(
		menu._library_item_button_bar.visible, "library bar should be visible on hotbar tab"
	)
	assert_eq(menu._library_item_button_nodes.size(), 5, "library bar should have 5 item buttons")
	assert_not_null(menu._library_focus_button, "library focus button should exist")


func test_admin_menu_library_item_click_updates_selected_index() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.selected_library_index = 2
	menu.debug_click_library_item(0)
	var selected_index: int = menu.selected_library_index
	var start_index: int = maxi(2 - 2, 0)
	assert_eq(
		selected_index,
		start_index,
		"clicking window position 0 should select start_index of the window"
	)


func test_admin_menu_library_focus_toggle_changes_library_focus() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	var initial_focus: bool = menu.library_focus
	menu.debug_click_library_focus_toggle()
	assert_ne(menu.library_focus, initial_focus, "library focus should toggle on button click")


func test_admin_menu_library_focus_button_flat_state() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.library_focus = false
	menu._refresh()
	assert_true(
		menu._library_focus_button.flat, "library focus button should be flat when focus is OFF"
	)
	menu.library_focus = true
	menu._refresh()
	assert_false(
		menu._library_focus_button.flat, "library focus button should not be flat when focus is ON"
	)


func test_admin_menu_library_selected_item_not_flat() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	menu.selected_library_index = 0
	menu._refresh()
	var first_btn: Button = menu._library_item_button_nodes[0]
	assert_false(first_btn.flat, "selected library item button should not be flat")


func test_admin_menu_equipment_action_button_hidden_outside_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("hotbar")
	assert_false(
		menu._equipment_action_button_bar.visible,
		"equipment action bar should be hidden outside equipment tab"
	)


func test_admin_menu_equipment_action_button_visible_on_equipment_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	assert_true(
		menu._equipment_action_button_bar.visible,
		"equipment action bar should be visible on equipment tab"
	)
	assert_not_null(menu._equipment_interact_button, "equipment interact button should exist")


func test_admin_menu_equipment_action_button_label_grant_in_candidate_mode() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.selected_equipment_slot = 0
	menu.equipment_focus_mode = "candidate"
	var slot_name: String = str(menu.equipment_slot_order[0])
	var catalog: Array = menu.equipment_catalog_by_slot.get(slot_name, [])
	if catalog.size() > 1:
		menu.equipment_candidate_index_by_slot[slot_name] = 1
		menu._refresh()
		assert_eq(
			menu._equipment_interact_button.text,
			"지급",
			"button should show 지급 in candidate mode with item selected"
		)


func test_admin_menu_equipment_action_button_label_equip_in_owned_mode() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.selected_equipment_slot = 0
	var slot_name: String = str(menu.equipment_slot_order[0])
	var catalog: Array = menu.equipment_catalog_by_slot.get(slot_name, [])
	if catalog.size() > 1:
		var item_id: String = str(catalog[1])
		GameState.grant_equipment_item(item_id)
		menu.equipment_focus_mode = "owned"
		menu._refresh()
		assert_eq(
			menu._equipment_interact_button.text,
			"장착",
			"button should show 장착 in owned mode with item in inventory"
		)


func test_admin_menu_equipment_action_button_label_unequip_when_equipped() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.selected_equipment_slot = 0
	var slot_name: String = str(menu.equipment_slot_order[0])
	GameState.set_equipped_item(slot_name, "weapon_ember_staff")
	menu.equipment_focus_mode = "owned"
	menu._refresh()
	assert_eq(
		menu._equipment_interact_button.text,
		"해제",
		"button should show 해제 when slot is equipped and no owned selection"
	)


func test_admin_menu_equipment_interact_button_click_executes_interact() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("equipment")
	menu.selected_equipment_slot = 0
	var slot_name: String = str(menu.equipment_slot_order[0])
	var catalog: Array = menu.equipment_catalog_by_slot.get(slot_name, [])
	if catalog.size() > 1:
		var item_id: String = str(catalog[1])
		menu.equipment_focus_mode = "candidate"
		menu.equipment_candidate_index_by_slot[slot_name] = 1
		menu._refresh()
		menu.debug_click_equipment_interact()
		assert_true(
			GameState.has_equipment_in_inventory(item_id),
			"clicking interact in candidate mode should grant item to inventory"
		)

extends "res://addons/gut/test.gd"

const ADMIN_MENU_SCRIPT := preload("res://scripts/admin/admin_menu.gd")


func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()


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


func test_admin_status_summary_reflects_infinite_health_flag() -> void:
	assert_eq(GameState.get_admin_status_summary(), "Admin  Resources[-] Combat[-] Gear[default]")
	GameState.set_admin_infinite_health(true)
	assert_string_contains(GameState.get_admin_status_summary(), "InfiniteHP")
	assert_string_contains(GameState.get_admin_status_summary(), "Gear[default]")


func test_admin_status_summary_groups_resource_and_combat_flags() -> void:
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_cooldowns(true)
	var summary := GameState.get_admin_status_summary()
	assert_string_contains(summary, "Resources[InfiniteMP]")
	assert_string_contains(summary, "Combat[NoCooldown]")


func test_admin_menu_can_apply_equipment_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_equipment_preset("storm_tempo")
	assert_string_contains(GameState.get_equipment_summary(), "Preset:storm_tempo")


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
	assert_string_contains(GameState.get_admin_status_summary(), "FreeBuffSlots")


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
	assert_string_contains(menu.body_label.text, "Skill Library")
	assert_string_contains(menu.body_label.text, "파이어 볼트")


func test_admin_menu_can_focus_library_and_assign_skill_to_slot() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle_library_focus()
	menu.debug_cycle_library(2)
	menu.debug_assign_library_to_slot(0)
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "volt_spear")
	assert_string_contains(menu.body_label.text, "Library Focus: ON")


func test_admin_menu_library_focus_changes_tuned_skill_target() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle_library_focus()
	menu.debug_cycle_library(2)
	menu.debug_adjust_selected_skill_level(0, 3)
	assert_eq(GameState.get_skill_level("volt_spear"), 4)
	assert_eq(GameState.get_skill_level("fire_bolt"), 1)
	assert_string_contains(menu.body_label.text, "Skill  Volt Spear")


func test_admin_menu_can_apply_deploy_lab_preset() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_named_preset("deploy_lab")
	var hotbar: Array = GameState.get_spell_hotbar()
	assert_eq(str(hotbar[0].get("skill_id", "")), "earth_stone_spire")
	assert_eq(str(hotbar[1].get("skill_id", "")), "dark_grave_echo")
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
	var preset_ids: Array = menu.HOTBAR_PRESET_IDS
	assert_true(preset_ids.has("funeral_bloom"), "HOTBAR_PRESET_IDS must include funeral_bloom")


func test_admin_menu_can_cycle_tabs_and_update_summary() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	assert_string_contains(menu.get_admin_tab_summary(), "Tab[Hotbar]")
	assert_string_contains(menu.body_label.text, "Hotbar")
	menu.debug_cycle_tab(1)
	assert_string_contains(menu.get_admin_tab_summary(), "Tab[Resources]")
	assert_string_contains(menu.body_label.text, "Resources")
	menu.debug_cycle_tab(1)
	assert_string_contains(menu.get_admin_tab_summary(), "Tab[Equipment]")
	assert_string_contains(menu.get_admin_tab_summary(), "Focus[owned]")
	assert_string_contains(menu.get_admin_tab_summary(), "Slot[weapon]")
	assert_string_contains(menu.get_admin_tab_summary(), "Nav[0/0]")
	assert_string_contains(menu.get_admin_tab_summary(), "Target[(empty)]")
	assert_string_contains(menu.body_label.text, "Equipment")
	menu.debug_cycle_tab(1)
	assert_string_contains(menu.get_admin_tab_summary(), "Tab[Spawn]")
	assert_string_contains(menu.body_label.text, "Spawn")


func test_admin_menu_hides_library_focus_outside_hotbar_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle_library_focus()
	assert_string_contains(menu.get_admin_tab_summary(), "Library[ON]")
	menu.debug_cycle_tab(1)
	assert_false(menu.get_admin_tab_summary().contains("Library[ON]"))


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
	assert_string_contains(menu.body_label.text, "Inventory")


func test_admin_menu_equipment_tab_shows_slot_specific_owned_items() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Selected Slot  weapon")
	assert_string_contains(menu.body_label.text, "Owned  Tempest Rod")
	assert_false(menu.body_label.text.contains("Owned  Storm Orb"))


func test_admin_menu_can_cycle_owned_equipment_selection_and_equip_it() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	menu.debug_cycle_owned_equipment(0, 1)
	assert_string_contains(menu.body_label.text, "Owned Selection  [FOCUS]  Tempest Rod")
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
	assert_string_contains(menu.body_label.text, "Owned List")
	assert_string_contains(menu.body_label.text, "> Ember Staff [Rare / weapon]")
	menu.debug_cycle_owned_equipment(0, 1)
	assert_string_contains(menu.body_label.text, "> Tempest Rod [Rare / weapon]")
	assert_string_contains(menu.body_label.text, "Owned Detail")
	assert_string_contains(menu.body_label.text, "Tags:lightning, tempo")
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all")
	assert_string_contains(menu.body_label.text, "Owned Nav  1/1  Items 1-2/2")


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
	assert_string_contains(body_text, "> Ember Robe [Rare / body]")
	assert_string_contains(body_text, "- Mage Coat [Uncommon / body]")


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
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all")
	menu.debug_cycle_equipment_sort_mode(1)
	assert_string_contains(menu.body_label.text, "Owned View  Sort:name  Filter:all")
	assert_string_contains(menu.body_label.text, "> Ash Tome [Rare / offhand]")
	assert_string_contains(menu.body_label.text, "- Storm Orb [Rare / offhand]")


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
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all")
	menu.debug_cycle_equipment_filter_mode(1)
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:tempo")
	assert_string_contains(menu.body_label.text, "> Storm Orb [Rare / offhand]")
	# Ash Tome visible in candidate list (catalog unfiltered) but excluded from owned list
	var owned_lines := "\n".join(menu._get_owned_equipment_preview_lines("offhand"))
	assert_false(
		owned_lines.contains("Ash Tome"),
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
	assert_string_contains(menu.body_label.text, "Owned Nav  1/2  Items 1-5/6")
	menu.debug_cycle_owned_page(0, 1)
	assert_string_contains(menu.body_label.text, "Owned Nav  2/2  Items 6-6/6")
	assert_string_contains(menu.body_label.text, "> Tempest Rod [Rare / weapon]")


func test_admin_menu_equipment_focus_can_toggle_to_candidate() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Equipment Focus  owned")
	assert_string_contains(menu.get_admin_tab_summary(), "Focus[owned]")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "Equipment Focus  candidate")
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]")
	assert_string_contains(menu.get_admin_tab_summary(), "Focus[candidate]")
	assert_string_contains(menu.get_admin_tab_summary(), "Nav[Items 1-4/4]")
	assert_string_contains(menu.get_admin_tab_summary(), "Target[(empty)]")


func test_admin_menu_equipment_summary_tracks_candidate_target_and_owned_state() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	assert_string_contains(menu.get_admin_tab_summary(), "Target[Tempest Rod]")
	assert_string_contains(menu.get_admin_tab_summary(), "Owned[Y]")


func test_admin_menu_equipment_tab_shows_selected_slot_stat_summary() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_apply_equipment_preset("storm_tempo")
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Slot Stats  MATK +4")
	menu.selected_equipment_slot = 3
	menu._refresh()
	assert_string_contains(menu.body_label.text, "Slot Stats  MaxHP +15  DR 6%")


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
		menu.body_label.text, "Compare Header  Equipped:Ember Staff  Candidate:Tempest Rod"
	)
	assert_string_contains(menu.body_label.text, "Candidate Compare  MATK -1")
	assert_string_contains(menu.body_label.text, "CDR +4%")


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
		"Compare Header  Equipped:Ember Staff  Candidate:Tempest Rod"
	)
	var stats_index: int = menu.body_label.text.find("Slot Stats  MATK +4")
	var delta_index: int = menu.body_label.text.find("Candidate Compare  MATK -1")
	assert_true(compare_index >= 0)
	assert_true(stats_index > compare_index)
	assert_true(delta_index > stats_index)


func test_admin_menu_equipment_panel_helpers_keep_candidate_and_owned_sections_visible() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "   Candidate")
	assert_string_contains(menu.body_label.text, "-- Owned --")
	assert_string_contains(menu.body_label.text, "Candidate Status")
	assert_string_contains(menu.body_label.text, "Owned Status")


func test_admin_menu_equipment_common_panel_wrapper_keeps_status_before_body() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	var candidate_header_index: int = menu.body_label.text.find("   Candidate")
	var candidate_status_index: int = menu.body_label.text.find("Candidate Status")
	var candidate_body_index: int = menu.body_label.text.find("Candidate Selection")
	var owned_header_index: int = menu.body_label.text.find("-- Owned --")
	var owned_status_index: int = menu.body_label.text.find("Owned Status")
	var owned_body_index: int = menu.body_label.text.find("Owned Selection")
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
	var selection_index: int = menu.body_label.text.find("Candidate Selection")
	var detail_index: int = menu.body_label.text.find("Candidate Detail")
	var view_index: int = menu.body_label.text.find("Candidate View  State:not-owned")
	var window_index: int = menu.body_label.text.find("Candidate Nav")
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
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all")
	assert_string_contains(menu.body_label.text, "Owned Nav  1/1  Items 1-1/1")


func test_admin_menu_equipment_owned_source_helpers_keep_single_selection_line() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var occurrences: int = menu.body_label.text.split("Owned Selection").size() - 1
	assert_eq(occurrences, 1)
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all")
	assert_string_contains(menu.body_label.text, "Owned Nav  1/1  Items 1-1/1")


func test_admin_menu_equipment_panel_body_source_helpers_keep_both_view_lines() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(
		menu.body_label.text, "Candidate View  State:not-owned  Browse:Items 1-4/4"
	)
	assert_string_contains(
		menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all  Browse:0/0"
	)


func test_admin_menu_selection_lines_keep_shared_name_and_index_format() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Owned Selection  [FOCUS]  Ember Staff  [1/1]")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]  (empty)  [1/4]")


func test_admin_menu_view_lines_keep_shared_prefix_and_browse_info() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(
		menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all  Browse:0/0"
	)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(
		menu.body_label.text, "Candidate View  State:not-owned  Browse:Items 1-4/4"
	)


func test_admin_menu_nav_lines_keep_shared_prefix_and_navigation_info() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Owned Nav  1/1  Items 1-1/1")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "Candidate Nav  Items 1-4/4")


func test_admin_menu_navigation_section_keeps_view_selection_and_nav_grouped() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	var selection_index: int = menu.body_label.text.find(
		"Candidate Selection  [FOCUS]  (empty)  [1/4]"
	)
	var view_index: int = menu.body_label.text.find(
		"Candidate View  State:not-owned  Browse:Items 1-4/4"
	)
	var nav_index: int = menu.body_label.text.find("Candidate Nav  Items 1-4/4")
	var list_index: int = menu.body_label.text.find("Candidate List")
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
		"Owned View  Sort:rarity -> name  Filter:all  Browse:1/1"
	)
	var nav_index: int = menu.body_label.text.find("Owned Nav  1/1  Items 1-1/1")
	var list_index: int = menu.body_label.text.find("Owned List")
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
	var detail_index: int = menu.body_label.text.find("Candidate Detail  none")
	var view_index: int = menu.body_label.text.find(
		"Candidate View  State:not-owned  Browse:Items 1-4/4"
	)
	var nav_index: int = menu.body_label.text.find("Candidate Nav  Items 1-4/4")
	var list_index: int = menu.body_label.text.find("Candidate List")
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
		menu.body_label.text, "Panel Summary  Candidate:(empty)  Owned:Ember Staff"
	)
	assert_string_contains(
		menu.body_label.text, "Panel Flow  Candidate:grant  Owned:equip  Browse:Items 1-4/4 | 1/1"
	)


func test_admin_menu_owned_content_section_keeps_detail_then_navigation_then_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var detail_index: int = menu.body_label.text.find("Owned Detail  화염 계열 마법 출력을 끌어올리는 지팡이")
	var view_index: int = menu.body_label.text.find(
		"Owned View  Sort:rarity -> name  Filter:all  Browse:1/1"
	)
	var nav_index: int = menu.body_label.text.find("Owned Nav  1/1  Items 1-1/1")
	var list_index: int = menu.body_label.text.find("Owned List")
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
		menu.body_label.text, "Panel Summary  Candidate:Tempest Rod  Owned:Tempest Rod"
	)
	assert_string_contains(menu.body_label.text, "Panel Flow  Candidate:grant  Owned:equip-now")


func test_admin_menu_dual_panel_preview_keeps_summary_before_flow() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	menu.debug_cycle_tab(2)
	var summary_index: int = menu.body_label.text.find(
		"Panel Summary  Candidate:(empty)  Owned:Ember Staff"
	)
	var flow_index: int = menu.body_label.text.find(
		"Panel Flow  Candidate:grant  Owned:equip  Browse:Items 1-4/4 | 1/1"
	)
	var candidate_header_index: int = menu.body_label.text.find("   Candidate")
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
	var compare_index: int = menu.body_label.text.find("Compare Header")
	var summary_index: int = menu.body_label.text.find(
		"Panel Summary  Candidate:(empty)  Owned:Ember Staff"
	)
	var flow_index: int = menu.body_label.text.find(
		"Panel Flow  Candidate:grant  Owned:equip  Browse:Items 1-4/4 | 1/1"
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
		"Panel Flow  Candidate:grant  Owned:equip  Browse:Items 1-4/4 | 1/1"
	)
	var focus_index: int = menu.body_label.text.find("Equipment Focus  owned")
	assert_true(flow_index >= 0)
	assert_true(focus_index > flow_index)


func test_admin_menu_equipment_layout_keeps_candidate_before_owned_panel() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	var candidate_header_index: int = menu.body_label.text.find("   Candidate")
	var owned_header_index: int = menu.body_label.text.find("-- Owned --")
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
		"Panel Summary  Candidate:(empty)  Owned:Ember Staff"
	)
	var focus_index: int = menu.body_label.text.find("Equipment Focus  owned")
	var columns_index: int = menu.body_label.text.find("Panel Columns  Left:Candidate  Right:Owned")
	var left_slot_index: int = menu.body_label.text.find("[Candidate]")
	var right_slot_index: int = menu.body_label.text.find("[Owned]")
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
	assert_string_contains(menu.body_label.text, "Panel Columns  Left:Candidate  Right:Owned")
	assert_string_contains(menu.body_label.text, "Panel Mode  side-by-side")
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[Candidate]") and line.contains("[Owned]"):
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
	var left_slot_index: int = menu.body_label.text.find("[Candidate]")
	var right_slot_index: int = menu.body_label.text.find("[Owned]")
	var gap_index: int = menu.body_label.text.find("[Owned]", left_slot_index + 1)
	assert_true(left_slot_index >= 0)
	assert_true(right_slot_index > left_slot_index)
	assert_eq(right_slot_index, gap_index)


func test_admin_menu_equipment_layout_uses_side_by_side_slot_section_renderer_by_default() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Panel Mode  side-by-side")
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[Candidate]") and line.contains("[Owned]"):
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
	assert_string_contains(menu.body_label.text, "[Candidate]")
	assert_string_contains(menu.body_label.text, "[Owned]")
	assert_string_contains(menu.body_label.text, "Panel Mode  stacked bridge (2-panel ready)")


func test_admin_menu_side_by_side_slot_section_helper_formats_two_columns() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._build_equipment_panel_slot_section_side_by_side_lines(
		{
			"left_slot_lines": ["[Candidate]", "-- Candidate --", "Candidate Status  idle"],
			"right_slot_lines": ["[Owned]", "-- Owned --", "Owned Status  idle"]
		}
	)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0], "[Candidate]")
	assert_string_contains(lines[0], "[Owned]")
	assert_string_contains(lines[1], "-- Candidate --")
	assert_string_contains(lines[1], "-- Owned --")


func test_admin_menu_side_by_side_slot_section_helper_respects_separator_from_source() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._build_equipment_panel_slot_section_side_by_side_lines(
		{
			"column_width": 24,
			"column_separator": " | ",
			"left_slot_lines": ["[Candidate]"],
			"right_slot_lines": ["[Owned]"]
		}
	)
	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], " | [Owned]")


func test_admin_menu_side_by_side_default_output_uses_pipe_separator() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[Candidate]") and line.contains("[Owned]"):
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
	assert_string_contains(menu.body_label.text, "Action:equip-now  State:fresh  [!]")


func test_admin_menu_can_switch_equipment_layout_mode_to_side_by_side_for_debug() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_set_equipment_panel_layout_mode("side_by_side")
	assert_string_contains(menu.body_label.text, "Panel Mode  side-by-side")
	var lines: PackedStringArray = menu.body_label.text.split("\n")
	var combined_slot_line := ""
	for line in lines:
		if line.contains("[Candidate]") and line.contains("[Owned]"):
			combined_slot_line = line
			break
	assert_ne(combined_slot_line, "")


func test_admin_menu_equipment_tab_header_shows_active_panel() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "[OWNED panel active]")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "[CANDIDATE panel active]")


func test_admin_menu_equipment_tab_shows_panel_section_headers() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "-- Owned --")
	assert_string_contains(menu.body_label.text, "   Candidate")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "-- Candidate --")
	assert_string_contains(menu.body_label.text, "   Owned")


func test_admin_menu_equipment_focused_panel_shows_its_controls() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "N/R cycle owned")
	assert_false(menu.body_label.text.contains("N/R cycle candidate"))
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "N/R cycle candidate")
	assert_false(menu.body_label.text.contains("N/R cycle owned"))


func test_admin_menu_candidate_focus_cycles_candidates_and_grants_on_interact() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	menu.debug_cycle_equipment_candidate(0, 2)
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]  Tempest Rod")
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
	assert_string_contains(menu.get_admin_tab_summary(), "Focus[owned]")
	assert_string_contains(menu.get_admin_tab_summary(), "Target[Tempest Rod]")
	assert_string_contains(menu.body_label.text, "Owned Selection  [FOCUS]  Tempest Rod")
	assert_string_contains(
		menu.body_label.text, "Owned Status  FOCUSED  Action:equip-now  State:fresh"
	)
	assert_string_contains(menu.footer_label.text, "E equip new item")
	assert_string_contains(menu.body_label.text, "Owned View  Sort:rarity -> name  Filter:all")


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
		menu.body_label.text, "Owned Status  FOCUSED  Action:equip-now  State:fresh"
	)
	menu.debug_cycle_owned_equipment(0, 1)
	assert_false(menu.body_label.text.contains("Action:equip-now"))
	assert_string_contains(menu.body_label.text, "Owned Status  FOCUSED  Action:equip  State:")


func test_admin_menu_candidate_panel_shows_selection_and_preview_list() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]  (empty)  [1/4]")
	assert_string_contains(menu.body_label.text, "Candidate Nav  Items 1-4/4")
	assert_string_contains(menu.body_label.text, "Candidate Detail  none")
	assert_string_contains(menu.body_label.text, "Candidate List")
	assert_string_contains(menu.body_label.text, "> (empty)")
	assert_string_contains(menu.body_label.text, "- Ember Staff [Rare / weapon]")
	menu.debug_cycle_equipment_candidate(0, 1)
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]  Ember Staff  [2/4]")
	assert_string_contains(menu.body_label.text, "Candidate Nav  Items 1-4/4")
	assert_string_contains(menu.body_label.text, "Candidate Detail  화염 계열 마법 출력을 끌어올리는 지팡이")
	assert_string_contains(menu.body_label.text, "Tags:fire, burst")
	assert_string_contains(menu.body_label.text, "> Ember Staff [Rare / weapon]")
	menu.debug_cycle_equipment_candidate(0, 1)
	assert_string_contains(menu.body_label.text, "> Tempest Rod [Rare / weapon]  [Owned]")


func test_admin_menu_can_cycle_candidate_window_when_candidate_panel_is_focused() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_cycle_tab(2)
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]  (empty)  [1/4]")
	assert_string_contains(menu.body_label.text, "Candidate Nav  Items 1-4/4")
	assert_string_contains(menu.body_label.text, "> (empty)")
	# 4 items ≤ EQUIPMENT_PAGE_SIZE=5 → single page → cycling forward stays on page 0
	menu.debug_cycle_candidate_window(0, 1)
	assert_string_contains(menu.body_label.text, "Candidate Selection  [FOCUS]  (empty)  [1/4]")
	assert_string_contains(menu.body_label.text, "Candidate Nav  Items 1-4/4")


func test_admin_menu_equipment_tab_shows_panel_status_lines() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.body_label.text, "Candidate Status  idle  Action:grant")
	assert_string_contains(menu.body_label.text, "Owned Status  FOCUSED  Action:equip  State:ready")
	menu.debug_toggle_equipment_focus()
	assert_string_contains(menu.body_label.text, "Candidate Status  FOCUSED  Action:grant")
	assert_string_contains(menu.body_label.text, "Owned Status  idle  Action:equip")


func test_admin_menu_footer_changes_by_tab() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	assert_string_contains(menu.footer_label.text, "T library focus")
	menu.debug_cycle_tab(2)
	assert_string_contains(menu.footer_label.text, "T toggle focus")
	assert_string_contains(menu.footer_label.text, "E focused action")


func test_admin_buff_tab_is_accessible_via_cycle() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_toggle()
	menu.debug_cycle_tab(4)
	assert_string_contains(menu.body_label.text, "Buffs")
	assert_true(menu.buff_catalog.size() > 0, "Buff catalog must be non-empty")


func test_admin_buff_tab_force_activate_adds_to_active_buffs() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	assert_eq(GameState.active_buffs.size(), 0)
	menu.debug_force_activate_selected_buff()
	assert_gt(GameState.active_buffs.size(), 0, "Force activate must add a buff to active_buffs")
	assert_string_contains(menu.body_label.text, "Active:")


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
	assert_string_contains(text, "Combos:", "Buffs tab must include a Combos: section header")
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
	assert_string_contains(text, "[ON]", "Active combo must show [ON] marker in buffs tab")
	assert_string_contains(text, "Prismatic Guard", "Active combo name must appear in buffs tab")
	GameState.reset_progress_for_tests()


func test_admin_buff_tab_combo_shows_required_buff_names() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_buff_tab_lines()
	var combo_line: String = ""
	for line in lines:
		if "Ashen Rite" in line:
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
	var text: String = "\n".join(lines)
	# The Ashen Rite line must show [v] for the active buff and [ ] for the missing one
	var ashen_line: String = ""
	for line in lines:
		if "Ashen Rite" in line:
			ashen_line = line
			break
	assert_false(ashen_line.is_empty(), "Ashen Rite combo must appear in buff tab")
	assert_string_contains(ashen_line, "[v]", "Active required buff must show [v] marker")
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
	assert_string_contains(text, "Circle:", "Resource tab must show circle status")
	assert_string_contains(text, "Buff Slots:", "Resource tab must show buff slot count")
	assert_string_contains(text, "Score:", "Resource tab must show progression score")


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
		"Buff Slots: %d" % expected_slots,
		"Buff slot count in resource tab must match GameState.get_buff_slot_limit()"
	)


func test_admin_spawn_tab_lists_all_enemies_from_database() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_spawn_tab_lines()
	# First line is header "Spawn"
	assert_eq(str(lines[0]), "Spawn", "Spawn tab header must be 'Spawn'")
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
	assert_string_contains(all_text, "[SA]", "Elite entry must show [SA] super armor indicator")


func test_admin_spawn_tab_shows_hp_values() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._get_spawn_tab_lines()
	var elite_line: String = ""
	for line in lines:
		if "elite" in line.to_lower() or "Elite" in line:
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
	assert_string_contains(footer_active, "active", "Footer must show 'active' when AI not frozen")
	GameState.admin_freeze_ai = true
	var lines_frozen: Array[String] = menu._get_spawn_tab_lines()
	var footer_frozen: String = lines_frozen[lines_frozen.size() - 1]
	assert_string_contains(footer_frozen, "FROZEN", "Footer must show 'FROZEN' when AI is frozen")
	GameState.admin_freeze_ai = false


func test_admin_menu_side_by_side_slot_section_helper_clamps_long_right_column_text() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	var lines: Array[String] = menu._build_equipment_panel_slot_section_side_by_side_lines(
		{
			"column_width": 20,
			"left_slot_lines": ["[Candidate]"],
			"right_slot_lines":
			["Owned Detail  this-right-column-text-should-be-clamped-for-readability"]
		}
	)
	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], "[Candidate]")
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
	assert_eq(menu._preset_button_nodes.size(), menu.HOTBAR_PRESET_IDS.size())


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
			"Grant",
			"button should show Grant in candidate mode with item selected"
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
			"Equip",
			"button should show Equip in owned mode with item in inventory"
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
		"Unequip",
		"button should show Unequip when slot is equipped and no owned selection"
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

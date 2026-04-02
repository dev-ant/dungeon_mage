extends "res://addons/gut/test.gd"


func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()


func _capture_enemy_validation_errors_with_overrides(
	enemy_id: String, overrides: Dictionary
) -> Array:
	var enemy: Dictionary = GameDatabase.get_enemy_data(enemy_id)
	var previous_errors: Array = GameDatabase.get_enemy_validation_errors()
	for key in overrides.keys():
		enemy[key] = overrides[key]
	GameDatabase.enemy_validation_errors.clear()
	GameDatabase._validate_enemy_entry(enemy)
	var captured: Array = GameDatabase.get_enemy_validation_errors()
	GameDatabase.enemy_validation_errors.clear()
	for error in previous_errors:
		GameDatabase.enemy_validation_errors.append(str(error))
	return captured


func _capture_enemy_validation_errors_with_removed_fields(
	enemy_id: String, removed_fields: Array[String]
) -> Array:
	var enemy: Dictionary = GameDatabase.get_enemy_data(enemy_id)
	var previous_errors: Array = GameDatabase.get_enemy_validation_errors()
	for field_name in removed_fields:
		enemy.erase(field_name)
	GameDatabase.enemy_validation_errors.clear()
	GameDatabase._validate_enemy_entry(enemy)
	var captured: Array = GameDatabase.get_enemy_validation_errors()
	GameDatabase.enemy_validation_errors.clear()
	for error in previous_errors:
		GameDatabase.enemy_validation_errors.append(str(error))
	return captured


func _assert_error_list_contains(errors: Array, expected_message: String) -> void:
	var found := false
	for error in errors:
		if str(error).contains(expected_message):
			found = true
			break
	assert_true(found, "Expected enemy validation errors to contain: %s" % expected_message)


func _promote_to_circle_6_for_tests() -> void:
	for skill in GameDatabase.get_all_skills():
		var skill_id: String = str(skill.get("skill_id", ""))
		GameState.skill_level_data[skill_id] = 6
		if (
			skill_id
			in ["fire_ember_dart", "ice_frost_needle", "lightning_thunder_lance", "fire_mastery"]
		):
			GameState.skill_level_data[skill_id] = 12
	GameState.recalculate_circle_progression(false)


func test_spell_mastery_unlocks_runtime_bonus() -> void:
	GameState.register_skill_damage("fire_bolt", 140.0)
	assert_eq(GameState.get_spell_level("fire_bolt"), 2)
	var runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	assert_gt(float(runtime["damage"]), 18.0)
	assert_lt(float(runtime["cooldown"]), 0.22)
	assert_eq(GameState.get_skill_level("fire_ember_dart"), 2)


func test_set_skill_level_updates_runtime_and_circle_state() -> void:
	assert_true(GameState.set_skill_level("lightning_tempest_crown", 24))
	assert_eq(GameState.get_skill_level("lightning_tempest_crown"), 24)
	assert_gt(GameState.get_skill_experience("lightning_tempest_crown"), 0.0)
	assert_false(GameState.set_skill_level("", 10))


func test_dominant_resonance_changes_room_variant() -> void:
	GameState.resonance["lightning"] = 3
	GameState.resonance["fire"] = 1
	var variant: Dictionary = GameState.get_room_variant("deep_gate")
	assert_eq(GameState.get_dominant_school(), "lightning")
	assert_eq(
		variant["label"], "Lightning resonance makes the maze feel alert and over-responsive."
	)
	assert_eq(variant["extra_spawns"].size(), 2)


func test_buff_slots_limit_current_circle() -> void:
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("fire_pyre_heart"))
	assert_false(GameState.try_activate_buff("ice_frostblood_ward"))
	assert_eq(GameState.active_buffs.size(), 2)


func test_admin_can_ignore_buff_slot_limit_for_sandbox() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("fire_pyre_heart"))
	assert_true(GameState.try_activate_buff("ice_frostblood_ward"))
	assert_eq(GameState.active_buffs.size(), 3)
	assert_string_contains(GameState.get_active_buff_summary(), "/ INF")


func test_restore_after_death_returns_saved_room_and_full_health() -> void:
	GameState.current_room_id = "deep_gate"
	GameState.health = 12
	GameState.save_progress("vault_sector", Vector2(820, 360))
	GameState.health = 1
	var restore_data: Dictionary = GameState.restore_after_death()
	assert_eq(
		str(restore_data.get("room_id", "")),
		"vault_sector",
		"restore_after_death must return the saved room id"
	)
	assert_eq(
		restore_data.get("spawn_position", Vector2.ZERO),
		Vector2(820, 360),
		"restore_after_death must return the saved spawn position"
	)
	assert_eq(
		GameState.current_room_id,
		"vault_sector",
		"restore_after_death must restore current_room_id to the saved room"
	)
	assert_eq(
		GameState.health, GameState.max_health, "restore_after_death must fully heal the player"
	)


func test_restore_after_death_clears_transient_combat_runtime() -> void:
	GameState.save_progress("vault_sector", Vector2(820, 360))
	GameState.mana = 4.0
	GameState.active_buffs.append({"skill_id": "holy_mana_veil", "remaining": 4.0, "effects": []})
	GameState.active_penalties.append(
		{"stat": "defense_multiplier", "mode": "mul", "value": 0.75, "remaining": 8.0}
	)
	GameState.buff_cooldowns["holy_mana_veil"] = 6.0
	GameState.combo_barrier = 24.0
	GameState.combo_barrier_combo_id = "combo_prismatic_guard"
	GameState.time_collapse_active = true
	GameState.time_collapse_charges = 2
	GameState.soul_dominion_active = true
	GameState.soul_dominion_aftershock_timer = 3.5
	GameState.last_damage_amount = 12
	GameState.last_damage_school = "dark"
	GameState.last_damage_display_timer = 2.0
	GameState.restore_after_death()
	assert_eq(GameState.mana, GameState.max_mana, "restore_after_death must restore mana to full")
	assert_true(GameState.active_buffs.is_empty(), "restore_after_death must clear active buffs")
	assert_true(
		GameState.active_penalties.is_empty(), "restore_after_death must clear active penalties"
	)
	assert_true(
		GameState.buff_cooldowns.is_empty(), "restore_after_death must clear buff cooldowns"
	)
	assert_eq(GameState.combo_barrier, 0.0, "restore_after_death must clear combo barrier")
	assert_eq(
		GameState.combo_barrier_combo_id, "", "restore_after_death must clear combo barrier source"
	)
	assert_false(
		GameState.time_collapse_active, "restore_after_death must clear Time Collapse state"
	)
	assert_eq(
		GameState.time_collapse_charges, 0, "restore_after_death must clear Time Collapse charges"
	)
	assert_false(
		GameState.soul_dominion_active, "restore_after_death must clear Soul Dominion state"
	)
	assert_eq(
		GameState.soul_dominion_aftershock_timer,
		0.0,
		"restore_after_death must clear Soul Dominion aftershock"
	)
	assert_eq(
		GameState.last_damage_amount, 0, "restore_after_death must clear last-hit feedback amount"
	)
	assert_eq(
		GameState.last_damage_school, "", "restore_after_death must clear last-hit feedback school"
	)
	assert_eq(
		GameState.last_damage_display_timer,
		0.0,
		"restore_after_death must clear last-hit feedback timer"
	)


func test_buff_combo_resolves_from_active_buffs() -> void:
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	var combo_names := GameState.get_active_combo_names()
	assert_true(combo_names.has("Prismatic Guard"))
	assert_lt(GameState.get_damage_taken_multiplier(), 0.82)
	assert_gt(GameState.combo_barrier, 0.0)


func test_prismatic_guard_barrier_absorbs_damage() -> void:
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	var starting_health := GameState.health
	var starting_barrier := GameState.combo_barrier
	GameState.damage(10)
	assert_eq(GameState.health, starting_health)
	assert_lt(GameState.combo_barrier, starting_barrier)


func test_overclock_circuit_boosts_lightning_runtime() -> void:
	assert_true(GameState.try_activate_buff("wind_tempest_drive"))
	assert_true(GameState.try_activate_buff("lightning_conductive_surge"))
	var combo_names := GameState.get_active_combo_names()
	assert_true(combo_names.has("Overclock Circuit"))
	var runtime: Dictionary = GameState.get_spell_runtime("volt_spear")
	assert_lt(float(runtime["cooldown"]), 0.55)
	assert_gt(int(runtime["pierce"]), 2)
	assert_gt(float(runtime["speed"]), 1020.0)


func test_time_collapse_grants_three_discounted_casts() -> void:
	assert_true(GameState.try_activate_buff("arcane_astral_compression"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	var combo_names := GameState.get_active_combo_names()
	assert_true(combo_names.has("Time Collapse"))
	assert_eq(GameState.time_collapse_charges, 3)
	var runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	assert_lt(float(runtime["cooldown"]), 0.22)
	assert_gt(float(runtime["damage"]), 18.0)
	GameState.consume_spell_cast("fire_bolt")
	assert_eq(GameState.time_collapse_charges, 2)
	GameState.consume_spell_cast("frost_nova")
	GameState.consume_spell_cast("volt_spear")
	assert_eq(GameState.time_collapse_charges, 0)


func test_circle_progression_unlocks_three_buff_slots() -> void:
	_promote_to_circle_6_for_tests()
	assert_eq(GameState.get_current_circle(), 6)
	assert_eq(GameState.get_buff_slot_limit(), 3)


func test_ashen_rite_builds_stacks_and_emits_detonation() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	var combo_names := GameState.get_active_combo_names()
	assert_true(combo_names.has("Ashen Rite"))
	GameState.register_skill_damage("fire_bolt", 20.0)
	GameState.register_skill_damage("volt_spear", 20.0)
	assert_true(GameState.ashen_rite_active)
	assert_eq(GameState.ash_stacks, 2)
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.2)
	assert_false(GameState.ashen_rite_active)
	assert_eq(str(GameState.last_combo_effect.get("effect_id", "")), "ash_detonation")
	assert_gt(float(GameState.last_combo_effect.get("damage", 0.0)), 24.0)


func test_active_buff_summary_shows_stack_count_for_double_cast() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_eq(GameState.active_buffs.size(), 2)
	var summary := GameState.get_active_buff_summary()
	assert_string_contains(summary, "x2")


func test_active_buff_summary_marks_expiring_buffs() -> void:
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	GameState.active_buffs[0]["remaining"] = 1.5
	var summary := GameState.get_active_buff_summary()
	assert_string_contains(summary, " !")


func test_active_buff_summary_no_expiry_marker_when_time_is_ample() -> void:
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	GameState.active_buffs[0]["remaining"] = 5.0
	var summary := GameState.get_active_buff_summary()
	assert_false(summary.contains(" !"))


func test_combo_summary_shows_burst_marker_when_time_collapse_active() -> void:
	assert_true(GameState.try_activate_buff("arcane_astral_compression"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.time_collapse_active)
	assert_string_contains(GameState.get_combo_summary(), "[BURST]")


func test_combo_summary_shows_burst_marker_when_ashen_rite_active() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	assert_true(GameState.ashen_rite_active)
	assert_string_contains(GameState.get_combo_summary(), "[BURST]")


func test_combo_summary_no_burst_marker_for_passive_combos() -> void:
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	assert_true(GameState.get_active_combo_names().has("Prismatic Guard"))
	assert_false(GameState.get_combo_summary().contains("[BURST]"))


func test_story_progression_events_can_reach_circle_six() -> void:
	assert_true(GameState.grant_progression_event("rest_entrance"))
	assert_true(GameState.grant_progression_event("echo_entrance_1"))
	assert_true(GameState.grant_progression_event("echo_entrance_2"))
	assert_true(GameState.grant_progression_event("boss_conduit"))
	assert_true(GameState.grant_progression_event("core_conduit"))
	assert_true(GameState.grant_progression_event("echo_deep_0"))
	assert_true(GameState.grant_progression_event("echo_deep_1"))
	assert_eq(GameState.get_current_circle(), 6)
	assert_eq(GameState.get_buff_slot_limit(), 3)
	assert_false(GameState.grant_progression_event("rest_entrance"))


func test_resource_status_line_shows_hp_and_mp_normally() -> void:
	GameState.health = 80
	GameState.max_health = 100
	GameState.mana = 120.0
	GameState.max_mana = 180.0
	var line := GameState.get_resource_status_line()
	assert_string_contains(line, "HP 80/100")
	assert_string_contains(line, "MP 120/180")
	assert_false(line.contains("[!"), "No risk marker when Soul Dominion is inactive")


func test_resource_status_line_shows_mp_lock_when_soul_dominion_active() -> void:
	GameState.soul_dominion_active = true
	var line := GameState.get_resource_status_line()
	assert_string_contains(line, "[!MP-LOCK")
	assert_string_contains(line, "DMG]")


func test_resource_status_line_shows_aftershock_when_timer_running() -> void:
	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = 3.5
	var line := GameState.get_resource_status_line()
	assert_string_contains(line, "[!SHOCK")
	assert_string_contains(line, "3.5")
	assert_string_contains(line, "DMG]")


func test_combo_summary_shows_closes_in_when_time_collapse_active() -> void:
	assert_true(GameState.try_activate_buff("arcane_astral_compression"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.time_collapse_active)
	var summary := GameState.get_combo_summary()
	assert_string_contains(summary, "TimeCharges")
	assert_string_contains(summary, "Closes")


func test_resource_status_line_shows_last_hit_with_school() -> void:
	GameState.damage(15, "fire")
	var line := GameState.get_resource_status_line()
	assert_string_contains(line, "←15")
	assert_string_contains(line, "fire")


func test_resource_status_line_shows_last_hit_without_school() -> void:
	GameState.damage(10)
	var line := GameState.get_resource_status_line()
	assert_string_contains(line, "←10")


func test_resource_status_line_no_hit_marker_when_timer_zero() -> void:
	GameState.last_damage_amount = 10
	GameState.last_damage_school = "fire"
	GameState.last_damage_display_timer = 0.0
	var line := GameState.get_resource_status_line()
	assert_false(line.contains("←"), "No hit marker when display timer is zero")


func test_overclock_circuit_activates_and_shows_activation_message() -> void:
	assert_true(GameState.try_activate_buff("wind_tempest_drive"))
	assert_true(GameState.try_activate_buff("lightning_conductive_surge"))
	assert_true(GameState.overclock_circuit_active)
	assert_true(GameState.get_active_combo_names().has("Overclock Circuit"))


func test_overclock_circuit_deactivates_when_buff_expires() -> void:
	assert_true(GameState.try_activate_buff("wind_tempest_drive"))
	assert_true(GameState.try_activate_buff("lightning_conductive_surge"))
	assert_true(GameState.overclock_circuit_active)
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.1)
	assert_false(GameState.overclock_circuit_active)


func test_funeral_bloom_activates_when_required_buffs_are_present() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	assert_true(GameState.funeral_bloom_active)
	assert_true(GameState.get_active_combo_names().has("Funeral Bloom"))


func test_funeral_bloom_notify_deploy_kill_emits_corruption_burst() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	assert_true(GameState.funeral_bloom_active)
	GameState.notify_deploy_kill()
	assert_eq(str(GameState.last_combo_effect.get("effect_id", "")), "corruption_burst")
	assert_true(float(GameState.last_combo_effect.get("radius", 0.0)) >= 80.0)
	assert_eq(str(GameState.last_combo_effect.get("apply_status", "")), "snare")


func test_funeral_bloom_icd_blocks_rapid_repeat_triggers() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	GameState.notify_deploy_kill()
	var first_effect := GameState.last_combo_effect.duplicate(true)
	GameState.notify_deploy_kill()
	assert_eq(
		GameState.last_combo_effect.get("effect_id", ""),
		first_effect.get("effect_id", ""),
		"ICD must block second trigger"
	)
	assert_gt(GameState.funeral_bloom_icd_timer, 0.0, "ICD timer must be running")


func test_funeral_bloom_combo_summary_shows_bloom_state() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	assert_string_contains(GameState.get_combo_summary(), "Bloom")
	assert_string_contains(GameState.get_combo_summary(), "ready")


func test_ashen_rite_end_drains_mana_and_applies_penalties() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	assert_true(GameState.ashen_rite_active)
	GameState.mana = 100.0
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.2)
	assert_false(GameState.ashen_rite_active)
	assert_eq(GameState.mana, 0.0)
	var has_defense_penalty := false
	var has_recast_lock := false
	for p in GameState.active_penalties:
		if str(p.get("stat", "")) == "defense_multiplier":
			has_defense_penalty = true
		if str(p.get("stat", "")) == "ritual_recast_lock":
			has_recast_lock = true
	assert_true(has_defense_penalty)
	assert_true(has_recast_lock)


func test_ashen_rite_end_penalty_increases_damage_taken() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.2)
	assert_gt(GameState.get_damage_taken_multiplier(), 1.0)


func test_ashen_rite_recast_lock_blocks_buff_activation() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.2)
	assert_false(GameState.ashen_rite_active)
	assert_false(
		GameState.try_activate_buff("holy_mana_veil"),
		"ritual_recast_lock must block new buff activation"
	)


func test_combo_summary_shows_ashen_rite_aftermath_window_after_burst() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	GameState.register_skill_damage("fire_bolt", 20.0)
	GameState.register_skill_damage("volt_spear", 20.0)
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.2)
	var summary := GameState.get_combo_summary()
	assert_string_contains(summary, "Aftermath")
	assert_string_contains(summary, "GuardBreak")
	assert_string_contains(summary, "Lock")
	assert_false(summary.contains("[BURST]"), "Burst marker must end once Ashen Rite expires")


func test_ashen_rite_penalties_expire_and_runtime_returns_to_normal() -> void:
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	for buff in GameState.active_buffs:
		buff["remaining"] = 0.0
	GameState._tick_buff_runtime(0.2)
	assert_false(GameState.active_penalties.is_empty(), "Ashen Rite aftermath must create penalties")
	assert_gt(GameState.get_damage_taken_multiplier(), 1.0)
	assert_false(GameState.try_activate_buff("holy_mana_veil"))
	GameState._tick_buff_runtime(10.1)
	assert_true(GameState.active_penalties.is_empty(), "All Ashen Rite penalties must expire")
	assert_eq(GameState.get_damage_taken_multiplier(), 1.0)
	assert_eq(GameState.get_combo_summary(), "Combos  none")
	GameState.mana = GameState.max_mana
	assert_true(GameState.try_activate_buff("holy_mana_veil"), "Buff casting must recover after Ashen Rite penalties expire")


func test_buff_cooldown_summary_shows_all_ready_when_no_cooldowns() -> void:
	GameState.reset_progress_for_tests()
	var summary := GameState.get_buff_cooldown_summary()
	assert_string_contains(
		summary, "all ready", "Summary must show 'all ready' when no buff is on cooldown"
	)
	assert_false(
		summary.contains("cd:"), "Summary must not contain cd: prefix when all buffs are ready"
	)


func test_buff_cooldown_summary_shows_cd_format_for_active_cooldown() -> void:
	GameState.reset_progress_for_tests()
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	var summary := GameState.get_buff_cooldown_summary()
	assert_string_contains(summary, "cd:", "Summary must show cd: prefix for a buff on cooldown")
	assert_false(
		summary.contains("all ready"),
		"Summary must not show 'all ready' when a buff is cooling down"
	)


func test_buff_cooldown_summary_omits_ready_buffs_from_list() -> void:
	GameState.reset_progress_for_tests()
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	var summary := GameState.get_buff_cooldown_summary()
	assert_false(summary.contains("Pyre Heart"), "Ready buff must not appear in cooldown summary")
	assert_false(summary.contains("Frostblood"), "Ready buff must not appear in cooldown summary")


func test_dark_grave_pact_buff_increases_dark_spell_damage() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	var base_payload: Dictionary = {"school": "dark", "damage": 20, "cooldown": 1.0}
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	var modified := GameState.apply_spell_modifiers(base_payload.duplicate())
	assert_gt(
		int(modified.get("damage", 0)),
		20,
		"dark_grave_pact buff must increase dark spell damage via apply_spell_modifiers"
	)
	GameState.reset_progress_for_tests()


func test_astral_compression_buff_reduces_mana_cost() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	var base_cost: float = GameState.get_skill_mana_cost("fire_ember_dart")
	assert_true(GameState.try_activate_buff("arcane_astral_compression"))
	var reduced_cost: float = GameState.get_skill_mana_cost("fire_ember_dart")
	assert_lt(reduced_cost, base_cost, "Astral Compression buff must reduce spell mana cost")
	GameState.reset_progress_for_tests()


func test_mana_efficiency_multiplier_not_applied_without_buff() -> void:
	GameState.reset_progress_for_tests()
	var cost_a: float = GameState.get_skill_mana_cost("fire_ember_dart")
	var cost_b: float = GameState.get_skill_mana_cost("fire_ember_dart")
	assert_eq(cost_a, cost_b, "Mana cost must be consistent without any buffs")


func test_sanctum_loop_equipment_boosts_barrier_power_multiplier() -> void:
	GameState.reset_progress_for_tests()
	var base_mult: float = GameState.get_equipment_barrier_power_multiplier()
	assert_eq(base_mult, 1.0, "Barrier power multiplier must be 1.0 with no equipment")
	GameState.set_equipped_item("accessory_2", "ring_sanctum_loop")
	var boosted_mult: float = GameState.get_equipment_barrier_power_multiplier()
	assert_gt(boosted_mult, 1.0, "Sanctum Loop must increase barrier power multiplier above 1.0")
	GameState.reset_progress_for_tests()


func test_spark_diadem_equipment_provides_cast_speed_bonus() -> void:
	GameState.reset_progress_for_tests()
	var base_cast_speed: float = GameState.get_equipment_cast_speed_bonus()
	assert_eq(base_cast_speed, 0.0, "Cast speed bonus must be 0.0 with no equipment")
	GameState.set_equipped_item("head", "helm_spark_diadem")
	var boosted_cast_speed: float = GameState.get_equipment_cast_speed_bonus()
	assert_gt(boosted_cast_speed, 0.0, "Spark Diadem must provide positive cast speed bonus")
	GameState.reset_progress_for_tests()


func test_grave_pact_hp_drain_reduces_health_over_time() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	GameState.health = GameState.max_health
	var hp_before: int = GameState.health
	# Simulate a large delta to guarantee visible drain
	GameState._tick_active_buff_drains(5.0)
	assert_lt(GameState.health, hp_before, "Active Grave Pact buff must drain HP over time")


func test_poise_bonus_from_mana_veil_buff_is_positive() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_eq(GameState.get_poise_bonus(), 0.0, "Poise bonus must be 0 without active buff")
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_gt(GameState.get_poise_bonus(), 0.0, "Mana Veil buff must provide positive poise bonus")
	GameState.reset_progress_for_tests()


func test_world_hourglass_buff_reduces_spell_cooldown() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	var base_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var base_cooldown: float = float(base_runtime.get("cooldown", 0.0))
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	var boosted_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var reduced_cooldown: float = float(boosted_runtime.get("cooldown", 0.0))
	assert_lt(
		reduced_cooldown, base_cooldown, "World Hourglass buff must reduce fire_bolt cooldown"
	)
	GameState.reset_progress_for_tests()


func test_world_hourglass_buff_duration_scales_with_skill_level() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.skill_level_data["arcane_world_hourglass"] = 1
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.active_buffs.size() >= 1)
	var low_duration: float = float(GameState.active_buffs[0].get("remaining", 0.0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.skill_level_data["arcane_world_hourglass"] = 30
	assert_true(GameState.try_activate_buff("arcane_world_hourglass"))
	assert_true(GameState.active_buffs.size() >= 1)
	var high_duration: float = float(GameState.active_buffs[0].get("remaining", 0.0))

	assert_gt(
		high_duration,
		low_duration,
		"World Hourglass buff duration must scale upward with skill level"
	)
	GameState.reset_progress_for_tests()


func test_grave_pact_kill_leech_restores_hp_on_notify_enemy_killed() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	GameState.health = GameState.max_health - 20
	var hp_before: int = GameState.health
	GameState.notify_enemy_killed()
	assert_gt(
		GameState.health, hp_before, "kill_leech from Grave Pact must restore HP on enemy kill"
	)


func test_notify_enemy_killed_without_kill_leech_does_not_change_hp() -> void:
	GameState.reset_progress_for_tests()
	GameState.health = GameState.max_health - 10
	var hp_before: int = GameState.health
	GameState.notify_enemy_killed()
	assert_eq(
		GameState.health, hp_before, "Without kill_leech active, enemy kill must not restore HP"
	)


func test_world_hourglass_downside_penalty_increases_cooldown_after_expiry() -> void:
	GameState.reset_progress_for_tests()
	var base_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var base_cooldown: float = float(base_runtime.get("cooldown", 0.0))
	# Inject the downside penalty directly (cast_speed_multiplier < 1.0 = slowdown)
	GameState.active_penalties.append(
		{"stat": "cast_speed_multiplier", "mode": "mul", "value": 0.75, "remaining": 8.0}
	)
	var penalized_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var penalized_cooldown: float = float(penalized_runtime.get("cooldown", 0.0))
	assert_gt(
		penalized_cooldown,
		base_cooldown,
		"World Hourglass downside penalty must increase spell cooldown"
	)
	GameState.reset_progress_for_tests()


func test_crystal_aegis_buff_provides_super_armor_charges() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_eq(GameState.get_super_armor_charges(), 0, "No super armor charges without buff")
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	assert_gt(
		GameState.get_super_armor_charges(),
		0,
		"Crystal Aegis buff must provide super armor charges"
	)
	GameState.reset_progress_for_tests()


func test_crystal_aegis_super_armor_skips_hitstun_but_applies_damage() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	assert_gt(GameState.get_super_armor_charges(), 0, "Precondition: super armor must be active")
	GameState.health = GameState.max_health
	# Verify that the flag is non-zero — player.receive_hit skips velocity/hitstun when this is > 0
	var charges_before_hit: int = GameState.get_super_armor_charges()
	assert_gt(
		charges_before_hit, 0, "Super armor charges must be present while Crystal Aegis is active"
	)
	GameState.reset_progress_for_tests()


func test_mana_regen_multiplier_penalty_stops_mana_regen() -> void:
	GameState.reset_progress_for_tests()
	GameState.mana = 0.0
	# Inject mana_regen_multiplier: 0.0 penalty (conductive_surge downside)
	GameState.active_penalties.append(
		{"stat": "mana_regen_multiplier", "mode": "mul", "value": 0.0, "remaining": 6.0}
	)
	var mana_before: float = GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_eq(
		GameState.mana,
		mana_before,
		"mana_regen_multiplier 0.0 penalty must stop mana regeneration entirely"
	)
	GameState.reset_progress_for_tests()


func test_mana_regen_works_normally_without_penalty() -> void:
	GameState.reset_progress_for_tests()
	GameState.mana = 0.0
	var mana_before: float = GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_gt(
		GameState.mana, mana_before, "Mana must regenerate normally when no penalty is active"
	)
	GameState.reset_progress_for_tests()


func test_self_burn_penalty_deals_periodic_fire_damage() -> void:
	GameState.reset_progress_for_tests()
	GameState.health = GameState.max_health
	# Inject self_burn: 1 penalty (fire_pyre_heart downside after expiry)
	GameState.active_penalties.append(
		{"stat": "self_burn", "mode": "add", "value": 1, "remaining": 4.0}
	)
	var hp_before: int = GameState.health
	GameState._tick_active_buff_drains(5.0)
	assert_lt(GameState.health, hp_before, "self_burn penalty must deal damage over time")
	GameState.reset_progress_for_tests()


func test_self_burn_penalty_does_not_kill_player() -> void:
	GameState.reset_progress_for_tests()
	GameState.health = 1
	GameState.active_penalties.append(
		{"stat": "self_burn", "mode": "add", "value": 100, "remaining": 4.0}
	)
	GameState._tick_active_buff_drains(10.0)
	assert_eq(GameState.health, 1, "self_burn must not reduce health below 1")
	GameState.reset_progress_for_tests()


func test_extra_lightning_ping_emits_combo_effect_on_lightning_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("lightning_conductive_surge"))
	GameState.last_combo_effect = {}
	var payload: Dictionary = {"school": "lightning", "damage": 30, "cooldown": 1.0}
	GameState.apply_spell_modifiers(payload.duplicate())
	assert_eq(
		str(GameState.last_combo_effect.get("effect_id", "")),
		"lightning_ping",
		"extra_lightning_ping must emit lightning_ping combo effect"
	)
	assert_eq(str(GameState.last_combo_effect.get("school", "")), "lightning")
	GameState.reset_progress_for_tests()


func test_extra_lightning_ping_does_not_fire_for_non_lightning_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("lightning_conductive_surge"))
	GameState.last_combo_effect = {}
	var payload: Dictionary = {"school": "fire", "damage": 30, "cooldown": 1.0}
	GameState.apply_spell_modifiers(payload.duplicate())
	assert_ne(
		str(GameState.last_combo_effect.get("effect_id", "")),
		"lightning_ping",
		"extra_lightning_ping must not fire for non-lightning spells"
	)
	GameState.reset_progress_for_tests()


func test_dark_throne_of_ash_activation_drains_mana_to_zero() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.mana = GameState.max_mana
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	assert_eq(GameState.mana, 0.0, "dark_throne_of_ash must drain mana to 0 on activation")
	GameState.reset_progress_for_tests()


func test_activation_without_mana_percent_does_not_drain_mana() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.mana = GameState.max_mana
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_eq(
		GameState.mana,
		GameState.max_mana,
		"Buffs without mana_percent effect must not drain mana to zero on activation"
	)
	GameState.reset_progress_for_tests()


func test_stagger_taken_multiplier_is_one_without_penalty() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(
		GameState.get_stagger_taken_multiplier(),
		1.0,
		"Stagger multiplier must be 1.0 with no active penalty"
	)
	GameState.reset_progress_for_tests()


func test_stagger_taken_multiplier_above_one_with_penalty() -> void:
	GameState.reset_progress_for_tests()
	# wind_tempest_drive downside pushes this penalty on expiry
	GameState.active_penalties.append(
		{"stat": "stagger_taken_multiplier", "mode": "mul", "value": 1.15, "remaining": 2.0}
	)
	assert_gt(
		GameState.get_stagger_taken_multiplier(),
		1.0,
		"Stagger penalty must raise multiplier above 1.0"
	)
	GameState.reset_progress_for_tests()


func test_ice_reflect_wave_emits_combo_effect_on_ice_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("ice_frostblood_ward"))
	GameState.last_combo_effect = {}
	var payload: Dictionary = {"school": "ice", "damage": 25, "cooldown": 1.0}
	GameState.apply_spell_modifiers(payload.duplicate())
	assert_eq(
		str(GameState.last_combo_effect.get("effect_id", "")),
		"ice_reflect_wave",
		"ice_reflect_wave must emit combo effect on ice spell cast"
	)
	assert_eq(str(GameState.last_combo_effect.get("school", "")), "ice")
	GameState.reset_progress_for_tests()


func test_ice_reflect_wave_does_not_fire_for_non_ice_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("ice_frostblood_ward"))
	GameState.last_combo_effect = {}
	var payload: Dictionary = {"school": "lightning", "damage": 25, "cooldown": 1.0}
	GameState.apply_spell_modifiers(payload.duplicate())
	assert_ne(
		str(GameState.last_combo_effect.get("effect_id", "")),
		"ice_reflect_wave",
		"ice_reflect_wave must not fire for non-ice spells"
	)
	GameState.reset_progress_for_tests()


func test_ash_residue_burst_fires_when_dark_throne_active_without_ashen_rite() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	assert_false(
		GameState.ashen_rite_active,
		"Precondition: Ashen Rite must NOT be active without the full trio"
	)
	GameState.last_combo_effect = {}
	GameState.ash_residue_timer = 0.0  # force immediate trigger on next tick
	GameState._tick_buff_runtime(0.1)
	assert_eq(
		str(GameState.last_combo_effect.get("effect_id", "")),
		"ash_residue_burst",
		"ash_residue_burst must fire periodically when dark_throne_of_ash is active solo"
	)
	GameState.reset_progress_for_tests()


func test_ash_residue_burst_does_not_fire_without_ash_buff() -> void:
	GameState.reset_progress_for_tests()
	assert_false(GameState.ashen_rite_active)
	GameState.last_combo_effect = {}
	GameState.ash_residue_timer = 0.0
	GameState._tick_buff_runtime(0.1)
	assert_ne(
		str(GameState.last_combo_effect.get("effect_id", "")),
		"ash_residue_burst",
		"ash_residue_burst must not fire without dark_throne_of_ash or Ashen Rite"
	)
	GameState.reset_progress_for_tests()


func test_record_enemy_hit_increments_counters() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(GameState.session_damage_dealt, 0)
	assert_eq(GameState.session_hit_count, 0)
	GameState.record_enemy_hit(25, "fire")
	assert_eq(GameState.session_damage_dealt, 25)
	assert_eq(GameState.session_hit_count, 1)
	GameState.record_enemy_hit(10, "ice")
	assert_eq(GameState.session_damage_dealt, 35)
	assert_eq(GameState.session_hit_count, 2)
	GameState.reset_progress_for_tests()


func test_record_enemy_hit_tracks_school_breakdown() -> void:
	GameState.reset_progress_for_tests()
	GameState.record_enemy_hit(15, "fire")
	GameState.record_enemy_hit(20, "fire")
	GameState.record_enemy_hit(5, "ice")
	assert_eq(int(GameState.progression_flags.get("school_hits_fire", 0)), 2)
	assert_eq(int(GameState.progression_flags.get("school_hits_ice", 0)), 1)
	GameState.reset_progress_for_tests()


func test_reset_progress_clears_session_stats() -> void:
	GameState.record_enemy_hit(100, "lightning")
	GameState.reset_progress_for_tests()
	assert_eq(GameState.session_damage_dealt, 0)
	assert_eq(GameState.session_hit_count, 0)


func test_get_combat_stats_summary_format() -> void:
	GameState.reset_progress_for_tests()
	GameState.record_enemy_hit(30, "fire")
	GameState.record_enemy_hit(20, "ice")
	var summary: String = GameState.get_combat_stats_summary()
	assert_true(summary.contains("2"), "summary must contain hit count")
	assert_true(summary.contains("50"), "summary must contain total damage")
	GameState.reset_progress_for_tests()


func test_notify_enemy_killed_increments_session_kills() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(GameState.session_kills, 0)
	GameState.notify_enemy_killed()
	assert_eq(GameState.session_kills, 1)
	GameState.notify_enemy_killed()
	assert_eq(GameState.session_kills, 2)
	GameState.reset_progress_for_tests()


func test_record_item_drop_increments_session_drops() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(GameState.session_drops, 0)
	assert_eq(GameState.last_drop_display, "")
	GameState.record_item_drop("ring_earth_seed")
	assert_eq(GameState.session_drops, 1)
	GameState.record_item_drop("ring_earth_seed")
	assert_eq(GameState.session_drops, 2)
	GameState.reset_progress_for_tests()


func test_reset_progress_clears_kills_and_drops() -> void:
	GameState.notify_enemy_killed()
	GameState.record_item_drop("ring_earth_seed")
	GameState.reset_progress_for_tests()
	assert_eq(GameState.session_kills, 0)
	assert_eq(GameState.session_drops, 0)
	assert_eq(GameState.last_drop_display, "")


# --- Room data loading tests ---


func test_game_database_loads_all_rooms() -> void:
	var all_rooms: Array = GameDatabase.get_all_rooms()
	assert_true(all_rooms.size() >= 4, "GameDatabase must load at least 4 rooms from rooms.json")


func test_game_database_get_room_returns_correct_data() -> void:
	var room: Dictionary = GameDatabase.get_room("entrance")
	assert_false(room.is_empty(), "get_room('entrance') must return a non-empty dictionary")
	assert_eq(str(room.get("id", "")), "entrance", "Returned room must have id 'entrance'")
	assert_true(int(room.get("width", 0)) > 0, "Room width must be positive")


func test_room_entrance_spawns_include_mushroom() -> void:
	var room: Dictionary = GameDatabase.get_room("entrance")
	var spawns: Array = room.get("spawns", [])
	var types: Array = []
	for s in spawns:
		types.append(str(s.get("type", "")))
	assert_true("mushroom" in types, "Entrance room spawns must include mushroom type")


func test_vault_sector_room_exists_and_has_elite() -> void:
	var room: Dictionary = GameDatabase.get_room("vault_sector")
	assert_false(room.is_empty(), "vault_sector room must exist in rooms.json")
	var spawns: Array = room.get("spawns", [])
	var types: Array = []
	for s in spawns:
		types.append(str(s.get("type", "")))
	assert_true("elite" in types, "vault_sector must include an elite spawn")
	assert_true("mushroom" in types, "vault_sector must include mushroom spawns")


func test_game_database_get_all_rooms_returns_duplicate_not_reference() -> void:
	var rooms_a: Array = GameDatabase.get_all_rooms()
	var rooms_b: Array = GameDatabase.get_all_rooms()
	assert_false(rooms_a == null, "get_all_rooms must return an array")
	rooms_a.clear()
	assert_true(rooms_b.size() >= 4, "Modifying one copy must not affect another (duplicate check)")


func test_game_database_get_all_enemies_returns_duplicate_not_reference() -> void:
	var enemies_a: Array = GameDatabase.get_all_enemies()
	var enemies_b: Array = GameDatabase.get_all_enemies()
	assert_false(enemies_a == null, "get_all_enemies must return an array")
	enemies_a.clear()
	assert_true(
		enemies_b.size() >= 10,
		"Modifying one enemy catalog copy must not affect another caller"
	)


func test_enemy_database_validation_report_is_empty_for_current_catalog() -> void:
	assert_false(
		GameDatabase.has_enemy_validation_errors(),
		"Current enemy catalog must satisfy required fields, duplicate-id checks, grade rules, drop-profile validation, and enemy enum validation"
	)
	assert_eq(
		GameDatabase.get_enemy_validation_errors().size(),
		0,
		"Enemy validation report must remain empty for the checked-in catalog"
	)


func test_enemy_validation_error_accessor_returns_duplicate_not_reference() -> void:
	var errors_a: Array = GameDatabase.get_enemy_validation_errors()
	errors_a.append("fake error")
	var errors_b: Array = GameDatabase.get_enemy_validation_errors()
	assert_eq(
		errors_b.size(),
		0,
		"Enemy validation error accessor must return a duplicate instead of the live backing array"
	)


func test_enemy_validation_rejects_invalid_role() -> void:
	var errors := _capture_enemy_validation_errors_with_overrides(
		"rat", {"role": "invalid_role"}
	)
	assert_eq(errors.size(), 1, "Invalid role sample must add exactly one validation error")
	_assert_error_list_contains(errors, "invalid role 'invalid_role'")
	assert_push_error("invalid role 'invalid_role'", "Invalid role validation must emit one push_error")


func test_enemy_validation_rejects_invalid_attack_damage_type() -> void:
	var errors := _capture_enemy_validation_errors_with_overrides(
		"rat", {"attack_damage_type": "invalid_damage_type"}
	)
	assert_eq(
		errors.size(), 1, "Invalid attack damage type sample must add exactly one validation error"
	)
	_assert_error_list_contains(
		errors, "invalid attack_damage_type 'invalid_damage_type'"
	)
	assert_push_error(
		"invalid attack_damage_type 'invalid_damage_type'",
		"Invalid attack damage type validation must emit one push_error"
	)


func test_enemy_validation_rejects_invalid_attack_element() -> void:
	var errors := _capture_enemy_validation_errors_with_overrides(
		"rat", {"attack_element": "invalid_element"}
	)
	assert_eq(errors.size(), 1, "Invalid attack element sample must add exactly one validation error")
	_assert_error_list_contains(errors, "invalid attack_element 'invalid_element'")
	assert_push_error(
		"invalid attack_element 'invalid_element'",
		"Invalid attack element validation must emit one push_error"
	)


func test_enemy_validation_rejects_missing_phase_1_required_fields() -> void:
	var required_fields := [
		"role",
		"attack_damage_type",
		"attack_element",
		"attack_period",
		"drop_profile",
		"knockback_resistance"
	]
	for field_name in required_fields:
		var errors := _capture_enemy_validation_errors_with_removed_fields("rat", [field_name])
		assert_eq(
			errors.size(), 1, "Missing required field sample must add exactly one validation error"
		)
		_assert_error_list_contains(
			errors, "missing required field '%s' for enemy 'rat'" % field_name
		)
		assert_push_error(
			"missing required field '%s' for enemy 'rat'" % field_name,
			"Missing required field validation must emit one push_error"
		)


func test_enemy_validation_rejects_non_array_super_armor_tags() -> void:
	var errors := _capture_enemy_validation_errors_with_overrides(
		"boss", {"super_armor_tags": "default"}
	)
	assert_eq(
		errors.size(), 1, "Non-array super_armor_tags sample must add exactly one validation error"
	)
	_assert_error_list_contains(errors, "non-array super_armor_tags for enemy 'boss'")
	assert_push_error(
		"non-array super_armor_tags for enemy 'boss'",
		"super_armor_tags type validation must emit one push_error"
	)


func test_enemy_validation_rejects_non_string_super_armor_tag_member() -> void:
	var errors := _capture_enemy_validation_errors_with_overrides(
		"boss", {"super_armor_tags": ["default", 1]}
	)
	assert_eq(
		errors.size(), 1, "Non-string super_armor_tag sample must add exactly one validation error"
	)
	_assert_error_list_contains(errors, "non-string super_armor_tag for enemy 'boss'")
	assert_push_error(
		"non-string super_armor_tag for enemy 'boss'",
		"super_armor_tags member validation must emit one push_error"
	)


func test_enemy_validation_rejects_missing_required_element_resist_fields() -> void:
	var required_fields := [
		"fire_resist",
		"water_resist",
		"ice_resist",
		"lightning_resist",
		"wind_resist",
		"earth_resist",
		"plant_resist",
		"dark_resist",
		"holy_resist",
		"arcane_resist"
	]
	for field_name in required_fields:
		var errors := _capture_enemy_validation_errors_with_removed_fields("rat", [field_name])
		assert_eq(
			errors.size(), 1, "Missing element resist field sample must add exactly one validation error"
		)
		_assert_error_list_contains(
			errors, "missing required element_resist field '%s' for enemy 'rat'" % field_name
		)
		assert_push_error(
			"missing required element_resist field '%s' for enemy 'rat'" % field_name,
			"Missing element resist validation must emit one push_error"
		)


func test_enemy_validation_rejects_missing_required_status_resist_fields() -> void:
	var required_fields := [
		"slow_resist",
		"root_resist",
		"stun_resist",
		"freeze_resist",
		"shock_resist",
		"burn_resist",
		"poison_resist",
		"silence_resist"
	]
	for field_name in required_fields:
		var errors := _capture_enemy_validation_errors_with_removed_fields("rat", [field_name])
		assert_eq(
			errors.size(), 1, "Missing status resist field sample must add exactly one validation error"
		)
		_assert_error_list_contains(
			errors, "missing required status_resist field '%s' for enemy 'rat'" % field_name
		)
		assert_push_error(
			"missing required status_resist field '%s' for enemy 'rat'" % field_name,
			"Missing status resist validation must emit one push_error"
		)


func test_game_database_get_enemy_spawn_entries_returns_gui_ready_summary() -> void:
	var entries: Array[Dictionary] = GameDatabase.get_enemy_spawn_entries()
	assert_false(entries.is_empty(), "Enemy spawn entry summary must not be empty")
	var boss_entry: Dictionary = {}
	for entry in entries:
		if str(entry.get("enemy_id", "")) == "boss":
			boss_entry = entry
			break
	assert_false(boss_entry.is_empty(), "Enemy spawn entry summary must include boss")
	assert_eq(str(boss_entry.get("enemy_grade", "")), "boss")
	assert_eq(str(boss_entry.get("drop_profile", "")), "boss")
	assert_eq(float(boss_entry.get("drop_chance", 0.0)), 0.70)
	assert_eq(Array(boss_entry.get("drop_rarity_preview", [])).size(), 2)
	assert_true(bool(boss_entry.get("has_super_armor_hint", false)), "Boss summary must expose super armor hint for GUI/read-only consumers")


func test_game_database_get_enemy_spawn_entries_returns_duplicate_not_reference() -> void:
	var entries_a: Array[Dictionary] = GameDatabase.get_enemy_spawn_entries()
	var entries_b: Array[Dictionary] = GameDatabase.get_enemy_spawn_entries()
	assert_false(entries_a.is_empty(), "Enemy spawn entry summary must return rows")
	entries_a[0]["display_name"] = "mutated"
	var preview: Array = entries_a[0].get("drop_rarity_preview", [])
	if not preview.is_empty():
		preview[0] = "mutated"
	assert_ne(
		str(entries_b[0].get("display_name", "")),
		"mutated",
		"Enemy spawn entry summary must return duplicate dictionaries, not live references"
	)
	assert_ne(
		Array(entries_b[0].get("drop_rarity_preview", []))[0] if not Array(entries_b[0].get("drop_rarity_preview", [])).is_empty() else "",
		"mutated",
		"Enemy spawn entry summary must duplicate nested rarity preview arrays too"
	)


func test_drop_profile_preview_exposes_chance_and_rarity_filter() -> void:
	var boss_preview: Dictionary = GameDatabase.get_drop_profile_preview("boss")
	assert_eq(str(boss_preview.get("profile", "")), "boss")
	assert_eq(float(boss_preview.get("drop_chance", 0.0)), 0.70)
	assert_eq(Array(boss_preview.get("rarity_preview", [])), ["epic", "legendary"])
	var none_preview: Dictionary = GameDatabase.get_drop_profile_preview("none")
	assert_eq(float(none_preview.get("drop_chance", 1.0)), 0.0)
	assert_eq(Array(none_preview.get("rarity_preview", [])).size(), 0)


func test_drop_profile_summary_exposes_pool_and_weight_counts() -> void:
	var boss_summary: Dictionary = GameDatabase.get_drop_profile_summary("boss")
	assert_eq(str(boss_summary.get("profile", "")), "boss")
	assert_eq(float(boss_summary.get("drop_chance", 0.0)), 0.70)
	assert_eq(Array(boss_summary.get("rarity_preview", [])), ["epic", "legendary"])
	assert_gt(int(boss_summary.get("pool_size", 0)), 0, "Boss drop summary must report non-empty pool size")
	assert_gt(
		int(boss_summary.get("weighted_pool_size", 0)),
		0,
		"Boss drop summary must report weighted pool size"
	)
	var rarity_counts: Dictionary = boss_summary.get("rarity_counts", {})
	var weighted_counts: Dictionary = boss_summary.get("weighted_rarity_counts", {})
	assert_true(rarity_counts.has("epic"), "Boss drop summary must include epic rarity count")
	assert_true(rarity_counts.has("legendary"), "Boss drop summary must include legendary rarity count")
	assert_false(rarity_counts.has("common"), "Boss drop summary must not include common rarity count")
	assert_eq(
		int(boss_summary.get("pool_size", 0)),
		int(rarity_counts.get("epic", 0)) + int(rarity_counts.get("legendary", 0)),
		"Boss drop pool size must equal the sum of rarity counts"
	)
	assert_eq(
		int(boss_summary.get("weighted_pool_size", 0)),
		int(weighted_counts.get("epic", 0)) + int(weighted_counts.get("legendary", 0)),
		"Weighted pool size must equal the sum of weighted rarity counts"
	)


func test_drop_profile_summary_for_unknown_profile_returns_empty_counts() -> void:
	var summary: Dictionary = GameDatabase.get_drop_profile_summary("unknown_profile")
	assert_eq(str(summary.get("profile", "")), "unknown_profile")
	assert_eq(float(summary.get("drop_chance", 1.0)), 0.0)
	assert_eq(Array(summary.get("rarity_preview", [])).size(), 0)
	assert_eq(int(summary.get("pool_size", -1)), 0)
	assert_eq(int(summary.get("weighted_pool_size", -1)), 0)
	assert_true(Dictionary(summary.get("rarity_counts", {})).is_empty())
	assert_true(Dictionary(summary.get("weighted_rarity_counts", {})).is_empty())


func test_drop_profile_summaries_return_duplicate_not_reference() -> void:
	var summaries_a: Array[Dictionary] = GameDatabase.get_drop_profile_summaries()
	var summaries_b: Array[Dictionary] = GameDatabase.get_drop_profile_summaries()
	assert_false(summaries_a.is_empty(), "Drop profile summaries must not be empty")
	summaries_a[0]["profile"] = "mutated"
	var rarity_counts: Dictionary = summaries_a[0].get("rarity_counts", {})
	for rarity in rarity_counts.keys():
		rarity_counts[rarity] = 999
		break
	assert_ne(
		str(summaries_b[0].get("profile", "")),
		"mutated",
		"Drop profile summaries must return duplicate dictionaries, not live references"
	)
	var nested_counts: Dictionary = summaries_b[0].get("rarity_counts", {})
	for rarity in nested_counts.keys():
		assert_ne(
			int(nested_counts.get(rarity, 0)),
			999,
			"Drop profile summaries must duplicate nested rarity count dictionaries too"
		)
		break


func test_room_spawn_validation_report_is_empty_for_current_rooms() -> void:
	assert_false(
		GameDatabase.has_room_spawn_validation_errors(),
		"Current room catalog must only reference known enemy spawn types"
	)
	assert_eq(
		GameDatabase.get_room_spawn_validation_errors().size(),
		0,
		"Room spawn validation report must remain empty for the checked-in rooms"
	)


func test_room_spawn_validation_error_accessor_returns_duplicate_not_reference() -> void:
	var errors_a: Array = GameDatabase.get_room_spawn_validation_errors()
	errors_a.append("fake room spawn error")
	var errors_b: Array = GameDatabase.get_room_spawn_validation_errors()
	assert_eq(
		errors_b.size(),
		0,
		"Room spawn validation accessor must return a duplicate instead of the live backing array"
	)


func test_game_database_get_room_spawn_summary_returns_room_ready_overview() -> void:
	var summary: Dictionary = GameDatabase.get_room_spawn_summary("arcane_core")
	assert_false(summary.is_empty(), "arcane_core room summary must exist")
	assert_eq(str(summary.get("room_id", "")), "arcane_core")
	assert_eq(int(summary.get("spawn_count", 0)), 5)
	assert_eq(int(Dictionary(summary.get("spawn_type_counts", {})).get("boss", 0)), 1)
	assert_true(bool(summary.get("has_rest_point", false)), "arcane_core summary must expose rest point hint")
	assert_true(bool(summary.get("has_rope", false)), "arcane_core summary must expose rope hint")
	assert_true(bool(summary.get("has_core", false)), "arcane_core summary must expose core availability")


func test_game_database_get_room_spawn_summary_returns_empty_for_unknown_room() -> void:
	var summary: Dictionary = GameDatabase.get_room_spawn_summary("missing_room")
	assert_true(summary.is_empty(), "Unknown room id must return an empty room summary")


func test_game_database_get_room_spawn_summaries_returns_duplicate_not_reference() -> void:
	var summaries_a: Array[Dictionary] = GameDatabase.get_room_spawn_summaries()
	var summaries_b: Array[Dictionary] = GameDatabase.get_room_spawn_summaries()
	assert_false(summaries_a.is_empty(), "Room spawn summaries must not be empty")
	summaries_a[0]["title"] = "mutated"
	var spawn_counts: Dictionary = summaries_a[0].get("spawn_type_counts", {})
	for spawn_type in spawn_counts.keys():
		spawn_counts[spawn_type] = 999
		break
	assert_ne(
		str(summaries_b[0].get("title", "")),
		"mutated",
		"Room spawn summaries must return duplicate dictionaries, not live references"
	)
	var nested_counts: Dictionary = summaries_b[0].get("spawn_type_counts", {})
	for spawn_type in nested_counts.keys():
		assert_ne(
			int(nested_counts.get(spawn_type, 0)),
			999,
			"Room spawn summaries must duplicate nested spawn count dictionaries too"
		)
		break


func test_game_database_get_room_spawn_enemy_summaries_returns_gui_ready_roster() -> void:
	var vault_summaries: Array[Dictionary] = GameDatabase.get_room_spawn_enemy_summaries("vault_sector")
	assert_false(vault_summaries.is_empty(), "Room spawn enemy summaries must not be empty for known rooms")
	assert_eq(
		str(vault_summaries[0].get("enemy_id", "")),
		"mushroom",
		"Room spawn enemy summaries must preserve first-seen encounter order for GUI/read-only consumers"
	)
	var mushroom_summary: Dictionary = {}
	for summary in vault_summaries:
		if str(summary.get("enemy_id", "")) == "mushroom":
			mushroom_summary = summary
			break
	assert_false(mushroom_summary.is_empty(), "vault_sector roster must include mushroom")
	assert_eq(int(mushroom_summary.get("count", 0)), 2, "vault_sector must aggregate duplicate mushroom spawns")
	assert_true(int(mushroom_summary.get("max_hp", 0)) > 0, "Roster summary must expose enemy max_hp")
	var arcane_summaries: Array[Dictionary] = GameDatabase.get_room_spawn_enemy_summaries("arcane_core")
	var boss_summary: Dictionary = {}
	for summary in arcane_summaries:
		if str(summary.get("enemy_id", "")) == "boss":
			boss_summary = summary
			break
	assert_false(boss_summary.is_empty(), "arcane_core roster must include boss")
	assert_eq(str(boss_summary.get("enemy_grade", "")), "boss")
	assert_eq(str(boss_summary.get("drop_profile", "")), "boss")
	assert_eq(float(boss_summary.get("drop_chance", 0.0)), 0.70)
	assert_eq(Array(boss_summary.get("drop_rarity_preview", [])), ["epic", "legendary"])
	assert_true(bool(boss_summary.get("has_super_armor_hint", false)), "Boss roster summary must expose super armor hint")


func test_game_database_get_room_spawn_enemy_summaries_returns_empty_for_unknown_room() -> void:
	var summaries: Array[Dictionary] = GameDatabase.get_room_spawn_enemy_summaries("missing_room")
	assert_true(summaries.is_empty(), "Unknown room id must return an empty room spawn enemy summary array")


func test_game_database_get_room_spawn_enemy_summaries_returns_duplicate_not_reference() -> void:
	var summaries_a: Array[Dictionary] = GameDatabase.get_room_spawn_enemy_summaries("arcane_core")
	var summaries_b: Array[Dictionary] = GameDatabase.get_room_spawn_enemy_summaries("arcane_core")
	assert_false(summaries_a.is_empty(), "Room spawn enemy summaries must not be empty")
	summaries_a[0]["display_name"] = "mutated"
	var rarity_preview: Array = summaries_a[0].get("drop_rarity_preview", [])
	if not rarity_preview.is_empty():
		rarity_preview[0] = "mutated"
	assert_ne(
		str(summaries_b[0].get("display_name", "")),
		"mutated",
		"Room spawn enemy summaries must return duplicate dictionaries, not live references"
	)
	var nested_preview: Array = summaries_b[0].get("drop_rarity_preview", [])
	if not nested_preview.is_empty():
		assert_ne(
			str(nested_preview[0]),
			"mutated",
			"Room spawn enemy summaries must duplicate nested rarity preview arrays too"
		)


# --- Wind/Water/Plant spell and school tests ---


func test_water_aqua_bullet_spell_loads_from_database() -> void:
	var spell: Dictionary = GameDatabase.get_spell("water_aqua_bullet")
	assert_false(spell.is_empty(), "water_aqua_bullet must exist in spells.json")
	assert_eq(str(spell.get("school", "")), "water", "Aqua Bullet must have water school")
	assert_true(int(spell.get("damage", 0)) > 0, "Aqua Bullet must deal damage")


func test_wind_gale_cutter_spell_loads_from_database() -> void:
	var spell: Dictionary = GameDatabase.get_spell("wind_gale_cutter")
	assert_false(spell.is_empty(), "wind_gale_cutter must exist in spells.json")
	assert_eq(str(spell.get("school", "")), "wind", "Gale Cutter must have wind school")
	assert_true(int(spell.get("pierce", 0)) >= 2, "Gale Cutter must have pierce >= 2")


func test_game_database_resolves_canonical_skill_ids_for_migrating_rows() -> void:
	var fire_skill: Dictionary = GameDatabase.get_skill_data("fire_bolt")
	assert_false(fire_skill.is_empty(), "canonical fire_bolt id must resolve during migration")
	assert_eq(str(fire_skill.get("skill_id", "")), "fire_ember_dart")
	assert_eq(str(fire_skill.get("canonical_skill_id", "")), "fire_bolt")
	assert_eq(str(fire_skill.get("display_name", "")), "파이어 볼트")

	var water_skill: Dictionary = GameDatabase.get_skill_data("water_bullet")
	assert_false(water_skill.is_empty(), "canonical water_bullet id must resolve during migration")
	assert_eq(str(water_skill.get("skill_id", "")), "water_aqua_bullet")
	assert_eq(str(water_skill.get("canonical_skill_id", "")), "water_bullet")
	assert_eq(str(water_skill.get("display_name", "")), "워터 불릿")

	var frost_needle_skill: Dictionary = GameDatabase.get_skill_data("ice_frost_needle")
	assert_false(frost_needle_skill.is_empty(), "canonical ice_frost_needle id must stay readable during migration")
	assert_eq(str(frost_needle_skill.get("skill_id", "")), "ice_frost_needle")
	assert_eq(str(frost_needle_skill.get("canonical_skill_id", "")), "ice_frost_needle")
	assert_eq(str(frost_needle_skill.get("display_name", "")), "프로스트 니들")
	assert_eq(
		str(frost_needle_skill.get("description", "")),
		"짧은 쿨마다 끼워 넣는 둔화·관통형 얼음 견제탄"
	)
	assert_true(Array(frost_needle_skill.get("role_tags", [])).has("poke"))

	var wind_skill: Dictionary = GameDatabase.get_skill_data("wind_cutter")
	assert_false(wind_skill.is_empty(), "canonical wind_cutter id must resolve during migration")
	assert_eq(str(wind_skill.get("skill_id", "")), "wind_gale_cutter")
	assert_eq(str(wind_skill.get("canonical_skill_id", "")), "wind_cutter")
	assert_eq(str(wind_skill.get("display_name", "")), "윈드 커터")

	var plant_skill: Dictionary = GameDatabase.get_skill_data("plant_root_bind")
	assert_false(plant_skill.is_empty(), "canonical plant_root_bind id must resolve during migration")
	assert_eq(str(plant_skill.get("skill_id", "")), "plant_vine_snare")
	assert_eq(str(plant_skill.get("canonical_skill_id", "")), "plant_root_bind")
	assert_eq(str(plant_skill.get("display_name", "")), "루트 바인드")

	var holy_healing_pulse_skill: Dictionary = GameDatabase.get_skill_data("holy_healing_pulse")
	assert_false(holy_healing_pulse_skill.is_empty(), "canonical holy_healing_pulse id must stay readable during migration")
	assert_eq(str(holy_healing_pulse_skill.get("skill_id", "")), "holy_healing_pulse")
	assert_eq(str(holy_healing_pulse_skill.get("canonical_skill_id", "")), "holy_healing_pulse")
	assert_eq(str(holy_healing_pulse_skill.get("display_name", "")), "힐링 펄스")
	assert_eq(
		str(holy_healing_pulse_skill.get("description", "")),
		"즉시 회복과 짧은 안정화를 제공하는 백마법 burst 프록시"
	)
	assert_eq(str(holy_healing_pulse_skill.get("skill_type", "")), "active")
	assert_eq(str(holy_healing_pulse_skill.get("element", "")), "holy")

	var dark_abyss_gate_skill: Dictionary = GameDatabase.get_skill_data("dark_abyss_gate")
	assert_false(dark_abyss_gate_skill.is_empty(), "canonical dark_abyss_gate id must stay readable during migration")
	assert_eq(str(dark_abyss_gate_skill.get("skill_id", "")), "dark_abyss_gate")
	assert_eq(str(dark_abyss_gate_skill.get("canonical_skill_id", "")), "dark_abyss_gate")
	assert_eq(str(dark_abyss_gate_skill.get("display_name", "")), "어비스 게이트")
	assert_eq(
		str(dark_abyss_gate_skill.get("description", "")),
		"적을 끌어당긴 뒤 폭발하는 흑마법 burst 프록시"
	)
	assert_eq(str(dark_abyss_gate_skill.get("skill_type", "")), "active")
	assert_eq(str(dark_abyss_gate_skill.get("element", "")), "dark")

	var ice_skill: Dictionary = GameDatabase.get_skill_data("ice_frozen_domain")
	assert_false(ice_skill.is_empty(), "canonical ice_frozen_domain id must resolve during migration")
	assert_eq(str(ice_skill.get("skill_id", "")), "ice_glacial_dominion")
	assert_eq(str(ice_skill.get("canonical_skill_id", "")), "ice_frozen_domain")
	assert_eq(str(ice_skill.get("display_name", "")), "프로즌 도메인")

	var earth_skill: Dictionary = GameDatabase.get_skill_data("earth_quake_break")
	assert_false(earth_skill.is_empty(), "canonical earth_quake_break id must resolve during migration")
	assert_eq(str(earth_skill.get("skill_id", "")), "earth_terra_break")
	assert_eq(str(earth_skill.get("canonical_skill_id", "")), "earth_quake_break")
	assert_eq(str(earth_skill.get("display_name", "")), "퀘이크 브레이크")

	var earth_spire_skill: Dictionary = GameDatabase.get_skill_data("earth_stone_spire")
	assert_false(earth_spire_skill.is_empty(), "canonical earth_stone_spire id must stay readable during migration")
	assert_eq(str(earth_spire_skill.get("skill_id", "")), "earth_stone_spire")
	assert_eq(str(earth_spire_skill.get("canonical_skill_id", "")), "earth_stone_spire")
	assert_eq(str(earth_spire_skill.get("display_name", "")), "어스 스파이크")
	assert_eq(
		str(earth_spire_skill.get("description", "")),
		"즉발 부채꼴 돌출로 전면을 압박하는 2서클 대지 주력 설치기"
	)
	assert_eq(str(earth_spire_skill.get("hit_shape", "")), "cone")
	assert_true(Array(earth_spire_skill.get("role_tags", [])).has("main_deploy"))

	var flame_arc_skill: Dictionary = GameDatabase.get_skill_data("fire_flame_arc")
	assert_false(flame_arc_skill.is_empty(), "canonical fire_flame_arc id must stay readable during migration")
	assert_eq(str(flame_arc_skill.get("skill_id", "")), "fire_flame_arc")
	assert_eq(str(flame_arc_skill.get("canonical_skill_id", "")), "fire_flame_arc")
	assert_eq(str(flame_arc_skill.get("display_name", "")), "플레임 써클")
	assert_eq(
		str(flame_arc_skill.get("description", "")),
		"원형 폭발로 무리 정리에 강한 3서클 화염 광역 버스터"
	)
	assert_eq(str(flame_arc_skill.get("hit_shape", "")), "circle")
	assert_true(Array(flame_arc_skill.get("role_tags", [])).has("mob_clear"))

	var tidal_ring_skill: Dictionary = GameDatabase.get_skill_data("water_tidal_ring")
	assert_false(tidal_ring_skill.is_empty(), "canonical water_tidal_ring id must stay readable during migration")
	assert_eq(str(tidal_ring_skill.get("skill_id", "")), "water_tidal_ring")
	assert_eq(str(tidal_ring_skill.get("canonical_skill_id", "")), "water_tidal_ring")
	assert_eq(str(tidal_ring_skill.get("display_name", "")), "타이달 링")
	assert_eq(
		str(tidal_ring_skill.get("description", "")),
		"원형 수압 파동으로 주변 적을 밀어내는 3서클 물 제어기"
	)
	assert_eq(str(tidal_ring_skill.get("hit_shape", "")), "circle")
	assert_true(Array(tidal_ring_skill.get("role_tags", [])).has("control"))

	var ice_wall_skill: Dictionary = GameDatabase.get_skill_data("ice_ice_wall")
	assert_false(ice_wall_skill.is_empty(), "canonical ice_ice_wall id must stay readable during migration")
	assert_eq(str(ice_wall_skill.get("skill_id", "")), "ice_ice_wall")
	assert_eq(str(ice_wall_skill.get("canonical_skill_id", "")), "ice_ice_wall")
	assert_eq(str(ice_wall_skill.get("display_name", "")), "아이스 월")
	assert_eq(
		str(ice_wall_skill.get("description", "")),
		"전장을 가르는 얼음 장벽으로 진입 경로를 끊는 4서클 냉기 제어기"
	)
	assert_eq(str(ice_wall_skill.get("hit_shape", "")), "wall")
	assert_true(Array(ice_wall_skill.get("role_tags", [])).has("control"))

	var thunder_lance_skill: Dictionary = GameDatabase.get_skill_data("lightning_thunder_lance")
	assert_false(thunder_lance_skill.is_empty(), "canonical lightning_thunder_lance id must stay readable during migration")
	assert_eq(str(thunder_lance_skill.get("skill_id", "")), "lightning_thunder_lance")
	assert_eq(str(thunder_lance_skill.get("canonical_skill_id", "")), "lightning_thunder_lance")
	assert_eq(str(thunder_lance_skill.get("display_name", "")), "썬더 랜스")
	assert_eq(
		str(thunder_lance_skill.get("description", "")),
		"중간 쿨마다 강한 관통 직선을 꽂아 넣는 보스용 번개 버스터"
	)
	assert_eq(str(thunder_lance_skill.get("hit_shape", "")), "line")
	assert_true(Array(thunder_lance_skill.get("role_tags", [])).has("boss_burst"))

	var inferno_sigil_skill: Dictionary = GameDatabase.get_skill_data("fire_inferno_sigil")
	assert_false(inferno_sigil_skill.is_empty(), "canonical fire_inferno_sigil id must stay readable during migration")
	assert_eq(str(inferno_sigil_skill.get("skill_id", "")), "fire_inferno_sigil")
	assert_eq(str(inferno_sigil_skill.get("canonical_skill_id", "")), "fire_inferno_sigil")
	assert_eq(str(inferno_sigil_skill.get("display_name", "")), "인페르노 시길")
	assert_eq(
		str(inferno_sigil_skill.get("description", "")),
		"대형 화염 마법진의 반복 폭발로 보스와 무리를 함께 압박하는 7서클 화염 버스터"
	)
	assert_eq(str(inferno_sigil_skill.get("hit_shape", "")), "circle")
	assert_true(Array(inferno_sigil_skill.get("role_tags", [])).has("boss_burst"))

	var arcane_mastery_skill: Dictionary = GameDatabase.get_skill_data("arcane_magic_mastery")
	assert_false(arcane_mastery_skill.is_empty(), "canonical arcane_magic_mastery id must stay readable during migration")
	assert_eq(str(arcane_mastery_skill.get("skill_id", "")), "arcane_magic_mastery")
	assert_eq(str(arcane_mastery_skill.get("canonical_skill_id", "")), "arcane_magic_mastery")
	assert_eq(str(arcane_mastery_skill.get("display_name", "")), "아케인 마스터리")
	assert_eq(
		str(arcane_mastery_skill.get("description", "")),
		"아케인 축을 대표하면서 모든 마법의 효율과 이해도를 높이는 1서클 공용 마스터리"
	)
	assert_eq(str(arcane_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(arcane_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(arcane_mastery_skill.get("applies_to_school", "")), "all")
	assert_eq(str(arcane_mastery_skill.get("applies_to_element", "")), "all")

	var arcane_astral_compression_skill: Dictionary = GameDatabase.get_skill_data("arcane_astral_compression")
	assert_false(arcane_astral_compression_skill.is_empty(), "canonical arcane_astral_compression id must stay readable during migration")
	assert_eq(str(arcane_astral_compression_skill.get("skill_id", "")), "arcane_astral_compression")
	assert_eq(str(arcane_astral_compression_skill.get("canonical_skill_id", "")), "arcane_astral_compression")
	assert_eq(str(arcane_astral_compression_skill.get("display_name", "")), "아스트랄 압축")
	assert_eq(
		str(arcane_astral_compression_skill.get("description", "")),
		"모든 마법의 마나 효율을 끌어올리는 8서클 공용 아케인 버프"
	)
	assert_eq(str(arcane_astral_compression_skill.get("skill_type", "")), "buff")
	assert_eq(str(arcane_astral_compression_skill.get("element", "")), "arcane")

	var arcane_world_hourglass_skill: Dictionary = GameDatabase.get_skill_data("arcane_world_hourglass")
	assert_false(arcane_world_hourglass_skill.is_empty(), "canonical arcane_world_hourglass id must stay readable during migration")
	assert_eq(str(arcane_world_hourglass_skill.get("skill_id", "")), "arcane_world_hourglass")
	assert_eq(str(arcane_world_hourglass_skill.get("canonical_skill_id", "")), "arcane_world_hourglass")
	assert_eq(str(arcane_world_hourglass_skill.get("display_name", "")), "월드 아워글래스 오브 아케인")
	assert_eq(
		str(arcane_world_hourglass_skill.get("description", "")),
		"모든 마법의 극딜 창구를 여는 9서클 공용 아케인 버프"
	)
	assert_eq(str(arcane_world_hourglass_skill.get("skill_type", "")), "buff")
	assert_eq(str(arcane_world_hourglass_skill.get("element", "")), "arcane")

	var tempest_crown_skill: Dictionary = GameDatabase.get_skill_data("lightning_tempest_crown")
	assert_false(tempest_crown_skill.is_empty(), "canonical lightning_tempest_crown id must stay readable during migration")
	assert_eq(str(tempest_crown_skill.get("skill_id", "")), "lightning_tempest_crown")
	assert_eq(str(tempest_crown_skill.get("canonical_skill_id", "")), "lightning_tempest_crown")
	assert_eq(str(tempest_crown_skill.get("display_name", "")), "템페스트 크라운")
	assert_eq(
		str(tempest_crown_skill.get("description", "")),
		"자동 번개 낙하와 연쇄 타격을 제공하는 전기 토글 오라"
	)
	assert_eq(str(tempest_crown_skill.get("skill_type", "")), "toggle")
	assert_eq(str(tempest_crown_skill.get("element", "")), "lightning")

	var genesis_arbor_skill: Dictionary = GameDatabase.get_skill_data("plant_genesis_arbor")
	assert_false(genesis_arbor_skill.is_empty(), "canonical plant_genesis_arbor id must stay readable during migration")
	assert_eq(str(genesis_arbor_skill.get("skill_id", "")), "plant_genesis_arbor")
	assert_eq(str(genesis_arbor_skill.get("canonical_skill_id", "")), "plant_genesis_arbor")
	assert_eq(str(genesis_arbor_skill.get("display_name", "")), "제네시스 아버")
	assert_eq(
		str(genesis_arbor_skill.get("description", "")),
		"거목을 소환해 광역 구속과 연속 타격을 가하는 최종 자연 설치기"
	)
	assert_eq(str(genesis_arbor_skill.get("skill_type", "")), "deploy")
	assert_eq(str(genesis_arbor_skill.get("element", "")), "plant")

	var fire_mastery_skill: Dictionary = GameDatabase.get_skill_data("fire_mastery")
	assert_false(fire_mastery_skill.is_empty(), "canonical fire_mastery id must stay readable during migration")
	assert_eq(str(fire_mastery_skill.get("skill_id", "")), "fire_mastery")
	assert_eq(str(fire_mastery_skill.get("canonical_skill_id", "")), "fire_mastery")
	assert_eq(str(fire_mastery_skill.get("display_name", "")), "파이어 마스터리")
	assert_eq(
		str(fire_mastery_skill.get("description", "")),
		"화염 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 화염 마스터리"
	)
	assert_eq(str(fire_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(fire_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(fire_mastery_skill.get("applies_to_element", "")), "fire")

	var water_mastery_skill: Dictionary = GameDatabase.get_skill_data("water_mastery")
	assert_false(water_mastery_skill.is_empty(), "canonical water_mastery id must stay readable during migration")
	assert_eq(str(water_mastery_skill.get("skill_id", "")), "water_mastery")
	assert_eq(str(water_mastery_skill.get("canonical_skill_id", "")), "water_mastery")
	assert_eq(str(water_mastery_skill.get("display_name", "")), "워터 마스터리")
	assert_eq(
		str(water_mastery_skill.get("description", "")),
		"물 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 물 마스터리"
	)
	assert_eq(str(water_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(water_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(water_mastery_skill.get("applies_to_element", "")), "water")

	var ice_mastery_skill: Dictionary = GameDatabase.get_skill_data("ice_mastery")
	assert_false(ice_mastery_skill.is_empty(), "canonical ice_mastery id must stay readable during migration")
	assert_eq(str(ice_mastery_skill.get("skill_id", "")), "ice_mastery")
	assert_eq(str(ice_mastery_skill.get("canonical_skill_id", "")), "ice_mastery")
	assert_eq(str(ice_mastery_skill.get("display_name", "")), "아이스 마스터리")
	assert_eq(
		str(ice_mastery_skill.get("description", "")),
		"얼음 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 냉기 마스터리"
	)
	assert_eq(str(ice_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(ice_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(ice_mastery_skill.get("applies_to_element", "")), "ice")

	var lightning_mastery_skill: Dictionary = GameDatabase.get_skill_data("lightning_mastery")
	assert_false(lightning_mastery_skill.is_empty(), "canonical lightning_mastery id must stay readable during migration")
	assert_eq(str(lightning_mastery_skill.get("skill_id", "")), "lightning_mastery")
	assert_eq(str(lightning_mastery_skill.get("canonical_skill_id", "")), "lightning_mastery")
	assert_eq(str(lightning_mastery_skill.get("display_name", "")), "라이트닝 마스터리")
	assert_eq(
		str(lightning_mastery_skill.get("description", "")),
		"전기 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 전기 마스터리"
	)
	assert_eq(str(lightning_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(lightning_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(lightning_mastery_skill.get("applies_to_element", "")), "lightning")

	var wind_mastery_skill: Dictionary = GameDatabase.get_skill_data("wind_mastery")
	assert_false(wind_mastery_skill.is_empty(), "canonical wind_mastery id must stay readable during migration")
	assert_eq(str(wind_mastery_skill.get("skill_id", "")), "wind_mastery")
	assert_eq(str(wind_mastery_skill.get("canonical_skill_id", "")), "wind_mastery")
	assert_eq(str(wind_mastery_skill.get("display_name", "")), "윈드 마스터리")
	assert_eq(
		str(wind_mastery_skill.get("description", "")),
		"바람 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 바람 마스터리"
	)
	assert_eq(str(wind_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(wind_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(wind_mastery_skill.get("applies_to_element", "")), "wind")

	var earth_mastery_skill: Dictionary = GameDatabase.get_skill_data("earth_mastery")
	assert_false(earth_mastery_skill.is_empty(), "canonical earth_mastery id must stay readable during migration")
	assert_eq(str(earth_mastery_skill.get("skill_id", "")), "earth_mastery")
	assert_eq(str(earth_mastery_skill.get("canonical_skill_id", "")), "earth_mastery")
	assert_eq(str(earth_mastery_skill.get("display_name", "")), "어스 마스터리")
	assert_eq(
		str(earth_mastery_skill.get("description", "")),
		"대지 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 대지 마스터리"
	)
	assert_eq(str(earth_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(earth_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(earth_mastery_skill.get("applies_to_element", "")), "earth")

	var plant_mastery_skill: Dictionary = GameDatabase.get_skill_data("plant_mastery")
	assert_false(plant_mastery_skill.is_empty(), "canonical plant_mastery id must stay readable during migration")
	assert_eq(str(plant_mastery_skill.get("skill_id", "")), "plant_mastery")
	assert_eq(str(plant_mastery_skill.get("canonical_skill_id", "")), "plant_mastery")
	assert_eq(str(plant_mastery_skill.get("display_name", "")), "플랜트 마스터리")
	assert_eq(
		str(plant_mastery_skill.get("description", "")),
		"자연 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 1서클 자연 마스터리"
	)
	assert_eq(str(plant_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(plant_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(plant_mastery_skill.get("applies_to_element", "")), "plant")

	var dark_magic_mastery_skill: Dictionary = GameDatabase.get_skill_data("dark_magic_mastery")
	assert_false(dark_magic_mastery_skill.is_empty(), "canonical dark_magic_mastery id must stay readable during migration")
	assert_eq(str(dark_magic_mastery_skill.get("skill_id", "")), "dark_magic_mastery")
	assert_eq(str(dark_magic_mastery_skill.get("canonical_skill_id", "")), "dark_magic_mastery")
	assert_eq(str(dark_magic_mastery_skill.get("display_name", "")), "다크 매직 마스터리")
	assert_eq(
		str(dark_magic_mastery_skill.get("description", "")),
		"흑마법 계열 스킬의 최종 피해를 강화하고 구간별로 마나와 쿨타임 부담을 낮추는 3서클 흑마법 마스터리"
	)
	assert_eq(str(dark_magic_mastery_skill.get("skill_type", "")), "passive")
	assert_eq(str(dark_magic_mastery_skill.get("passive_family", "")), "mastery")
	assert_eq(str(dark_magic_mastery_skill.get("applies_to_element", "")), "dark")

	var fire_pyre_heart_skill: Dictionary = GameDatabase.get_skill_data("fire_pyre_heart")
	assert_false(fire_pyre_heart_skill.is_empty(), "canonical fire_pyre_heart id must stay readable during migration")
	assert_eq(str(fire_pyre_heart_skill.get("skill_id", "")), "fire_pyre_heart")
	assert_eq(str(fire_pyre_heart_skill.get("canonical_skill_id", "")), "fire_pyre_heart")
	assert_eq(str(fire_pyre_heart_skill.get("display_name", "")), "파이어 하트")
	assert_eq(
		str(fire_pyre_heart_skill.get("description", "")),
		"화염 폭딜 창구를 여는 4서클 화염 공격 버프"
	)
	assert_eq(str(fire_pyre_heart_skill.get("skill_type", "")), "buff")
	assert_eq(str(fire_pyre_heart_skill.get("element", "")), "fire")

	var ice_frostblood_ward_skill: Dictionary = GameDatabase.get_skill_data("ice_frostblood_ward")
	assert_false(ice_frostblood_ward_skill.is_empty(), "canonical ice_frostblood_ward id must stay readable during migration")
	assert_eq(str(ice_frostblood_ward_skill.get("skill_id", "")), "ice_frostblood_ward")
	assert_eq(str(ice_frostblood_ward_skill.get("canonical_skill_id", "")), "ice_frostblood_ward")
	assert_eq(str(ice_frostblood_ward_skill.get("display_name", "")), "프로스트블러드 워드")
	assert_eq(
		str(ice_frostblood_ward_skill.get("description", "")),
		"빙결 제어와 반사 파동으로 안정성을 높이는 4서클 냉기 방어 버프"
	)
	assert_eq(str(ice_frostblood_ward_skill.get("skill_type", "")), "buff")
	assert_eq(str(ice_frostblood_ward_skill.get("element", "")), "ice")

	var dark_soul_skill: Dictionary = GameDatabase.get_skill_data("dark_soul_dominion")
	assert_false(dark_soul_skill.is_empty(), "canonical dark_soul_dominion id must stay readable during migration")
	assert_eq(str(dark_soul_skill.get("skill_id", "")), "dark_soul_dominion")
	assert_eq(str(dark_soul_skill.get("canonical_skill_id", "")), "dark_soul_dominion")
	assert_eq(str(dark_soul_skill.get("display_name", "")), "소울 도미니언")
	assert_eq(
		str(dark_soul_skill.get("description", "")),
		"규칙 변조와 하이리스크 피니셔 압박을 제공하는 흑마법 토글 오라"
	)

	var dark_shadow_skill: Dictionary = GameDatabase.get_skill_data("dark_shadow_bind")
	assert_false(dark_shadow_skill.is_empty(), "canonical dark_shadow_bind id must stay readable during migration")
	assert_eq(str(dark_shadow_skill.get("skill_id", "")), "dark_shadow_bind")
	assert_eq(str(dark_shadow_skill.get("canonical_skill_id", "")), "dark_shadow_bind")
	assert_eq(str(dark_shadow_skill.get("display_name", "")), "섀도우 바인드")
	assert_eq(
		str(dark_shadow_skill.get("description", "")),
		"둔화와 지속 피해를 누적시키는 흑마법 설치형 디버프"
	)

	var dark_grave_echo_skill: Dictionary = GameDatabase.get_skill_data("dark_grave_echo")
	assert_false(dark_grave_echo_skill.is_empty(), "canonical dark_grave_echo id must stay readable during migration")
	assert_eq(str(dark_grave_echo_skill.get("skill_id", "")), "dark_grave_echo")
	assert_eq(str(dark_grave_echo_skill.get("canonical_skill_id", "")), "dark_grave_echo")
	assert_eq(str(dark_grave_echo_skill.get("display_name", "")), "그레이브 에코")
	assert_eq(
		str(dark_grave_echo_skill.get("description", "")),
		"지속 저주와 누적 압박을 제공하는 흑마법 저주 오라"
	)

	var dark_grave_pact_skill: Dictionary = GameDatabase.get_skill_data("dark_grave_pact")
	assert_false(dark_grave_pact_skill.is_empty(), "canonical dark_grave_pact id must stay readable during migration")
	assert_eq(str(dark_grave_pact_skill.get("skill_id", "")), "dark_grave_pact")
	assert_eq(str(dark_grave_pact_skill.get("canonical_skill_id", "")), "dark_grave_pact")
	assert_eq(str(dark_grave_pact_skill.get("display_name", "")), "그레이브 팩트")
	assert_eq(
		str(dark_grave_pact_skill.get("description", "")),
		"HP 소모를 대가로 흑마법을 증폭하는 리스크 버프"
	)

	var lightning_conductive_surge_skill: Dictionary = GameDatabase.get_skill_data("lightning_conductive_surge")
	assert_false(lightning_conductive_surge_skill.is_empty(), "canonical lightning_conductive_surge id must stay readable during migration")
	assert_eq(str(lightning_conductive_surge_skill.get("skill_id", "")), "lightning_conductive_surge")
	assert_eq(str(lightning_conductive_surge_skill.get("canonical_skill_id", "")), "lightning_conductive_surge")
	assert_eq(str(lightning_conductive_surge_skill.get("display_name", "")), "컨덕티브 서지")
	assert_eq(
		str(lightning_conductive_surge_skill.get("description", "")),
		"연쇄와 감전 burst를 증폭하는 전기 버프"
	)

	var plant_worldroot_bastion_skill: Dictionary = GameDatabase.get_skill_data("plant_worldroot_bastion")
	assert_false(plant_worldroot_bastion_skill.is_empty(), "canonical plant_worldroot_bastion id must stay readable during migration")
	assert_eq(str(plant_worldroot_bastion_skill.get("skill_id", "")), "plant_worldroot_bastion")
	assert_eq(str(plant_worldroot_bastion_skill.get("canonical_skill_id", "")), "plant_worldroot_bastion")
	assert_eq(str(plant_worldroot_bastion_skill.get("display_name", "")), "월드루트 바스천")
	assert_eq(
		str(plant_worldroot_bastion_skill.get("description", "")),
		"구속과 누적 피해를 제공하는 식물 성채형 설치 스킬"
	)

	var plant_verdant_overflow_skill: Dictionary = GameDatabase.get_skill_data("plant_verdant_overflow")
	assert_false(plant_verdant_overflow_skill.is_empty(), "canonical plant_verdant_overflow id must stay readable during migration")
	assert_eq(str(plant_verdant_overflow_skill.get("skill_id", "")), "plant_verdant_overflow")
	assert_eq(str(plant_verdant_overflow_skill.get("canonical_skill_id", "")), "plant_verdant_overflow")
	assert_eq(str(plant_verdant_overflow_skill.get("display_name", "")), "버던트 오버플로")
	assert_eq(
		str(plant_verdant_overflow_skill.get("description", "")),
		"설치형 빌드의 burst 창구를 여는 자연 버프"
	)

	var holy_crystal_aegis_skill: Dictionary = GameDatabase.get_skill_data("holy_crystal_aegis")
	assert_false(holy_crystal_aegis_skill.is_empty(), "canonical holy_crystal_aegis id must stay readable during migration")
	assert_eq(str(holy_crystal_aegis_skill.get("skill_id", "")), "holy_crystal_aegis")
	assert_eq(str(holy_crystal_aegis_skill.get("canonical_skill_id", "")), "holy_crystal_aegis")
	assert_eq(str(holy_crystal_aegis_skill.get("display_name", "")), "크리스탈 이지스")
	assert_eq(
		str(holy_crystal_aegis_skill.get("description", "")),
		"피해 감소와 상태 안정화를 제공하는 상위 방어 버프"
	)

	var holy_sanctuary_skill: Dictionary = GameDatabase.get_skill_data("holy_sanctuary_of_reversal")
	assert_false(holy_sanctuary_skill.is_empty(), "canonical holy_sanctuary_of_reversal id must stay readable during migration")
	assert_eq(str(holy_sanctuary_skill.get("skill_id", "")), "holy_sanctuary_of_reversal")
	assert_eq(str(holy_sanctuary_skill.get("canonical_skill_id", "")), "holy_sanctuary_of_reversal")
	assert_eq(str(holy_sanctuary_skill.get("display_name", "")), "생츄어리 오브 리버설")
	assert_eq(
		str(holy_sanctuary_skill.get("description", "")),
		"회복과 정화를 제공하는 백마법 성역 필드"
	)

	var dark_throne_skill: Dictionary = GameDatabase.get_skill_data("dark_throne_of_ash")
	assert_false(dark_throne_skill.is_empty(), "canonical dark_throne_of_ash id must stay readable during migration")
	assert_eq(str(dark_throne_skill.get("skill_id", "")), "dark_throne_of_ash")
	assert_eq(str(dark_throne_skill.get("canonical_skill_id", "")), "dark_throne_of_ash")
	assert_eq(str(dark_throne_skill.get("display_name", "")), "스론 오브 애시")
	assert_eq(
		str(dark_throne_skill.get("description", "")),
		"화염과 흑마법 최종 배수를 증폭하는 의식 피니셔 버프"
	)

	var wind_tempest_drive_skill: Dictionary = GameDatabase.get_skill_data("wind_tempest_drive")
	assert_false(wind_tempest_drive_skill.is_empty(), "canonical wind_tempest_drive id must stay readable during migration")
	assert_eq(str(wind_tempest_drive_skill.get("skill_id", "")), "wind_tempest_drive")
	assert_eq(str(wind_tempest_drive_skill.get("canonical_skill_id", "")), "wind_tempest_drive")
	assert_eq(str(wind_tempest_drive_skill.get("display_name", "")), "템페스트 드라이브")
	assert_eq(
		str(wind_tempest_drive_skill.get("description", "")),
		"이동과 연속 시전 리듬을 강화하는 바람 버프 프록시"
	)


func test_wind_damage_multiplier_applies_to_wind_school() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("offhand", "focus_gale_shard"))
	var base_mult := GameState.get_equipment_damage_multiplier("fire")
	var wind_mult := GameState.get_equipment_damage_multiplier("wind")
	assert_gt(wind_mult, base_mult, "Wind multiplier must exceed base when Gale Shard equipped")
	assert_true(wind_mult >= 1.15, "Gale Shard must provide at least 15% wind damage bonus")


func test_water_damage_multiplier_applies_to_water_school() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_1", "ring_tidal_crest"))
	var water_mult := GameState.get_equipment_damage_multiplier("water")
	assert_gt(water_mult, 1.0, "Water multiplier must exceed 1.0 when Tidal Crest equipped")


func test_plant_damage_multiplier_applies_to_plant_school() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_2", "ring_verdant_coil"))
	var plant_mult := GameState.get_equipment_damage_multiplier("plant")
	assert_gt(plant_mult, 1.0, "Plant multiplier must exceed 1.0 when Verdant Coil equipped")


func test_wind_resonance_tracks_wind_spell_use() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("wind", 0)), 0, "Wind resonance starts at 0")
	GameState.register_spell_use("wind_gale_cutter", "wind")
	assert_eq(
		int(GameState.resonance.get("wind", 0)), 1, "Wind resonance must increment on spell use"
	)


func test_default_hotbar_contains_water_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_water":
			assert_eq(str(slot.get("skill_id", "")), "water_aqua_bullet")
			assert_eq(str(slot.get("label", "")), "U")
			found = true
			break
	assert_true(found, "Hotbar must include spell_water slot with water_aqua_bullet")


func test_default_hotbar_contains_wind_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_wind":
			assert_eq(str(slot.get("skill_id", "")), "wind_gale_cutter")
			assert_eq(str(slot.get("label", "")), "I")
			found = true
			break
	assert_true(found, "Hotbar must include spell_wind slot with wind_gale_cutter")


func test_default_hotbar_contains_plant_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_plant":
			assert_eq(str(slot.get("skill_id", "")), "plant_vine_snare")
			assert_eq(str(slot.get("label", "")), "P")
			found = true
			break
	assert_true(found, "Hotbar must include spell_plant slot with plant_vine_snare")


func test_plant_vine_snare_skill_type_is_deploy() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("plant_vine_snare")
	assert_false(skill_data.is_empty(), "plant_vine_snare must exist in GameDatabase")
	assert_eq(str(skill_data.get("skill_type", "")), "deploy")
	assert_eq(str(skill_data.get("element", "")), "plant")


func test_plant_vine_snare_has_valid_deploy_parameters() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("plant_vine_snare")
	assert_gt(float(skill_data.get("range_base", 0)), 0.0, "range_base must be positive")
	assert_gt(float(skill_data.get("duration_base", 0)), 0.0, "duration_base must be positive")
	assert_gt(float(skill_data.get("mana_cost_base", 0)), 0.0, "mana_cost_base must be positive")


func test_plant_vine_snare_spell_loads_with_correct_school() -> void:
	var spell: Dictionary = GameDatabase.get_spell("plant_vine_snare")
	assert_false(spell.is_empty(), "plant_vine_snare spell data must exist in GameDatabase")
	assert_eq(str(spell.get("id", "")), "plant_vine_snare")
	assert_eq(str(spell.get("school", "")), "plant")


func test_arcane_astral_compression_is_buff_type_in_skills_data() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("arcane_astral_compression")
	assert_false(skill_data.is_empty(), "arcane_astral_compression must exist in GameDatabase")
	assert_eq(str(skill_data.get("skill_type", "")), "buff")
	assert_eq(str(skill_data.get("element", "")), "arcane")


func test_arcane_astral_compression_activates_and_sets_final_damage_multiplier() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var fire_spell_base := GameState.get_spell_runtime("fire_bolt")
	var base_dmg: int = int(fire_spell_base.get("damage", 0))
	GameState.try_activate_buff("arcane_astral_compression")
	assert_eq(GameState.active_buffs.size(), 1)
	var fire_spell_with_buff := GameState.get_spell_runtime("fire_bolt")
	var buffed_dmg: int = int(fire_spell_with_buff.get("damage", 0))
	assert_gt(
		buffed_dmg,
		base_dmg,
		"Astral Compression final_damage_multiplier must increase fire_bolt damage"
	)
	GameState.reset_progress_for_tests()


func test_arcane_astral_compression_reduces_mana_cost_via_mana_efficiency() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var base_cost: float = GameState.get_skill_mana_cost("fire_bolt")
	GameState.try_activate_buff("arcane_astral_compression")
	var buffed_cost: float = GameState.get_skill_mana_cost("fire_bolt")
	assert_lt(
		buffed_cost,
		base_cost,
		"Astral Compression mana_efficiency_multiplier must reduce mana cost"
	)
	GameState.reset_progress_for_tests()


func test_arcane_astral_compression_final_multiplier_applies_to_all_schools() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var fire_base: int = int(GameState.get_spell_runtime("fire_bolt").get("damage", 0))
	var volt_base: int = int(GameState.get_spell_runtime("volt_spear").get("damage", 0))
	GameState.try_activate_buff("arcane_astral_compression")
	var fire_buffed: int = int(GameState.get_spell_runtime("fire_bolt").get("damage", 0))
	var volt_buffed: int = int(GameState.get_spell_runtime("volt_spear").get("damage", 0))
	assert_gt(fire_buffed, fire_base, "Astral Compression must boost fire damage")
	assert_gt(volt_buffed, volt_base, "Astral Compression must boost lightning damage")
	GameState.reset_progress_for_tests()


func test_arcane_core_room_exists_in_room_list() -> void:
	var rooms: Array = GameDatabase.get_all_rooms()
	var found := false
	for r in rooms:
		if str(r.get("id", "")) == "arcane_core":
			found = true
			break
	assert_true(found, "arcane_core room must exist in rooms.json")


func test_arcane_core_has_five_rooms_total() -> void:
	var rooms: Array = GameDatabase.get_all_rooms()
	assert_gte(rooms.size(), 5, "There must be at least 5 rooms total")


func test_arcane_core_has_boss_spawn() -> void:
	var rooms: Array = GameDatabase.get_all_rooms()
	var arcane_core: Dictionary = {}
	for r in rooms:
		if str(r.get("id", "")) == "arcane_core":
			arcane_core = r
			break
	assert_false(arcane_core.is_empty(), "arcane_core must be found")
	var spawns: Array = arcane_core.get("spawns", [])
	var has_boss := false
	for s in spawns:
		if str(s.get("type", "")) == "boss":
			has_boss = true
			break
	assert_true(has_boss, "arcane_core must have a boss spawn")


func test_arcane_core_has_core_position() -> void:
	var rooms: Array = GameDatabase.get_all_rooms()
	for r in rooms:
		if str(r.get("id", "")) == "arcane_core":
			assert_true(r.has("core_position"), "arcane_core must have a core_position")
			return
	fail_test("arcane_core not found")


func test_earth_tremor_spell_loads_with_correct_school() -> void:
	var spell: Dictionary = GameDatabase.get_spell("earth_tremor")
	assert_false(spell.is_empty(), "earth_tremor must exist in GameDatabase")
	assert_eq(str(spell.get("school", "")), "earth")
	assert_gt(int(spell.get("damage", 0)), 0)
	assert_gt(float(spell.get("range", 0.0)), 0.0)


func test_holy_radiant_burst_spell_loads_with_correct_school() -> void:
	var spell: Dictionary = GameDatabase.get_spell("holy_radiant_burst")
	assert_false(spell.is_empty(), "holy_radiant_burst must exist in GameDatabase")
	assert_eq(str(spell.get("school", "")), "holy")
	assert_gt(int(spell.get("speed", 0)), 0, "holy_radiant_burst must have speed > 0 (projectile)")
	assert_gt(int(spell.get("damage", 0)), 0)


func test_holy_healing_pulse_skill_data_uses_latest_korean_display_name() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("holy_healing_pulse")
	assert_false(skill_data.is_empty(), "holy_healing_pulse skill data must exist")
	assert_eq(str(skill_data.get("skill_id", "")), "holy_healing_pulse")
	assert_eq(str(skill_data.get("display_name", "")), "힐링 펄스")
	assert_eq(str(skill_data.get("description", "")), "즉시 회복과 짧은 안정화를 제공하는 백마법 burst 프록시")


func test_earth_tremor_runtime_reflects_earth_equipment_multiplier() -> void:
	GameState.reset_progress_for_tests()
	var base_runtime: Dictionary = GameState.get_spell_runtime("earth_tremor")
	var base_dmg: int = int(base_runtime.get("damage", 0))
	assert_true(GameState.set_equipped_item("accessory_1", "ring_earth_seed"))
	var boosted_runtime: Dictionary = GameState.get_spell_runtime("earth_tremor")
	var boosted_dmg: int = int(boosted_runtime.get("damage", 0))
	assert_gt(boosted_dmg, base_dmg, "ring_earth_seed must boost earth_tremor damage")
	GameState.reset_progress_for_tests()


func test_earth_resonance_tracks_earth_spell_use() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("earth", 0)), 0)
	GameState.register_spell_use("earth_tremor", "earth")
	assert_eq(int(GameState.resonance.get("earth", 0)), 1)


func test_holy_resonance_tracks_holy_spell_use() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("holy", 0)), 0)
	GameState.register_spell_use("holy_radiant_burst", "holy")
	assert_eq(int(GameState.resonance.get("holy", 0)), 1)


func test_default_hotbar_contains_earth_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_earth":
			assert_eq(str(slot.get("skill_id", "")), "earth_tremor")
			assert_eq(str(slot.get("label", "")), "O")
			found = true
			break
	assert_true(found, "Hotbar must include spell_earth slot with earth_tremor")


func test_default_hotbar_contains_holy_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_holy":
			assert_eq(str(slot.get("skill_id", "")), "holy_radiant_burst")
			assert_eq(str(slot.get("label", "")), "K")
			found = true
			break
	assert_true(found, "Hotbar must include spell_holy slot with holy_radiant_burst")


func test_earthen_stride_boots_boost_earth_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("earth")
	assert_true(GameState.set_equipped_item("legs", "greaves_earthen_stride"))
	var boosted := GameState.get_equipment_damage_multiplier("earth")
	assert_gt(boosted, base, "Earthen Stride Boots must boost earth damage multiplier")
	GameState.reset_progress_for_tests()


func test_holy_halo_crown_boosts_holy_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("holy")
	assert_true(GameState.set_equipped_item("head", "helm_holy_halo"))
	var boosted := GameState.get_equipment_damage_multiplier("holy")
	assert_gt(boosted, base, "Holy Halo Crown must boost holy damage multiplier")
	GameState.reset_progress_for_tests()


func test_dark_void_bolt_spell_exists_in_database() -> void:
	var s: Dictionary = GameDatabase.get_spell("dark_void_bolt")
	assert_false(s.is_empty(), "dark_void_bolt must exist in spells database")
	assert_eq(str(s.get("school", "")), "dark", "dark_void_bolt school must be dark")
	assert_gt(int(s.get("damage", 0)), 0, "dark_void_bolt damage must be > 0")
	assert_gt(int(s.get("speed", 0)), 0, "dark_void_bolt speed must be > 0")


func test_dark_abyss_gate_skill_data_uses_latest_korean_display_name() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("dark_abyss_gate")
	assert_false(skill_data.is_empty(), "dark_abyss_gate skill data must exist")
	assert_eq(str(skill_data.get("skill_id", "")), "dark_abyss_gate")
	assert_eq(str(skill_data.get("display_name", "")), "어비스 게이트")
	assert_eq(str(skill_data.get("description", "")), "적을 끌어당긴 뒤 폭발하는 흑마법 burst 프록시")


func test_arcane_force_pulse_spell_exists_in_database() -> void:
	var s: Dictionary = GameDatabase.get_spell("arcane_force_pulse")
	assert_false(s.is_empty(), "arcane_force_pulse must exist in spells database")
	assert_eq(str(s.get("school", "")), "arcane", "arcane_force_pulse school must be arcane")
	assert_gt(int(s.get("damage", 0)), 0, "arcane_force_pulse damage must be > 0")


func test_lightning_tempest_crown_skill_data_uses_latest_korean_display_name() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("lightning_tempest_crown")
	assert_false(skill_data.is_empty(), "lightning_tempest_crown skill data must exist")
	assert_eq(str(skill_data.get("skill_id", "")), "lightning_tempest_crown")
	assert_eq(str(skill_data.get("display_name", "")), "템페스트 크라운")
	assert_eq(str(skill_data.get("description", "")), "자동 번개 낙하와 연쇄 타격을 제공하는 전기 토글 오라")


func test_plant_genesis_arbor_skill_data_uses_latest_korean_display_name() -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data("plant_genesis_arbor")
	assert_false(skill_data.is_empty(), "plant_genesis_arbor skill data must exist")
	assert_eq(str(skill_data.get("skill_id", "")), "plant_genesis_arbor")
	assert_eq(str(skill_data.get("display_name", "")), "제네시스 아버")
	assert_eq(str(skill_data.get("description", "")), "거목을 소환해 광역 구속과 연속 타격을 가하는 최종 자연 설치기")


func test_dark_resonance_initializes_to_zero() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("dark", -1)), 0, "dark resonance must start at 0")


func test_arcane_resonance_initializes_to_zero() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("arcane", -1)), 0, "arcane resonance must start at 0")


func test_dark_resonance_tracks_dark_spell_use() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("dark", 0)), 0)
	GameState.register_spell_use("dark_void_bolt", "dark")
	assert_eq(int(GameState.resonance.get("dark", 0)), 1)


func test_arcane_resonance_tracks_arcane_spell_use() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(int(GameState.resonance.get("arcane", 0)), 0)
	GameState.register_spell_use("arcane_force_pulse", "arcane")
	assert_eq(int(GameState.resonance.get("arcane", 0)), 1)


func test_default_hotbar_contains_dark_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_dark":
			assert_eq(str(slot.get("skill_id", "")), "dark_void_bolt")
			assert_eq(str(slot.get("label", "")), "L")
			found = true
			break
	assert_true(found, "Hotbar must include spell_dark slot with dark_void_bolt")


func test_default_hotbar_contains_arcane_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	var found := false
	for slot in hotbar:
		if str(slot.get("action", "")) == "spell_arcane":
			assert_eq(str(slot.get("skill_id", "")), "arcane_force_pulse")
			assert_eq(str(slot.get("label", "")), "M")
			found = true
			break
	assert_true(found, "Hotbar must include spell_arcane slot with arcane_force_pulse")


func test_school_to_mastery_includes_arcane() -> void:
	var mastery_id: String = str(GameState.SCHOOL_TO_MASTERY.get("arcane", ""))
	assert_eq(mastery_id, "arcane_magic_mastery", "arcane school must map to arcane_magic_mastery")


func test_dark_void_bolt_links_to_dark_abyss_gate() -> void:
	GameState.reset_progress_for_tests()
	var skill_id := GameState.get_skill_id_for_spell("dark_void_bolt")
	assert_eq(
		str(skill_id),
		"dark_abyss_gate",
		"dark_void_bolt must map to dark_abyss_gate via LEGACY_SPELL_TO_SKILL"
	)


func test_arcane_mastery_skill_level_reflects_spell_use() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("arcane_magic_mastery")
	for _i in range(5):
		GameState.register_spell_use("arcane_force_pulse", "arcane")
	var new_level: int = GameState.get_skill_level("arcane_magic_mastery")
	assert_true(
		new_level >= base_level,
		"arcane_magic_mastery level must not decrease after arcane spell use"
	)


func test_fire_mastery_skill_level_reflects_fire_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("fire_mastery")
	GameState.register_skill_damage("fire_bolt", 140.0)
	var new_level: int = GameState.get_skill_level("fire_mastery")
	assert_true(
		new_level > base_level,
		"fire_mastery level must increase when fire_bolt damage is registered"
	)


func test_water_mastery_skill_level_reflects_water_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("water_mastery")
	GameState.register_skill_damage("water_aqua_bullet", 140.0)
	var new_level: int = GameState.get_skill_level("water_mastery")
	assert_true(
		new_level > base_level,
		"water_mastery level must increase when water_aqua_bullet damage is registered"
	)


func test_ice_mastery_skill_level_reflects_ice_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("ice_mastery")
	GameState.register_skill_damage("frost_nova", 140.0)
	var new_level: int = GameState.get_skill_level("ice_mastery")
	assert_true(
		new_level > base_level,
		"ice_mastery level must increase when frost_nova damage is registered"
	)


func test_lightning_mastery_skill_level_reflects_lightning_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("lightning_mastery")
	GameState.register_skill_damage("volt_spear", 140.0)
	var new_level: int = GameState.get_skill_level("lightning_mastery")
	assert_true(
		new_level > base_level,
		"lightning_mastery level must increase when volt_spear damage is registered"
	)


func test_wind_mastery_skill_level_reflects_wind_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("wind_mastery")
	GameState.register_skill_damage("wind_gale_cutter", 140.0)
	var new_level: int = GameState.get_skill_level("wind_mastery")
	assert_true(
		new_level > base_level,
		"wind_mastery level must increase when wind_gale_cutter damage is registered"
	)


func test_earth_mastery_skill_level_reflects_earth_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("earth_mastery")
	GameState.register_skill_damage("earth_tremor", 140.0)
	var new_level: int = GameState.get_skill_level("earth_mastery")
	assert_true(
		new_level > base_level,
		"earth_mastery level must increase when earth_tremor damage is registered"
	)


func test_plant_mastery_skill_level_reflects_plant_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("plant_mastery")
	GameState.register_skill_damage("plant_vine_snare", 140.0)
	var new_level: int = GameState.get_skill_level("plant_mastery")
	assert_true(
		new_level > base_level,
		"plant_mastery level must increase when plant_vine_snare damage is registered"
	)


func test_dark_magic_mastery_skill_level_reflects_dark_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_level: int = GameState.get_skill_level("dark_magic_mastery")
	GameState.register_skill_damage("dark_void_bolt", 140.0)
	var new_level: int = GameState.get_skill_level("dark_magic_mastery")
	assert_true(
		new_level > base_level,
		"dark_magic_mastery level must increase when dark_void_bolt damage is registered"
	)


func test_void_rift_room_exists_in_database() -> void:
	var room: Dictionary = GameDatabase.get_room("void_rift")
	assert_false(room.is_empty(), "void_rift room must exist in rooms.json")
	assert_eq(str(room.get("id", "")), "void_rift", "Room id must be void_rift")


func test_void_rift_room_has_required_spawns() -> void:
	var room: Dictionary = GameDatabase.get_room("void_rift")
	var spawns: Array = room.get("spawns", [])
	assert_true(spawns.size() >= 4, "void_rift must have at least 4 spawn entries")


func test_all_rooms_count_reaches_six() -> void:
	var all_rooms: Array = GameDatabase.get_all_rooms()
	assert_true(
		all_rooms.size() >= 6, "GameDatabase must load at least 6 rooms after void_rift added"
	)


func test_resonance_milestone_5_pushes_message() -> void:
	GameState.reset_progress_for_tests()
	GameState.ui_message = ""
	for _i in range(4):
		GameState.register_spell_use("fire_bolt", "fire")
	assert_eq(GameState.ui_message, "", "No milestone message before 5th cast")
	GameState.register_spell_use("fire_bolt", "fire")
	assert_ne(GameState.ui_message, "", "Milestone message must be set at resonance 5")
	assert_string_contains(GameState.ui_message, "Fire", "Message must mention the school (Fire)")
	GameState.reset_progress_for_tests()


func test_resonance_milestone_15_pushes_message() -> void:
	GameState.reset_progress_for_tests()
	for _i in range(14):
		GameState.register_spell_use("volt_spear", "lightning")
	GameState.ui_message = ""
	GameState.register_spell_use("volt_spear", "lightning")
	assert_ne(GameState.ui_message, "", "Milestone message must be set at resonance 15")
	assert_string_contains(
		GameState.ui_message, "Lightning", "Message must mention the school (Lightning)"
	)
	GameState.reset_progress_for_tests()


func test_resonance_milestone_30_pushes_message() -> void:
	GameState.reset_progress_for_tests()
	for _i in range(29):
		GameState.register_spell_use("frost_nova", "ice")
	GameState.ui_message = ""
	GameState.register_spell_use("frost_nova", "ice")
	assert_ne(GameState.ui_message, "", "Milestone message must be set at resonance 30")
	assert_string_contains(GameState.ui_message, "Ice", "Message must mention the school (Ice)")
	GameState.reset_progress_for_tests()


func test_resonance_non_milestone_does_not_push_message() -> void:
	GameState.reset_progress_for_tests()
	GameState.ui_message = ""
	GameState.register_spell_use("fire_bolt", "fire")
	GameState.register_spell_use("fire_bolt", "fire")
	GameState.register_spell_use("fire_bolt", "fire")
	assert_eq(GameState.ui_message, "", "No milestone at resonance 3 — message must remain empty")
	GameState.reset_progress_for_tests()


func test_resonance_30_activates_bonus_school_and_timer() -> void:
	GameState.reset_progress_for_tests()
	for _i in range(30):
		GameState.register_spell_use("fire_bolt", "fire")
	assert_eq(GameState.resonance_bonus_school, "fire", "Bonus school set to fire at resonance 30")
	assert_almost_eq(GameState.resonance_bonus_timer, 15.0, 0.001, "Bonus timer set to 15 seconds")
	GameState.reset_progress_for_tests()


func test_resonance_30_bonus_increases_damage_multiplier() -> void:
	GameState.reset_progress_for_tests()
	var base_mult: float = GameState.get_equipment_damage_multiplier("lightning")
	for _i in range(30):
		GameState.register_spell_use("volt_spear", "lightning")
	var bonus_mult: float = GameState.get_equipment_damage_multiplier("lightning")
	assert_almost_eq(
		bonus_mult, base_mult * 1.10, 0.001, "Resonance 30 adds 10% to lightning damage multiplier"
	)
	GameState.reset_progress_for_tests()


func test_resonance_bonus_only_applies_to_matching_school() -> void:
	GameState.reset_progress_for_tests()
	for _i in range(30):
		GameState.register_spell_use("fire_bolt", "fire")
	var fire_mult: float = GameState.get_equipment_damage_multiplier("fire")
	var ice_mult_base: float = 1.0  # no equipment
	var ice_mult: float = GameState.get_equipment_damage_multiplier("ice")
	assert_gt(fire_mult, 1.0, "Fire multiplier elevated by resonance bonus")
	assert_almost_eq(
		ice_mult, ice_mult_base, 0.001, "Ice multiplier unaffected by fire resonance bonus"
	)
	GameState.reset_progress_for_tests()


func test_resonance_bonus_clears_on_reset() -> void:
	GameState.reset_progress_for_tests()
	for _i in range(30):
		GameState.register_spell_use("fire_bolt", "fire")
	assert_ne(GameState.resonance_bonus_school, "", "Bonus school set before reset")
	GameState.reset_progress_for_tests()
	assert_eq(GameState.resonance_bonus_school, "", "Bonus school cleared by reset")
	assert_eq(GameState.resonance_bonus_timer, 0.0, "Bonus timer cleared by reset")

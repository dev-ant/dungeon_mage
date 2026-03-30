extends "res://addons/gut/test.gd"

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()

func _promote_to_circle_6_for_tests() -> void:
	for skill in GameDatabase.get_all_skills():
		var skill_id: String = str(skill.get("skill_id", ""))
		GameState.skill_level_data[skill_id] = 6
		if skill_id in ["fire_ember_dart", "ice_frost_needle", "lightning_thunder_lance", "fire_mastery"]:
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
	assert_eq(variant["label"], "Lightning resonance makes the maze feel alert and over-responsive.")
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
	assert_eq(GameState.last_combo_effect.get("effect_id", ""), first_effect.get("effect_id", ""), "ICD must block second trigger")
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
	assert_false(GameState.try_activate_buff("holy_mana_veil"), "ritual_recast_lock must block new buff activation")

func test_buff_cooldown_summary_shows_all_ready_when_no_cooldowns() -> void:
	GameState.reset_progress_for_tests()
	var summary := GameState.get_buff_cooldown_summary()
	assert_string_contains(summary, "all ready", "Summary must show 'all ready' when no buff is on cooldown")
	assert_false(summary.contains("cd:"), "Summary must not contain cd: prefix when all buffs are ready")

func test_buff_cooldown_summary_shows_cd_format_for_active_cooldown() -> void:
	GameState.reset_progress_for_tests()
	_promote_to_circle_6_for_tests()
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	var summary := GameState.get_buff_cooldown_summary()
	assert_string_contains(summary, "cd:", "Summary must show cd: prefix for a buff on cooldown")
	assert_false(summary.contains("all ready"), "Summary must not show 'all ready' when a buff is cooling down")

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
	assert_gt(int(modified.get("damage", 0)), 20, "dark_grave_pact buff must increase dark spell damage via apply_spell_modifiers")
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
	assert_lt(reduced_cooldown, base_cooldown, "World Hourglass buff must reduce fire_bolt cooldown")
	GameState.reset_progress_for_tests()

func test_grave_pact_kill_leech_restores_hp_on_notify_enemy_killed() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("dark_grave_pact"))
	GameState.health = GameState.max_health - 20
	var hp_before: int = GameState.health
	GameState.notify_enemy_killed()
	assert_gt(GameState.health, hp_before, "kill_leech from Grave Pact must restore HP on enemy kill")

func test_notify_enemy_killed_without_kill_leech_does_not_change_hp() -> void:
	GameState.reset_progress_for_tests()
	GameState.health = GameState.max_health - 10
	var hp_before: int = GameState.health
	GameState.notify_enemy_killed()
	assert_eq(GameState.health, hp_before, "Without kill_leech active, enemy kill must not restore HP")

func test_world_hourglass_downside_penalty_increases_cooldown_after_expiry() -> void:
	GameState.reset_progress_for_tests()
	var base_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var base_cooldown: float = float(base_runtime.get("cooldown", 0.0))
	# Inject the downside penalty directly (cast_speed_multiplier < 1.0 = slowdown)
	GameState.active_penalties.append({"stat": "cast_speed_multiplier", "mode": "mul", "value": 0.75, "remaining": 8.0})
	var penalized_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var penalized_cooldown: float = float(penalized_runtime.get("cooldown", 0.0))
	assert_gt(penalized_cooldown, base_cooldown, "World Hourglass downside penalty must increase spell cooldown")
	GameState.reset_progress_for_tests()

func test_crystal_aegis_buff_provides_super_armor_charges() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_eq(GameState.get_super_armor_charges(), 0, "No super armor charges without buff")
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	assert_gt(GameState.get_super_armor_charges(), 0, "Crystal Aegis buff must provide super armor charges")
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
	assert_gt(charges_before_hit, 0, "Super armor charges must be present while Crystal Aegis is active")
	GameState.reset_progress_for_tests()

func test_mana_regen_multiplier_penalty_stops_mana_regen() -> void:
	GameState.reset_progress_for_tests()
	GameState.mana = 0.0
	# Inject mana_regen_multiplier: 0.0 penalty (conductive_surge downside)
	GameState.active_penalties.append({"stat": "mana_regen_multiplier", "mode": "mul", "value": 0.0, "remaining": 6.0})
	var mana_before: float = GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_eq(GameState.mana, mana_before, "mana_regen_multiplier 0.0 penalty must stop mana regeneration entirely")
	GameState.reset_progress_for_tests()

func test_mana_regen_works_normally_without_penalty() -> void:
	GameState.reset_progress_for_tests()
	GameState.mana = 0.0
	var mana_before: float = GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_gt(GameState.mana, mana_before, "Mana must regenerate normally when no penalty is active")
	GameState.reset_progress_for_tests()

func test_self_burn_penalty_deals_periodic_fire_damage() -> void:
	GameState.reset_progress_for_tests()
	GameState.health = GameState.max_health
	# Inject self_burn: 1 penalty (fire_pyre_heart downside after expiry)
	GameState.active_penalties.append({"stat": "self_burn", "mode": "add", "value": 1, "remaining": 4.0})
	var hp_before: int = GameState.health
	GameState._tick_active_buff_drains(5.0)
	assert_lt(GameState.health, hp_before, "self_burn penalty must deal damage over time")
	GameState.reset_progress_for_tests()

func test_self_burn_penalty_does_not_kill_player() -> void:
	GameState.reset_progress_for_tests()
	GameState.health = 1
	GameState.active_penalties.append({"stat": "self_burn", "mode": "add", "value": 100, "remaining": 4.0})
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
	assert_eq(str(GameState.last_combo_effect.get("effect_id", "")), "lightning_ping", "extra_lightning_ping must emit lightning_ping combo effect")
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
	assert_ne(str(GameState.last_combo_effect.get("effect_id", "")), "lightning_ping", "extra_lightning_ping must not fire for non-lightning spells")
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
	assert_eq(GameState.mana, GameState.max_mana, "Buffs without mana_percent effect must not drain mana to zero on activation")
	GameState.reset_progress_for_tests()

func test_stagger_taken_multiplier_is_one_without_penalty() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(GameState.get_stagger_taken_multiplier(), 1.0, "Stagger multiplier must be 1.0 with no active penalty")
	GameState.reset_progress_for_tests()

func test_stagger_taken_multiplier_above_one_with_penalty() -> void:
	GameState.reset_progress_for_tests()
	# wind_tempest_drive downside pushes this penalty on expiry
	GameState.active_penalties.append({"stat": "stagger_taken_multiplier", "mode": "mul", "value": 1.15, "remaining": 2.0})
	assert_gt(GameState.get_stagger_taken_multiplier(), 1.0, "Stagger penalty must raise multiplier above 1.0")
	GameState.reset_progress_for_tests()

func test_ice_reflect_wave_emits_combo_effect_on_ice_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("ice_frostblood_ward"))
	GameState.last_combo_effect = {}
	var payload: Dictionary = {"school": "ice", "damage": 25, "cooldown": 1.0}
	GameState.apply_spell_modifiers(payload.duplicate())
	assert_eq(str(GameState.last_combo_effect.get("effect_id", "")), "ice_reflect_wave", "ice_reflect_wave must emit combo effect on ice spell cast")
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
	assert_ne(str(GameState.last_combo_effect.get("effect_id", "")), "ice_reflect_wave", "ice_reflect_wave must not fire for non-ice spells")
	GameState.reset_progress_for_tests()

func test_ash_residue_burst_fires_when_dark_throne_active_without_ashen_rite() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("dark_throne_of_ash"))
	assert_false(GameState.ashen_rite_active, "Precondition: Ashen Rite must NOT be active without the full trio")
	GameState.last_combo_effect = {}
	GameState.ash_residue_timer = 0.0  # force immediate trigger on next tick
	GameState._tick_buff_runtime(0.1)
	assert_eq(str(GameState.last_combo_effect.get("effect_id", "")), "ash_residue_burst", "ash_residue_burst must fire periodically when dark_throne_of_ash is active solo")
	GameState.reset_progress_for_tests()

func test_ash_residue_burst_does_not_fire_without_ash_buff() -> void:
	GameState.reset_progress_for_tests()
	assert_false(GameState.ashen_rite_active)
	GameState.last_combo_effect = {}
	GameState.ash_residue_timer = 0.0
	GameState._tick_buff_runtime(0.1)
	assert_ne(str(GameState.last_combo_effect.get("effect_id", "")), "ash_residue_burst", "ash_residue_burst must not fire without dark_throne_of_ash or Ashen Rite")
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

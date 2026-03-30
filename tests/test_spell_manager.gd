extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const SPELL_MANAGER_SCRIPT := preload("res://scripts/player/spell_manager.gd")

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()

func test_spell_manager_starts_cooldown_after_cast() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("fire_bolt"))
	assert_gt(manager.get_cooldown("fire_bolt"), 0.0)
	assert_false(manager.attempt_cast("fire_bolt"))
	manager.tick(1.0)
	assert_true(manager.attempt_cast("fire_bolt"))

func test_spell_manager_respects_dead_player_lock() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	player.debug_mark_dead()
	assert_false(manager.attempt_cast("volt_spear"))

func test_spell_manager_can_activate_buff_slot_and_report_it() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_mana_veil"))
	assert_eq(GameState.active_buffs.size(), 1)
	assert_string_contains(manager.get_hotbar_summary(), "Q Mana Veil")

func test_spell_manager_can_reassign_slot_and_persist_to_game_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "volt_spear"))
	var bindings: Array = manager.get_slot_bindings()
	assert_eq(str(bindings[0].get("skill_id", "")), "volt_spear")
	var saved_bindings: Array = GameState.get_spell_hotbar()
	assert_eq(str(saved_bindings[0].get("skill_id", "")), "volt_spear")

func test_spell_manager_can_cast_deploy_skill_from_reassigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.assign_skill_to_slot(1, "earth_stone_spire"))
	assert_true(manager.attempt_cast("earth_stone_spire"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_stone_spire")
	assert_eq(str(payloads[0].get("school", "")), "earth")

func test_spell_manager_toggle_skill_emits_periodic_aura_and_can_turn_off() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	assert_true(manager.attempt_cast("dark_grave_echo"))
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "dark_grave_echo")
	assert_string_contains(manager.get_hotbar_summary(), "Grave Echo ON")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_false(manager.get_hotbar_summary().contains("Grave Echo ON"))

func test_spell_manager_blocks_cast_when_mana_is_empty() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	GameState.mana = 0.0
	assert_false(manager.attempt_cast("fire_bolt"))
	assert_eq(manager.get_last_failure_reason(), "mana")
	assert_eq(manager.get_feedback_summary(), "Cast  Need more mana")

func test_spell_manager_ignores_cooldown_when_admin_flag_is_enabled() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("fire_bolt"))
	assert_false(manager.attempt_cast("fire_bolt"))
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(manager.attempt_cast("fire_bolt"))

func test_spell_manager_reports_toggle_feedback_in_summary() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_eq(manager.get_feedback_summary(), "Cast  Grave Echo on")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_eq(manager.get_feedback_summary(), "Cast  Grave Echo off")

func test_toggle_skill_consumes_mana_each_tick() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	var before_mana := GameState.mana
	assert_true(manager.attempt_cast("dark_grave_echo"))
	manager.tick(0.2)
	assert_lt(GameState.mana, before_mana - 1.0)

func test_toggle_skill_turns_off_when_mana_runs_out() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	GameState.mana = 8.0
	assert_true(manager.attempt_cast("dark_grave_echo"))
	manager.tick(0.2)
	manager.tick(1.1)
	assert_false(manager.get_hotbar_summary().contains("Grave Echo ON"))
	assert_eq(manager.get_feedback_summary(), "Cast  Grave Echo off (mana)")

func test_toggle_skill_uses_data_driven_sustain_cost() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	var before_mana := GameState.mana
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(0.2)
	var mana_spent := before_mana - GameState.mana
	assert_gt(mana_spent, 15.0)
	assert_lt(mana_spent, 17.5)

func test_toggle_sustain_cost_scales_down_with_skill_level() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	GameState.skill_level_data["ice_glacial_dominion"] = 20
	var before_mana := GameState.mana
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(0.2)
	var mana_spent := before_mana - GameState.mana
	assert_gt(mana_spent, 14.0)
	assert_lt(mana_spent, 16.0)

func test_glacial_dominion_toggle_emits_slow_utility_payload() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow")

func test_tempest_crown_toggle_emits_runtime_pierce_bonus() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	GameState.skill_level_data["lightning_tempest_crown"] = 24
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	assert_eq(int(payloads[0].get("pierce", 0)), 4)

func test_toggle_summary_reports_active_toggle_tick_and_drain() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "Glacial Dominion")
	assert_string_contains(summary, "drain")
	assert_string_contains(summary, "slow")

func test_toggle_summary_reports_pierce_and_risk_tags() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	var crown_summary := manager.get_toggle_summary()
	assert_string_contains(crown_summary, "pierce")
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var soul_summary := manager.get_toggle_summary()
	assert_string_contains(soul_summary, "risk")

func test_soul_dominion_blocks_mp_regen_while_active() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	GameState.mana = 24.0
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(GameState.soul_dominion_active)
	var mana_before := GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_eq(GameState.mana, mana_before, "MP regen must be blocked while Soul Dominion is active")

func test_soul_dominion_increases_damage_taken_while_active() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(GameState.soul_dominion_active)
	var multiplier := GameState.get_damage_taken_multiplier()
	assert_true(multiplier >= GameState.SOUL_DOMINION_DAMAGE_TAKEN_MULT - 0.01)

func test_soul_dominion_starts_aftershock_on_toggle_off() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_false(GameState.soul_dominion_active)
	assert_gt(GameState.soul_dominion_aftershock_timer, 0.0)
	var mana_before := GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_eq(GameState.mana, mana_before, "MP regen must be blocked during aftershock")

func test_soul_dominion_aftershock_clears_after_duration() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_gt(GameState.soul_dominion_aftershock_timer, 0.0)
	GameState._tick_buff_runtime(GameState.SOUL_DOMINION_AFTERSHOCK_DURATION + 0.1)
	assert_eq(GameState.soul_dominion_aftershock_timer, 0.0)
	GameState.mana = 100.0
	GameState._tick_mana_regeneration(1.0)
	assert_gt(GameState.mana, 100.0, "MP regen resumes after aftershock expires")

func test_hotbar_summary_shows_ready_marker_when_cooldown_is_zero() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	manager.reset_all_cooldowns()
	var summary := manager.get_hotbar_summary()
	assert_string_contains(summary, "---", "Ready slot must show --- not 0.0")
	assert_false(summary.contains(" 0.0"), "0.0 should not appear in hotbar summary for ready slots")

func test_hotbar_summary_shows_cd_prefix_when_on_cooldown() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("fire_bolt"))
	var summary := manager.get_hotbar_summary()
	assert_string_contains(summary, "cd:", "Cooling-down slot must show cd: prefix")

func test_hotbar_summary_shows_empty_marker_for_unassigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, ""))
	var summary := manager.get_hotbar_summary()
	assert_string_contains(summary, "[empty]", "Unassigned slot must show [empty]")

func test_toggle_summary_shows_soul_dominion_risk_detail_inline() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "MP-LOCK", "Soul Dominion toggle must show MP-LOCK risk detail")
	assert_string_contains(summary, "DMG+", "Soul Dominion toggle must show damage increase percent")
	assert_string_contains(summary, "risk", "Soul Dominion toggle must still carry risk tag")

func test_toggle_summary_other_skills_do_not_show_soul_dominion_detail() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_false(summary.contains("MP-LOCK"), "Non-Soul-Dominion toggles must not show MP-LOCK risk detail")

func test_hotbar_mastery_summary_shows_level_and_xp_for_default_slots() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var summary := manager.get_hotbar_mastery_summary()
	assert_string_contains(summary, "Skills", "Mastery summary must start with Skills prefix")
	assert_string_contains(summary, "Lv.", "Mastery summary must contain level marker")
	assert_string_contains(summary, "Z", "Mastery summary must include first hotbar label Z")
	assert_string_contains(summary, "Q", "Mastery summary must include buff hotbar label Q")

func test_hotbar_mastery_summary_reflects_hotbar_changes() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "dark_soul_dominion"))
	var summary := manager.get_hotbar_mastery_summary()
	assert_string_contains(summary, "Soul", "Mastery summary must reflect reassigned slot 0 skill name")
	assert_false(summary.contains("Fire Bolt") or summary.contains("Fire Lv"), "Old skill must not appear in mastery summary after reassignment")

func test_hotbar_mastery_summary_shows_empty_marker_for_unassigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, ""))
	var summary := manager.get_hotbar_mastery_summary()
	assert_string_contains(summary, "[empty]", "Unassigned slot must show [empty] in mastery summary")

func test_toggle_summary_glacial_dominion_shows_slow_percent() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "slow", "Glacial Dominion toggle must include slow tag")
	assert_string_contains(summary, "%", "Glacial Dominion toggle must include slow percent value")
	assert_false(summary.contains("MP-LOCK"), "Glacial Dominion must not show Soul Dominion risk detail")

func test_toggle_summary_tempest_crown_shows_pierce_count() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "pierce x", "Tempest Crown toggle must show pierce count with x prefix")
	assert_false(summary.contains("MP-LOCK"), "Tempest Crown must not show Soul Dominion risk detail")
	GameState.reset_progress_for_tests()

func test_toggle_summary_glacial_dominion_does_not_show_pierce_detail() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_false(summary.contains("pierce x"), "Glacial Dominion must not show pierce count detail")

func test_verdant_overflow_buff_extends_deploy_duration() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	var base_data: Dictionary = {"size": 40.0, "duration": 10.0, "damage": 20}
	var modified := GameState.apply_deploy_buff_modifiers(base_data)
	assert_gt(float(modified.get("duration", 0.0)), 10.0, "Verdant Overflow buff must extend deploy duration beyond base")
	GameState.reset_progress_for_tests()

func test_verdant_overflow_buff_extends_deploy_range() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	var base_data: Dictionary = {"size": 40.0, "duration": 10.0, "damage": 20}
	var modified := GameState.apply_deploy_buff_modifiers(base_data)
	assert_gt(float(modified.get("size", 0.0)), 40.0, "Verdant Overflow buff must extend deploy range beyond base")
	GameState.reset_progress_for_tests()

func test_deploy_buff_modifiers_not_applied_without_active_buff() -> void:
	GameState.reset_progress_for_tests()
	var base_data: Dictionary = {"size": 40.0, "duration": 10.0, "damage": 20}
	var modified := GameState.apply_deploy_buff_modifiers(base_data)
	assert_eq(float(modified.get("size", 0.0)), 40.0, "Without buffs deploy size must remain unchanged")
	assert_eq(float(modified.get("duration", 0.0)), 10.0, "Without buffs deploy duration must remain unchanged")

func test_deploy_recast_delay_penalty_blocks_deploy_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	# Inject deploy_recast_delay penalty (verdant_overflow downside after expiry)
	GameState.active_penalties.append({"stat": "deploy_recast_delay", "mode": "add", "value": 1, "remaining": 6.0})
	assert_false(manager.attempt_cast("earth_stone_spire"), "deploy_recast_delay penalty must block deploy cast")
	GameState.reset_progress_for_tests()

func test_deploy_recast_delay_not_present_allows_deploy_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("earth_stone_spire"), "Without deploy_recast_delay penalty, deploy cast must succeed")
	GameState.reset_progress_for_tests()

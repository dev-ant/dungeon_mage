extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const SPELL_MANAGER_SCRIPT := preload("res://scripts/player/spell_manager.gd")
const SPELL_PROJECTILE_SCRIPT := preload("res://scripts/player/spell_projectile.gd")
const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")
const SPLIT_EFFECT_CASES := [
	{"spell_id": "volt_spear", "attack": "volt_spear_attack", "hit": "volt_spear_hit"},
	{"spell_id": "fire_bolt", "attack": "fire_bolt_attack", "hit": "fire_bolt_hit"},
	{"spell_id": "holy_radiant_burst", "attack": "holy_radiant_burst_attack", "hit": "holy_radiant_burst_hit"},
	{"spell_id": "water_aqua_bullet", "attack": "water_aqua_bullet_attack", "hit": "water_aqua_bullet_hit"},
	{"spell_id": "wind_gale_cutter", "attack": "wind_gale_cutter_attack", "hit": "wind_gale_cutter_hit"},
	{"spell_id": "earth_tremor", "attack": "earth_tremor_attack", "hit": "earth_tremor_hit"},
	{"spell_id": "dark_void_bolt", "attack": "dark_void_bolt_attack", "hit": "dark_void_bolt_hit"}
]
const ENEMY_ARCHETYPE_CASES := [
	{"type": "brute", "label": "melee"},
	{"type": "bomber", "label": "ranged"},
	{"type": "leaper", "label": "pressure"},
	{"type": "elite", "label": "elite"}
]

class DummyProjectileTarget extends Node2D:
	var received_hits: Array = []

	func receive_hit(p_damage: int, hit_position: Vector2, p_knockback: float, p_school: String, p_utility_effects: Array = []) -> void:
		received_hits.append({
			"damage": p_damage,
			"position": hit_position,
			"knockback": p_knockback,
			"school": p_school,
			"utility_effects": p_utility_effects.duplicate(true)
		})

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()


func after_each() -> void:
	Engine.time_scale = 1.0

func _assert_split_effect_visual_uses_cropped_single_tile(projectile: Area2D, effect_id: String) -> void:
	var sprite := projectile._create_world_effect_visual(effect_id) as AnimatedSprite2D
	assert_true(sprite != null, "%s visual must resolve from the shared world-effect registry" % effect_id)
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "%s must keep the shared 8-frame split-effect sequence" % effect_id)
	var first_frame := sprite.sprite_frames.get_frame_texture("fly", 0)
	assert_eq(first_frame.get_width(), 64, "%s frame width must stay on the cropped 64px tile, not the full preview sheet" % effect_id)
	assert_eq(first_frame.get_height(), 64, "%s frame height must stay on the cropped 64px tile, not the full preview sheet" % effect_id)
	sprite.free()

func _spawn_enemy_for_spell_coverage(root: Node2D, enemy_type: String) -> CharacterBody2D:
	var player_target := Node2D.new()
	root.add_child(player_target)
	player_target.global_position = Vector2(420.0, 0.0)
	var enemy := ENEMY_SCRIPT.new()
	enemy.configure({"type": enemy_type, "position": Vector2.ZERO}, player_target)
	root.add_child(enemy)
	return enemy

func _spawn_projectile_for_spell_coverage(root: Node2D, config: Dictionary) -> Area2D:
	var projectile := SPELL_PROJECTILE_SCRIPT.new()
	projectile.setup(config)
	root.add_child(projectile)
	return projectile

func _advance_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame

func _force_status_effect_rolls(payload: Dictionary, forced_roll: float = 0.0) -> Dictionary:
	var adjusted: Dictionary = payload.duplicate(true)
	var adjusted_effects: Array = []
	for effect in adjusted.get("utility_effects", []):
		var effect_data: Dictionary = effect.duplicate(true)
		effect_data["debug_roll"] = forced_roll
		adjusted_effects.append(effect_data)
	adjusted["utility_effects"] = adjusted_effects
	return adjusted

func _find_effect_sprite(root: Node2D, effect_id: String, effect_stage: String) -> AnimatedSprite2D:
	for child in root.get_children():
		var sprite := child as AnimatedSprite2D
		if sprite == null:
			continue
		if str(sprite.get_meta("effect_id", "")) == effect_id and str(sprite.get_meta("effect_stage", "")) == effect_stage:
			return sprite
	return null

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
	assert_string_contains(manager.get_hotbar_summary(), "Q 마나 베일")

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
	assert_eq(float(payloads[0].get("knockback", 180.0)), 0.0, "Stone Spire deploy payload should not eject targets out of its pulse zone")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "Persistent deploy hits must not freeze the whole combat loop")

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
	assert_string_contains(manager.get_hotbar_summary(), "그레이브 에코 ON")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_false(manager.get_hotbar_summary().contains("그레이브 에코 ON"))

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
	assert_eq(manager.get_feedback_summary(), "Cast  그레이브 에코 on")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_eq(manager.get_feedback_summary(), "Cast  그레이브 에코 off")

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
	assert_false(manager.get_hotbar_summary().contains("그레이브 에코 ON"))
	assert_eq(manager.get_feedback_summary(), "Cast  그레이브 에코 off (mana)")

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
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "Toggle aura ticks must not trigger hitstop")


func test_earth_tremor_active_payload_uses_area_burst_hitstop_policy() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_tremor"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "Instant area bursts must use the reduced area hitstop policy")


func test_frost_nova_active_payload_uses_area_burst_hitstop_policy() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("frost_nova"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "frost_nova")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "Frost Nova must inherit the instant area burst hitstop policy")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "freeze", "Frost Nova must act as the representative freeze burst")

func test_glacial_dominion_toggle_applies_slow_to_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.global_position = Vector2(56.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("ice_glacial_dominion"), "Glacial Dominion must activate for %s archetype" % enemy_type)
		manager.tick(1.1)
		assert_true(payloads.size() >= 1, "Glacial Dominion must emit at least one aura tick for %s" % enemy_type)
		var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
		await _advance_frames(10)
		assert_true(is_instance_valid(enemy), "Glacial Dominion should slow %s without instantly deleting it" % enemy_type)
		assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "Glacial Dominion must apply slow to %s" % enemy_type)
		assert_lt(enemy.slow_multiplier, 1.0, "Glacial Dominion must reduce movement multiplier for %s" % enemy_type)
		assert_lt(enemy.get_behavior_tempo_multiplier(), 1.0, "Glacial Dominion must also lower behavior tempo for %s" % enemy_type)
		enemy.attack_cooldown = enemy.attack_period
		enemy._tick_runtime_timers(0.5)
		assert_gt(
			enemy.attack_cooldown,
			maxf(enemy.attack_period - 0.5, 0.0),
			"Glacial Dominion slow must reduce cooldown recovery tempo for %s" % enemy_type
		)
		assert_gt(GameState.session_hit_count, 0, "Glacial Dominion must register a hit against %s" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		Engine.time_scale = 1.0
		GameState.reset_progress_for_tests()
		root.queue_free()

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

func test_tempest_crown_toggle_pierce_scales_with_skill_milestones() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)

	var player_low = autofree(PLAYER_SCRIPT.new())
	var manager_low = SPELL_MANAGER_SCRIPT.new()
	manager_low.setup(player_low)
	var low_payloads: Array = []
	manager_low.spell_cast.connect(func(payload: Dictionary) -> void: low_payloads.append(payload))
	GameState.skill_level_data["lightning_tempest_crown"] = 1
	assert_true(manager_low.attempt_cast("lightning_tempest_crown"))
	manager_low.tick(2.0)
	assert_true(low_payloads.size() >= 1)
	var low_pierce: int = int(low_payloads[0].get("pierce", 0))
	assert_eq(low_pierce, 2, "Tempest Crown base pierce must stay at 2 below milestone levels")
	assert_true(manager_low.attempt_cast("lightning_tempest_crown"))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)

	var player_high = autofree(PLAYER_SCRIPT.new())
	var manager_high = SPELL_MANAGER_SCRIPT.new()
	manager_high.setup(player_high)
	var high_payloads: Array = []
	manager_high.spell_cast.connect(func(payload: Dictionary) -> void: high_payloads.append(payload))
	GameState.skill_level_data["lightning_tempest_crown"] = 24
	assert_true(manager_high.attempt_cast("lightning_tempest_crown"))
	manager_high.tick(2.0)
	assert_true(high_payloads.size() >= 1)
	var high_pierce: int = int(high_payloads[0].get("pierce", 0))
	assert_eq(high_pierce, 4, "Tempest Crown milestone pierce must reach 4 at level 24")
	assert_gt(high_pierce, low_pierce, "Tempest Crown pierce must scale upward after milestone levels")
	assert_true(manager_high.attempt_cast("lightning_tempest_crown"))
	GameState.reset_progress_for_tests()

func test_toggle_summary_reports_active_toggle_tick_and_drain() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "프로즌 도메인")
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
	assert_string_contains(summary, "소울", "Mastery summary must reflect reassigned slot 0 skill name")
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

func test_stone_spire_deploy_repeatedly_hits_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		player.facing = 1
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.velocity = Vector2.ZERO
		enemy.gravity = 0.0
		enemy.set_physics_process(false)
		enemy.global_position = Vector2(48.0, -4.0)
		await _advance_frames(2)
		var hp_before: int = enemy.health
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("earth_stone_spire"), "Stone Spire must cast for %s archetype" % enemy_type)
		assert_eq(payloads.size(), 1, "Stone Spire must emit one deploy payload for %s archetype" % enemy_type)
		var payload: Dictionary = payloads[0]
		var single_hit_damage: int = int(
			enemy.debug_calculate_incoming_damage(int(payload.get("damage", 0)), str(payload.get("school", ""))).get("final_damage", 0)
		)
		var projectile := _spawn_projectile_for_spell_coverage(root, payload)
		await _advance_frames(120)
		var enemy_survived := is_instance_valid(enemy)
		if enemy_survived:
			assert_lt(enemy.health, hp_before - single_hit_damage, "Stone Spire must hit %s more than once while deployed" % enemy_type)
		else:
			assert_true(true, "Stone Spire may defeat %s before the deploy finishes" % enemy_type)
		assert_gt(GameState.session_hit_count, 1, "Stone Spire must record repeated hits against %s" % enemy_type)
		assert_false(is_instance_valid(projectile), "Stone Spire deploy must expire after its duration for %s" % enemy_type)
		root.queue_free()


func test_stone_spire_pulses_do_not_change_engine_time_scale() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	Engine.time_scale = 1.0
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.global_position = Vector2(52.0, -4.0)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_stone_spire"))
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(20)
	assert_gt(GameState.session_hit_count, 0, "Stone Spire must still deal damage while hitstop is disabled")
	assert_eq(Engine.time_scale, 1.0, "Persistent deploy pulses must not freeze the global timescale")
	if is_instance_valid(projectile):
		projectile.queue_free()
	root.queue_free()


func test_glacial_dominion_aura_ticks_do_not_change_engine_time_scale() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	Engine.time_scale = 1.0
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.global_position = Vector2(56.0, -4.0)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(1.1)
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(10)
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "Glacial Dominion must still apply slow while hitstop is disabled")
	assert_eq(Engine.time_scale, 1.0, "Toggle aura ticks must not freeze the global timescale")
	if is_instance_valid(projectile):
		projectile.queue_free()
	root.queue_free()


func test_earth_tremor_area_burst_triggers_short_hitstop_and_recovers() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	Engine.time_scale = 1.0
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.global_position = Vector2(20.0, -4.0)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_tremor"))
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	assert_true(projectile._hit_enemy(enemy), "Earth Tremor test projectile must register a burst hit")
	assert_lt(Engine.time_scale, 1.0, "Area burst actives should still create a short hitstop window")
	await _advance_frames(12)
	assert_eq(Engine.time_scale, 1.0, "Area burst hitstop must recover automatically")
	if is_instance_valid(projectile):
		projectile.queue_free()
	root.queue_free()


func test_frost_nova_area_burst_applies_freeze_and_feedback_to_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		Engine.time_scale = 1.0
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.global_position = Vector2(18.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("frost_nova"), "Frost Nova must cast for %s archetype" % enemy_type)
		assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst")
		var forced_payload := _force_status_effect_rolls(payloads[0])
		var utility_effects: Array = forced_payload.get("utility_effects", [])
		assert_eq(str(utility_effects[0].get("type", "")), "freeze", "Frost Nova must carry freeze utility for %s archetype" % enemy_type)
		var projectile := _spawn_projectile_for_spell_coverage(root, forced_payload)
		assert_gt(projectile.get_child_count(), 0, "Frost Nova burst must build its visual immediately for %s archetype" % enemy_type)
		var sprite := projectile.get_child(0) as AnimatedSprite2D
		assert_true(sprite != null, "Frost Nova burst must use AnimatedSprite2D feedback for %s archetype" % enemy_type)
		var hp_before: int = enemy.health
		assert_true(projectile._hit_enemy(enemy), "Frost Nova burst must connect through the real projectile hit path for %s archetype" % enemy_type)
		assert_lt(Engine.time_scale, 1.0, "Frost Nova burst must create a short area-burst hitstop window for %s archetype" % enemy_type)
		assert_lt(enemy.health, hp_before, "Frost Nova burst must damage %s archetype" % enemy_type)
		assert_gt(enemy.hit_flash_timer, 0.0, "Frost Nova burst must trigger hit flash on %s archetype" % enemy_type)
		assert_gt(float(enemy.status_timers.get("freeze", 0.0)), 0.0, "Frost Nova burst must apply freeze to %s archetype" % enemy_type)
		await _advance_frames(12)
		assert_eq(Engine.time_scale, 1.0, "Frost Nova area-burst hitstop must recover automatically for %s archetype" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		root.queue_free()

func test_plant_vine_snare_deploy_reapplies_root_during_duration() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		player.facing = 1
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.global_position = Vector2(48.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("plant_vine_snare"), "Vine Snare deploy must succeed for %s archetype" % enemy_type)
		var forced_payload := _force_status_effect_rolls(payloads[0])
		var utility_effects: Array = forced_payload.get("utility_effects", [])
		assert_eq(str(utility_effects[0].get("type", "")), "root", "Vine Snare must carry root utility for %s archetype" % enemy_type)
		var projectile := _spawn_projectile_for_spell_coverage(root, forced_payload)
		await _advance_frames(75)
		assert_gt(float(enemy.status_timers.get("root", 0.0)), 0.0, "Vine Snare must reapply root during its deploy duration for %s archetype" % enemy_type)
		assert_true(enemy._is_rooted(), "Vine Snare must leave %s in the rooted movement-lock state after a repeated pulse" % enemy_type)
		assert_true(is_instance_valid(projectile), "Vine Snare must persist through repeated pulses for %s archetype" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		root.queue_free()

func test_plant_vine_snare_deploy_cast_emits_payload_with_plant_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("plant_vine_snare"), "plant_vine_snare deploy must succeed with infinite mana")
	assert_eq(payloads.size(), 1, "Exactly one payload must be emitted")
	assert_eq(str(payloads[0].get("spell_id", "")), "plant_vine_snare")
	assert_eq(str(payloads[0].get("school", "")), "plant")
	GameState.reset_progress_for_tests()

func test_plant_vine_snare_deploy_duration_scales_with_verdant_coil() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager_plain = SPELL_MANAGER_SCRIPT.new()
	manager_plain.setup(player)
	var payloads_plain: Array = []
	manager_plain.spell_cast.connect(func(p: Dictionary) -> void: payloads_plain.append(p))
	assert_true(manager_plain.attempt_cast("plant_vine_snare"))
	var duration_plain := float(payloads_plain[0].get("duration", 0.0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_equipped_item("accessory_2", "ring_verdant_coil")
	var player2 = autofree(PLAYER_SCRIPT.new())
	var manager_coil = SPELL_MANAGER_SCRIPT.new()
	manager_coil.setup(player2)
	var payloads_coil: Array = []
	manager_coil.spell_cast.connect(func(p: Dictionary) -> void: payloads_coil.append(p))
	assert_true(manager_coil.attempt_cast("plant_vine_snare"))
	var duration_coil := float(payloads_coil[0].get("duration", 0.0))
	assert_gt(duration_coil, duration_plain, "Verdant Coil installation_duration must increase vine snare duration")
	GameState.reset_progress_for_tests()

func test_plant_vine_snare_deploy_duration_and_range_scale_with_skill_level() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["plant_vine_snare"] = 1
	var player_low = autofree(PLAYER_SCRIPT.new())
	var manager_low = SPELL_MANAGER_SCRIPT.new()
	manager_low.setup(player_low)
	var payloads_low: Array = []
	manager_low.spell_cast.connect(func(payload: Dictionary) -> void: payloads_low.append(payload))
	assert_true(manager_low.attempt_cast("plant_vine_snare"))
	assert_true(payloads_low.size() >= 1)
	var low_duration := float(payloads_low[0].get("duration", 0.0))
	var low_size := float(payloads_low[0].get("size", 0.0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["plant_vine_snare"] = 30
	var player_high = autofree(PLAYER_SCRIPT.new())
	var manager_high = SPELL_MANAGER_SCRIPT.new()
	manager_high.setup(player_high)
	var payloads_high: Array = []
	manager_high.spell_cast.connect(func(payload: Dictionary) -> void: payloads_high.append(payload))
	assert_true(manager_high.attempt_cast("plant_vine_snare"))
	assert_true(payloads_high.size() >= 1)
	var high_duration := float(payloads_high[0].get("duration", 0.0))
	var high_size := float(payloads_high[0].get("size", 0.0))

	assert_gt(high_duration, low_duration, "plant_vine_snare duration must scale upward with skill level")
	assert_gt(high_size, low_size, "plant_vine_snare range/size must scale upward with skill level")
	GameState.reset_progress_for_tests()

func test_ice_glacial_dominion_toggle_on_emits_ice_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_glacial_dominion"), "Glacial Dominion must activate")
	assert_string_contains(manager.get_feedback_summary(), "on")
	manager.tick(2.0)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "ice")
	assert_eq(str(payloads[0].get("spell_id", "")), "ice_glacial_dominion")
	assert_true(manager.attempt_cast("ice_glacial_dominion"), "Toggle off must succeed")
	assert_string_contains(manager.get_feedback_summary(), "off")
	GameState.reset_progress_for_tests()

func test_lightning_tempest_crown_toggle_on_emits_lightning_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("lightning_tempest_crown"), "Tempest Crown must activate")
	manager.tick(2.0)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "lightning")
	assert_eq(str(payloads[0].get("spell_id", "")), "lightning_tempest_crown")
	assert_true(manager.attempt_cast("lightning_tempest_crown"), "Toggle off must succeed")
	GameState.reset_progress_for_tests()

func test_ice_glacial_dominion_and_dark_grave_echo_can_be_active_simultaneously() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	manager.tick(2.0)
	var schools: Array = []
	for p in payloads:
		var school := str(p.get("school", ""))
		if not schools.has(school):
			schools.append(school)
	assert_true(schools.has("dark"), "Dark toggle must emit dark payloads")
	assert_true(schools.has("ice"), "Ice toggle must emit ice payloads")
	GameState.reset_progress_for_tests()

func test_soul_dominion_aftershock_increases_damage_taken() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var base_mult := GameState.get_damage_taken_multiplier()
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_false(GameState.soul_dominion_active)
	assert_gt(GameState.soul_dominion_aftershock_timer, 0.0)
	var aftershock_mult := GameState.get_damage_taken_multiplier()
	assert_gt(aftershock_mult, base_mult, "Aftershock must still increase damage taken multiplier")
	GameState.reset_progress_for_tests()

func test_soul_dominion_risk_summary_shows_aftershock_text() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var active_summary := GameState.get_soul_dominion_risk_summary()
	assert_string_contains(active_summary, "ACTIVE", "Risk summary must say ACTIVE while on")
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var shock_summary := GameState.get_soul_dominion_risk_summary()
	assert_string_contains(shock_summary, "AFTERSHOCK", "Risk summary must say AFTERSHOCK after toggle off")
	GameState.reset_progress_for_tests()

func test_soul_dominion_can_reactivate_after_aftershock_expires() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	GameState._tick_buff_runtime(GameState.SOUL_DOMINION_AFTERSHOCK_DURATION + 0.5)
	assert_eq(GameState.soul_dominion_aftershock_timer, 0.0)
	assert_false(GameState.soul_dominion_active)
	assert_true(manager.attempt_cast("dark_soul_dominion"), "Soul Dominion must be re-activatable after aftershock expires")
	assert_true(GameState.soul_dominion_active)
	GameState.reset_progress_for_tests()

func test_water_aqua_bullet_cast_emits_payload_with_water_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("water_aqua_bullet"), "water_aqua_bullet cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "water_aqua_bullet")
	assert_eq(str(payloads[0].get("school", "")), "water")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "water_aqua_bullet must have positive speed")
	GameState.reset_progress_for_tests()

func test_wind_gale_cutter_cast_emits_payload_with_wind_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_gale_cutter"), "wind_gale_cutter cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_gale_cutter")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_gt(int(payloads[0].get("pierce", 0)), 0, "wind_gale_cutter must have pierce > 0")
	GameState.reset_progress_for_tests()

func test_earth_tremor_cast_emits_payload_with_earth_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_tremor"), "earth_tremor cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_tremor")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_gt(int(payloads[0].get("knockback", 0)), 0, "earth_tremor must have knockback > 0")
	GameState.reset_progress_for_tests()

func test_holy_radiant_burst_cast_emits_payload_with_holy_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_radiant_burst"), "holy_radiant_burst cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_radiant_burst")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "holy_radiant_burst must have positive speed")
	GameState.reset_progress_for_tests()

func test_dark_void_bolt_cast_emits_payload_with_dark_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("dark_void_bolt"), "dark_void_bolt cast must succeed with infinite mana")
	assert_eq(payloads.size(), 1, "Exactly one payload must be emitted for dark_void_bolt")
	assert_eq(str(payloads[0].get("spell_id", "")), "dark_void_bolt")
	assert_eq(str(payloads[0].get("school", "")), "dark", "Payload school must be dark")
	GameState.reset_progress_for_tests()

func test_arcane_force_pulse_cast_emits_payload_with_arcane_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("arcane_force_pulse"), "arcane_force_pulse cast must succeed with infinite mana")
	assert_eq(payloads.size(), 1, "Exactly one payload must be emitted for arcane_force_pulse")
	assert_eq(str(payloads[0].get("spell_id", "")), "arcane_force_pulse")
	assert_eq(str(payloads[0].get("school", "")), "arcane", "Payload school must be arcane")
	GameState.reset_progress_for_tests()

func test_arcane_pulse_preset_applies_and_boosts_arcane_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("arcane")
	assert_true(GameState.apply_equipment_preset("arcane_pulse"), "arcane_pulse preset must apply")
	var boosted := GameState.get_equipment_damage_multiplier("arcane")
	assert_gt(boosted, base, "arcane_pulse preset must boost arcane damage multiplier")
	GameState.reset_progress_for_tests()

func test_dark_void_bolt_damage_boosted_by_void_lens() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager_plain = SPELL_MANAGER_SCRIPT.new()
	manager_plain.setup(player)
	var payloads_plain: Array = []
	manager_plain.spell_cast.connect(func(p: Dictionary) -> void: payloads_plain.append(p))
	assert_true(manager_plain.attempt_cast("dark_void_bolt"))
	var dmg_plain: int = int(payloads_plain[0].get("damage", 0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_equipped_item("offhand", "focus_void_lens")
	var player2 = autofree(PLAYER_SCRIPT.new())
	var manager_lens = SPELL_MANAGER_SCRIPT.new()
	manager_lens.setup(player2)
	var payloads_lens: Array = []
	manager_lens.spell_cast.connect(func(p: Dictionary) -> void: payloads_lens.append(p))
	assert_true(manager_lens.attempt_cast("dark_void_bolt"))
	var dmg_lens: int = int(payloads_lens[0].get("damage", 0))
	assert_gt(dmg_lens, dmg_plain, "focus_void_lens must increase dark_void_bolt damage payload")
	GameState.reset_progress_for_tests()

func test_volt_spear_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 22,
		"knockback": 320.0,
		"school": "lightning",
		"size": 12.0,
		"spell_id": "volt_spear",
		"color": "#f7ef6a"
	})
	assert_gt(projectile.get_child_count(), 0, "volt_spear projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "volt_spear must use AnimatedSprite2D effect visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 15, "volt_spear effect must load all sampled frames")
	assert_lt(sprite.scale.x, 0.0, "volt_spear effect must flip when traveling left")

func test_volt_spear_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("volt_spear"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "volt_spear_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "volt_spear_hit")
	GameState.reset_progress_for_tests()

func test_fire_bolt_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("fire_bolt"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_bolt_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_bolt_hit")
	GameState.reset_progress_for_tests()

func test_fire_bolt_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 16,
		"knockback": 180.0,
		"school": "fire",
		"size": 10.0,
		"spell_id": "fire_bolt",
		"attack_effect_id": "fire_bolt_attack",
		"hit_effect_id": "fire_bolt_hit",
		"color": "#ff9f45"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_bolt_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_bolt must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "fire_bolt attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "fire_bolt attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "fire_bolt attack effect should keep native orientation on rightward cast")

func test_fire_bolt_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 16,
		"knockback": 180.0,
		"school": "fire",
		"size": 10.0,
		"spell_id": "fire_bolt",
		"attack_effect_id": "fire_bolt_attack",
		"hit_effect_id": "fire_bolt_hit",
		"color": "#ff9f45"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("fire_bolt_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "fire_bolt must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "fire_bolt hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "fire_bolt hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "fire")

func test_holy_radiant_burst_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("holy_radiant_burst"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "holy_radiant_burst_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "holy_radiant_burst_hit")
	GameState.reset_progress_for_tests()

func test_holy_radiant_burst_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 24,
		"knockback": 220.0,
		"school": "holy",
		"size": 12.0,
		"spell_id": "holy_radiant_burst",
		"attack_effect_id": "holy_radiant_burst_attack",
		"hit_effect_id": "holy_radiant_burst_hit",
		"color": "#fff5b8"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("holy_radiant_burst_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "holy_radiant_burst must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "holy attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "holy attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "holy attack effect should keep native orientation on rightward cast")

func test_holy_radiant_burst_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(20.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 24,
		"knockback": 220.0,
		"school": "holy",
		"size": 12.0,
		"spell_id": "holy_radiant_burst",
		"attack_effect_id": "holy_radiant_burst_attack",
		"hit_effect_id": "holy_radiant_burst_hit",
		"color": "#fff5b8"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("holy_radiant_burst_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "holy_radiant_burst must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "holy hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "holy hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "holy")

func test_water_aqua_bullet_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_aqua_bullet"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "water_aqua_bullet_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "water_aqua_bullet_hit")
	GameState.reset_progress_for_tests()

func test_water_aqua_bullet_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 16,
		"knockback": 160.0,
		"school": "water",
		"size": 10.0,
		"spell_id": "water_aqua_bullet",
		"attack_effect_id": "water_aqua_bullet_attack",
		"hit_effect_id": "water_aqua_bullet_hit",
		"color": "#9be9ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("water_aqua_bullet_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "water_aqua_bullet must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "water attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "water attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "water attack effect should keep native orientation on rightward cast")

func test_water_aqua_bullet_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 16,
		"knockback": 160.0,
		"school": "water",
		"size": 10.0,
		"spell_id": "water_aqua_bullet",
		"attack_effect_id": "water_aqua_bullet_attack",
		"hit_effect_id": "water_aqua_bullet_hit",
		"color": "#9be9ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("water_aqua_bullet_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "water_aqua_bullet must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "water hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "water hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "water")

func test_earth_tremor_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_tremor"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_tremor_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_tremor_hit")
	GameState.reset_progress_for_tests()

func test_earth_tremor_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "earth",
		"size": 14.0,
		"spell_id": "earth_tremor",
		"attack_effect_id": "earth_tremor_attack",
		"hit_effect_id": "earth_tremor_hit",
		"color": "#d9c19b"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("earth_tremor_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_tremor must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "earth attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "earth attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "earth attack effect should keep native orientation on rightward cast")

func test_earth_tremor_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "earth",
		"size": 14.0,
		"spell_id": "earth_tremor",
		"attack_effect_id": "earth_tremor_attack",
		"hit_effect_id": "earth_tremor_hit",
		"color": "#d9c19b"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("earth_tremor_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "earth_tremor must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "earth hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "earth hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "earth")

func test_dark_void_bolt_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("dark_void_bolt"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "dark_void_bolt_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "dark_void_bolt_hit")
	GameState.reset_progress_for_tests()

func test_dark_void_bolt_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 400.0,
		"team": "player",
		"damage": 18,
		"knockback": 170.0,
		"school": "dark",
		"size": 11.0,
		"spell_id": "dark_void_bolt",
		"attack_effect_id": "dark_void_bolt_attack",
		"hit_effect_id": "dark_void_bolt_hit",
		"color": "#7a63ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("dark_void_bolt_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "dark_void_bolt must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "dark attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "dark attack effect frame must be a 64px cropped tile")
	assert_lt(attack_effect.scale.x, 0.0, "dark attack effect must mirror with leftward cast direction")

func test_dark_void_bolt_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 400.0,
		"team": "player",
		"damage": 18,
		"knockback": 170.0,
		"school": "dark",
		"size": 11.0,
		"spell_id": "dark_void_bolt",
		"attack_effect_id": "dark_void_bolt_attack",
		"hit_effect_id": "dark_void_bolt_hit",
		"color": "#7a63ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("dark_void_bolt_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "dark_void_bolt must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "dark hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "dark hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "dark")

func test_wind_gale_cutter_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("wind_gale_cutter"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "wind_gale_cutter_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "wind_gale_cutter_hit")
	GameState.reset_progress_for_tests()

func test_wind_gale_cutter_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 480.0,
		"team": "player",
		"damage": 14,
		"knockback": 140.0,
		"school": "wind",
		"size": 10.0,
		"spell_id": "wind_gale_cutter",
		"attack_effect_id": "wind_gale_cutter_attack",
		"hit_effect_id": "wind_gale_cutter_hit",
		"color": "#b8ffe5"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("wind_gale_cutter_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "wind_gale_cutter must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "wind attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "wind attack effect frame must be a 64px cropped tile")
	assert_lt(attack_effect.scale.x, 0.0, "wind attack effect must mirror with leftward cast direction")

func test_wind_gale_cutter_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 480.0,
		"team": "player",
		"damage": 14,
		"knockback": 140.0,
		"school": "wind",
		"size": 10.0,
		"spell_id": "wind_gale_cutter",
		"attack_effect_id": "wind_gale_cutter_attack",
		"hit_effect_id": "wind_gale_cutter_hit",
		"color": "#b8ffe5"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("wind_gale_cutter_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "wind_gale_cutter must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "wind hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "wind hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "wind")

func test_volt_spear_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 22,
		"knockback": 320.0,
		"school": "lightning",
		"size": 12.0,
		"spell_id": "volt_spear",
		"attack_effect_id": "volt_spear_attack",
		"hit_effect_id": "volt_spear_hit",
		"color": "#f7ef6a"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("volt_spear_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "volt_spear must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "attack effect frame must be a 64px cropped tile, not the full preview sheet")
	assert_lt(attack_effect.scale.x, 0.0, "attack effect must mirror with leftward cast direction")

func test_volt_spear_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(24.0, -12.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 22,
		"knockback": 320.0,
		"school": "lightning",
		"size": 12.0,
		"spell_id": "volt_spear",
		"attack_effect_id": "volt_spear_attack",
		"hit_effect_id": "volt_spear_hit",
		"color": "#f7ef6a"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("volt_spear_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "volt_spear must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "hit effect frame must be a 64px cropped tile, not the full preview sheet")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "lightning")

func test_all_connected_split_effect_visuals_use_cropped_single_tiles() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 10,
		"knockback": 100.0,
		"school": "arcane",
		"size": 10.0,
		"spell_id": "volt_spear"
	})
	for split_case in SPLIT_EFFECT_CASES:
		_assert_split_effect_visual_uses_cropped_single_tile(projectile, str(split_case.get("attack", "")))
		_assert_split_effect_visual_uses_cropped_single_tile(projectile, str(split_case.get("hit", "")))

func test_split_effect_payload_registry_stays_in_sync_with_world_effect_registry() -> void:
	var manager = SPELL_MANAGER_SCRIPT.new()
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var expected_effect_ids: Array[String] = []
	for skill_id in manager.get_split_effect_skill_ids():
		var payload := manager.get_split_effect_payload(skill_id)
		assert_false(payload.is_empty(), "%s must keep a split-effect payload entry" % skill_id)
		var attack_id := str(payload.get("attack", ""))
		var hit_id := str(payload.get("hit", ""))
		assert_false(attack_id.is_empty(), "%s must keep an attack effect id" % skill_id)
		assert_false(hit_id.is_empty(), "%s must keep a hit effect id" % skill_id)
		assert_true(projectile.has_world_effect_spec(attack_id), "%s attack effect must have a matching world effect spec" % skill_id)
		assert_true(projectile.has_world_effect_spec(hit_id), "%s hit effect must have a matching world effect spec" % skill_id)
		expected_effect_ids.append(attack_id)
		expected_effect_ids.append(hit_id)
	expected_effect_ids.sort()
	assert_eq(projectile.get_world_effect_ids(), expected_effect_ids, "world effect registry must stay aligned with split-effect payload registry")

func test_single_projectile_active_hits_all_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		var root := Node2D.new()
		add_child_autofree(root)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		await get_tree().process_frame
		var hp_before: int = enemy.health
		var session_hits_before: int = GameState.session_hit_count
		var expected_damage: int = int(enemy.debug_calculate_incoming_damage(16, "fire").get("final_damage", 0))
		var projectile := _spawn_projectile_for_spell_coverage(root, {
			"position": Vector2(18.0, -10.0),
			"velocity": Vector2(120.0, 0.0),
			"range": 320.0,
			"team": "player",
			"damage": 16,
			"knockback": 180.0,
			"school": "fire",
			"size": 10.0,
			"spell_id": "fire_bolt",
			"attack_effect_id": "fire_bolt_attack",
			"hit_effect_id": "fire_bolt_hit",
			"color": "#ff9f45"
		})
		await get_tree().process_frame
		projectile._hit_enemy(enemy)
		await get_tree().process_frame
		var hit_effect := _find_effect_sprite(root, "fire_bolt_hit", "hit")
		assert_true(hit_effect != null, "fire_bolt hit effect must appear for %s archetype" % enemy_type)
		assert_eq(enemy.health, hp_before - expected_damage, "fire_bolt must damage %s archetype through projectile hit path" % enemy_type)
		assert_eq(GameState.session_hit_count, session_hits_before + 1, "fire_bolt must record one enemy hit for %s archetype" % enemy_type)
		assert_gt(enemy.hit_flash_timer, 0.0, "fire_bolt hit must trigger hit flash on %s archetype" % enemy_type)

func test_piercing_projectile_active_hits_all_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		var root := Node2D.new()
		add_child_autofree(root)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		await get_tree().process_frame
		var hp_before: int = enemy.health
		var expected_damage: int = int(enemy.debug_calculate_incoming_damage(14, "wind").get("final_damage", 0))
		var projectile := _spawn_projectile_for_spell_coverage(root, {
			"position": Vector2(18.0, -10.0),
			"velocity": Vector2(120.0, 0.0),
			"range": 480.0,
			"team": "player",
			"damage": 14,
			"knockback": 140.0,
			"school": "wind",
			"size": 10.0,
			"spell_id": "wind_gale_cutter",
			"attack_effect_id": "wind_gale_cutter_attack",
			"hit_effect_id": "wind_gale_cutter_hit",
			"pierce": 3,
			"color": "#b8ffe5"
		})
		await get_tree().process_frame
		projectile._hit_enemy(enemy)
		await get_tree().process_frame
		var hit_effect := _find_effect_sprite(root, "wind_gale_cutter_hit", "hit")
		assert_true(hit_effect != null, "wind_gale_cutter hit effect must appear for %s archetype" % enemy_type)
		assert_eq(enemy.health, hp_before - expected_damage, "wind_gale_cutter must damage %s archetype through projectile hit path" % enemy_type)
		assert_gt(enemy.hit_flash_timer, 0.0, "wind_gale_cutter hit must trigger hit flash on %s archetype" % enemy_type)
		assert_eq(projectile.pierce, 2, "wind_gale_cutter must preserve remaining pierce after hitting %s archetype" % enemy_type)

func test_frost_nova_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 76.0,
		"duration": 0.2,
		"team": "player",
		"damage": 14,
		"knockback": 120.0,
		"school": "ice",
		"size": 72.0,
		"spell_id": "frost_nova",
		"color": "#8cecff"
	})
	assert_gt(projectile.get_child_count(), 0, "frost_nova projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "frost_nova must use AnimatedSprite2D burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "frost_nova effect must load all sampled frames")
	assert_gt(sprite.scale.x, 0.0, "frost_nova burst must keep native non-flipped orientation")

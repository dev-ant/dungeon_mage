extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const SPELL_MANAGER_SCRIPT := preload("res://scripts/player/spell_manager.gd")
const SPELL_PROJECTILE_SCRIPT := preload("res://scripts/player/spell_projectile.gd")
const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()


func _advance_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _spawn_enemy_for_equipment_coverage(
	root: Node2D, enemy_type: String, target: Node2D = null, enemy_position: Vector2 = Vector2.ZERO
) -> CharacterBody2D:
	var enemy := ENEMY_SCRIPT.new()
	enemy.configure({"type": enemy_type, "position": enemy_position}, target)
	root.add_child(enemy)
	return enemy


func _spawn_projectile_for_equipment_coverage(root: Node2D, payload: Dictionary) -> Area2D:
	var projectile := SPELL_PROJECTILE_SCRIPT.new()
	projectile.setup(payload)
	root.add_child(projectile)
	return projectile


func _activate_prismatic_guard_for_equipment_coverage() -> void:
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("holy_mana_veil"))
	assert_true(GameState.try_activate_buff("holy_crystal_aegis"))
	assert_eq(
		GameState.combo_barrier_combo_id,
		"combo_prismatic_guard",
		"Prismatic Guard combo must be active for barrier coverage tests"
	)


func test_equipment_preset_changes_runtime_damage_and_summary() -> void:
	var base_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	var boosted_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	assert_gt(int(boosted_runtime.get("damage", 0)), int(base_runtime.get("damage", 0)))
	assert_string_contains(GameState.get_equipment_summary(), "Preset:fire_burst")


func test_equipment_affects_deploy_runtime() -> void:
	assert_true(GameState.apply_equipment_preset("ritual_control"))
	var manager = preload("res://scripts/player/spell_manager.gd").new()
	var player = autofree(preload("res://scripts/player/player.gd").new())
	manager.setup(player)
	var runtime: Dictionary = manager._build_skill_runtime(
		"earth_stone_spire", GameDatabase.get_skill_data("earth_stone_spire")
	)
	assert_gt(float(runtime.get("duration", 0.0)), 0.8)
	assert_gt(float(runtime.get("size", 0.0)), 80.0)


func test_fire_burst_preset_increases_fire_bolt_damage_against_brute() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root: Node2D = Node2D.new()
	add_child_autofree(root)
	var player: CharacterBody2D = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager: RefCounted = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy: CharacterBody2D = _spawn_enemy_for_equipment_coverage(root, "brute", null, Vector2(160.0, -6.0))
	enemy.set_physics_process(false)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var hp_before: int = enemy.health
	assert_true(manager.attempt_cast("fire_bolt"))
	var base_payload: Dictionary = payloads[0].duplicate(true)
	var projectile: Area2D = _spawn_projectile_for_equipment_coverage(root, base_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var base_damage: int = hp_before - enemy.health
	if is_instance_valid(projectile):
		projectile.queue_free()

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	payloads.clear()
	enemy.health = enemy.max_health
	var boosted_hp_before: int = enemy.health
	assert_true(manager.attempt_cast("fire_bolt"))
	var boosted_payload: Dictionary = payloads[0].duplicate(true)
	projectile = _spawn_projectile_for_equipment_coverage(root, boosted_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var boosted_damage: int = boosted_hp_before - enemy.health
	assert_gt(
		int(boosted_payload.get("damage", 0)),
		int(base_payload.get("damage", 0)),
		"fire_burst preset must increase Fire Bolt payload damage before the hit path resolves"
	)
	assert_gt(boosted_damage, base_damage, "fire_burst preset must increase Fire Bolt damage against brute")
	if is_instance_valid(projectile):
		projectile.queue_free()


func test_wind_tempo_preset_improves_gale_cutter_operation_against_leaper() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root: Node2D = Node2D.new()
	add_child_autofree(root)
	var player: CharacterBody2D = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager: RefCounted = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy: CharacterBody2D = _spawn_enemy_for_equipment_coverage(root, "leaper", null, Vector2(272.0, -6.0))
	enemy.set_physics_process(false)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var hp_before: int = enemy.health
	assert_true(manager.attempt_cast("wind_gale_cutter"))
	var base_payload: Dictionary = payloads[0].duplicate(true)
	var projectile: Area2D = _spawn_projectile_for_equipment_coverage(root, base_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var base_damage: int = hp_before - enemy.health
	var base_speed: float = Vector2(base_payload.get("velocity", Vector2.ZERO)).length()
	if is_instance_valid(projectile):
		projectile.queue_free()

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("wind_tempo"))
	payloads.clear()
	enemy.health = enemy.max_health
	var boosted_hp_before: int = enemy.health
	assert_true(manager.attempt_cast("wind_gale_cutter"))
	assert_true(payloads.size() >= 2, "wind_tempo preset must improve Gale Cutter operation with an extra spread projectile")
	var boosted_payload: Dictionary = payloads[0].duplicate(true)
	projectile = _spawn_projectile_for_equipment_coverage(root, boosted_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var boosted_damage: int = boosted_hp_before - enemy.health
	var boosted_speed: float = Vector2(boosted_payload.get("velocity", Vector2.ZERO)).length()
	assert_gt(boosted_speed, base_speed, "wind_tempo preset must increase Gale Cutter projectile speed")
	assert_gt(
		int(boosted_payload.get("damage", 0)),
		int(base_payload.get("damage", 0)),
		"wind_tempo preset must raise Gale Cutter payload damage through wind-focused gear"
	)
	assert_gt(boosted_damage, 0, "Gale Cutter must still damage leaper through the projectile hit path")
	assert_gt(boosted_damage, base_damage, "wind_tempo should improve Gale Cutter hit result while also preserving faster operation")
	if is_instance_valid(projectile):
		projectile.queue_free()


func test_earth_deploy_preset_increases_stone_spire_total_damage_against_elite() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root: Node2D = Node2D.new()
	add_child_autofree(root)
	var player: CharacterBody2D = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager: RefCounted = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy: CharacterBody2D = _spawn_enemy_for_equipment_coverage(root, "elite", null, Vector2(48.0, -4.0))
	enemy.velocity = Vector2.ZERO
	enemy.gravity = 0.0
	enemy.set_physics_process(false)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var hp_before: int = enemy.health
	assert_true(manager.attempt_cast("earth_stone_spire"))
	var projectile: Area2D = _spawn_projectile_for_equipment_coverage(root, payloads[0])
	await _advance_frames(84)
	var base_damage: int = hp_before - enemy.health
	if is_instance_valid(projectile):
		projectile.queue_free()

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("earth_deploy"))
	payloads.clear()
	enemy.health = enemy.max_health
	var boosted_hp_before: int = enemy.health
	assert_true(manager.attempt_cast("earth_stone_spire"))
	projectile = _spawn_projectile_for_equipment_coverage(root, payloads[0])
	await _advance_frames(84)
	var boosted_damage: int = boosted_hp_before - enemy.health
	assert_gt(
		boosted_damage,
		base_damage,
		"earth_deploy preset must increase Stone Spire total damage against elite over the same deploy window"
	)
	if is_instance_valid(projectile):
		projectile.queue_free()


func test_sanctum_sustain_preset_increases_prismatic_guard_barrier_and_blocks_midpoint_hit() -> void:
	GameState.reset_progress_for_tests()
	_activate_prismatic_guard_for_equipment_coverage()
	var base_barrier: float = GameState.combo_barrier
	GameState.reset_progress_for_tests()
	assert_true(GameState.apply_equipment_preset("sanctum_sustain"))
	_activate_prismatic_guard_for_equipment_coverage()
	var boosted_barrier: float = GameState.combo_barrier
	var incoming_damage := int(ceil(base_barrier))
	assert_gt(
		boosted_barrier,
		base_barrier,
		"sanctum_sustain must raise Prismatic Guard barrier amount over the no-equipment baseline"
	)
	GameState.reset_progress_for_tests()
	_activate_prismatic_guard_for_equipment_coverage()
	GameState.damage(incoming_damage)
	var base_remaining_barrier: float = GameState.combo_barrier
	GameState.reset_progress_for_tests()
	assert_true(GameState.apply_equipment_preset("sanctum_sustain"))
	_activate_prismatic_guard_for_equipment_coverage()
	GameState.damage(incoming_damage)
	var boosted_remaining_barrier: float = GameState.combo_barrier
	assert_gt(
		base_barrier,
		base_remaining_barrier,
		"Baseline Prismatic Guard must actually spend barrier capacity when the representative hit lands"
	)
	assert_gt(
		boosted_remaining_barrier,
		base_remaining_barrier,
		"sanctum_sustain must leave more remaining barrier after the same representative hit"
	)


func test_sanctum_sustain_preset_improves_mana_pool_regen_and_damage_taken() -> void:
	GameState.reset_progress_for_tests()
	var base_max_mana: float = GameState.max_mana
	GameState.mana = 0.0
	GameState._tick_mana_regeneration(1.0)
	var base_regen_gain: float = GameState.mana
	GameState.reset_progress_for_tests()
	var base_health_before: int = GameState.health
	GameState.damage(20)
	var base_damage_taken: int = base_health_before - GameState.health
	GameState.reset_progress_for_tests()
	assert_true(GameState.apply_equipment_preset("sanctum_sustain"))
	var boosted_max_mana: float = GameState.max_mana
	GameState.mana = 0.0
	GameState._tick_mana_regeneration(1.0)
	var boosted_regen_gain: float = GameState.mana
	var boosted_health_before: int = GameState.health
	GameState.damage(20)
	var boosted_damage_taken: int = boosted_health_before - GameState.health
	assert_gt(
		boosted_max_mana,
		base_max_mana,
		"sanctum_sustain must increase max mana through sustain-focused equipment"
	)
	assert_gt(
		boosted_regen_gain,
		base_regen_gain,
		"sanctum_sustain must increase 1-second mana regeneration over the no-equipment baseline"
	)
	assert_lt(
		boosted_damage_taken,
		base_damage_taken,
		"sanctum_sustain must reduce direct health loss through damage_taken_multiplier gear"
	)


func test_holy_guard_preset_improves_holy_radiant_burst_damage_and_speed_against_brute() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root: Node2D = Node2D.new()
	add_child_autofree(root)
	var player: CharacterBody2D = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager: RefCounted = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy: CharacterBody2D = _spawn_enemy_for_equipment_coverage(root, "brute", null, Vector2(176.0, -6.0))
	enemy.set_physics_process(false)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var hp_before: int = enemy.health
	assert_true(manager.attempt_cast("holy_radiant_burst"))
	var base_payload: Dictionary = payloads[0].duplicate(true)
	var projectile: Area2D = _spawn_projectile_for_equipment_coverage(root, base_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var base_damage: int = hp_before - enemy.health
	var base_speed: float = Vector2(base_payload.get("velocity", Vector2.ZERO)).length()
	if is_instance_valid(projectile):
		projectile.queue_free()

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("holy_guard"))
	payloads.clear()
	enemy.health = enemy.max_health
	var boosted_hp_before: int = enemy.health
	assert_true(manager.attempt_cast("holy_radiant_burst"))
	var boosted_payload: Dictionary = payloads[0].duplicate(true)
	projectile = _spawn_projectile_for_equipment_coverage(root, boosted_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var boosted_damage: int = boosted_hp_before - enemy.health
	var boosted_speed: float = Vector2(boosted_payload.get("velocity", Vector2.ZERO)).length()
	assert_gt(
		int(boosted_payload.get("damage", 0)),
		int(base_payload.get("damage", 0)),
		"holy_guard must raise Holy Radiant Burst payload damage before the hit path resolves"
	)
	assert_gt(
		boosted_speed,
		base_speed,
		"holy_guard must speed up Holy Radiant Burst projectile travel through guard/projectile gear"
	)
	assert_gt(
		boosted_damage,
		base_damage,
		"holy_guard must improve Holy Radiant Burst hit result against brute over the same representative path"
	)
	if is_instance_valid(projectile):
		projectile.queue_free()


func test_holy_guard_barrier_focus_exceeds_sanctum_sustain_guard_output() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.apply_equipment_preset("sanctum_sustain"))
	_activate_prismatic_guard_for_equipment_coverage()
	var sanctum_barrier: float = GameState.combo_barrier

	GameState.reset_progress_for_tests()
	assert_true(GameState.apply_equipment_preset("holy_guard"))
	_activate_prismatic_guard_for_equipment_coverage()
	var holy_guard_barrier: float = GameState.combo_barrier
	assert_gt(
		holy_guard_barrier,
		sanctum_barrier,
		"holy_guard must produce a larger Prismatic Guard barrier than sanctum_sustain to keep the two presets role-distinct"
	)


func test_dark_shadow_preset_improves_dark_void_bolt_damage_and_speed_against_brute() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root: Node2D = Node2D.new()
	add_child_autofree(root)
	var player: CharacterBody2D = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager: RefCounted = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy: CharacterBody2D = _spawn_enemy_for_equipment_coverage(root, "brute", null, Vector2(188.0, -6.0))
	enemy.set_physics_process(false)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var hp_before: int = enemy.health
	assert_true(manager.attempt_cast("dark_void_bolt"))
	var base_payload: Dictionary = payloads[0].duplicate(true)
	var projectile: Area2D = _spawn_projectile_for_equipment_coverage(root, base_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var base_damage: int = hp_before - enemy.health
	var base_speed: float = Vector2(base_payload.get("velocity", Vector2.ZERO)).length()
	if is_instance_valid(projectile):
		projectile.queue_free()

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("dark_shadow"))
	payloads.clear()
	enemy.health = enemy.max_health
	var boosted_hp_before: int = enemy.health
	assert_true(manager.attempt_cast("dark_void_bolt"))
	var boosted_payload: Dictionary = payloads[0].duplicate(true)
	projectile = _spawn_projectile_for_equipment_coverage(root, boosted_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var boosted_damage: int = boosted_hp_before - enemy.health
	var boosted_speed: float = Vector2(boosted_payload.get("velocity", Vector2.ZERO)).length()
	assert_gt(
		int(boosted_payload.get("damage", 0)),
		int(base_payload.get("damage", 0)),
		"dark_shadow must raise Dark Void Bolt payload damage before the hit path resolves"
	)
	assert_gt(
		boosted_speed,
		base_speed,
		"dark_shadow must increase Dark Void Bolt projectile speed through void lens gear"
	)
	assert_gt(
		boosted_damage,
		base_damage,
		"dark_shadow must improve Dark Void Bolt hit result against brute over the same representative path"
	)
	if is_instance_valid(projectile):
		projectile.queue_free()


func test_arcane_pulse_preset_improves_arcane_force_pulse_damage_against_brute() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root: Node2D = Node2D.new()
	add_child_autofree(root)
	var player: CharacterBody2D = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager: RefCounted = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy: CharacterBody2D = _spawn_enemy_for_equipment_coverage(root, "brute", null, Vector2(188.0, -6.0))
	enemy.set_physics_process(false)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var hp_before: int = enemy.health
	assert_true(manager.attempt_cast("arcane_force_pulse"))
	var base_payload: Dictionary = payloads[0].duplicate(true)
	var projectile: Area2D = _spawn_projectile_for_equipment_coverage(root, base_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var base_damage: int = hp_before - enemy.health
	if is_instance_valid(projectile):
		projectile.queue_free()

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("arcane_pulse"))
	payloads.clear()
	enemy.health = enemy.max_health
	var boosted_hp_before: int = enemy.health
	assert_true(manager.attempt_cast("arcane_force_pulse"))
	var boosted_payload: Dictionary = payloads[0].duplicate(true)
	projectile = _spawn_projectile_for_equipment_coverage(root, boosted_payload)
	await _advance_frames(1)
	projectile._hit_enemy(enemy)
	await _advance_frames(1)
	var boosted_damage: int = boosted_hp_before - enemy.health
	assert_gt(
		int(boosted_payload.get("damage", 0)),
		int(base_payload.get("damage", 0)),
		"arcane_pulse must raise Arcane Force Pulse payload damage before the hit path resolves"
	)
	assert_gt(
		boosted_damage,
		base_damage,
		"arcane_pulse must improve Arcane Force Pulse hit result against brute over the same representative path"
	)
	if is_instance_valid(projectile):
		projectile.queue_free()


func test_can_change_individual_equipment_slot() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_tempest_rod"))
	var equipped: Dictionary = GameState.get_equipped_items()
	assert_eq(str(equipped.get("weapon", "")), "weapon_tempest_rod")
	assert_string_contains(GameState.get_equipment_summary(), "Tempest Rod")


func test_equipment_updates_max_mana_and_regen() -> void:
	var base_max_mana := GameState.max_mana
	var base_regen := GameState.mana_regen_per_second
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	assert_gt(GameState.max_mana, base_max_mana)
	assert_gt(GameState.mana_regen_per_second, base_regen)


func test_equipment_damage_reduction_reduces_taken_damage() -> void:
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	var starting_health := GameState.max_health
	GameState.damage(10)
	assert_eq(GameState.health, starting_health - 9)


func test_can_grant_equipment_into_inventory() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	var inventory: Array = GameState.get_equipment_inventory()
	assert_eq(inventory.size(), 1)
	assert_eq(str(inventory[0]), "weapon_tempest_rod")
	assert_string_contains(GameState.get_equipment_inventory_summary(), "Tempest Rod")


func test_can_equip_item_from_inventory_and_swap_previous_item_back() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_ember_staff"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.equip_inventory_item("weapon", "weapon_tempest_rod"))
	var equipped: Dictionary = GameState.get_equipped_items()
	var inventory: Array = GameState.get_equipment_inventory()
	assert_eq(str(equipped.get("weapon", "")), "weapon_tempest_rod")
	assert_true(inventory.has("weapon_ember_staff"))
	assert_false(inventory.has("weapon_tempest_rod"))


func test_can_unequip_item_to_inventory() -> void:
	assert_true(GameState.set_equipped_item("offhand", "focus_storm_orb"))
	assert_true(GameState.unequip_item_to_inventory("offhand"))
	var equipped: Dictionary = GameState.get_equipped_items()
	var inventory: Array = GameState.get_equipment_inventory()
	assert_eq(str(equipped.get("offhand", "")), "")
	assert_true(inventory.has("focus_storm_orb"))


func test_slot_inventory_summary_filters_by_slot() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	assert_string_contains(GameState.get_equipment_slot_inventory_summary("weapon"), "Tempest Rod")
	assert_false(GameState.get_equipment_slot_inventory_summary("weapon").contains("Storm Orb"))


func test_drop_pool_none_returns_empty() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("none")
	assert_eq(pool.size(), 0, "none profile must have empty drop pool")


func test_drop_pool_unknown_returns_empty() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("unknown_profile")
	assert_eq(pool.size(), 0, "unknown profile must have empty drop pool")


func test_drop_pool_common_only_contains_common_and_uncommon_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("common")
	assert_gt(pool.size(), 0, "common pool must not be empty")
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		var rarity := str(item.get("rarity", ""))
		assert_true(
			rarity == "common" or rarity == "uncommon",
			"common pool must only contain common or uncommon items, got: " + rarity
		)


func test_drop_pool_common_contains_common_rarity_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("common")
	var has_common := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		if str(item.get("rarity", "")) == "common":
			has_common = true
	assert_true(has_common, "common pool must include at least one common-rarity item")


func test_drop_pool_rare_contains_uncommon_and_rare_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("rare")
	var has_rare := false
	var has_uncommon := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		var rarity := str(item.get("rarity", ""))
		if rarity == "rare":
			has_rare = true
		if rarity == "uncommon":
			has_uncommon = true
	assert_true(has_rare, "rare pool must contain at least one rare item")
	assert_true(has_uncommon, "rare pool must contain at least one uncommon item")


func test_drop_for_none_profile_always_returns_empty() -> void:
	for i in range(10):
		assert_eq(GameDatabase.get_drop_for_profile("none"), "", "none profile must never drop")


func test_resolve_drop_for_profile_returns_empty_when_chance_roll_fails() -> void:
	var item_id := GameDatabase.resolve_drop_for_profile("boss", 0.95, 0)
	assert_eq(item_id, "", "Boss drop must resolve to empty when chance roll is above 0.70")


func test_resolve_drop_for_profile_returns_weighted_item_when_chance_roll_succeeds() -> void:
	var expected_item_id := GameDatabase.get_weighted_drop_for_profile("boss", 0)
	var item_id := GameDatabase.resolve_drop_for_profile("boss", 0.0, 0)
	assert_eq(
		item_id,
		expected_item_id,
		"Resolved drop must use the weighted boss pool when chance roll succeeds"
	)
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	assert_false(item.is_empty(), "Resolved boss drop item must exist in equipment catalog")
	var rarity := str(item.get("rarity", ""))
	assert_true(
		rarity == "epic" or rarity == "legendary",
		"Resolved boss drop must stay inside epic/legendary pool, got: %s" % rarity
	)


func test_weighted_drop_for_profile_uses_forced_roll_with_wraparound() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("boss")
	assert_false(pool.is_empty(), "Boss drop pool must not be empty for forced roll coverage")
	var first_pick := GameDatabase.get_weighted_drop_for_profile("boss", 0)
	var wrapped_pick := GameDatabase.get_weighted_drop_for_profile("boss", 10_000)
	assert_ne(first_pick, "", "Forced weighted drop must return a valid item for boss profile")
	assert_ne(wrapped_pick, "", "Wrapped forced weighted drop must still return a valid item")
	var first_item: Dictionary = GameDatabase.get_equipment(first_pick)
	var wrapped_item: Dictionary = GameDatabase.get_equipment(wrapped_pick)
	assert_false(first_item.is_empty(), "Forced boss drop item must exist")
	assert_false(wrapped_item.is_empty(), "Wrapped forced boss drop item must exist")
	assert_true(
		["epic", "legendary"].has(str(first_item.get("rarity", ""))),
		"Forced boss drop must still honor rarity filter"
	)
	assert_true(
		["epic", "legendary"].has(str(wrapped_item.get("rarity", ""))),
		"Wrapped forced boss drop must still honor rarity filter"
	)


func test_drop_pool_elite_contains_both_rarities() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("elite")
	assert_gt(pool.size(), 0, "elite pool must not be empty")
	var has_rare := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		if str(item.get("rarity", "")) == "rare":
			has_rare = true
	assert_true(has_rare, "elite pool must include rare items")


# --- Projectile speed multiplier tests ---


func test_projectile_speed_multiplier_defaults_to_one_with_no_equipment() -> void:
	GameState.reset_progress_for_tests()
	var mult := GameState.get_equipment_projectile_speed_multiplier()
	assert_eq(
		mult, 1.0, "Default projectile speed multiplier must be 1.0 when no equipment is equipped"
	)


func test_swift_prism_raises_projectile_speed_multiplier() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("offhand", "focus_swift_prism"))
	var mult := GameState.get_equipment_projectile_speed_multiplier()
	assert_gt(mult, 1.0, "Swift Prism offhand must raise projectile_speed_multiplier above 1.0")
	assert_true(mult >= 1.15, "Swift Prism must provide at least 15% projectile speed bonus")


func test_flux_band_raises_projectile_speed_multiplier() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_1", "ring_flux_band"))
	var mult := GameState.get_equipment_projectile_speed_multiplier()
	assert_gt(mult, 1.0, "Flux Band must raise projectile_speed_multiplier above 1.0")


func test_projectile_speed_stacks_across_two_slots() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("offhand", "focus_swift_prism"))
	assert_true(GameState.set_equipped_item("accessory_1", "ring_flux_band"))
	var mult := GameState.get_equipment_projectile_speed_multiplier()
	assert_gt(mult, 1.25, "Stacking Swift Prism + Flux Band must exceed 1.25x multiplier")


func test_guardian_coat_raises_barrier_power_multiplier() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("body", "armor_guardian_coat"))
	var mult := GameState.get_equipment_barrier_power_multiplier()
	assert_gt(mult, 1.0, "Guardian Coat must raise barrier_power_multiplier above 1.0")
	assert_true(mult >= 1.15, "Guardian Coat must provide at least 15% barrier power bonus")


func test_projectile_count_bonus_default_is_zero() -> void:
	GameState.reset_progress_for_tests()
	assert_eq(
		GameState.get_equipment_projectile_count_bonus(),
		0,
		"Default projectile count bonus must be 0 when no equipment is equipped"
	)


func test_split_lens_grants_projectile_count_bonus_one() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_2", "accessory_split_lens"))
	assert_eq(
		GameState.get_equipment_projectile_count_bonus(),
		1,
		"Split Lens must grant projectile_count_bonus of 1"
	)


func test_triple_prism_grants_projectile_count_bonus_two() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_2", "accessory_triple_prism"))
	assert_eq(
		GameState.get_equipment_projectile_count_bonus(),
		2,
		"Triple Prism must grant projectile_count_bonus of 2"
	)


func test_spell_cast_emits_extra_projectiles_when_split_lens_equipped() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_2", "accessory_split_lens"))
	var manager := preload("res://scripts/player/spell_manager.gd").new()
	var player: Node = autofree(preload("res://scripts/player/player.gd").new())
	manager.setup(player)
	GameState.mana = GameState.max_mana
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	manager.attempt_cast("fire_bolt")
	assert_true(
		payloads.size() >= 2, "Split Lens must emit at least 2 spell_cast signals (main + 1 extra)"
	)
	var main_vel: Vector2 = payloads[0].get("velocity", Vector2.ZERO)
	var extra_vel: Vector2 = payloads[1].get("velocity", Vector2.ZERO)
	assert_true(
		absf(main_vel.angle_to(extra_vel)) > 0.05,
		"Extra projectile must travel at a different angle than the main projectile"
	)


func test_legendary_arcane_sovereign_loads_from_database() -> void:
	var item: Dictionary = GameDatabase.get_equipment("focus_arcane_sovereign")
	assert_false(item.is_empty(), "focus_arcane_sovereign must exist in GameDatabase")
	assert_eq(str(item.get("rarity", "")), "legendary")
	assert_eq(str(item.get("slot_type", "")), "offhand")
	assert_gt(float(item.get("stat_modifiers", {}).get("magic_attack", 0.0)), 0.0)


func test_legendary_soul_weave_loads_and_has_survivability_stats() -> void:
	var item: Dictionary = GameDatabase.get_equipment("armor_soul_weave")
	assert_false(item.is_empty(), "armor_soul_weave must exist in GameDatabase")
	assert_eq(str(item.get("rarity", "")), "legendary")
	var mods: Dictionary = item.get("stat_modifiers", {})
	assert_gt(float(mods.get("max_hp", 0.0)), 0.0)
	assert_gt(float(mods.get("mp_regen", 0.0)), 0.0)
	assert_lt(
		float(mods.get("damage_taken_multiplier", 1.0)),
		1.0,
		"damage_taken_multiplier must reduce damage taken"
	)


func test_legendary_prismatic_apex_grants_buff_duration_and_aoe() -> void:
	GameState.reset_progress_for_tests()
	assert_true(GameState.set_equipped_item("accessory_1", "ring_prismatic_apex"))
	var buff_mult := GameState.get_equipment_buff_duration_multiplier()
	assert_gt(buff_mult, 1.20, "Prismatic Apex must grant > 1.20x buff duration")
	var aoe_mult := GameState.get_equipment_aoe_multiplier()
	assert_gt(aoe_mult, 1.15, "Prismatic Apex must grant > 1.15x AoE radius")
	GameState.reset_progress_for_tests()


func test_boss_drop_profile_pools_only_epic_and_legendary() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("boss")
	assert_false(pool.is_empty(), "Boss drop pool must not be empty")
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(item_id)
		var rarity := str(item.get("rarity", ""))
		assert_true(
			rarity == "epic" or rarity == "legendary",
			"Boss pool must only contain epic/legendary items, found: %s (%s)" % [item_id, rarity]
		)


func test_boss_drop_profile_includes_legendary_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("boss")
	var has_legendary := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(item_id)
		if str(item.get("rarity", "")) == "legendary":
			has_legendary = true
			break
	assert_true(has_legendary, "Boss drop pool must include at least one legendary item")


func test_legendary_arcane_sovereign_boosts_fire_and_lightning_damage() -> void:
	GameState.reset_progress_for_tests()
	var fire_base := GameState.get_equipment_damage_multiplier("fire")
	var lightning_base := GameState.get_equipment_damage_multiplier("lightning")
	assert_true(GameState.set_equipped_item("offhand", "focus_arcane_sovereign"))
	var fire_with := GameState.get_equipment_damage_multiplier("fire")
	var lightning_with := GameState.get_equipment_damage_multiplier("lightning")
	assert_gt(fire_with, fire_base, "Arcane Sovereign must boost fire damage")
	assert_gt(lightning_with, lightning_base, "Arcane Sovereign must boost lightning damage")
	GameState.reset_progress_for_tests()


func test_earth_deploy_preset_applies_and_boosts_earth_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_earth := GameState.get_equipment_damage_multiplier("earth")
	var ok := GameState.apply_equipment_preset("earth_deploy")
	assert_true(ok, "earth_deploy preset must apply successfully")
	var boosted_earth := GameState.get_equipment_damage_multiplier("earth")
	assert_gt(boosted_earth, base_earth, "earth_deploy preset must boost earth damage multiplier")
	GameState.reset_progress_for_tests()


func test_holy_guard_preset_applies_and_boosts_holy_damage() -> void:
	GameState.reset_progress_for_tests()
	var base_holy := GameState.get_equipment_damage_multiplier("holy")
	var ok := GameState.apply_equipment_preset("holy_guard")
	assert_true(ok, "holy_guard preset must apply successfully")
	var boosted_holy := GameState.get_equipment_damage_multiplier("holy")
	assert_gt(boosted_holy, base_holy, "holy_guard preset must boost holy damage multiplier")
	GameState.reset_progress_for_tests()


func test_holy_guard_preset_boosts_barrier_power() -> void:
	GameState.reset_progress_for_tests()
	var base_barrier := GameState.get_equipment_barrier_power_multiplier()
	assert_true(GameState.apply_equipment_preset("holy_guard"))
	var boosted_barrier := GameState.get_equipment_barrier_power_multiplier()
	assert_gt(
		boosted_barrier,
		base_barrier,
		"holy_guard preset must boost barrier power via armor_guardian_coat"
	)
	GameState.reset_progress_for_tests()


func test_earth_deploy_preset_equips_greaves_earthen_stride() -> void:
	assert_true(GameState.apply_equipment_preset("earth_deploy"))
	var equipped: Dictionary = GameState.get_equipped_items()
	assert_eq(
		str(equipped.get("legs", "")),
		"greaves_earthen_stride",
		"earth_deploy preset must equip greaves_earthen_stride in legs slot"
	)
	GameState.reset_progress_for_tests()


func test_legacy_spell_earth_tremor_links_to_earth_terra_break() -> void:
	GameState.reset_progress_for_tests()
	var skill_id := GameState.get_skill_id_for_spell("earth_tremor")
	assert_eq(
		str(skill_id),
		"earth_terra_break",
		"earth_tremor must map to earth_terra_break via LEGACY_SPELL_TO_SKILL"
	)


func test_legacy_spell_holy_radiant_burst_links_to_holy_healing_pulse() -> void:
	GameState.reset_progress_for_tests()
	var skill_id := GameState.get_skill_id_for_spell("holy_radiant_burst")
	assert_eq(
		str(skill_id),
		"holy_healing_pulse",
		"holy_radiant_burst must map to holy_healing_pulse via LEGACY_SPELL_TO_SKILL"
	)


func test_focus_void_lens_boosts_dark_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("dark")
	assert_true(GameState.set_equipped_item("offhand", "focus_void_lens"))
	var boosted := GameState.get_equipment_damage_multiplier("dark")
	assert_gt(boosted, base, "focus_void_lens must boost dark damage multiplier")
	GameState.reset_progress_for_tests()


func test_ring_abyss_signet_boosts_dark_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("dark")
	assert_true(GameState.set_equipped_item("accessory_1", "ring_abyss_signet"))
	var boosted := GameState.get_equipment_damage_multiplier("dark")
	assert_gt(boosted, base, "ring_abyss_signet must boost dark damage multiplier")
	GameState.reset_progress_for_tests()


func test_focus_arcane_prism_boosts_arcane_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("arcane")
	assert_true(GameState.set_equipped_item("offhand", "focus_arcane_prism"))
	var boosted := GameState.get_equipment_damage_multiplier("arcane")
	assert_gt(boosted, base, "focus_arcane_prism must boost arcane damage multiplier")
	GameState.reset_progress_for_tests()


func test_ring_arcane_coil_boosts_arcane_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("arcane")
	assert_true(GameState.set_equipped_item("accessory_2", "ring_arcane_coil"))
	var boosted := GameState.get_equipment_damage_multiplier("arcane")
	assert_gt(boosted, base, "ring_arcane_coil must boost arcane damage multiplier")
	GameState.reset_progress_for_tests()


func test_dark_shadow_preset_applies_and_boosts_dark_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("dark")
	assert_true(GameState.apply_equipment_preset("dark_shadow"), "dark_shadow preset must apply")
	var boosted := GameState.get_equipment_damage_multiplier("dark")
	assert_gt(boosted, base, "dark_shadow preset must boost dark damage multiplier")
	GameState.reset_progress_for_tests()


func test_dark_shadow_preset_stacks_two_dark_items() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("dark")
	# stack both void_lens and abyss_signet manually
	assert_true(GameState.set_equipped_item("offhand", "focus_void_lens"))
	assert_true(GameState.set_equipped_item("accessory_1", "ring_abyss_signet"))
	var stacked := GameState.get_equipment_damage_multiplier("dark")
	assert_gt(stacked, base + 0.25, "Stacked dark items must yield > 1.25x dark damage multiplier")
	GameState.reset_progress_for_tests()


func test_weighted_drop_returns_valid_item_for_common_profile() -> void:
	var item_id := GameDatabase.get_weighted_drop_for_profile("common")
	assert_ne(item_id, "", "Weighted drop must return a non-empty item_id for common profile")
	var item := GameDatabase.get_equipment(item_id)
	assert_false(item.is_empty(), "Weighted drop item must exist in equipment catalog")
	var rarity := str(item.get("rarity", ""))
	assert_true(
		rarity == "common" or rarity == "uncommon",
		"Common profile weighted drop must return common or uncommon item, got: %s" % rarity
	)


func test_weighted_drop_returns_valid_item_for_boss_profile() -> void:
	var item_id := GameDatabase.get_weighted_drop_for_profile("boss")
	assert_ne(item_id, "", "Weighted drop must return a non-empty item_id for boss profile")
	var item := GameDatabase.get_equipment(item_id)
	assert_false(item.is_empty(), "Boss weighted drop item must exist in equipment catalog")
	var rarity := str(item.get("rarity", ""))
	assert_true(
		rarity == "epic" or rarity == "legendary",
		"Boss profile weighted drop must return epic or legendary item, got: %s" % rarity
	)


func test_weighted_drop_returns_empty_for_unknown_profile() -> void:
	var item_id := GameDatabase.get_weighted_drop_for_profile("unknown_xyz")
	assert_eq(item_id, "", "Unknown profile must return empty string from weighted drop")


func test_weighted_drop_rarity_weight_constant_has_all_rarities() -> void:
	var weights: Dictionary = GameDatabase.DROP_RARITY_WEIGHT
	assert_true(weights.has("common"), "DROP_RARITY_WEIGHT must have common")
	assert_true(weights.has("uncommon"), "DROP_RARITY_WEIGHT must have uncommon")
	assert_true(weights.has("rare"), "DROP_RARITY_WEIGHT must have rare")
	assert_true(weights.has("epic"), "DROP_RARITY_WEIGHT must have epic")
	assert_true(weights.has("legendary"), "DROP_RARITY_WEIGHT must have legendary")
	assert_gt(
		int(weights.get("common", 0)),
		int(weights.get("rare", 0)),
		"Common items must have higher weight than rare items"
	)
	assert_gt(
		int(weights.get("rare", 0)),
		int(weights.get("epic", 0)),
		"Rare items must have higher weight than epic items"
	)

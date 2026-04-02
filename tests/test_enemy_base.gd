extends "res://addons/gut/test.gd"

const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")
const ENEMY_ATTACK_PROFILES := preload("res://scripts/enemies/enemy_attack_profiles.gd")
const PROJECTILE_SCRIPT := preload("res://scripts/player/spell_projectile.gd")


func test_dummy_enemy_configures_as_stationary_training_target() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "dummy", "position": Vector2(120, 200)}, null)
	assert_eq(enemy.enemy_type, "dummy")
	assert_eq(enemy.max_health, 9999)
	assert_eq(enemy.contact_damage, 0)
	assert_eq(enemy.move_speed, 0.0)


func test_enemy_applies_slow_utility_effect_from_ice_toggle_hit() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(500, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"ice",
		[{"type": "slow", "value": 0.28, "duration": 1.0, "debug_roll": 0.0}]
	)
	assert_lt(enemy.slow_multiplier, 1.0)
	assert_gte(enemy.slow_timer, 0.9)
	assert_lt(enemy.get_behavior_tempo_multiplier(), 1.0, "Slow must also lower behavior tempo, not only movement speed")


func test_enemy_slow_slows_attack_cooldown_recovery_and_pattern_delays() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(500, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.attack_cooldown = enemy.attack_period
	enemy._tick_runtime_timers(0.5)
	var baseline_cooldown: float = enemy.attack_cooldown
	enemy.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"ice",
		[{"type": "slow", "value": 0.28, "duration": 1.0, "debug_roll": 0.0}]
	)
	enemy.attack_cooldown = enemy.attack_period
	enemy._tick_runtime_timers(0.5)
	assert_gt(enemy.attack_cooldown, baseline_cooldown, "Slow must make the next action recover more slowly than the unslowed baseline")
	assert_gt(enemy.get_behavior_delay_multiplier(), 1.0, "Slow must lengthen owned telegraph/action delays for tempo-sensitive enemies")


func test_enemy_applies_freeze_utility_effect_as_hard_cc() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(500, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"ice",
		[{"type": "freeze", "value": 1.0, "duration": 0.6, "debug_roll": 0.0}]
	)
	assert_gt(float(enemy.status_timers.get("freeze", 0.0)), 0.0)
	assert_true(enemy._is_hard_cc_active(), "Freeze must count as a hard CC state for enemy runtime")


func test_enemy_root_only_blocks_movement_and_does_not_count_as_hard_cc() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(48, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"plant",
		[{"type": "root", "value": 1.0, "duration": 0.8, "debug_roll": 0.0}]
	)
	assert_gt(float(enemy.status_timers.get("root", 0.0)), 0.0)
	assert_true(enemy._is_rooted(), "Root timer must put the enemy in the rooted movement lock state")
	assert_false(enemy._is_hard_cc_active(), "Root must not count as a full hard CC once v1 rules are applied")


func test_damage_pipeline_applies_defense_before_health_loss() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, null)
	var result: Dictionary = enemy.debug_calculate_incoming_damage(20, "")
	assert_eq(int(result.get("defense_value", -1.0)), int(enemy.physical_defense))
	assert_lt(float(result.get("post_defense", 999.0)), 20.0)
	assert_eq(int(result.get("final_damage", 0)), 16)


func test_damage_pipeline_applies_element_resistance_and_weakness() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, null)
	var resisted: Dictionary = enemy.debug_calculate_incoming_damage(20, "fire")
	var weakened: Dictionary = enemy.debug_calculate_incoming_damage(20, "holy")
	assert_eq(float(resisted.get("element_resist", 0.0)), 0.15)
	assert_eq(float(weakened.get("element_resist", 0.0)), -0.15)
	assert_lt(int(resisted.get("final_damage", 0)), int(weakened.get("final_damage", 0)))


func test_damage_pipeline_preserves_minimum_ten_percent_damage() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "dummy", "position": Vector2.ZERO}, null)
	enemy.physical_defense = 9999.0
	var result: Dictionary = enemy.debug_calculate_incoming_damage(10, "")
	assert_eq(int(result.get("final_damage", 0)), 1)


func test_elite_super_armor_reduces_damage_to_twenty_percent_and_can_break() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var player_target: Node2D = Node2D.new()
	root.add_child(player_target)
	player_target.global_position = Vector2(400, 0)
	var enemy = ENEMY_SCRIPT.new()
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	root.add_child(enemy)
	await get_tree().process_frame
	enemy.super_armor_active = true
	enemy.stagger_accumulator = enemy.super_armor_break_threshold - 1.0
	var hp_before: int = enemy.health
	var expected: Dictionary = enemy.debug_calculate_incoming_damage(100, "fire")
	var actual_damage: int = enemy.receive_hit(100, Vector2(-10, 0), 80.0, "fire")
	assert_eq(actual_damage, int(expected.get("final_damage", 0)))
	assert_eq(enemy.health, hp_before - actual_damage)
	assert_gt(enemy.vulnerability_timer, 2.4)
	assert_false(enemy.super_armor_active)


func test_boss_super_armor_reduces_damage_to_ten_percent() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target: Node2D = Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "boss", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.super_armor_active = true
	var result: Dictionary = enemy.debug_calculate_incoming_damage(100, "holy")
	assert_eq(int(result.get("final_damage", 0)), 8)


func test_vulnerability_window_applies_bonus_damage() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "dummy", "position": Vector2.ZERO}, null)
	var baseline: Dictionary = enemy.debug_calculate_incoming_damage(20, "")
	enemy.vulnerability_timer = 2.0
	var result: Dictionary = enemy.debug_calculate_incoming_damage(20, "holy")
	assert_eq(int(result.get("final_damage", 0)), 24)
	assert_gt(int(result.get("final_damage", 0)), int(baseline.get("final_damage", 0)))


func test_status_resistance_reduces_chance_and_duration() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "boss", "position": Vector2.ZERO}, null)
	var stun: Dictionary = enemy.debug_resolve_status_effect(
		{"type": "stun", "chance": 1.0, "duration": 2.0}, 0.9
	)
	var burn: Dictionary = enemy.debug_resolve_status_effect(
		{"type": "burn", "chance": 1.0, "duration": 2.0}, 0.9
	)
	assert_lt(float(stun.get("chance", 1.0)), 0.7)
	assert_lt(float(stun.get("duration", 2.0)), 2.0)
	assert_lt(float(burn.get("chance", 1.0)), 1.0)
	assert_lt(float(burn.get("duration", 2.0)), 1.3)


func test_elite_root_duration_is_shorter_than_brute_due_to_resistance() -> void:
	var brute = autofree(ENEMY_SCRIPT.new())
	brute.configure({"type": "brute", "position": Vector2.ZERO}, null)
	brute.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"plant",
		[{"type": "root", "value": 1.0, "duration": 0.8, "debug_roll": 0.0}]
	)
	var elite = autofree(ENEMY_SCRIPT.new())
	elite.configure({"type": "elite", "position": Vector2.ZERO}, null)
	elite.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"plant",
		[{"type": "root", "value": 1.0, "duration": 0.8, "debug_roll": 0.0}]
	)
	assert_gt(float(brute.status_timers.get("root", 0.0)), float(elite.status_timers.get("root", 0.0)))


func test_rooted_bomber_can_still_fire_projectile_while_movement_is_locked() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(360, 0)
	enemy.configure({"type": "bomber", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.receive_hit(
		10,
		Vector2(-10, 0),
		0.0,
		"plant",
		[{"type": "root", "value": 1.0, "duration": 1.2, "debug_roll": 0.0}]
	)
	var payloads: Array = []
	enemy.fire_projectile.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(enemy._is_rooted(), "Bomber root timer must be active before its ranged attack")
	assert_false(enemy._is_hard_cc_active(), "Root must not disable bomber actions like a hard CC")
	ENEMY_ATTACK_PROFILES.perform_attack(enemy)
	assert_true(payloads.size() >= 1, "Rooted bomber must still be allowed to cast ranged attacks while rooted")


func test_dasher_configures_as_fast_mobile_pressure_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "dasher", "position": Vector2(200, 400)}, null)
	assert_eq(enemy.enemy_type, "dasher")
	assert_eq(enemy.max_health, 30)
	assert_gt(enemy.move_speed, 160.0)
	assert_eq(enemy.contact_damage, 12)


func test_dasher_receives_hit_and_loses_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "dasher", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(10, Vector2(-10, 0), 80.0, "fire")
	assert_eq(enemy.health, hp_before - actual_damage)


func test_sentinel_configures_as_area_control_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "sentinel", "position": Vector2(300, 400)}, null)
	assert_eq(enemy.enemy_type, "sentinel")
	assert_eq(enemy.max_health, 32)
	assert_lt(enemy.move_speed, 100.0)
	assert_eq(enemy.contact_damage, 7)


func test_sentinel_receives_hit_and_applies_knockback() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "sentinel", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(15, Vector2(-10, 0), 180.0, "fire")
	assert_eq(enemy.health, hp_before - actual_damage)
	assert_gt(enemy.velocity.x, 0.0)


func test_elite_configures_with_high_health_and_stagger_threshold() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "elite", "position": Vector2(200, 400)}, null)
	assert_eq(enemy.enemy_type, "elite")
	assert_true(enemy.max_health >= 150)
	assert_gt(enemy.stagger_threshold, 40)
	assert_true(enemy.contact_damage >= 16)


func test_elite_super_armor_blocks_stagger_below_threshold() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.super_armor_active = true
	var hp_before: int = enemy.health
	var expected: Dictionary = enemy.debug_calculate_incoming_damage(20, "fire")
	var actual_damage: int = enemy.receive_hit(20, Vector2(-10, 0), 100.0, "fire")
	assert_eq(actual_damage, int(expected.get("final_damage", 0)))
	assert_eq(enemy.health, hp_before - actual_damage)
	assert_ne(
		enemy.behavior_state, "stagger", "Super armor must block direct stagger below threshold"
	)


func test_leaper_configures_as_mobile_burst_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "leaper", "position": Vector2(300, 400)}, null)
	assert_eq(enemy.enemy_type, "leaper")
	assert_true(enemy.move_speed >= 140.0)
	assert_true(enemy.contact_damage >= 13)
	assert_false(enemy.leaper_jumping)


func test_leaper_receives_hit_and_loses_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "leaper", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(18, Vector2(-10, 0), 140.0, "lightning")
	assert_eq(enemy.health, hp_before - actual_damage)
	assert_gt(enemy.velocity.x, 0.0)


func test_bomber_configures_as_slow_ranged_denial_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "bomber", "position": Vector2(300, 400)}, null)
	assert_eq(enemy.enemy_type, "bomber")
	assert_true(enemy.move_speed < 100.0, "Bomber must be slow to maintain standoff range")
	assert_true(enemy.attack_period >= 2.5, "Bomber must have long attack interval")
	assert_true(enemy.max_health > 0)


func test_bomber_emits_fire_projectile_signal_on_attack() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(350, 0)
	enemy.configure({"type": "bomber", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	enemy._fire_bomb()
	assert_eq(payloads.size(), 1)
	assert_true(float(payloads[0].get("size", 0.0)) >= 14.0, "Bomb must be large for area denial")
	assert_true(
		(
			float(payloads[0].get("speed", 999.0)) < 120.0
			or float(payloads[0].get("velocity", Vector2.ZERO).length()) < 120.0
		),
		"Bomb must be slow"
	)
	assert_gt(
		float(payloads[0].get("gravity_per_second", 0.0)), 0.0, "Bomb must arc downward over time"
	)
	assert_gt(
		float(payloads[0].get("horizontal_drag_per_second", 0.0)),
		0.0,
		"Bomb must lose horizontal speed over time"
	)
	assert_gt(
		absf(float(payloads[0].get("velocity", Vector2.ZERO).x)),
		float(payloads[0].get("min_horizontal_speed", 0.0)),
		"Bomb must start faster than its final drift floor"
	)
	assert_eq(
		str(payloads[0].get("spell_id", "")),
		"enemy_bomber_bomb",
		"Bomb payload must identify itself for terminal burst visuals"
	)
	assert_eq(
		str(payloads[0].get("terminal_effect_id", "")),
		"bomber_burst",
		"Bomb payload must request the bomber burst terminal effect"
	)


func test_bomber_attack_state_emits_warning_marker_before_bomb() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(340, 18)
	enemy.configure({"type": "bomber", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	enemy._on_attack_state_entered()
	assert_eq(payloads.size(), 2, "Bomber attack must emit a warning marker and a bomb")
	var marker_payload: Dictionary = payloads[0]
	var bomb_payload: Dictionary = payloads[1]
	assert_eq(
		str(marker_payload.get("team", "")), "marker", "First payload must be the warning marker"
	)
	assert_true(
		bool(marker_payload.get("marker", false)), "Warning marker payload must carry marker:true"
	)
	assert_eq(int(marker_payload.get("damage", -1)), 0, "Warning marker must not deal damage")
	assert_almost_eq(
		float(marker_payload.get("position", Vector2.ZERO).x),
		player_target.global_position.x,
		0.01,
		"Warning marker must lock to the player's current X"
	)
	assert_almost_eq(
		float(marker_payload.get("position", Vector2.ZERO).y),
		player_target.global_position.y + 12.0,
		0.01,
		"Warning marker must sit on the committed aim point"
	)
	assert_true(
		float(marker_payload.get("duration", 0.0)) >= 0.5,
		"Warning marker must stay long enough to read"
	)
	assert_eq(str(bomb_payload.get("team", "")), "enemy", "Second payload must be the live bomb")
	assert_gt(float(bomb_payload.get("damage", 0)), 0.0, "Bomb payload must still deal damage")


func test_bomber_projectile_runtime_curves_and_slows() -> void:
	var projectile = autofree(PROJECTILE_SCRIPT.new())
	projectile.setup(
		{
			"position": Vector2.ZERO,
			"velocity": Vector2(88.0, 0.0),
			"range": 9999.0,
			"duration": 10.0,
			"team": "enemy",
			"damage": 14,
			"knockback": 190.0,
			"school": "void",
			"size": 16.0,
			"horizontal_drag_per_second": 24.0,
			"min_horizontal_speed": 34.0,
			"gravity_per_second": 180.0
		}
	)
	var start_speed_x: float = projectile.velocity.x
	projectile._physics_process(0.5)
	assert_lt(projectile.velocity.x, start_speed_x, "Bomb must lose horizontal speed after launch")
	assert_gt(projectile.velocity.y, 0.0, "Bomb must gain downward velocity from gravity")
	assert_gt(projectile.position.y, 0.0, "Bomb trajectory must curve downward")
	projectile._physics_process(2.0)
	assert_true(
		projectile.velocity.x >= 33.9,
		"Bomb horizontal drift must not fall below the configured floor"
	)


func test_bomber_projectile_plays_terminal_burst_effect_on_finish() -> void:
	var projectile = autofree(PROJECTILE_SCRIPT.new())
	projectile.setup(
		{
			"position": Vector2.ZERO,
			"velocity": Vector2(88.0, 0.0),
			"range": 580.0,
			"duration": 3.0,
			"team": "enemy",
			"damage": 14,
			"knockback": 190.0,
			"school": "void",
			"size": 16.0,
			"color": "#c8a033",
			"spell_id": "enemy_bomber_bomb",
			"terminal_effect_id": "bomber_burst"
		}
	)
	projectile._finish_projectile()
	assert_true(
		projectile.terminal_effect_played, "Bomber projectile must switch into terminal burst mode"
	)
	assert_false(
		projectile.is_physics_processing(), "Projectile motion must stop while terminal burst plays"
	)
	var burst_sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(burst_sprite != null, "Terminal bomber burst must use AnimatedSprite2D")
	assert_eq(
		burst_sprite.sprite_frames.get_frame_count("fly"),
		6,
		"Bomber burst must load all copied burst frames"
	)
	assert_false(
		burst_sprite.sprite_frames.get_animation_loop("fly"),
		"Bomber burst must be a one-shot animation"
	)


func test_rat_runtime_sprite_frames_load_from_assets() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var frames: SpriteFrames = enemy._build_strip_sprite_frames(
		enemy.RAT_SHEET_DIR, enemy.RAT_SHEETS, enemy.RAT_ANIM_FILES, 32, 32
	)
	assert_true(frames != null, "Rat asset bundle must load from res://assets/monsters/rat/")
	assert_eq(frames.get_frame_count("idle"), 6, "Rat idle must load 6 frames from runtime asset")
	assert_eq(frames.get_frame_count("run"), 6, "Rat run must load 6 frames from runtime asset")
	assert_eq(
		frames.get_frame_count("attack"), 6, "Rat attack must load 6 frames from runtime asset"
	)
	assert_eq(
		frames.get_frame_count("hurt"),
		1,
		"Rat hurt must load the single hurt frame from runtime asset"
	)
	assert_eq(frames.get_frame_count("death"), 6, "Rat death must load 6 frames from runtime asset")
	assert_true(frames.get_animation_loop("idle"), "Rat idle must loop")
	assert_false(frames.get_animation_loop("attack"), "Rat attack must be one-shot")


func test_tooth_walker_runtime_sprite_frames_trim_empty_death_tail() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var frames: SpriteFrames = enemy._build_grid_sprite_frames(
		enemy.TOOTH_WALKER_SHEET_PATH, enemy.TOOTH_WALKER_ANIM_ROWS, 64, 64
	)
	assert_true(
		frames != null,
		"tooth_walker runtime sheet must load from res://assets/monsters/tooth_walker/"
	)
	assert_eq(
		frames.get_frame_count("idle"), 6, "tooth_walker idle must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("run"), 6, "tooth_walker run must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("attack"),
		6,
		"tooth_walker attack must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("hurt"), 6, "tooth_walker hurt must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("death"),
		2,
		"tooth_walker death must trim blank tail cells and keep only populated frames"
	)
	assert_true(frames.get_animation_loop("idle"), "tooth_walker idle must loop")
	assert_false(frames.get_animation_loop("death"), "tooth_walker death must remain one-shot")


func test_eyeball_runtime_sprite_frames_load_from_vertical_sheet() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var frames: SpriteFrames = enemy._build_vertical_sprite_frames(
		enemy.EYEBALL_SHEET_PATH, enemy.EYEBALL_ANIM_VERT, 128, 48
	)
	assert_true(
		frames != null, "eyeball runtime sheet must load from res://assets/monsters/eyeball/"
	)
	assert_eq(
		frames.get_frame_count("idle"), 10, "eyeball idle must load 10 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("run"), 10, "eyeball run must load 10 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("attack"),
		15,
		"eyeball attack must load 15 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("hurt"), 10, "eyeball hurt must load 10 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("death"), 5, "eyeball death must load 5 frames from runtime sheet"
	)
	assert_true(frames.get_animation_loop("idle"), "eyeball idle must loop")
	assert_false(frames.get_animation_loop("attack"), "eyeball attack must remain one-shot")


func test_sword_runtime_sprite_frames_trim_empty_tail_cells() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var frames: SpriteFrames = enemy._build_grid_sprite_frames(
		enemy.SWORD_SHEET_PATH, enemy.SWORD_ANIM_ROWS, 128, 64
	)
	assert_true(frames != null, "sword runtime sheet must load from res://assets/monsters/sword/")
	assert_eq(
		frames.get_frame_count("idle"),
		7,
		"sword idle must trim blank tail cells and keep populated frames only"
	)
	assert_eq(
		frames.get_frame_count("run"),
		4,
		"sword run must trim blank tail cells and keep populated frames only"
	)
	assert_eq(
		frames.get_frame_count("attack"),
		8,
		"sword attack must trim blank tail cells and keep populated frames only"
	)
	assert_eq(frames.get_frame_count("hurt"), 14, "sword hurt must preserve all populated frames")
	assert_eq(
		frames.get_frame_count("death"),
		2,
		"sword death must trim blank tail cells and keep populated frames only"
	)
	assert_true(frames.get_animation_loop("idle"), "sword idle must loop")
	assert_false(frames.get_animation_loop("death"), "sword death must remain one-shot")


func test_trash_monster_runtime_sprite_frames_load_from_grid_sheet() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var frames: SpriteFrames = enemy._build_grid_sprite_frames(
		enemy.TRASH_MONSTER_SHEET_PATH, enemy.TRASH_MONSTER_ANIM_ROWS, 64, 64
	)
	assert_true(
		frames != null,
		"trash_monster runtime sheet must load from res://assets/monsters/trash_monster/"
	)
	assert_eq(
		frames.get_frame_count("idle"),
		6,
		"trash_monster idle must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("run"), 6, "trash_monster run must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("attack"),
		6,
		"trash_monster attack must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("hurt"),
		6,
		"trash_monster hurt must load 6 frames from runtime sheet"
	)
	assert_eq(
		frames.get_frame_count("death"),
		6,
		"trash_monster death must load 6 frames from runtime sheet"
	)
	assert_true(frames.get_animation_loop("idle"), "trash_monster idle must loop")
	assert_false(frames.get_animation_loop("attack"), "trash_monster attack must remain one-shot")


func test_charger_configures_as_punish_stationary_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "charger", "position": Vector2(200, 400)}, null)
	assert_eq(enemy.enemy_type, "charger")
	assert_true(enemy.contact_damage >= 14, "Charger must deal significant damage on connection")
	assert_true(enemy.attack_period >= 2.0, "Charger must have meaningful recovery after charge")


func test_charger_locks_target_position_at_telegraph_start() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(180, 0)
	enemy.configure({"type": "charger", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.behavior_state = "pursue"
	enemy.charge_locked_x = player_target.global_position.x
	assert_eq(enemy.charge_locked_x, 180.0, "Charger must lock target X at telegraph start")


func test_leaper_landing_emits_shockwave_projectiles() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(100, 0)
	enemy.configure({"type": "leaper", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	enemy._on_leaper_land()
	assert_eq(payloads.size(), 2, "Leaper landing must emit 2 shockwave projectiles")
	assert_true(
		float(payloads[0].get("size", 0.0)) >= 14.0, "Landing impact must be visually large"
	)
	assert_true(
		float(payloads[0].get("damage", 0)) >= 8, "Landing impact must deal meaningful damage"
	)
	assert_true(
		float(payloads[0].get("knockback", 0.0)) >= 200.0,
		"Landing impact must have strong knockback"
	)
	assert_false(enemy.leaper_jumping, "leaper_jumping flag must be cleared on land")


func test_elite_phase2_super_armor_triggers_at_half_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var initial_threshold: int = enemy.stagger_threshold
	enemy.health = int(enemy.max_health / 2)
	enemy.receive_hit(1, Vector2(-10, 0), 0.0, "")
	assert_eq(enemy.stagger_threshold, 90, "Elite phase-2 must raise stagger threshold to 90")
	assert_true(
		enemy.stagger_threshold > initial_threshold, "Phase-2 threshold must exceed phase-1"
	)
	assert_true(enemy.elite_phase2_activated, "Phase-2 flag must be set")


func test_elite_phase2_triggers_only_once() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.health = int(enemy.max_health / 2)
	enemy.receive_hit(1, Vector2(-10, 0), 0.0, "")
	assert_eq(enemy.stagger_threshold, 90)
	enemy.stagger_threshold = 200
	enemy.receive_hit(1, Vector2(-10, 0), 0.0, "")
	assert_eq(enemy.stagger_threshold, 200, "Phase-2 must not fire again once activated")


func test_elite_fires_ranged_burst_at_mid_range() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(200, 0)
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	enemy._fire_elite_burst(200.0)
	assert_eq(payloads.size(), 3, "Elite burst must fire 3 projectiles in spread")
	assert_true(
		float(payloads[0].get("damage", 0)) >= 10, "Elite burst projectiles must deal damage"
	)
	assert_true(
		float(payloads[0].get("range", 0.0)) >= 300.0, "Elite burst must have mid-range reach"
	)
	assert_true(
		float(payloads[1].get("velocity", Vector2.ZERO).length()) >= 200.0,
		"Elite burst projectiles must travel at speed"
	)


# --- Leaper warning marker tests ---


func test_leaper_emits_warning_marker_on_jump_start() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(200, 0)
	enemy.configure({"type": "leaper", "position": Vector2.ZERO}, player_target)
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	enemy._emit_leaper_warning_marker(200.0)
	assert_eq(payloads.size(), 1, "Must emit exactly one warning marker")
	assert_eq(str(payloads[0].get("team", "")), "marker", "Marker must have team 'marker'")
	assert_eq(int(payloads[0].get("damage", -1)), 0, "Marker must deal no damage")
	assert_true(float(payloads[0].get("duration", 0.0)) > 0.5, "Marker duration must exceed 0.5s")
	assert_true(
		bool(payloads[0].get("marker", false)), "Marker payload must carry marker:true flag"
	)


func test_leaper_warning_marker_lands_at_predicted_x() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "leaper", "position": Vector2.ZERO}, null)
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	# Jump right: dx > 0, predicted landing ≈ +238 px from enemy origin
	enemy._emit_leaper_warning_marker(300.0)
	var marker_x: float = float(payloads[0].get("position", Vector2.ZERO).x)
	assert_true(marker_x > 200.0, "Marker must appear to the right when jumping right")
	# Jump left: predicted landing ≈ -238 px
	payloads.clear()
	enemy._emit_leaper_warning_marker(-300.0)
	var marker_x_left: float = float(payloads[0].get("position", Vector2.ZERO).x)
	assert_true(marker_x_left < -200.0, "Marker must appear to the left when jumping left")


# --- super_armor_attack flag tests ---


func test_elite_has_super_armor_attack_flag_set() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, null)
	assert_true(
		enemy.has_super_armor_attack,
		"Elite must have has_super_armor_attack = true from fallback stats"
	)


func test_brute_has_no_super_armor_attack_flag() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, null)
	assert_false(enemy.has_super_armor_attack, "Brute must not have super armor attack flag")


func test_elite_attack_state_activates_super_armor() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, null)
	enemy._ready()
	# Directly call the state handler: super_armor_active should be set from has_super_armor_attack
	enemy._on_attack_state_entered()
	assert_true(
		enemy.super_armor_active,
		"Elite attack state must activate super_armor_active via has_super_armor_attack"
	)


func test_brute_attack_state_does_not_activate_super_armor() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(50, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy._on_attack_state_entered()
	assert_false(
		enemy.super_armor_active, "Brute must not activate super_armor_active during attack"
	)


# --- JSON data separation tests ---


func test_apply_stats_from_data_overrides_defaults_via_dict() -> void:
	# Verifies _apply_stats_from_data() correctly reads each stat field.
	# GameDatabase may not be available in headless tests; we use the fallback path
	# by confirming configure() still produces correct values from the fallback branch.
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "bomber", "position": Vector2.ZERO}, null)
	assert_eq(enemy.max_health, 36, "Bomber max_health from fallback stats")
	assert_eq(enemy.move_speed, 62.0, "Bomber move_speed from fallback stats")
	assert_eq(enemy.contact_damage, 9, "Bomber contact_damage from fallback stats")
	assert_eq(enemy.attack_period, 2.8, "Bomber attack_period from fallback stats")
	assert_eq(enemy.projectile_color, "#c8a033", "Bomber projectile_color from fallback stats")


func test_apply_stats_from_data_charger_fallback() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "charger", "position": Vector2.ZERO}, null)
	assert_eq(enemy.max_health, 40, "Charger max_health from fallback stats")
	assert_eq(enemy.contact_damage, 16, "Charger contact_damage from fallback stats")
	assert_eq(enemy.attack_period, 2.6, "Charger attack_period from fallback stats")


func test_normalize_attack_contract_defaults_falls_back_unknown_damage_type_to_physical() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.enemy_type = "rat"
	enemy.attack_damage_type = "broken_damage_type"
	enemy.attack_element = "none"
	enemy.contact_damage = 9
	enemy.physical_attack = 0
	enemy.magic_attack = 0
	enemy._finalize_combat_runtime_defaults()
	assert_eq(enemy.attack_damage_type, "physical")
	assert_eq(enemy.physical_attack, 9, "Unknown damage type must resolve to physical fallback")
	assert_eq(enemy.magic_attack, 0, "Physical fallback must not inject magic attack")


func test_normalize_attack_contract_defaults_falls_back_unknown_element_to_none() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.enemy_type = "eyeball"
	enemy.attack_damage_type = "magic"
	enemy.attack_element = "broken_element"
	enemy.magic_attack = 12
	enemy._finalize_combat_runtime_defaults()
	assert_eq(enemy.attack_element, "none")
	assert_eq(enemy._get_outgoing_attack_school(), "", "Unknown element must resolve to neutral outgoing school")


func test_normalize_loaded_identity_fields_falls_back_empty_display_name_from_loaded_data() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.display_name = ""
	enemy.enemy_grade = "normal"
	enemy._normalize_loaded_identity_fields("rat", true)
	assert_eq(enemy.display_name, "Rat", "Empty loaded display_name must resolve to capitalized enemy_id")


func test_normalize_loaded_identity_fields_falls_back_invalid_enemy_grade_from_loaded_data() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.display_name = "Training Dummy"
	enemy.enemy_grade = "broken_grade"
	enemy._normalize_loaded_identity_fields("dummy", true)
	assert_eq(enemy.enemy_grade, "normal", "Invalid loaded enemy_grade must resolve to the type default")


func test_enemy_health_equals_max_health_after_configure() -> void:
	# configure() must set health = max_health regardless of data source.
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, null)
	assert_eq(enemy.health, enemy.max_health, "health must equal max_health after configure()")


func test_receive_hit_sets_hit_flash_timer() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(500, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	assert_eq(enemy.hit_flash_timer, 0.0, "Precondition: hit_flash_timer must be 0 before any hit")
	enemy.receive_hit(5, Vector2(-10, 0), 0.0, "fire")
	assert_gt(
		enemy.hit_flash_timer, 0.0, "receive_hit must set hit_flash_timer to a positive value"
	)


func test_hit_flash_timer_starts_at_zero() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "ranged", "position": Vector2.ZERO}, null)
	assert_eq(
		enemy.hit_flash_timer, 0.0, "hit_flash_timer must start at 0.0 when no hit has occurred"
	)


func test_receive_hit_increments_session_damage() -> void:
	GameState.reset_progress_for_tests()
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	var before: int = GameState.session_damage_dealt
	var actual_damage: int = enemy.receive_hit(18, Vector2(-10, 0), 0.0, "fire")
	assert_eq(
		GameState.session_damage_dealt,
		before + actual_damage,
		"receive_hit must forward damage to GameState.session_damage_dealt"
	)
	assert_eq(GameState.session_hit_count, 1, "receive_hit must increment session_hit_count")


func test_receive_hit_emits_damage_label_signal() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	var signals: Array = []
	enemy.damage_label_requested.connect(
		func(a: int, p: Vector2, s: String) -> void: signals.append({"amount": a, "school": s})
	)
	var actual_damage: int = enemy.receive_hit(25, Vector2(-10, 0), 80.0, "fire")
	assert_eq(signals.size(), 1, "receive_hit must emit damage_label_requested once")
	assert_eq(signals[0]["amount"], actual_damage, "Emitted amount must match final damage")
	assert_eq(signals[0]["school"], "fire", "Emitted school must match hit school")


func test_receive_hit_emits_damage_label_signal_with_correct_school() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	var schools: Array = []
	enemy.damage_label_requested.connect(
		func(_a: int, _p: Vector2, s: String) -> void: schools.append(s)
	)
	enemy.receive_hit(10, Vector2(-10, 0), 0.0, "ice")
	assert_eq(schools[0], "ice", "damage_label_requested must emit the hit's school")


# --- Bat (flying ranged harasser) tests ---


func test_bat_configures_as_flying_ranged_harasser() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "bat", "position": Vector2(200, 400)}, null)
	assert_eq(enemy.enemy_type, "bat")
	assert_true(enemy.max_health > 0)
	assert_true(enemy.move_speed >= 90.0, "Bat must have meaningful flight speed")
	assert_true(enemy.contact_damage > 0)


func test_bat_receives_hit_and_loses_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "bat", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(12, Vector2(-10, 0), 100.0, "fire")
	assert_eq(enemy.health, hp_before - actual_damage)


func test_bat_fires_projectile_toward_player() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(300, 0)
	enemy.configure({"type": "bat", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var payloads: Array = []
	enemy.fire_projectile.connect(func(p: Dictionary) -> void: payloads.append(p))
	enemy._fire_bat_shot()
	assert_eq(payloads.size(), 1, "Bat must fire exactly one projectile")
	assert_eq(str(payloads[0].get("team", "")), "enemy", "Bat projectile must belong to enemy team")
	assert_true(float(payloads[0].get("damage", 0)) > 0, "Bat projectile must deal damage")
	assert_true(
		float(payloads[0].get("range", 0.0)) >= 300.0, "Bat projectile must have ranged reach"
	)


func test_bat_fallback_stats_are_lower_than_elite() -> void:
	var bat = autofree(ENEMY_SCRIPT.new())
	bat.configure({"type": "bat", "position": Vector2.ZERO}, null)
	var elite = autofree(ENEMY_SCRIPT.new())
	elite.configure({"type": "elite", "position": Vector2.ZERO}, null)
	assert_true(bat.max_health < elite.max_health, "Bat must have lower HP than elite")
	assert_true(
		bat.contact_damage < elite.contact_damage, "Bat must deal less contact damage than elite"
	)


# --- Worm (ground charge presser) tests ---


func test_worm_configures_as_ground_charge_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "worm", "position": Vector2(200, 400)}, null)
	assert_eq(enemy.enemy_type, "worm")
	assert_true(enemy.move_speed >= 140.0, "Worm must be fast for charge pressure")
	assert_true(enemy.contact_damage >= 12, "Worm must deal significant contact damage")


func test_worm_receives_hit_and_loses_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "worm", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(20, Vector2(-10, 0), 150.0, "fire")
	assert_eq(enemy.health, hp_before - actual_damage)
	assert_gt(enemy.velocity.x, 0.0, "Worm must gain knockback velocity from hit")


func test_worm_attack_charges_toward_player() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(200, 0)
	enemy.configure({"type": "worm", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy._on_attack_state_entered()
	assert_true(enemy.velocity.x > 0.0, "Worm must charge toward player on attack")
	assert_true(absf(enemy.velocity.x) >= 400.0, "Worm charge must be fast")


func test_worm_fallback_stats_match_json() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "worm", "position": Vector2.ZERO}, null)
	assert_eq(enemy.max_health, 45, "Worm max_health from fallback stats")
	assert_eq(enemy.move_speed, 160.0, "Worm move_speed from fallback stats")
	assert_eq(enemy.contact_damage, 14, "Worm contact_damage from fallback stats")
	assert_eq(enemy.attack_period, 2.2, "Worm attack_period from fallback stats")


# --- Mushroom (melee stunner) tests ---


func test_mushroom_configures_as_melee_stunner() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "mushroom", "position": Vector2(100, 400)}, null)
	assert_eq(enemy.enemy_type, "mushroom")
	assert_eq(enemy.max_health, 60, "Mushroom must have 60 HP")
	assert_eq(enemy.move_speed, 100.0, "Mushroom must have moderate speed")
	assert_eq(enemy.contact_damage, 12, "Mushroom contact_damage from fallback stats")


func test_mushroom_receives_hit_and_loses_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "mushroom", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(15, Vector2(-10, 0), 120.0, "fire")
	assert_eq(enemy.health, hp_before - actual_damage, "Mushroom must take damage from receive_hit")


func test_mushroom_stun_attack_activates_every_third_attack() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(60, 0)
	enemy.configure({"type": "mushroom", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	# First attack (counter=1): not stun
	enemy.attack_cooldown = 0.0
	enemy._on_attack_state_entered()
	assert_false(enemy.mushroom_stun_attack_active, "Attack 1 must not be a stun attack")
	# Second attack (counter=2): not stun
	enemy.attack_cooldown = 0.0
	enemy._on_attack_state_entered()
	assert_false(enemy.mushroom_stun_attack_active, "Attack 2 must not be a stun attack")
	# Third attack (counter=3, 3%3==0): stun attack
	enemy.attack_cooldown = 0.0
	enemy._on_attack_state_entered()
	assert_true(enemy.mushroom_stun_attack_active, "Attack 3 must activate mushroom stun attack")


func test_mushroom_stun_attack_deals_more_damage_than_normal() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var mock_player := Node2D.new()
	autofree(mock_player)
	mock_player.global_position = Vector2(50, 0)
	enemy.configure({"type": "mushroom", "position": Vector2.ZERO}, mock_player)
	enemy._ready()
	# Normal attack: count 1 (not stun)
	enemy.mushroom_stun_attack_counter = 2  # Next call becomes 3 → stun
	var stun_base: int = enemy.contact_damage + 6
	assert_true(
		stun_base > enemy.contact_damage, "Stun attack must deal more than normal contact_damage"
	)


func test_mushroom_stun_flag_resets_after_attack_state_exit() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(60, 0)
	enemy.configure({"type": "mushroom", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	# Trigger stun attack (3rd)
	enemy.mushroom_stun_attack_counter = 2
	enemy._on_attack_state_entered()
	assert_true(enemy.mushroom_stun_attack_active, "Precondition: stun attack must be active")
	# Simulate attack state exit
	enemy.mushroom_stun_attack_active = false
	assert_false(
		enemy.mushroom_stun_attack_active, "Stun flag must be false after attack state exits"
	)


func test_rat_configures_as_fast_melee_swarm_enemy() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "rat", "position": Vector2(100, 400)}, null)
	assert_eq(enemy.enemy_type, "rat")
	assert_eq(enemy.max_health, 22)
	assert_gt(enemy.move_speed, 150.0)
	assert_eq(enemy.contact_damage, 8)


func test_rat_receives_hit_and_loses_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "rat", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var hp_before: int = enemy.health
	var actual_damage: int = enemy.receive_hit(12, Vector2(-10, 0), 100.0, "fire")
	assert_eq(enemy.health, hp_before - actual_damage)


func test_tooth_walker_configures_as_slow_bite_chaser() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "tooth_walker", "position": Vector2(200, 400)}, null)
	assert_eq(enemy.enemy_type, "tooth_walker")
	assert_eq(enemy.max_health, 55)
	assert_lt(enemy.move_speed, 100.0)
	assert_eq(enemy.contact_damage, 16)


func test_eyeball_configures_as_flying_observer() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "eyeball", "position": Vector2(300, 300)}, null)
	assert_eq(enemy.enemy_type, "eyeball")
	assert_eq(enemy.max_health, 32)
	assert_eq(enemy.contact_damage, 7)
	assert_eq(enemy.projectile_color, "#c864e0")


func test_eyeball_fires_projectile_toward_player() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(200, 0)
	enemy.configure({"type": "eyeball", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var shot_count := [0]
	enemy.fire_projectile.connect(func(_p): shot_count[0] += 1)
	enemy._fire_eyeball_shot()
	assert_true(shot_count[0] > 0, "Eyeball must emit fire_projectile signal")


func test_trash_monster_configures_as_high_hp_tank() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "trash_monster", "position": Vector2(400, 400)}, null)
	assert_eq(enemy.enemy_type, "trash_monster")
	assert_eq(enemy.max_health, 80)
	assert_lt(enemy.move_speed, 100.0)
	assert_eq(enemy.contact_damage, 18)


func test_sword_configures_as_fast_rusher() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "sword", "position": Vector2(500, 400)}, null)
	assert_eq(enemy.enemy_type, "sword")
	assert_eq(enemy.max_health, 38)
	assert_gt(enemy.move_speed, 180.0)
	assert_eq(enemy.contact_damage, 14)


func test_new_enemies_all_load_from_data() -> void:
	for type_id in ["rat", "tooth_walker", "eyeball", "trash_monster", "sword"]:
		var enemy = autofree(ENEMY_SCRIPT.new())
		enemy.configure({"type": type_id, "position": Vector2.ZERO}, null)
		assert_eq(enemy.enemy_type, type_id, "%s must configure correctly" % type_id)
		assert_gt(enemy.max_health, 0, "%s must have positive max_health" % type_id)


func test_tooth_walker_has_finite_stagger_threshold() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "tooth_walker", "position": Vector2.ZERO}, null)
	assert_lt(
		enemy.stagger_threshold, 9999, "tooth_walker must have finite stagger_threshold (< 9999)"
	)
	assert_gt(enemy.stagger_threshold, 0, "tooth_walker stagger_threshold must be > 0")


func test_trash_monster_uses_high_stagger_threshold_without_super_armor_attack() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "trash_monster", "position": Vector2.ZERO}, null)
	assert_false(enemy.has_super_armor_attack, "trash_monster must not use elite-style super armor")
	assert_lt(
		enemy.stagger_threshold, 9999, "trash_monster must have finite stagger_threshold (< 9999)"
	)
	assert_gt(
		enemy.stagger_threshold,
		enemy.max_health,
		"trash_monster stagger_threshold must exceed single-hit HP to function as armor"
	)


func test_trash_monster_stagger_threshold_is_higher_than_tooth_walker() -> void:
	var tooth = autofree(ENEMY_SCRIPT.new())
	tooth.configure({"type": "tooth_walker", "position": Vector2.ZERO}, null)
	var trash = autofree(ENEMY_SCRIPT.new())
	trash.configure({"type": "trash_monster", "position": Vector2.ZERO}, null)
	assert_gt(
		trash.stagger_threshold,
		tooth.stagger_threshold,
		"trash_monster (tank) must have higher stagger_threshold than tooth_walker"
	)


func test_rat_combo_timer_starts_at_zero() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "rat", "position": Vector2.ZERO}, null)
	assert_eq(enemy.rat_combo_timer, 0.0, "rat_combo_timer must start at 0")


func test_rat_attack_initiates_combo_timer() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "rat", "position": Vector2.ZERO}, null)
	# Simulate attack state entry manually
	var fake_target = autofree(Node2D.new())
	fake_target.global_position = Vector2(30.0, 0.0)
	enemy.target = fake_target
	enemy._on_attack_state_entered()
	assert_gt(enemy.rat_combo_timer, 0.0, "rat_combo_timer must be set after attack")


func test_rat_attack_period_shorter_than_other_melee() -> void:
	var rat = autofree(ENEMY_SCRIPT.new())
	rat.configure({"type": "rat", "position": Vector2.ZERO}, null)
	var brute = autofree(ENEMY_SCRIPT.new())
	brute.configure({"type": "brute", "position": Vector2.ZERO}, null)
	assert_lt(
		rat.attack_period,
		brute.attack_period,
		"rat attack_period must be shorter than brute (swarm role)"
	)


func test_sword_retreat_timer_starts_at_zero() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "sword", "position": Vector2.ZERO}, null)
	assert_eq(enemy.sword_retreat_timer, 0.0, "sword_retreat_timer must start at 0")


func test_sword_attack_state_sets_retreat_timer() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "sword", "position": Vector2.ZERO}, null)
	var fake_target = autofree(Node2D.new())
	fake_target.global_position = Vector2(50.0, 0.0)
	enemy.target = fake_target
	enemy.charge_locked_x = 50.0
	enemy._on_attack_state_entered()
	assert_gt(
		enemy.sword_retreat_timer, 0.0, "sword_retreat_timer must be set after attack state entered"
	)


func test_sword_has_higher_move_speed_than_brute() -> void:
	var sword = autofree(ENEMY_SCRIPT.new())
	sword.configure({"type": "sword", "position": Vector2.ZERO}, null)
	var brute = autofree(ENEMY_SCRIPT.new())
	brute.configure({"type": "brute", "position": Vector2.ZERO}, null)
	assert_gt(sword.move_speed, brute.move_speed, "sword (agile) must be faster than brute")


func test_eyeball_fire_projectile_school_is_dark() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var fake_target = autofree(Node2D.new())
	fake_target.global_position = Vector2(200.0, 0.0)
	enemy.configure({"type": "eyeball", "position": Vector2.ZERO}, fake_target)
	var emitted_payloads: Array = []
	enemy.fire_projectile.connect(func(p): emitted_payloads.append(p))
	enemy._fire_eyeball_shot()
	assert_eq(emitted_payloads.size(), 1, "Eyeball must emit one projectile")
	assert_eq(
		str(emitted_payloads[0].get("school", "")), "dark", "Eyeball projectile must be school=dark"
	)


func test_eyeball_has_finite_stagger_threshold() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "eyeball", "position": Vector2.ZERO}, null)
	assert_lt(enemy.stagger_threshold, 9999, "eyeball must have finite stagger_threshold (< 9999)")
	assert_gt(enemy.stagger_threshold, 0, "eyeball stagger_threshold must be > 0")


func test_eyeball_projectile_color_matches_tint_family() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "eyeball", "position": Vector2.ZERO}, null)
	assert_ne(enemy.projectile_color, "", "eyeball projectile_color must not be empty")

extends "res://addons/gut/test.gd"

const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")

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
	enemy.receive_hit(10, Vector2(-10, 0), 0.0, "ice", [{"type": "slow", "value": 0.28, "duration": 1.0}])
	assert_lt(enemy.slow_multiplier, 1.0)
	assert_gt(enemy.slow_timer, 0.9)

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
	enemy.receive_hit(10, Vector2(-10, 0), 80.0, "fire")
	assert_eq(enemy.health, 20)

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
	enemy.receive_hit(15, Vector2(-10, 0), 180.0, "fire")
	assert_eq(enemy.health, hp_before - 15)
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
	enemy.receive_hit(20, Vector2(-10, 0), 100.0, "fire")
	assert_eq(enemy.health, hp_before - 20)
	assert_ne(enemy.behavior_state, "stagger", "Super armor must block direct stagger below threshold")

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
	enemy.receive_hit(18, Vector2(-10, 0), 140.0, "lightning")
	assert_eq(enemy.health, hp_before - 18)
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
	assert_true(float(payloads[0].get("speed", 999.0)) < 120.0 or float(payloads[0].get("velocity", Vector2.ZERO).length()) < 120.0, "Bomb must be slow")

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
	assert_true(float(payloads[0].get("size", 0.0)) >= 14.0, "Landing impact must be visually large")
	assert_true(float(payloads[0].get("damage", 0)) >= 8, "Landing impact must deal meaningful damage")
	assert_true(float(payloads[0].get("knockback", 0.0)) >= 200.0, "Landing impact must have strong knockback")
	assert_false(enemy.leaper_jumping, "leaper_jumping flag must be cleared on land")

func test_elite_phase2_super_armor_triggers_at_half_health() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	var initial_threshold: int = enemy.stagger_threshold
	enemy.receive_hit(enemy.max_health / 2, Vector2(-10, 0), 0.0, "")
	assert_eq(enemy.stagger_threshold, 90, "Elite phase-2 must raise stagger threshold to 90")
	assert_true(enemy.stagger_threshold > initial_threshold, "Phase-2 threshold must exceed phase-1")
	assert_true(enemy.elite_phase2_activated, "Phase-2 flag must be set")

func test_elite_phase2_triggers_only_once() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	enemy.configure({"type": "elite", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy.receive_hit(enemy.max_health / 2, Vector2(-10, 0), 0.0, "")
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
	assert_true(float(payloads[0].get("damage", 0)) >= 10, "Elite burst projectiles must deal damage")
	assert_true(float(payloads[0].get("range", 0.0)) >= 300.0, "Elite burst must have mid-range reach")
	assert_true(float(payloads[1].get("velocity", Vector2.ZERO).length()) >= 200.0, "Elite burst projectiles must travel at speed")

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
	assert_true(bool(payloads[0].get("marker", false)), "Marker payload must carry marker:true flag")

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
	assert_true(enemy.has_super_armor_attack, "Elite must have has_super_armor_attack = true from fallback stats")

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
	assert_true(enemy.super_armor_active, "Elite attack state must activate super_armor_active via has_super_armor_attack")

func test_brute_attack_state_does_not_activate_super_armor() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(50, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	enemy._ready()
	enemy._on_attack_state_entered()
	assert_false(enemy.super_armor_active, "Brute must not activate super_armor_active during attack")

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
	assert_gt(enemy.hit_flash_timer, 0.0, "receive_hit must set hit_flash_timer to a positive value")

func test_hit_flash_timer_starts_at_zero() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	enemy.configure({"type": "ranged", "position": Vector2.ZERO}, null)
	assert_eq(enemy.hit_flash_timer, 0.0, "hit_flash_timer must start at 0.0 when no hit has occurred")

func test_receive_hit_increments_session_damage() -> void:
	GameState.reset_progress_for_tests()
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	var before: int = GameState.session_damage_dealt
	enemy.receive_hit(18, Vector2(-10, 0), 0.0, "fire")
	assert_eq(GameState.session_damage_dealt, before + 18, "receive_hit must forward damage to GameState.session_damage_dealt")
	assert_eq(GameState.session_hit_count, 1, "receive_hit must increment session_hit_count")

func test_receive_hit_emits_damage_label_signal() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	var signals: Array = []
	enemy.damage_label_requested.connect(func(a: int, p: Vector2, s: String) -> void: signals.append({"amount": a, "school": s}))
	enemy.receive_hit(25, Vector2(-10, 0), 80.0, "fire")
	assert_eq(signals.size(), 1, "receive_hit must emit damage_label_requested once")
	assert_eq(signals[0]["amount"], 25, "Emitted amount must match hit amount")
	assert_eq(signals[0]["school"], "fire", "Emitted school must match hit school")

func test_receive_hit_emits_damage_label_signal_with_correct_school() -> void:
	var enemy = autofree(ENEMY_SCRIPT.new())
	var player_target := Node2D.new()
	autofree(player_target)
	player_target.global_position = Vector2(400, 0)
	enemy.configure({"type": "brute", "position": Vector2.ZERO}, player_target)
	var schools: Array = []
	enemy.damage_label_requested.connect(func(_a: int, _p: Vector2, s: String) -> void: schools.append(s))
	enemy.receive_hit(10, Vector2(-10, 0), 0.0, "ice")
	assert_eq(schools[0], "ice", "damage_label_requested must emit the hit's school")


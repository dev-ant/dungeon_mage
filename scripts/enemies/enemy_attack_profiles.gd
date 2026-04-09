extends RefCounted


static func _start_owned_delay(owner: Node, delay: float, callback: Callable) -> void:
	if owner == null or delay <= 0.0:
		if callback.is_valid():
			callback.call()
		return
	var adjusted_delay := delay
	if owner.has_method("get_behavior_delay_multiplier"):
		adjusted_delay *= float(owner.call("get_behavior_delay_multiplier"))
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = adjusted_delay
	owner.add_child(timer)
	timer.timeout.connect(
		func() -> void:
			if callback.is_valid():
				callback.call()
			if is_instance_valid(timer):
				timer.queue_free(),
		CONNECT_ONE_SHOT
	)
	timer.start()


static func apply_fallback_stats(enemy: CharacterBody2D, type_id: String) -> void:
	match type_id:
		"brute":
			enemy.max_health = 52
			enemy.move_speed = 120.0
			enemy.contact_damage = 13
			enemy.tint = Color("#c25a62")
		"ranged":
			enemy.max_health = 34
			enemy.move_speed = 80.0
			enemy.contact_damage = 8
			enemy.attack_period = 1.6
			enemy.tint = Color("#7d92d8")
		"boss":
			enemy.max_health = 120
			enemy.move_speed = 150.0
			enemy.contact_damage = 16
			enemy.attack_period = 1.0
			enemy.tint = Color("#e0b06d")
		"dummy":
			enemy.max_health = 9999
			enemy.move_speed = 0.0
			enemy.contact_damage = 0
			enemy.attack_period = 99.0
			enemy.tint = Color("#9ca3af")
		"dasher":
			enemy.max_health = 30
			enemy.move_speed = 200.0
			enemy.contact_damage = 12
			enemy.attack_period = 2.2
			enemy.tint = Color("#e8792f")
		"sentinel":
			enemy.max_health = 32
			enemy.move_speed = 70.0
			enemy.contact_damage = 7
			enemy.attack_period = 2.5
			enemy.tint = Color("#5eb868")
		"elite":
			enemy.max_health = 180
			enemy.move_speed = 95.0
			enemy.contact_damage = 18
			enemy.attack_period = 2.0
			enemy.stagger_threshold = 55
			enemy.tint = Color("#b06dc8")
			enemy.has_super_armor_attack = true
		"leaper":
			enemy.max_health = 44
			enemy.move_speed = 160.0
			enemy.contact_damage = 15
			enemy.attack_period = 2.4
			enemy.tint = Color("#e8c440")
		"bomber":
			enemy.max_health = 36
			enemy.move_speed = 62.0
			enemy.contact_damage = 9
			enemy.attack_period = 2.8
			enemy.tint = Color("#c8a033")
			enemy.projectile_color = "#c8a033"
		"charger":
			enemy.max_health = 40
			enemy.move_speed = 130.0
			enemy.contact_damage = 16
			enemy.attack_period = 2.6
			enemy.tint = Color("#e03a3a")
		"bat":
			enemy.max_health = 28
			enemy.move_speed = 110.0
			enemy.contact_damage = 9
			enemy.attack_period = 1.8
			enemy.tint = Color("#9b6fcf")
		"worm":
			enemy.max_health = 45
			enemy.move_speed = 160.0
			enemy.contact_damage = 14
			enemy.attack_period = 2.2
			enemy.tint = Color("#8a5c2e")
		"mushroom":
			enemy.max_health = 60
			enemy.move_speed = 100.0
			enemy.contact_damage = 12
			enemy.attack_period = 1.8
			enemy.tint = Color("#7dab65")
		"rat":
			enemy.max_health = 22
			enemy.move_speed = 170.0
			enemy.contact_damage = 8
			enemy.attack_period = 1.2
			enemy.tint = Color("#b5935a")
		"tooth_walker":
			enemy.max_health = 55
			enemy.move_speed = 85.0
			enemy.contact_damage = 16
			enemy.attack_period = 1.6
			enemy.tint = Color("#c0a87a")
			enemy.stagger_threshold = 60
		"eyeball":
			enemy.max_health = 32
			enemy.move_speed = 90.0
			enemy.contact_damage = 7
			enemy.attack_period = 2.0
			enemy.tint = Color("#b06dc8")
			enemy.projectile_color = "#c864e0"
			enemy.stagger_threshold = 40
		"trash_monster":
			enemy.max_health = 80
			enemy.move_speed = 70.0
			enemy.contact_damage = 18
			enemy.attack_period = 2.0
			enemy.tint = Color("#7a9a5a")
			enemy.stagger_threshold = 120
			enemy.has_super_armor_attack = true
		"sword":
			enemy.max_health = 38
			enemy.move_speed = 190.0
			enemy.contact_damage = 14
			enemy.attack_period = 1.8
			enemy.tint = Color("#88a0c8")


static func build_state_chart(
	enemy: CharacterBody2D,
	state_chart_script,
	compound_state_script,
	atomic_state_script,
	transition_script
) -> void:
	enemy.state_chart = state_chart_script.new()
	enemy.state_chart.name = "AIStateChart"
	enemy.root_state = compound_state_script.new()
	enemy.root_state.name = "Root"
	enemy.state_chart.add_child(enemy.root_state)
	enemy.idle_state = _add_atomic_state(enemy.root_state, atomic_state_script, "Idle")
	enemy.pursue_state = _add_atomic_state(enemy.root_state, atomic_state_script, "Pursue")
	enemy.kite_state = _add_atomic_state(enemy.root_state, atomic_state_script, "Kite")
	enemy.attack_state = _add_atomic_state(enemy.root_state, atomic_state_script, "Attack")
	enemy.stagger_state = _add_atomic_state(enemy.root_state, atomic_state_script, "Stagger")
	enemy.idle_state.state_entered.connect(func() -> void: enemy.behavior_state = "idle")
	enemy.pursue_state.state_entered.connect(func() -> void: enemy.behavior_state = "pursue")
	enemy.kite_state.state_entered.connect(func() -> void: enemy.behavior_state = "kite")
	enemy.attack_state.state_entered.connect(enemy._on_attack_state_entered)
	enemy.attack_state.state_exited.connect(func() -> void: enemy._on_attack_state_exited())
	enemy.stagger_state.state_entered.connect(func() -> void: enemy.behavior_state = "stagger")
	_add_transition(enemy.idle_state, enemy.pursue_state, transition_script, "player_seen")
	_add_transition(enemy.idle_state, enemy.stagger_state, transition_script, "stagger")
	_add_transition(enemy.pursue_state, enemy.attack_state, transition_script, "attack_window")
	_add_transition(enemy.pursue_state, enemy.kite_state, transition_script, "keep_distance")
	_add_transition(enemy.pursue_state, enemy.stagger_state, transition_script, "stagger")
	_add_transition(enemy.kite_state, enemy.attack_state, transition_script, "attack_window")
	_add_transition(enemy.kite_state, enemy.pursue_state, transition_script, "chase_window")
	_add_transition(enemy.kite_state, enemy.stagger_state, transition_script, "stagger")
	_add_transition(
		enemy.attack_state,
		enemy.kite_state if _returns_to_kite(enemy.enemy_type) else enemy.pursue_state,
		transition_script,
		"",
		"0.28"
	)
	_add_transition(enemy.attack_state, enemy.stagger_state, transition_script, "stagger")
	_add_transition(enemy.stagger_state, enemy.pursue_state, transition_script, "", "0.18")
	enemy.add_child(enemy.state_chart)


static func run_ai(enemy: CharacterBody2D) -> void:
	if not enemy.state_chart or not enemy.root_state:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0.0, 32.0)
		return
	var dx: float = enemy.target.global_position.x - enemy.global_position.x
	var distance := absf(dx)
	if distance < 460.0:
		enemy.state_chart.send_event("player_seen")
	match enemy.behavior_state:
		"idle":
			enemy.velocity.x = move_toward(enemy.velocity.x, 0.0, 36.0)
		"pursue":
			_run_pursue_ai(enemy, distance, dx)
		"kite":
			_run_kite_ai(enemy, distance)
		"attack":
			enemy.velocity.x = move_toward(enemy.velocity.x, 0.0, 50.0)
		"stagger":
			enemy.velocity.x = move_toward(enemy.velocity.x, 0.0, 28.0)


static func perform_attack(enemy: CharacterBody2D) -> void:
	enemy.behavior_state = "attack"
	if enemy.has_super_armor_attack:
		enemy.super_armor_active = true
	if enemy.attack_cooldown > 0.0 or not is_instance_valid(enemy.target):
		return
	var dx: float = enemy.target.global_position.x - enemy.global_position.x
	match enemy.enemy_type:
		"brute":
			enemy.attack_cooldown = enemy.attack_period
			if absf(dx) < 84.0:
				_try_damage_target(
					enemy.target, enemy.contact_damage + 4, enemy.global_position, 240.0, ""
				)
		"ranged":
			enemy._fire_orb(dx)
		"boss":
			enemy._fire_boss_volley()
		"dasher":
			enemy.attack_cooldown = enemy.attack_period
			enemy.velocity.x = (
				sign(enemy.target.global_position.x - enemy.global_position.x) * 520.0
			)
			enemy.velocity.y = -90.0
		"sentinel":
			enemy._fire_sentinel_shots()
		"elite":
			enemy.attack_cooldown = enemy.attack_period
			if absf(dx) < 120.0:
				_try_damage_target(
					enemy.target, enemy.contact_damage + 6, enemy.global_position, 280.0, ""
				)
			else:
				enemy._fire_elite_burst(dx)
		"leaper":
			enemy.attack_cooldown = enemy.attack_period
			enemy._emit_leaper_warning_marker(dx)
			enemy.velocity.x = sign(dx) * 340.0
			enemy.velocity.y = -480.0
			_start_owned_delay(
				enemy,
				0.7,
				func() -> void:
					if is_instance_valid(enemy):
						enemy._on_leaper_land()
			)
		"bomber":
			enemy._emit_bomber_warning_marker()
			enemy._fire_bomb()
		"charger":
			enemy.attack_cooldown = enemy.attack_period
			enemy.velocity.x = sign(enemy.charge_locked_x - enemy.global_position.x) * 620.0
			enemy.velocity.y = -55.0
		"bat":
			enemy._fire_bat_shot()
		"worm":
			enemy.attack_cooldown = enemy.attack_period
			enemy.velocity.x = (
				sign(enemy.target.global_position.x - enemy.global_position.x) * 480.0
			)
		"mushroom":
			enemy.attack_cooldown = enemy.attack_period
			enemy.mushroom_stun_attack_counter += 1
			enemy.mushroom_stun_attack_active = (enemy.mushroom_stun_attack_counter % 3 == 0)
			if absf(dx) < 84.0:
				_try_damage_target(
					enemy.target,
					enemy.contact_damage + (6 if enemy.mushroom_stun_attack_active else 0),
					enemy.global_position,
					320.0 if enemy.mushroom_stun_attack_active else 220.0,
					""
				)
		"rat":
			enemy.attack_cooldown = enemy.attack_period
			if absf(dx) < 56.0:
				_try_damage_target(
					enemy.target, enemy.contact_damage, enemy.global_position, 180.0, ""
				)
				enemy.rat_combo_timer = 0.18
		"tooth_walker":
			enemy.attack_cooldown = enemy.attack_period
			if absf(dx) < 96.0:
				_try_damage_target(
					enemy.target,
					enemy.contact_damage + 3,
					enemy.global_position,
					200.0,
					"",
					[{"type": "slow", "value": 0.3, "duration": 1.5}]
				)
		"eyeball":
			enemy._fire_eyeball_shot()
		"trash_monster":
			enemy.attack_cooldown = enemy.attack_period
			if absf(dx) < 80.0:
				_try_damage_target(
					enemy.target, enemy.contact_damage + 5, enemy.global_position, 160.0, ""
				)
		"sword":
			enemy.attack_cooldown = enemy.attack_period
			enemy.velocity.x = sign(enemy.charge_locked_x - enemy.global_position.x) * 560.0
			enemy.velocity.y = -45.0
			enemy.sword_retreat_timer = 0.45
		"dummy":
			enemy.velocity.x = 0.0


static func _run_pursue_ai(enemy: CharacterBody2D, distance: float, dx: float) -> void:
	if enemy.enemy_type == "dummy":
		enemy.velocity.x = 0.0
		return
	enemy.velocity.x = sign(dx) * enemy.move_speed * enemy.slow_multiplier
	match enemy.enemy_type:
		"brute", "mushroom":
			if distance < 72.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"ranged":
			if distance < 160.0:
				enemy.state_chart.send_event("keep_distance")
			elif distance <= 270.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"boss":
			if distance < 260.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"dasher":
			_start_dash_telegraph(enemy, distance < 115.0, 0.42)
		"sentinel":
			if distance < 200.0:
				enemy.state_chart.send_event("keep_distance")
			elif distance <= 380.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"elite":
			if distance < 80.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"leaper":
			if not enemy.leaper_jumping and distance < 130.0 and enemy.attack_cooldown == 0.0:
				enemy.leaper_jumping = true
				enemy.velocity.x = 0.0
				_start_state_delay(enemy, 0.48)
		"bomber":
			if distance < 240.0:
				enemy.state_chart.send_event("keep_distance")
			elif distance <= 500.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"charger":
			if enemy.dash_telegraphing:
				enemy.velocity.x = 0.0
			elif distance < 200.0 and enemy.attack_cooldown == 0.0:
				enemy.dash_telegraphing = true
				enemy.charge_locked_x = enemy.target.global_position.x
				enemy.velocity.x = 0.0
				_start_state_delay(enemy, 0.65)
		"bat":
			if distance < 140.0:
				enemy.state_chart.send_event("keep_distance")
			elif distance <= 320.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"worm":
			_start_dash_telegraph(enemy, distance < 140.0, 0.55)
		"rat":
			if distance < 56.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"tooth_walker":
			if distance < 96.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"eyeball":
			if distance < 120.0:
				enemy.state_chart.send_event("keep_distance")
			elif distance <= 280.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"trash_monster":
			if distance < 80.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"sword":
			if enemy.sword_retreat_timer > 0.0:
				enemy.velocity.x = -sign(dx) * enemy.move_speed * 0.7
			elif enemy.dash_telegraphing:
				enemy.velocity.x = 0.0
			elif distance < 120.0 and enemy.attack_cooldown == 0.0:
				enemy.dash_telegraphing = true
				enemy.charge_locked_x = enemy.target.global_position.x
				enemy.velocity.x = 0.0
				_start_state_delay(enemy, 0.45)


static func _run_kite_ai(enemy: CharacterBody2D, distance: float) -> void:
	enemy.velocity.x = (
		-sign(enemy.target.global_position.x - enemy.global_position.x)
		* enemy.move_speed
		* enemy.slow_multiplier
	)
	match enemy.enemy_type:
		"sentinel":
			if distance > 380.0:
				enemy.state_chart.send_event("chase_window")
			elif distance >= 200.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"bomber":
			if distance > 500.0:
				enemy.state_chart.send_event("chase_window")
			elif distance >= 240.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"bat":
			if distance > 320.0:
				enemy.state_chart.send_event("chase_window")
			elif distance >= 140.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		"eyeball":
			if distance > 280.0:
				enemy.state_chart.send_event("chase_window")
			elif distance >= 120.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")
		_:
			if distance > 250.0:
				enemy.state_chart.send_event("chase_window")
			elif distance >= 170.0 and enemy.attack_cooldown == 0.0:
				enemy.state_chart.send_event("attack_window")


static func _start_dash_telegraph(
	enemy: CharacterBody2D, should_trigger: bool, delay: float
) -> void:
	if enemy.dash_telegraphing:
		enemy.velocity.x = 0.0
	elif should_trigger and enemy.attack_cooldown == 0.0:
		enemy.dash_telegraphing = true
		enemy.velocity.x = 0.0
		_start_state_delay(enemy, delay)


static func _start_state_delay(enemy: CharacterBody2D, delay: float) -> void:
	_start_owned_delay(
		enemy,
		delay,
		func() -> void:
			enemy.dash_telegraphing = false
			if is_instance_valid(enemy) and enemy.behavior_state == "pursue" and enemy.state_chart:
				enemy.state_chart.send_event("attack_window")
	)


static func _try_damage_target(
	target: Node,
	amount: int,
	source: Vector2,
	knockback: float,
	school: String,
	utility_effects: Array = []
) -> void:
	if target != null and target.has_method("receive_hit"):
		target.receive_hit(amount, source, knockback, school, utility_effects)


static func _returns_to_kite(enemy_type: String) -> bool:
	return enemy_type in ["ranged", "sentinel", "bomber", "bat", "eyeball"]


static func _add_atomic_state(root_state, atomic_state_script, state_name: String):
	var state = atomic_state_script.new()
	state.name = state_name
	root_state.add_child(state)
	if root_state.initial_state.is_empty():
		root_state.initial_state = root_state.get_path_to(state)
	return state


static func _add_transition(
	from_state, to_state, transition_script, event: String = "", delay: String = "0"
) -> void:
	var transition = transition_script.new()
	transition.name = "%s_to_%s" % [from_state.name, to_state.name]
	from_state.add_child(transition)
	transition.to = transition.get_path_to(to_state)
	transition.event = event
	transition.delay_in_seconds = delay

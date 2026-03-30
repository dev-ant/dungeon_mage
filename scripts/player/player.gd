extends CharacterBody2D

signal cast_spell(payload: Dictionary)
signal request_room_shift(direction: int)

const SPEED := 310.0
const JUMP_VELOCITY := -680.0
const DASH_SPEED := 780.0
const DASH_TIME := 0.16
const DASH_COOLDOWN := 0.5
const IFRAME_TIME := 0.8
const HIT_STUN_TIME := 0.18
const CAST_LOCK_TIME := 0.08
const MAX_JUMPS := 2

const StateChartScript := preload("res://addons/godot_state_charts/state_chart.gd")
const CompoundStateScript := preload("res://addons/godot_state_charts/compound_state.gd")
const AtomicStateScript := preload("res://addons/godot_state_charts/atomic_state.gd")
const TransitionScript := preload("res://addons/godot_state_charts/transition.gd")

const ROPE_CLIMB_SPEED := 180.0

var facing := 1
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var dash_timer := 0.0
var dash_cooldown := 0.0
var invuln_timer := 0.0
var hit_stun_timer := 0.0
var cast_lock_timer := 0.0
var jump_count := 0
var state_name := "Idle"
var is_dead := false
var current_interactable: Node = null
var current_rope = null
var spell_manager = null
var state_chart = null
var _sc_root = null
var _cam_shake_timer := 0.0
var _cam_shake_intensity := 0.0

@onready var body_polygon: Polygon2D = $Body
# SPRITE DIRECTION: native facing = RIGHT (detected by analyzer)
# sprite.scale.x = 1.0 → faces RIGHT, sprite.scale.x = -1.0 → faces LEFT
# @onready set after editor import: var sprite: AnimatedSprite2D = $Sprite
var sprite: AnimatedSprite2D = null

func _ready() -> void:
	add_to_group("player")
	spell_manager = preload("res://scripts/player/spell_manager.gd").new()
	spell_manager.setup(self)
	spell_manager.spell_cast.connect(_on_spell_cast)
	if not GameState.player_died.is_connected(_on_player_died):
		GameState.player_died.connect(_on_player_died)
	_build_player_state_chart()
	if has_node("Sprite"):
		sprite = $Sprite

func _build_player_state_chart() -> void:
	state_chart = StateChartScript.new()
	state_chart.name = "PlayerStateChart"
	_sc_root = CompoundStateScript.new()
	_sc_root.name = "Root"
	state_chart.add_child(_sc_root)

	var sc_idle := _add_player_state("Idle")
	var sc_walk := _add_player_state("Walk")
	var sc_jump := _add_player_state("Jump")
	var sc_double_jump := _add_player_state("DoubleJump")
	var sc_fall := _add_player_state("Fall")
	var sc_dash := _add_player_state("Dash")
	var sc_cast := _add_player_state("Cast")
	var sc_hit := _add_player_state("Hit")
	var sc_dead := _add_player_state("Dead")
	var sc_on_rope := _add_player_state("OnRope")

	sc_idle.state_entered.connect(func() -> void: state_name = "Idle")
	sc_walk.state_entered.connect(func() -> void: state_name = "Walk")
	sc_jump.state_entered.connect(func() -> void: state_name = "Jump")
	sc_double_jump.state_entered.connect(func() -> void: state_name = "DoubleJump")
	sc_fall.state_entered.connect(func() -> void: state_name = "Fall")
	sc_dash.state_entered.connect(func() -> void: state_name = "Dash")
	sc_cast.state_entered.connect(func() -> void: state_name = "Cast")
	sc_hit.state_entered.connect(func() -> void: state_name = "Hit")
	sc_dead.state_entered.connect(func() -> void: state_name = "Dead")
	sc_on_rope.state_entered.connect(func() -> void: state_name = "OnRope")

	# player_died: any locomotion state → Dead
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_dash, sc_cast, sc_hit, sc_on_rope]:
		_add_player_transition(from, sc_dead, "player_died")
	# revived: Dead → Idle
	_add_player_transition(sc_dead, sc_idle, "revived")

	# hit_taken: non-dead states → Hit
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_cast, sc_dash]:
		_add_player_transition(from, sc_hit, "hit_taken")
	# hit_recovered: Hit → Idle
	_add_player_transition(sc_hit, sc_idle, "hit_recovered")

	# dash_start / dash_end
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_hit]:
		_add_player_transition(from, sc_dash, "dash_start")
	_add_player_transition(sc_dash, sc_idle, "dash_end")

	# jump / double_jump / peak / land
	for from in [sc_idle, sc_walk, sc_hit, sc_fall]:
		_add_player_transition(from, sc_jump, "jumped")
	for from in [sc_jump, sc_fall, sc_hit]:
		_add_player_transition(from, sc_double_jump, "double_jumped")
	_add_player_transition(sc_jump, sc_fall, "peaked")
	_add_player_transition(sc_double_jump, sc_fall, "peaked")
	for from in [sc_jump, sc_double_jump, sc_fall, sc_dash]:
		_add_player_transition(from, sc_idle, "landed")

	# walk / idle
	_add_player_transition(sc_idle, sc_walk, "started_walking")
	_add_player_transition(sc_walk, sc_idle, "stopped_walking")

	# cast_start / cast_end
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall]:
		_add_player_transition(from, sc_cast, "cast_start")
	_add_player_transition(sc_cast, sc_idle, "cast_end")

	# rope_grabbed / rope_released
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_hit]:
		_add_player_transition(from, sc_on_rope, "rope_grabbed")
	_add_player_transition(sc_on_rope, sc_fall, "rope_released")

	add_child(state_chart)

func _add_player_state(state_label: String) -> Object:
	var st := AtomicStateScript.new()
	st.name = state_label
	_sc_root.add_child(st)
	if _sc_root.initial_state.is_empty():
		_sc_root.initial_state = _sc_root.get_path_to(st)
	return st

func _add_player_transition(from_state: Object, to_state: Object, event: String) -> void:
	var t := TransitionScript.new()
	t.name = "%s_to_%s" % [from_state.name, to_state.name]
	from_state.add_child(t)
	t.to = t.get_path_to(to_state)
	t.event = event

func _sc_send(event: String) -> void:
	if state_chart and is_node_ready():
		state_chart.send_event(event)

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	_tick_timers(delta)
	if is_dead:
		velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		_update_state_name(move_axis_from_velocity())
		_update_visual()
		return
	if state_name == "OnRope":
		_handle_rope_physics()
		move_and_slide()
		_update_visual()
		return
	var move_axis := Input.get_axis("move_left", "move_right")
	var move_speed := SPEED * GameState.get_player_move_multiplier()
	if move_axis != 0:
		facing = 1 if move_axis > 0 else -1
	if dash_timer > 0.0:
		velocity.x = DASH_SPEED * GameState.get_player_move_multiplier() * facing
	elif hit_stun_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)
	else:
		velocity.x = move_axis * move_speed
		if Input.is_action_just_pressed("dash"):
			_begin_dash()
		if Input.is_action_just_pressed("jump"):
			_try_jump(was_on_floor)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if not was_on_floor:
			_on_landed()
		velocity.y = min(velocity.y, 50.0)
	if hit_stun_timer <= 0.0:
		_handle_spell_input()
		if current_rope != null and Input.is_action_just_pressed("move_up"):
			_try_grab_rope()
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		_on_landed()
	_update_state_name(move_axis)
	_update_visual()
	_check_room_edges()
	if Input.is_action_just_pressed("interact") and current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact(self)

func receive_hit(amount: int, source: Vector2, knockback: float, _school: String = "", _utility_effects: Array = []) -> void:
	if invuln_timer > 0.0 or is_dead:
		return
	invuln_timer = IFRAME_TIME
	if GameState.get_super_armor_charges() > 0:
		GameState.damage(amount, _school)
		return
	var stagger_mult: float = GameState.get_stagger_taken_multiplier()
	var poise_reduction: float = clampf(GameState.get_poise_bonus() * 0.01, 0.0, 0.6)
	hit_stun_timer = HIT_STUN_TIME * (1.0 - poise_reduction) * stagger_mult
	var push_dir: float = sign(global_position.x - source.x)
	if push_dir == 0:
		push_dir = -facing
	velocity = Vector2(push_dir * knockback * stagger_mult, -240.0)
	GameState.damage(amount, _school)
	_cam_shake_timer = 0.3
	_cam_shake_intensity = 8.0
	_sc_send("hit_taken")

func register_interactable(target: Node) -> void:
	current_interactable = target

func unregister_interactable(target: Node) -> void:
	if current_interactable == target:
		current_interactable = null

func register_rope(rope: Node) -> void:
	current_rope = rope

func unregister_rope(rope: Node) -> void:
	if current_rope == rope:
		current_rope = null
		if state_name == "OnRope":
			_exit_rope()

func _try_grab_rope() -> bool:
	if current_rope == null or state_name == "OnRope":
		return false
	if is_dead or hit_stun_timer > 0.0:
		return false
	state_name = "OnRope"
	velocity = Vector2.ZERO
	_sc_send("rope_grabbed")
	return true

func _exit_rope() -> void:
	if state_name != "OnRope":
		return
	_sc_send("rope_released")
	# state_name will be corrected by next _update_state_name() call

func _handle_rope_physics() -> void:
	if current_rope == null or not is_instance_valid(current_rope):
		_exit_rope()
		return
	velocity.x = 0.0
	var vert_input := Input.get_axis("move_up", "move_down")
	velocity.y = vert_input * ROPE_CLIMB_SPEED
	# Jump exits rope with upward impulse
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jump_count = 1
		_exit_rope()
		return
	# Dash exits rope
	if Input.is_action_just_pressed("dash"):
		_exit_rope()
		return
	# Rope bounds clamp
	var top_y: float = current_rope.rope_top_y
	var bot_y: float = current_rope.rope_bottom_y
	if global_position.y <= top_y:
		global_position.y = top_y
		velocity.y = max(velocity.y, 0.0)
		if vert_input < 0.0:
			_exit_rope()
	elif global_position.y >= bot_y:
		global_position.y = bot_y
		velocity.y = min(velocity.y, 0.0)

func reset_at(position_value: Vector2) -> void:
	global_position = position_value
	velocity = Vector2.ZERO
	jump_count = 0
	is_dead = false
	state_name = "Idle"
	dash_timer = 0.0
	dash_cooldown = 0.0
	hit_stun_timer = 0.0
	cast_lock_timer = 0.0
	_sc_send("revived")
	if spell_manager != null:
		spell_manager = preload("res://scripts/player/spell_manager.gd").new()
		spell_manager.setup(self)
		spell_manager.spell_cast.connect(_on_spell_cast)

func _handle_spell_input() -> void:
	if is_dead or hit_stun_timer > 0.0 or cast_lock_timer > 0.0:
		return
	spell_manager.handle_input()
	if Input.is_action_just_pressed("buff_aegis"):
		GameState.try_activate_buff("holy_crystal_aegis")
	if Input.is_action_just_pressed("buff_tempo"):
		GameState.try_activate_buff("wind_tempest_drive")
	if Input.is_action_just_pressed("buff_surge"):
		GameState.try_activate_buff("lightning_conductive_surge")
	if Input.is_action_just_pressed("buff_compression"):
		GameState.try_activate_buff("arcane_astral_compression")
	if Input.is_action_just_pressed("buff_hourglass"):
		GameState.try_activate_buff("arcane_world_hourglass")
	if Input.is_action_just_pressed("buff_pact"):
		GameState.try_activate_buff("dark_grave_pact")
	if Input.is_action_just_pressed("buff_throne"):
		GameState.try_activate_buff("dark_throne_of_ash")

func _on_spell_cast(payload: Dictionary) -> void:
	cast_lock_timer = CAST_LOCK_TIME
	cast_spell.emit(payload)
	_sc_send("cast_start")

func _tick_timers(delta: float) -> void:
	dash_timer = max(dash_timer - delta, 0.0)
	dash_cooldown = max(dash_cooldown - delta, 0.0)
	invuln_timer = max(invuln_timer - delta, 0.0)
	hit_stun_timer = max(hit_stun_timer - delta, 0.0)
	cast_lock_timer = max(cast_lock_timer - delta, 0.0)
	if spell_manager != null:
		spell_manager.tick(delta)
	if _cam_shake_timer > 0.0:
		_cam_shake_timer = max(_cam_shake_timer - delta, 0.0)
		var cam: Camera2D = get_node_or_null("Camera2D")
		if cam != null:
			if _cam_shake_timer > 0.0:
				var s := _cam_shake_intensity * (_cam_shake_timer / 0.3)
				cam.offset = Vector2(randf_range(-s, s), randf_range(-s, s))
			else:
				cam.offset = Vector2.ZERO

func _update_visual() -> void:
	body_polygon.scale.x = facing
	body_polygon.color = Color("#e9f0ff") if invuln_timer <= 0.0 or int(Time.get_ticks_msec() / 60) % 2 == 0 else Color("#6b778d")
	if sprite != null:
		_update_anim()

func _update_anim() -> void:
	if sprite == null:
		return
	sprite.scale.x = float(facing) * sprite.scale.y
	# iframe flicker: modulate alpha
	if invuln_timer > 0.0 and int(Time.get_ticks_msec() / 60) % 2 == 1:
		sprite.modulate = Color(1, 1, 1, 0.4)
	else:
		sprite.modulate = Color(1, 1, 1, 1)
	# animation selection
	var target_anim: String
	match state_name:
		"Dead":
			target_anim = "death"
		"Hit":
			target_anim = "hurt"
		"Dash":
			target_anim = "dash"
		"Jump", "DoubleJump":
			target_anim = "jump"
		"Fall":
			target_anim = "fall_loop"
		"Walk", "Run":
			target_anim = "run"
		_:
			target_anim = "idle"
	# Only call play() on transition to avoid restart mid-loop
	if sprite.animation != target_anim:
		sprite.play(target_anim)

func _check_room_edges() -> void:
	if global_position.x > 1540:
		request_room_shift.emit(1)
	elif global_position.x < 20:
		request_room_shift.emit(-1)

func _try_jump(was_on_floor: bool) -> bool:
	if is_dead or hit_stun_timer > 0.0:
		return false
	if was_on_floor:
		jump_count = 0
	if jump_count >= MAX_JUMPS:
		return false
	jump_count += 1
	velocity.y = JUMP_VELOCITY
	if jump_count == 1:
		state_name = "Jump"
		_sc_send("jumped")
	else:
		state_name = "DoubleJump"
		_sc_send("double_jumped")
	return true

func _on_landed() -> void:
	jump_count = 0
	_sc_send("landed")

func _begin_dash() -> bool:
	if is_dead or hit_stun_timer > 0.0 or dash_cooldown > 0.0:
		return false
	dash_timer = DASH_TIME
	dash_cooldown = DASH_COOLDOWN
	invuln_timer = max(invuln_timer, DASH_TIME)
	velocity.x = DASH_SPEED * facing
	state_name = "Dash"
	_sc_send("dash_start")
	return true

func _update_state_name(move_axis: float) -> void:
	var prev := state_name
	if is_dead:
		state_name = "Dead"
	elif state_name == "OnRope":
		pass  # rope physics loop controls exit; state is managed by _exit_rope()
	elif hit_stun_timer > 0.0:
		state_name = "Hit"
	elif dash_timer > 0.0:
		state_name = "Dash"
	elif cast_lock_timer > 0.0:
		state_name = "Cast"
	elif not is_on_floor():
		if velocity.y < -20.0:
			state_name = "DoubleJump" if jump_count >= 2 else "Jump"
		else:
			state_name = "Fall"
	elif absf(move_axis) > 0.01:
		state_name = "Walk"
	else:
		state_name = "Idle"
	if state_chart and is_node_ready() and state_name != prev:
		_send_state_transition_event(prev, state_name)

func _send_state_transition_event(prev: String, next: String) -> void:
	match next:
		"Dead":
			state_chart.send_event("player_died")
		"Hit":
			state_chart.send_event("hit_taken")
		"Dash":
			state_chart.send_event("dash_start")
		"Cast":
			state_chart.send_event("cast_start")
		"Jump":
			state_chart.send_event("jumped")
		"DoubleJump":
			state_chart.send_event("double_jumped")
		"Fall":
			if prev in ["Jump", "DoubleJump"]:
				state_chart.send_event("peaked")
			elif prev == "OnRope":
				state_chart.send_event("rope_released")
		"OnRope":
			state_chart.send_event("rope_grabbed")
		"Walk":
			state_chart.send_event("started_walking")
		"Idle":
			if prev == "Walk":
				state_chart.send_event("stopped_walking")
			elif prev == "Hit":
				state_chart.send_event("hit_recovered")
			elif prev == "Dash":
				state_chart.send_event("dash_end")
			elif prev == "Cast":
				state_chart.send_event("cast_end")
			elif prev in ["Jump", "DoubleJump", "Fall"]:
				state_chart.send_event("landed")

func move_axis_from_velocity() -> float:
	if absf(velocity.x) <= 0.01:
		return 0.0
	return signf(velocity.x)

func get_debug_state_name() -> String:
	return state_name

func get_jump_count() -> int:
	return jump_count

func is_input_locked() -> bool:
	return is_dead or hit_stun_timer > 0.0

func can_cast_spell() -> bool:
	return not is_dead and hit_stun_timer <= 0.0 and cast_lock_timer <= 0.0

func get_hotbar_summary() -> String:
	if spell_manager == null:
		return "Hotbar  unavailable"
	return spell_manager.get_hotbar_summary()

func get_hotbar_mastery_summary() -> String:
	if spell_manager == null:
		return "Skills  unavailable"
	return spell_manager.get_hotbar_mastery_summary()

func get_cast_feedback_summary() -> String:
	if spell_manager == null:
		return "Cast  unavailable"
	return spell_manager.get_feedback_summary()

func get_toggle_summary() -> String:
	if spell_manager == null:
		return "Toggles  unavailable"
	return spell_manager.get_toggle_summary()

func debug_reset_spell_cooldowns() -> void:
	if spell_manager != null:
		spell_manager.reset_all_cooldowns()

func debug_try_jump(grounded: bool) -> bool:
	return _try_jump(grounded)

func debug_begin_dash() -> bool:
	return _begin_dash()

func debug_advance_timers(delta: float) -> void:
	_tick_timers(delta)
	_update_state_name(move_axis_from_velocity())

func debug_mark_dead() -> void:
	_on_player_died()

func _on_player_died() -> void:
	is_dead = true
	state_name = "Dead"
	_sc_send("player_died")

func cast_hotbar_slot(slot_index: int) -> bool:
	if is_dead or hit_stun_timer > 0.0 or cast_lock_timer > 0.0:
		return false
	if spell_manager == null:
		return false
	var hotbar := GameState.get_spell_hotbar()
	if slot_index < 0 or slot_index >= hotbar.size():
		return false
	var skill_id := str(hotbar[slot_index].get("skill_id", ""))
	return spell_manager.attempt_cast(skill_id)

func get_state_chart() -> Object:
	return state_chart

func debug_setup_state_chart() -> void:
	_build_player_state_chart()

func debug_setup_spell_manager() -> void:
	spell_manager = preload("res://scripts/player/spell_manager.gd").new()
	spell_manager.setup(self)
	spell_manager.spell_cast.connect(_on_spell_cast)

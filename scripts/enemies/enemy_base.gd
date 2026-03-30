extends CharacterBody2D

signal died(enemy: Node)
signal fire_projectile(payload: Dictionary)
signal damage_label_requested(amount: int, position: Vector2, school: String)

const StateChartScript := preload("res://addons/godot_state_charts/state_chart.gd")
const CompoundStateScript := preload("res://addons/godot_state_charts/compound_state.gd")
const AtomicStateScript := preload("res://addons/godot_state_charts/atomic_state.gd")
const TransitionScript := preload("res://addons/godot_state_charts/transition.gd")

var enemy_type := "brute"
var max_health := 40
var health := 40
var move_speed := 120.0
var contact_damage := 10
var attack_cooldown := 0.0
var attack_period := 1.4
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var tint := Color("#c74d4d")
var projectile_color := "#ffcf73"
var target: Node2D = null
var behavior_state := "idle"
var slow_timer := 0.0
var slow_multiplier := 1.0
var dash_telegraphing := false
var super_armor_active := false
var has_super_armor_attack := false
var stagger_accumulator := 0
var stagger_threshold := 9999
var leaper_jumping := false
var charge_locked_x := 0.0
var elite_phase2_activated := false
var hit_flash_timer := 0.0
var state_chart = null
var root_state = null
var idle_state = null
var pursue_state = null
var kite_state = null
var attack_state = null
var stagger_state = null
var enemy_sprite: AnimatedSprite2D = null

const MUSHROOM_SHEETS := {
	"idle":   {"frames": 7,  "fps": 8.0,  "loop": true},
	"run":    {"frames": 8,  "fps": 10.0, "loop": true},
	"attack": {"frames": 10, "fps": 10.0, "loop": false},
	"hurt":   {"frames": 5,  "fps": 10.0, "loop": false},
	"death":  {"frames": 15, "fps": 8.0,  "loop": false},
}
const MUSHROOM_SHEET_DIR := "res://asset_sample/Monster/Forest_Monsters_FREE/Mushroom/Mushroom without VFX/"
const MUSHROOM_ANIM_FILES := {
	"idle": "Mushroom-Idle.png", "run": "Mushroom-Run.png",
	"attack": "Mushroom-Attack.png", "hurt": "Mushroom-Hit.png", "death": "Mushroom-Die.png",
}

@onready var collision_shape: CollisionShape2D = CollisionShape2D.new()
@onready var body_polygon: Polygon2D = Polygon2D.new()

func _ready() -> void:
	add_to_group("enemy")
	if get_child_count() == 0:
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.size = Vector2(40, 54)
		add_child(collision_shape)
		body_polygon.color = tint
		body_polygon.polygon = PackedVector2Array([
			Vector2(-22, -28),
			Vector2(22, -28),
			Vector2(18, 26),
			Vector2(-18, 26)
		])
		body_polygon.position = Vector2(0, -2)
		add_child(body_polygon)
	_setup_sprite()
	_build_state_chart()

func _setup_sprite() -> void:
	if enemy_type not in ["brute", "dummy", "ranged"]:
		return
	if DisplayServer.get_name() == "headless":
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var loaded_any := false
	for anim_name in MUSHROOM_SHEETS:
		var info: Dictionary = MUSHROOM_SHEETS[anim_name]
		var file_name: String = MUSHROOM_ANIM_FILES[anim_name]
		var tex: Texture2D = ResourceLoader.load(MUSHROOM_SHEET_DIR + file_name, "Texture2D")
		if tex == null:
			return
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, bool(info["loop"]))
		frames.set_animation_speed(anim_name, float(info["fps"]))
		var frame_count: int = int(info["frames"])
		for i in range(frame_count):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * 80, 0, 80, 64)
			frames.add_frame(anim_name, atlas)
		loaded_any = true
	if not loaded_any:
		return
	enemy_sprite = AnimatedSprite2D.new()
	enemy_sprite.sprite_frames = frames
	enemy_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy_sprite.scale = Vector2(1.2, 1.2)
	enemy_sprite.position = Vector2(0, -10)
	enemy_sprite.animation = "idle"
	add_child(enemy_sprite)
	enemy_sprite.play("idle")
	body_polygon.visible = false

func configure(config: Dictionary, player_ref: Node2D) -> void:
	target = player_ref
	enemy_type = str(config.get("type", enemy_type))
	_apply_stats_from_data(enemy_type)
	health = max_health
	position = config.get("position", Vector2.ZERO)

func _apply_stats_from_data(type_id: String) -> void:
	var data: Dictionary = {}
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.root:
		var db = main_loop.root.get_node_or_null("GameDatabase")
		if db:
			data = db.get_enemy_data(type_id)
	if not data.is_empty():
		max_health = int(data.get("max_hp", max_health))
		move_speed = float(data.get("move_speed", move_speed))
		contact_damage = int(data.get("contact_damage", contact_damage))
		attack_period = float(data.get("attack_period", attack_period))
		stagger_threshold = int(data.get("stagger_threshold", stagger_threshold))
		var tint_str: String = str(data.get("tint", ""))
		if tint_str != "":
			tint = Color(tint_str)
		var proj_color: String = str(data.get("projectile_color", ""))
		if proj_color != "":
			projectile_color = proj_color
		var armor_tags: Array = data.get("super_armor_tags", [])
		has_super_armor_attack = armor_tags.size() > 0
		return
	# Fallback hardcoded stats when GameDatabase is unavailable (tests without autoload)
	match type_id:
		"brute":
			max_health = 52; move_speed = 120.0; contact_damage = 13
			tint = Color("#c25a62")
		"ranged":
			max_health = 34; move_speed = 80.0; contact_damage = 8
			attack_period = 1.6; tint = Color("#7d92d8")
		"boss":
			max_health = 120; move_speed = 150.0; contact_damage = 16
			attack_period = 1.0; tint = Color("#e0b06d")
		"dummy":
			max_health = 9999; move_speed = 0.0; contact_damage = 0
			attack_period = 99.0; tint = Color("#9ca3af")
		"dasher":
			max_health = 30; move_speed = 200.0; contact_damage = 12
			attack_period = 2.2; tint = Color("#e8792f")
		"sentinel":
			max_health = 32; move_speed = 70.0; contact_damage = 7
			attack_period = 2.5; tint = Color("#5eb868")
		"elite":
			max_health = 180; move_speed = 95.0; contact_damage = 18
			attack_period = 2.0; stagger_threshold = 55; tint = Color("#b06dc8")
			has_super_armor_attack = true
		"leaper":
			max_health = 44; move_speed = 160.0; contact_damage = 15
			attack_period = 2.4; tint = Color("#e8c440")
		"bomber":
			max_health = 36; move_speed = 62.0; contact_damage = 9
			attack_period = 2.8; tint = Color("#c8a033"); projectile_color = "#c8a033"
		"charger":
			max_health = 40; move_speed = 130.0; contact_damage = 16
			attack_period = 2.6; tint = Color("#e03a3a")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	slow_timer = max(slow_timer - delta, 0.0)
	if slow_timer <= 0.0:
		slow_multiplier = 1.0
	hit_flash_timer = max(hit_flash_timer - delta, 0.0)
	if enemy_sprite != null:
		enemy_sprite.modulate = Color(2.0, 2.0, 2.0) if hit_flash_timer > 0.0 else Color(1, 1, 1)
		_update_enemy_anim()
	else:
		body_polygon.color = Color.WHITE if hit_flash_timer > 0.0 else tint
	velocity.y += gravity * delta
	_run_ai(delta)
	move_and_slide()
	_handle_contact()

func _update_enemy_anim() -> void:
	if enemy_sprite == null:
		return
	var facing_dir: float = sign(velocity.x)
	if facing_dir != 0.0:
		enemy_sprite.scale.x = facing_dir * enemy_sprite.scale.y
	var target_anim: String
	match behavior_state:
		"stagger":
			target_anim = "hurt"
		"attack":
			target_anim = "attack"
		"pursue":
			target_anim = "run" if abs(velocity.x) > 10.0 else "idle"
		_:
			target_anim = "idle"
	if not enemy_sprite.sprite_frames.has_animation(target_anim):
		target_anim = "idle"
	if enemy_sprite.animation != target_anim:
		enemy_sprite.play(target_anim)

func receive_hit(amount: int, source: Vector2, knockback: float, school: String, utility_effects: Array = []) -> void:
	hit_flash_timer = 0.12
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.root:
		var gs = main_loop.root.get_node_or_null("GameState")
		if gs:
			gs.record_enemy_hit(amount, school)
	health -= amount
	_spawn_damage_label(amount, school)
	if enemy_type == "elite" and not elite_phase2_activated and health > 0 and health <= max_health / 2:
		elite_phase2_activated = true
		stagger_threshold = 90
	var direction: float = sign(global_position.x - source.x)
	if direction == 0:
		direction = 1
	velocity.x = direction * knockback
	velocity.y = -150.0
	if school == "ice":
		velocity.x *= 0.65
	_apply_utility_effects(utility_effects)
	if state_chart and is_node_ready():
		if super_armor_active:
			stagger_accumulator += amount
			if stagger_accumulator >= stagger_threshold:
				stagger_accumulator = 0
				state_chart.send_event("stagger")
		else:
			state_chart.send_event("stagger")
	if health <= 0:
		died.emit(self)
		_play_death_and_free()

func _play_death_and_free() -> void:
	set_physics_process(false)
	set_process(false)
	if state_chart != null:
		state_chart.set_process(false)
		state_chart.set_physics_process(false)
	collision_shape.disabled = true
	if enemy_sprite != null and enemy_sprite.sprite_frames != null \
			and enemy_sprite.sprite_frames.has_animation("death"):
		enemy_sprite.play("death")
		var frames: int = enemy_sprite.sprite_frames.get_frame_count("death")
		var fps: float = enemy_sprite.sprite_frames.get_animation_speed("death")
		var death_duration: float = float(frames) / fps
		await get_tree().create_timer(death_duration, false, true).timeout
	queue_free()

func _spawn_damage_label(amount: int, school: String) -> void:
	damage_label_requested.emit(amount, global_position + Vector2(0, -20), school)

func _run_ai(_delta: float) -> void:
	if not state_chart or not root_state:
		velocity.x = move_toward(velocity.x, 0.0, 32.0)
		return
	var dx: float = target.global_position.x - global_position.x
	var distance := absf(dx)
	if distance < 460.0:
		state_chart.send_event("player_seen")
	match behavior_state:
		"idle":
			velocity.x = move_toward(velocity.x, 0.0, 36.0)
		"pursue":
			if enemy_type == "dummy":
				velocity.x = 0.0
				return
			velocity.x = sign(dx) * move_speed * slow_multiplier
			if enemy_type == "brute" and distance < 72.0 and attack_cooldown == 0.0:
				state_chart.send_event("attack_window")
			elif enemy_type == "ranged":
				if distance < 160.0:
					state_chart.send_event("keep_distance")
				elif distance <= 270.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
			elif enemy_type == "boss" and distance < 260.0 and attack_cooldown == 0.0:
				state_chart.send_event("attack_window")
			elif enemy_type == "dasher":
				if dash_telegraphing:
					velocity.x = 0.0
				elif distance < 115.0 and attack_cooldown == 0.0:
					dash_telegraphing = true
					velocity.x = 0.0
					var timer := get_tree().create_timer(0.42)
					timer.timeout.connect(func() -> void:
						dash_telegraphing = false
						if is_instance_valid(self) and behavior_state == "pursue" and state_chart:
							state_chart.send_event("attack_window")
					)
			elif enemy_type == "sentinel":
				if distance < 200.0:
					state_chart.send_event("keep_distance")
				elif distance <= 380.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
			elif enemy_type == "elite":
				if distance < 80.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
			elif enemy_type == "leaper":
				if leaper_jumping:
					pass
				elif distance < 130.0 and attack_cooldown == 0.0:
					leaper_jumping = true
					velocity.x = 0.0
					var jump_timer := get_tree().create_timer(0.48)
					jump_timer.timeout.connect(func() -> void:
						if is_instance_valid(self) and behavior_state == "pursue" and state_chart:
							state_chart.send_event("attack_window")
					)
			elif enemy_type == "bomber":
				if distance < 240.0:
					state_chart.send_event("keep_distance")
				elif distance <= 500.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
			elif enemy_type == "charger":
				if dash_telegraphing:
					velocity.x = 0.0
				elif distance < 200.0 and attack_cooldown == 0.0:
					dash_telegraphing = true
					charge_locked_x = target.global_position.x
					velocity.x = 0.0
					var charge_timer := get_tree().create_timer(0.65)
					charge_timer.timeout.connect(func() -> void:
						dash_telegraphing = false
						if is_instance_valid(self) and behavior_state == "pursue" and state_chart:
							state_chart.send_event("attack_window")
					)
		"kite":
			velocity.x = -sign(dx) * move_speed * slow_multiplier
			if enemy_type == "sentinel":
				if distance > 380.0:
					state_chart.send_event("chase_window")
				elif distance >= 200.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
			elif enemy_type == "bomber":
				if distance > 500.0:
					state_chart.send_event("chase_window")
				elif distance >= 240.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
			else:
				if distance > 250.0:
					state_chart.send_event("chase_window")
				elif distance >= 170.0 and attack_cooldown == 0.0:
					state_chart.send_event("attack_window")
		"attack":
			velocity.x = move_toward(velocity.x, 0.0, 50.0)
		"stagger":
			velocity.x = move_toward(velocity.x, 0.0, 28.0)

func _handle_contact() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("receive_hit"):
			collider.receive_hit(contact_damage, global_position, 220.0, "")

func _fire_orb(dx: float) -> void:
	attack_cooldown = attack_period
	fire_projectile.emit({
		"position": global_position + Vector2(sign(dx) * 24, -12),
		"velocity": Vector2(sign(dx) * 360.0, 0.0),
		"range": 360.0,
		"team": "enemy",
		"damage": 10,
		"knockback": 160.0,
		"school": "void",
		"size": 10.0,
		"color": projectile_color,
		"owner": self
	})

func _fire_boss_volley() -> void:
	attack_cooldown = attack_period
	for dir in [-1, 1]:
		fire_projectile.emit({
			"position": global_position + Vector2(dir * 20, -18),
			"velocity": Vector2(dir * 420.0, -80.0),
			"range": 420.0,
			"team": "enemy",
			"damage": 12,
			"knockback": 220.0,
			"school": "void",
			"size": 12.0,
			"color": "#ffd18e",
			"owner": self
		})

func _fire_sentinel_shots() -> void:
	attack_cooldown = attack_period
	if not is_instance_valid(target):
		return
	var to_player := (target.global_position - global_position).normalized()
	var to_above := (target.global_position + Vector2(0, -52) - global_position).normalized()
	var shot_speed := 155.0
	for dir in [to_player, to_above]:
		fire_projectile.emit({
			"position": global_position + Vector2(0, -12),
			"velocity": dir * shot_speed,
			"range": 560.0,
			"team": "enemy",
			"damage": 8,
			"knockback": 110.0,
			"school": "lightning",
			"size": 8.0,
			"color": "#8de0a0",
			"owner": self
		})

func _fire_bomb() -> void:
	attack_cooldown = attack_period
	if not is_instance_valid(target):
		return
	var to_target := (target.global_position + Vector2(0, 12) - global_position).normalized()
	fire_projectile.emit({
		"position": global_position + Vector2(0, -14),
		"velocity": to_target * 88.0,
		"range": 580.0,
		"team": "enemy",
		"damage": 14,
		"knockback": 190.0,
		"school": "void",
		"size": 16.0,
		"color": projectile_color,
		"owner": self
	})

func _emit_leaper_warning_marker(dx_l: float) -> void:
	# Emit a non-damaging ground marker at the predicted landing X.
	# Horizontal travel: 340 px/s * 0.7 s ≈ 238 px.
	var land_x: float = global_position.x + sign(dx_l) * 238.0
	fire_projectile.emit({
		"position": Vector2(land_x, global_position.y),
		"velocity": Vector2.ZERO,
		"range": 999.0,
		"team": "marker",
		"damage": 0,
		"knockback": 0.0,
		"school": "",
		"size": 28.0,
		"duration": 0.65,
		"color": "#ff4444",
		"marker": true,
		"owner": self
	})

func _on_leaper_land() -> void:
	leaper_jumping = false
	for dir in [-1, 1]:
		fire_projectile.emit({
			"position": global_position,
			"velocity": Vector2(dir * 200.0, 0.0),
			"range": 100.0,
			"team": "enemy",
			"damage": 10,
			"knockback": 260.0,
			"school": "void",
			"size": 18.0,
			"color": "#ffd060",
			"owner": self
		})

func _fire_elite_burst(dx: float) -> void:
	for angle_offset in [-15.0, 0.0, 15.0]:
		var angle_rad := deg_to_rad(angle_offset)
		var shot_dir := Vector2(sign(dx), 0.0).rotated(angle_rad)
		fire_projectile.emit({
			"position": global_position + Vector2(sign(dx) * 24, -20),
			"velocity": shot_dir * 300.0,
			"range": 480.0,
			"team": "enemy",
			"damage": 12,
			"knockback": 150.0,
			"school": "void",
			"size": 10.0,
			"color": "#c84bff",
			"owner": self
		})

func _build_state_chart() -> void:
	state_chart = StateChartScript.new()
	state_chart.name = "AIStateChart"

	root_state = CompoundStateScript.new()
	root_state.name = "Root"
	state_chart.add_child(root_state)

	idle_state = _add_atomic_state("Idle")
	pursue_state = _add_atomic_state("Pursue")
	kite_state = _add_atomic_state("Kite")
	attack_state = _add_atomic_state("Attack")
	stagger_state = _add_atomic_state("Stagger")

	idle_state.state_entered.connect(func() -> void: behavior_state = "idle")
	pursue_state.state_entered.connect(func() -> void: behavior_state = "pursue")
	kite_state.state_entered.connect(func() -> void: behavior_state = "kite")
	attack_state.state_entered.connect(_on_attack_state_entered)
	attack_state.state_exited.connect(func() -> void: super_armor_active = false)
	stagger_state.state_entered.connect(func() -> void: behavior_state = "stagger")

	_add_transition(idle_state, pursue_state, "player_seen")
	_add_transition(idle_state, stagger_state, "stagger")
	_add_transition(pursue_state, attack_state, "attack_window")
	_add_transition(pursue_state, kite_state, "keep_distance")
	_add_transition(pursue_state, stagger_state, "stagger")
	_add_transition(kite_state, attack_state, "attack_window")
	_add_transition(kite_state, pursue_state, "chase_window")
	_add_transition(kite_state, stagger_state, "stagger")
	_add_transition(attack_state, kite_state if enemy_type in ["ranged", "sentinel", "bomber"] else pursue_state, "", "0.28")
	_add_transition(attack_state, stagger_state, "stagger")
	_add_transition(stagger_state, pursue_state, "", "0.18")
	add_child(state_chart)

func _add_atomic_state(name_value: String):
	var state = AtomicStateScript.new()
	state.name = name_value
	root_state.add_child(state)
	if root_state.initial_state.is_empty():
		root_state.initial_state = root_state.get_path_to(state)
	return state

func _add_transition(from_state, to_state, event: String = "", delay: String = "0") -> void:
	var transition = TransitionScript.new()
	transition.name = "%s_to_%s" % [from_state.name, to_state.name]
	from_state.add_child(transition)
	transition.to = transition.get_path_to(to_state)
	transition.event = event
	transition.delay_in_seconds = delay

func _on_attack_state_entered() -> void:
	behavior_state = "attack"
	if has_super_armor_attack:
		super_armor_active = true
	if attack_cooldown > 0.0 or not is_instance_valid(target):
		return
	var dx: float = target.global_position.x - global_position.x
	if enemy_type == "brute":
		attack_cooldown = attack_period
		if absf(dx) < 84.0 and target.has_method("receive_hit"):
			target.receive_hit(contact_damage + 4, global_position, 240.0, "")
	elif enemy_type == "ranged":
		_fire_orb(dx)
	elif enemy_type == "boss":
		_fire_boss_volley()
	elif enemy_type == "dasher":
		attack_cooldown = attack_period
		var dx_d: float = target.global_position.x - global_position.x
		velocity.x = sign(dx_d) * 520.0
		velocity.y = -90.0
	elif enemy_type == "sentinel":
		_fire_sentinel_shots()
	elif enemy_type == "elite":
		attack_cooldown = attack_period
		if absf(dx) < 120.0:
			if target.has_method("receive_hit"):
				target.receive_hit(contact_damage + 6, global_position, 280.0, "")
		else:
			_fire_elite_burst(dx)
	elif enemy_type == "leaper":
		attack_cooldown = attack_period
		var dx_l: float = target.global_position.x - global_position.x
		_emit_leaper_warning_marker(dx_l)
		velocity.x = sign(dx_l) * 340.0
		velocity.y = -480.0
		var tree := get_tree()
		if tree:
			var land_timer := tree.create_timer(0.7)
			land_timer.timeout.connect(func() -> void:
				if is_instance_valid(self):
					_on_leaper_land()
			)
	elif enemy_type == "bomber":
		_fire_bomb()
	elif enemy_type == "charger":
		attack_cooldown = attack_period
		velocity.x = sign(charge_locked_x - global_position.x) * 620.0
		velocity.y = -55.0
	elif enemy_type == "dummy":
		velocity.x = 0.0

func _apply_utility_effects(effects: Array) -> void:
	for effect in effects:
		var effect_data: Dictionary = effect
		match str(effect_data.get("type", "")):
			"slow":
				var slow_value: float = clampf(float(effect_data.get("value", 0.2)), 0.0, 0.9)
				slow_multiplier = min(slow_multiplier, 1.0 - slow_value)
				slow_timer = max(slow_timer, float(effect_data.get("duration", 0.8)))

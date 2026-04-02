extends CharacterBody2D

signal died(enemy: Node)
signal fire_projectile(payload: Dictionary)
signal damage_label_requested(amount: int, position: Vector2, school: String)

const StateChartScript := preload("res://addons/godot_state_charts/state_chart.gd")
const CompoundStateScript := preload("res://addons/godot_state_charts/compound_state.gd")
const AtomicStateScript := preload("res://addons/godot_state_charts/atomic_state.gd")
const TransitionScript := preload("res://addons/godot_state_charts/transition.gd")
const EnemyVisualLibrary := preload("res://scripts/enemies/enemy_visual_library.gd")
const EnemyAttackProfiles := preload("res://scripts/enemies/enemy_attack_profiles.gd")
const RAT_SHEET_DIR := EnemyVisualLibrary.RAT_SHEET_DIR
const RAT_SHEETS := EnemyVisualLibrary.RAT_SHEETS
const RAT_ANIM_FILES := EnemyVisualLibrary.RAT_ANIM_FILES
const TOOTH_WALKER_SHEET_PATH := EnemyVisualLibrary.TOOTH_WALKER_SHEET_PATH
const TOOTH_WALKER_ANIM_ROWS := EnemyVisualLibrary.TOOTH_WALKER_ANIM_ROWS
const EYEBALL_SHEET_PATH := EnemyVisualLibrary.EYEBALL_SHEET_PATH
const EYEBALL_ANIM_VERT := EnemyVisualLibrary.EYEBALL_ANIM_VERT
const SWORD_SHEET_PATH := EnemyVisualLibrary.SWORD_SHEET_PATH
const SWORD_ANIM_ROWS := EnemyVisualLibrary.SWORD_ANIM_ROWS
const TRASH_MONSTER_SHEET_PATH := EnemyVisualLibrary.TRASH_MONSTER_SHEET_PATH
const TRASH_MONSTER_ANIM_ROWS := EnemyVisualLibrary.TRASH_MONSTER_ANIM_ROWS
const VALID_ENEMY_GRADES := ["normal", "elite", "boss"]
const VALID_ATTACK_DAMAGE_TYPES := ["physical", "magic"]
const ELEMENT_KEYS := [
	"fire", "water", "ice", "lightning", "wind", "earth", "plant", "dark", "holy", "arcane"
]
const STATUS_KEYS := ["slow", "root", "stun", "freeze", "shock", "burn", "poison", "silence"]
const BASE_ELEMENT_MATCHUP := 0.15

var enemy_type := "brute"
var enemy_grade := "normal"
var base_enemy_type := "brute"
var display_name := "Brute"
var max_health := 40
var health := 40
var move_speed := 120.0
var contact_damage := 10
var physical_attack := 10
var magic_attack := 0
var attack_damage_type := "physical"
var attack_element := "none"
var physical_defense := 20.0
var magic_defense := 20.0
var element_resists: Dictionary = {}
var status_resists: Dictionary = {}
var status_timers: Dictionary = {}
var status_values: Dictionary = {}
var attack_cooldown := 0.0
var attack_period := 1.4
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var tint := Color("#c74d4d")
var projectile_color := "#ffcf73"
var visual_modulate := Color(1, 1, 1, 1)
var target: Node2D = null
var behavior_state := "idle"
var slow_timer := 0.0
var slow_multiplier := 1.0
var dash_telegraphing := false
var super_armor_enabled := false
var super_armor_active := false
var has_super_armor_attack := false
var super_armor_break_threshold := 0.0
var super_armor_break_duration := 0.0
var super_armor_damage_multiplier := 1.0
var vulnerability_damage_multiplier := 1.2
var vulnerability_timer := 0.0
var stagger_accumulator := 0.0
var stagger_threshold := 9999
var knockback_resistance := 0.0
var drop_profile := "common"
var leaper_jumping := false
var charge_locked_x := 0.0
var rat_combo_timer := 0.0
var sword_retreat_timer := 0.0
var elite_phase2_activated := false
var mushroom_stun_attack_active := false
var mushroom_stun_attack_counter := 0
var hit_flash_timer := 0.0
var state_chart = null
var root_state = null
var idle_state = null
var pursue_state = null
var kite_state = null
var attack_state = null
var stagger_state = null
var enemy_sprite: AnimatedSprite2D = null
var health_bar_bg: Polygon2D = null
var health_bar_fill: Polygon2D = null

const HP_BAR_W := 36.0
const HP_BAR_H := 4.0
const HP_BAR_Y := -38.0  # body_polygon 상단(-28) 기준 10px 위

@onready var collision_shape: CollisionShape2D = CollisionShape2D.new()
@onready var body_polygon: Polygon2D = Polygon2D.new()


func _ready() -> void:
	add_to_group("enemy")
	if get_child_count() == 0:
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.size = Vector2(40, 54)
		add_child(collision_shape)
		body_polygon.color = tint
		body_polygon.polygon = PackedVector2Array(
			[Vector2(-22, -28), Vector2(22, -28), Vector2(18, 26), Vector2(-18, 26)]
		)
		body_polygon.position = Vector2(0, -2)
		add_child(body_polygon)
	enemy_sprite = EnemyVisualLibrary.setup_enemy_sprite(self, enemy_type, body_polygon)
	EnemyAttackProfiles.build_state_chart(
		self, StateChartScript, CompoundStateScript, AtomicStateScript, TransitionScript
	)
	_build_health_bar()


func _build_health_bar() -> void:
	if DisplayServer.get_name() == "headless":
		return
	health_bar_bg = Polygon2D.new()
	health_bar_bg.color = Color("#374151")
	health_bar_bg.polygon = PackedVector2Array(
		[
			Vector2(-HP_BAR_W * 0.5, -HP_BAR_H * 0.5),
			Vector2(HP_BAR_W * 0.5, -HP_BAR_H * 0.5),
			Vector2(HP_BAR_W * 0.5, HP_BAR_H * 0.5),
			Vector2(-HP_BAR_W * 0.5, HP_BAR_H * 0.5),
		]
	)
	health_bar_bg.position = Vector2(0.0, HP_BAR_Y)
	health_bar_bg.z_index = 2
	add_child(health_bar_bg)
	health_bar_fill = Polygon2D.new()
	health_bar_fill.color = Color("#4ade80")
	health_bar_fill.polygon = health_bar_bg.polygon.duplicate()
	health_bar_fill.position = Vector2(0.0, HP_BAR_Y)
	health_bar_fill.z_index = 3
	add_child(health_bar_fill)


func _update_health_bar() -> void:
	if health_bar_fill == null or max_health <= 0:
		return
	var ratio := clampf(float(health) / float(max_health), 0.0, 1.0)
	var fill_w := HP_BAR_W * ratio
	var left := -HP_BAR_W * 0.5
	health_bar_fill.polygon = PackedVector2Array(
		[
			Vector2(left, -HP_BAR_H * 0.5),
			Vector2(left + fill_w, -HP_BAR_H * 0.5),
			Vector2(left + fill_w, HP_BAR_H * 0.5),
			Vector2(left, HP_BAR_H * 0.5),
		]
	)
	if ratio > 0.5:
		health_bar_fill.color = Color("#4ade80")  # 초록 (100~50%)
	elif ratio > 0.2:
		health_bar_fill.color = Color("#fb923c")  # 주황 (50~20%)
	else:
		health_bar_fill.color = Color("#ef4444")  # 빨강 (20~0%)


func configure(config: Dictionary, player_ref: Node2D) -> void:
	target = player_ref
	enemy_type = str(config.get("type", enemy_type))
	base_enemy_type = str(config.get("base_type", enemy_type))
	enemy_grade = str(config.get("grade", _default_grade_for_type(enemy_type)))
	_apply_stats_from_data(enemy_type)
	health = max_health
	position = config.get("position", Vector2.ZERO)
	if is_node_ready():
		if enemy_sprite != null:
			enemy_sprite.queue_free()
			enemy_sprite = null
		enemy_sprite = EnemyVisualLibrary.setup_enemy_sprite(self, enemy_type, body_polygon)
	_update_health_bar()


func _apply_stats_from_data(type_id: String) -> void:
	_reset_combat_runtime_state()
	var data: Dictionary = {}
	var loaded_from_data := false
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.root:
		var db = main_loop.root.get_node_or_null("GameDatabase")
		if db:
			data = db.get_enemy_data(type_id)
	if not data.is_empty():
		loaded_from_data = true
		display_name = str(data.get("display_name", display_name))
		enemy_grade = str(data.get("enemy_grade", enemy_grade))
		max_health = int(data.get("max_hp", max_health))
		move_speed = float(data.get("move_speed", move_speed))
		contact_damage = int(data.get("contact_damage", contact_damage))
		attack_period = float(data.get("attack_period", attack_period))
		physical_attack = int(data.get("physical_attack", contact_damage))
		magic_attack = int(data.get("magic_attack", magic_attack))
		attack_damage_type = str(data.get("attack_damage_type", attack_damage_type))
		attack_element = str(data.get("attack_element", attack_element))
		physical_defense = float(data.get("physical_defense", physical_defense))
		magic_defense = float(data.get("magic_defense", magic_defense))
		knockback_resistance = clampf(
			float(data.get("knockback_resistance", knockback_resistance)), 0.0, 1.0
		)
		drop_profile = str(data.get("drop_profile", drop_profile))
		super_armor_enabled = bool(data.get("super_armor_enabled", super_armor_enabled))
		super_armor_break_threshold = float(
			data.get("super_armor_break_threshold", super_armor_break_threshold)
		)
		super_armor_break_duration = float(
			data.get("super_armor_break_duration", super_armor_break_duration)
		)
		super_armor_damage_multiplier = float(
			data.get("super_armor_damage_multiplier", super_armor_damage_multiplier)
		)
		vulnerability_damage_multiplier = float(
			data.get("vulnerability_damage_multiplier", vulnerability_damage_multiplier)
		)
		stagger_threshold = int(
			data.get("stagger_threshold", int(round(super_armor_break_threshold)))
		)
		var tint_str: String = str(data.get("tint", ""))
		if tint_str != "":
			tint = Color(tint_str)
		var proj_color: String = str(data.get("projectile_color", ""))
		if proj_color != "":
			projectile_color = proj_color
		for element in ELEMENT_KEYS:
			element_resists[element] = float(data.get("%s_resist" % element, 0.0))
		for status_type in STATUS_KEYS:
			status_resists[status_type] = float(data.get("%s_resist" % status_type, 0.0))
		var armor_tags: Array = data.get("super_armor_tags", [])
		has_super_armor_attack = super_armor_enabled and (
			armor_tags.size() > 0 or enemy_grade == "elite"
		)
	else:
		EnemyAttackProfiles.apply_fallback_stats(self, type_id)
		display_name = type_id.capitalize()
	_normalize_loaded_identity_fields(type_id, loaded_from_data)
	_reset_runtime_status_containers()
	_apply_grade_runtime_override()
	_finalize_combat_runtime_defaults()
	_refresh_visual_modulate()


func _build_strip_sprite_frames(
	sheet_dir: String, sheets: Dictionary, anim_files: Dictionary, frame_w: int, frame_h: int
) -> SpriteFrames:
	return EnemyVisualLibrary._build_strip_sprite_frames(
		sheet_dir, sheets, anim_files, frame_w, frame_h
	)


func _build_grid_sprite_frames(
	sheet_path: String, anim_rows: Dictionary, frame_w: int, frame_h: int
) -> SpriteFrames:
	return EnemyVisualLibrary._build_grid_sprite_frames(sheet_path, anim_rows, frame_w, frame_h)


func _build_vertical_sprite_frames(
	sheet_path: String, anim_vert: Dictionary, frame_w: int, frame_h: int
) -> SpriteFrames:
	return EnemyVisualLibrary._build_vertical_sprite_frames(sheet_path, anim_vert, frame_w, frame_h)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	_tick_runtime_timers(delta)
	if rat_combo_timer > 0.0:
		if (
			rat_combo_timer == 0.0
			and is_instance_valid(target)
			and target.has_method("receive_hit")
		):
			var dx: float = target.global_position.x - global_position.x
			if absf(dx) < 72.0:
				target.receive_hit(_get_outgoing_attack_amount(), global_position, 140.0, _get_outgoing_attack_school())
	if enemy_sprite != null:
		enemy_sprite.modulate = Color(2.0, 2.0, 2.0) if hit_flash_timer > 0.0 else visual_modulate
		EnemyVisualLibrary.update_animation(
			enemy_sprite, behavior_state, enemy_type, mushroom_stun_attack_active, velocity
		)
	else:
		body_polygon.color = Color.WHITE if hit_flash_timer > 0.0 else tint
	if enemy_type in ["bat", "eyeball"]:
		if is_instance_valid(target):
			var hover_y := target.global_position.y - 90.0
			var dy := hover_y - global_position.y
			velocity.y = move_toward(
				velocity.y, clampf(dy * 3.5, -180.0, 180.0), gravity * delta * 3.0
			)
		else:
			velocity.y = move_toward(velocity.y, 0.0, gravity * delta * 2.0)
	else:
		velocity.y += gravity * delta
	if _is_action_locked():
		velocity.x = move_toward(velocity.x, 0.0, 48.0)
	else:
		EnemyAttackProfiles.run_ai(self)
	if _is_rooted():
		velocity.x = 0.0
	move_and_slide()
	_handle_contact()


func receive_hit(
	amount: int, source: Vector2, knockback: float, school: String, utility_effects: Array = []
) -> int:
	hit_flash_timer = 0.12
	var damage_result: Dictionary = debug_calculate_incoming_damage(amount, school)
	var final_damage: int = int(damage_result.get("final_damage", 0))
	var break_damage: float = float(damage_result.get("break_damage", 0.0))
	var broke_super_armor := false
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.root:
		var gs = main_loop.root.get_node_or_null("GameState")
		if gs:
			gs.record_enemy_hit(final_damage, school)
	health -= final_damage
	_update_health_bar()
	_spawn_damage_label(final_damage, school)
	if (
		enemy_type == "elite"
		and not elite_phase2_activated
		and health > 0
		and health <= max_health / 2
	):
		elite_phase2_activated = true
		stagger_threshold = 90
		super_armor_break_threshold = 90.0
	var direction: float = sign(global_position.x - source.x)
	if direction == 0:
		direction = 1
	var can_react_to_hit := not bool(damage_result.get("super_armor_applied", false))
	if can_react_to_hit:
		var knockback_mult := clampf(1.0 - knockback_resistance, 0.0, 1.0)
		velocity.x = direction * knockback * knockback_mult
		velocity.y = -150.0 * knockback_mult
		if school == "ice":
			velocity.x *= 0.65
	_apply_utility_effects(utility_effects)
	if state_chart and is_node_ready():
		if bool(damage_result.get("super_armor_applied", false)):
			stagger_accumulator += break_damage
			if super_armor_break_threshold > 0.0 and stagger_accumulator >= super_armor_break_threshold:
				stagger_accumulator = 0.0
				broke_super_armor = true
				_break_super_armor()
				state_chart.send_event("stagger")
		else:
			state_chart.send_event("stagger")
	if health <= 0:
		died.emit(self)
		_play_death_and_free()
	return final_damage


func _play_death_and_free() -> void:
	set_physics_process(false)
	set_process(false)
	if state_chart != null:
		state_chart.set_process(false)
		state_chart.set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	if (
		enemy_sprite != null
		and enemy_sprite.sprite_frames != null
		and enemy_sprite.sprite_frames.has_animation("death")
	):
		enemy_sprite.play("death")
		var frames: int = enemy_sprite.sprite_frames.get_frame_count("death")
		var fps: float = enemy_sprite.sprite_frames.get_animation_speed("death")
		if fps > 0.0:
			var death_duration: float = float(frames) / fps
			var timer := Timer.new()
			timer.one_shot = true
			timer.wait_time = death_duration
			add_child(timer)
			timer.start()
			await timer.timeout
			if is_instance_valid(timer):
				timer.queue_free()
	queue_free()


func _spawn_damage_label(amount: int, school: String) -> void:
	damage_label_requested.emit(amount, global_position + Vector2(0, -20), school)


func _handle_contact() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("receive_hit"):
			collider.receive_hit(
				_get_outgoing_attack_amount(), global_position, 220.0, _get_outgoing_attack_school()
			)


func _fire_orb(dx: float) -> void:
	attack_cooldown = attack_period
	fire_projectile.emit(
		{
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
		}
	)


func _fire_boss_volley() -> void:
	attack_cooldown = attack_period
	for dir in [-1, 1]:
		fire_projectile.emit(
			{
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
			}
		)


func _fire_sentinel_shots() -> void:
	attack_cooldown = attack_period
	if not is_instance_valid(target):
		return
	var to_player := (target.global_position - global_position).normalized()
	var to_above := (target.global_position + Vector2(0, -52) - global_position).normalized()
	var shot_speed := 155.0
	for dir in [to_player, to_above]:
		fire_projectile.emit(
			{
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
			}
		)


func _fire_bat_shot() -> void:
	attack_cooldown = attack_period
	if not is_instance_valid(target):
		return
	var to_player := (target.global_position - global_position).normalized()
	fire_projectile.emit(
		{
			"position": global_position + to_player * 20.0,
			"velocity": to_player * 280.0,
			"range": 400.0,
			"team": "enemy",
			"damage": 9,
			"knockback": 130.0,
			"school": "void",
			"size": 9.0,
			"color": "#9b6fcf",
			"owner": self
		}
	)


func _fire_bomb() -> void:
	attack_cooldown = attack_period
	if not is_instance_valid(target):
		return
	var to_target := (target.global_position + Vector2(0, 12) - global_position).normalized()
	# Slow denial bomb: readable launch, then sag + drift so stationary players still get clipped.
	fire_projectile.emit(
		{
			"position": global_position + Vector2(0, -14),
			"velocity": to_target * 88.0,
			"range": 580.0,
			"team": "enemy",
			"damage": 14,
			"knockback": 190.0,
			"school": "void",
			"size": 16.0,
			"color": projectile_color,
			"spell_id": "enemy_bomber_bomb",
			"terminal_effect_id": "bomber_burst",
			"horizontal_drag_per_second": 24.0,
			"min_horizontal_speed": 34.0,
			"gravity_per_second": 180.0,
			"owner": self
		}
	)


func _emit_bomber_warning_marker() -> void:
	if not is_instance_valid(target):
		return
	# Lock a short-lived marker to the player's current feet position.
	# Bomber punishes stationary play, so the telegraph should show the committed aim point.
	var aim_position := target.global_position + Vector2(0, 12)
	fire_projectile.emit(
		{
			"position": aim_position,
			"velocity": Vector2.ZERO,
			"range": 999.0,
			"team": "marker",
			"damage": 0,
			"knockback": 0.0,
			"school": "",
			"size": 22.0,
			"duration": 0.55,
			"color": "#e3a83a",
			"marker": true,
			"owner": self
		}
	)


func _emit_leaper_warning_marker(dx_l: float) -> void:
	# Emit a non-damaging ground marker at the predicted landing X.
	# Horizontal travel: 340 px/s * 0.7 s ≈ 238 px.
	var land_x: float = global_position.x + sign(dx_l) * 238.0
	fire_projectile.emit(
		{
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
		}
	)


func _on_leaper_land() -> void:
	leaper_jumping = false
	for dir in [-1, 1]:
		fire_projectile.emit(
			{
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
			}
		)


func _fire_elite_burst(dx: float) -> void:
	for angle_offset in [-15.0, 0.0, 15.0]:
		var angle_rad := deg_to_rad(angle_offset)
		var shot_dir := Vector2(sign(dx), 0.0).rotated(angle_rad)
		fire_projectile.emit(
			{
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
			}
		)


func _on_attack_state_entered() -> void:
	EnemyAttackProfiles.perform_attack(self)


func _fire_eyeball_shot() -> void:
	attack_cooldown = attack_period
	if not is_instance_valid(target):
		return
	var dir: Vector2 = (target.global_position - global_position).normalized()
	fire_projectile.emit(
		{
			"position": global_position + dir * 18.0,
			"velocity": dir * 300.0,
			"range": 320.0,
			"team": "enemy",
			"damage": 9,
			"knockback": 140.0,
			"school": "dark",
			"size": 10.0,
			"color": projectile_color,
			"owner": self
		}
	)


func _apply_utility_effects(effects: Array) -> void:
	for effect in effects:
		var effect_data: Dictionary = effect.duplicate(true)
		var forced_roll := float(effect_data.get("debug_roll", -1.0))
		var resolved: Dictionary = debug_resolve_status_effect(effect_data, forced_roll)
		if not bool(resolved.get("applied", false)):
			continue
		var effect_type: String = str(resolved.get("type", ""))
		var resisted_duration: float = float(resolved.get("duration", 0.0))
		var resisted_value: float = float(resolved.get("value", effect_data.get("value", 0.0)))
		status_timers[effect_type] = maxf(float(status_timers.get(effect_type, 0.0)), resisted_duration)
		status_values[effect_type] = resisted_value
		match effect_type:
			"slow":
				var slow_value: float = clampf(resisted_value, 0.0, 0.9)
				slow_multiplier = min(slow_multiplier, 1.0 - slow_value)
				slow_timer = maxf(slow_timer, resisted_duration)
			"root", "stun", "freeze", "shock", "burn", "poison", "silence":
				pass


func debug_calculate_incoming_damage(
	raw_amount: int, school: String = "", damage_type_override: String = ""
) -> Dictionary:
	if raw_amount <= 0:
		return {
			"raw_damage": 0,
			"damage_type": "physical",
			"element": "none",
			"defense_value": 0.0,
			"element_resist": 0.0,
			"post_defense": 0.0,
			"post_element": 0.0,
			"post_minimum": 0.0,
			"break_damage": 0.0,
			"final_damage": 0,
			"super_armor_applied": false
		}
	var damage_type: String = damage_type_override
	var element: String = _normalize_element(school)
	if damage_type.is_empty():
		damage_type = "physical" if element == "none" else "magic"
	var defense_value: float = physical_defense if damage_type == "physical" else magic_defense
	var post_defense: float = float(raw_amount) * (100.0 / (100.0 + maxf(defense_value, 0.0)))
	var element_resist: float = _get_element_resist(element)
	var post_element: float = post_defense * (1.0 - element_resist)
	var minimum_damage: float = float(raw_amount) * 0.10
	var post_minimum: float = maxf(minimum_damage, post_element)
	var final_damage_float: float = post_minimum
	var super_armor_applied := false
	if super_armor_active and super_armor_enabled and vulnerability_timer <= 0.0:
		final_damage_float *= clampf(super_armor_damage_multiplier, 0.0, 1.0)
		super_armor_applied = true
	if vulnerability_timer > 0.0:
		final_damage_float *= maxf(vulnerability_damage_multiplier, 1.0)
	var final_damage := int(maxf(1.0, round(final_damage_float)))
	return {
		"raw_damage": raw_amount,
		"damage_type": damage_type,
		"element": element,
		"defense_value": defense_value,
		"element_resist": element_resist,
		"post_defense": post_defense,
		"post_element": post_element,
		"post_minimum": post_minimum,
		"break_damage": post_minimum,
		"final_damage": final_damage,
		"super_armor_applied": super_armor_applied
	}


func debug_resolve_status_effect(effect_data: Dictionary, forced_roll: float = -1.0) -> Dictionary:
	var effect_type: String = str(effect_data.get("type", ""))
	if not STATUS_KEYS.has(effect_type):
		return {"type": effect_type, "applied": false, "chance": 0.0, "duration": 0.0, "value": 0.0}
	var effective_resist: float = _get_effective_status_resist(effect_type)
	var base_chance: float = clampf(float(effect_data.get("chance", 1.0)), 0.0, 1.0)
	var base_duration: float = maxf(float(effect_data.get("duration", 0.0)), 0.0)
	var final_chance := base_chance
	var final_duration := base_duration
	if effect_type in ["root", "stun", "freeze", "silence"]:
		final_chance = base_chance * (1.0 - effective_resist)
		final_duration = base_duration * (1.0 - effective_resist * 0.5)
	else:
		final_chance = base_chance * (1.0 - effective_resist * 0.5)
		final_duration = base_duration * (1.0 - effective_resist)
	var roll: float = forced_roll if forced_roll >= 0.0 else randf()
	var applied := final_chance > 0.0 and final_duration > 0.0 and roll <= final_chance
	return {
		"type": effect_type,
		"applied": applied,
		"chance": final_chance,
		"duration": final_duration,
		"value": float(effect_data.get("value", 0.0)),
		"resist": effective_resist,
		"roll": roll
	}


func get_current_drop_profile() -> String:
	return drop_profile


func _on_attack_state_exited() -> void:
	if enemy_grade != "boss" and vulnerability_timer <= 0.0:
		super_armor_active = false
	mushroom_stun_attack_active = false


func _reset_combat_runtime_state() -> void:
	element_resists = {}
	status_resists = {}
	_reset_runtime_status_containers()
	physical_attack = max(contact_damage, 1)
	magic_attack = 0
	attack_damage_type = "physical"
	attack_element = "none"
	physical_defense = 20.0
	magic_defense = 20.0
	knockback_resistance = 0.0
	drop_profile = "common"
	super_armor_enabled = false
	super_armor_active = false
	has_super_armor_attack = false
	super_armor_break_threshold = 0.0
	super_armor_break_duration = 0.0
	super_armor_damage_multiplier = 1.0
	vulnerability_damage_multiplier = 1.2
	vulnerability_timer = 0.0
	stagger_accumulator = 0.0
	for element in ELEMENT_KEYS:
		element_resists[element] = 0.0
	for status_type in STATUS_KEYS:
		status_resists[status_type] = 0.1


func _reset_runtime_status_containers() -> void:
	status_timers = {}
	status_values = {}
	for status_type in STATUS_KEYS:
		status_timers[status_type] = 0.0
		status_values[status_type] = 0.0


func _apply_grade_runtime_override() -> void:
	if enemy_grade != "elite" or enemy_type == "elite":
		return
	max_health = int(round(float(max_health) * 3.0))
	contact_damage = int(round(float(contact_damage) * 1.4))
	physical_attack = int(round(float(max(physical_attack, contact_damage)) * 1.4))
	magic_attack = int(round(float(max(magic_attack, 0)) * 1.4))
	physical_defense *= 2.0
	magic_defense *= 2.0
	for element in ELEMENT_KEYS:
		element_resists[element] = clampf(float(element_resists.get(element, 0.0)) + 0.10, -0.25, 0.45)
	for status_type in STATUS_KEYS:
		status_resists[status_type] = clampf(float(status_resists.get(status_type, 0.1)) + 0.15, 0.0, 0.75)
	super_armor_enabled = true
	has_super_armor_attack = true
	super_armor_break_threshold = maxf(float(max_health) * 0.35, 1.0)
	super_armor_break_duration = 2.5
	super_armor_damage_multiplier = 0.20
	vulnerability_damage_multiplier = 1.20
	stagger_threshold = int(round(super_armor_break_threshold))
	drop_profile = "elite"


func _finalize_combat_runtime_defaults() -> void:
	if enemy_grade.is_empty():
		enemy_grade = _default_grade_for_type(enemy_type)
	_normalize_attack_contract_defaults()
	if physical_attack <= 0 and magic_attack <= 0:
		if attack_damage_type == "magic":
			magic_attack = max(contact_damage, 1)
		else:
			physical_attack = max(contact_damage, 1)
	if physical_defense <= 0.0 and magic_defense <= 0.0:
		var defense_profile: Vector2 = _build_default_defense_profile()
		physical_defense = defense_profile.x
		magic_defense = defense_profile.y
	_apply_default_matchup_if_missing()
	_apply_default_status_resists_if_missing()
	if enemy_grade == "boss":
		super_armor_enabled = true
		super_armor_break_duration = maxf(super_armor_break_duration, 1.5)
		super_armor_damage_multiplier = clampf(super_armor_damage_multiplier, 0.10, 1.0)
		if super_armor_break_threshold <= 0.0:
			super_armor_break_threshold = maxf(float(max_health) * 0.20, 1.0)
		stagger_threshold = int(round(super_armor_break_threshold))
	if enemy_grade == "elite" and enemy_type == "elite":
		super_armor_enabled = true
		has_super_armor_attack = true
		super_armor_break_threshold = maxf(super_armor_break_threshold, 55.0)
		super_armor_break_duration = maxf(super_armor_break_duration, 2.5)
		super_armor_damage_multiplier = clampf(super_armor_damage_multiplier, 0.20, 1.0)
		stagger_threshold = int(round(super_armor_break_threshold))
	visual_modulate = Color(1, 1, 1, 1)


func _normalize_loaded_identity_fields(type_id: String, loaded_from_data: bool) -> void:
	if not loaded_from_data:
		return
	var fallback_grade := _default_grade_for_type(type_id)
	if display_name.is_empty():
		push_warning(
			"Enemy '%s' has empty display_name; falling back to '%s'."
			% [type_id, type_id.capitalize()]
		)
		display_name = type_id.capitalize()
	if enemy_grade.is_empty():
		push_warning(
			"Enemy '%s' has empty enemy_grade; falling back to '%s'."
			% [type_id, fallback_grade]
		)
		enemy_grade = fallback_grade
	elif not VALID_ENEMY_GRADES.has(enemy_grade):
		push_warning(
			"Enemy '%s' has invalid enemy_grade '%s'; falling back to '%s'."
			% [type_id, enemy_grade, fallback_grade]
		)
		enemy_grade = fallback_grade


func _normalize_attack_contract_defaults() -> void:
	if attack_damage_type.is_empty():
		attack_damage_type = "physical"
	elif not VALID_ATTACK_DAMAGE_TYPES.has(attack_damage_type):
		push_warning(
			"Enemy '%s' has unknown attack_damage_type '%s'; falling back to 'physical'."
			% [enemy_type, attack_damage_type]
		)
		attack_damage_type = "physical"
	if attack_element.is_empty():
		attack_element = "none"
	elif attack_element != "none" and not ELEMENT_KEYS.has(attack_element):
		push_warning(
			"Enemy '%s' has unknown attack_element '%s'; falling back to 'none'."
			% [enemy_type, attack_element]
		)
		attack_element = "none"


func _apply_default_matchup_if_missing() -> void:
	var all_zero := true
	for element in ELEMENT_KEYS:
		if absf(float(element_resists.get(element, 0.0))) > 0.001:
			all_zero = false
			break
	if not all_zero:
		return
	var matchup: Dictionary = _get_default_element_matchup()
	var resist_element: String = str(matchup.get("resist", ""))
	var weak_element: String = str(matchup.get("weak", ""))
	if not resist_element.is_empty():
		element_resists[resist_element] = BASE_ELEMENT_MATCHUP
	if not weak_element.is_empty():
		element_resists[weak_element] = -BASE_ELEMENT_MATCHUP


func _apply_default_status_resists_if_missing() -> void:
	var all_zero := true
	for status_type in STATUS_KEYS:
		if absf(float(status_resists.get(status_type, 0.0))) > 0.001:
			all_zero = false
			break
	if not all_zero:
		return
	var value := 0.10
	match enemy_grade:
		"elite":
			value = 0.25
		"boss":
			value = 0.42
	for status_type in STATUS_KEYS:
		status_resists[status_type] = value


func _build_default_defense_profile() -> Vector2:
	match enemy_type:
		"brute", "charger", "worm", "trash_monster", "mushroom", "tooth_walker":
			return Vector2(26.0, 20.0)
		"sentinel", "bomber", "eyeball", "bat", "ranged":
			return Vector2(18.0, 24.0)
		"rat", "dasher", "sword", "leaper":
			return Vector2(16.0, 17.0)
		"boss":
			return Vector2(48.0, 52.0)
		"dummy":
			return Vector2.ZERO
		_:
			return Vector2(20.0, 20.0)


func _get_default_element_matchup() -> Dictionary:
	match enemy_type:
		"brute":
			return {"resist": "fire", "weak": "holy"}
		"ranged":
			return {"resist": "wind", "weak": "earth"}
		"boss":
			return {"resist": "dark", "weak": "holy"}
		"dummy":
			return {}
		"dasher":
			return {"resist": "lightning", "weak": "ice"}
		"sentinel":
			return {"resist": "lightning", "weak": "earth"}
		"elite":
			return {"resist": "dark", "weak": "holy"}
		"leaper":
			return {"resist": "wind", "weak": "lightning"}
		"bomber":
			return {"resist": "fire", "weak": "water"}
		"charger":
			return {"resist": "lightning", "weak": "ice"}
		"bat":
			return {"resist": "dark", "weak": "holy"}
		"worm":
			return {"resist": "fire", "weak": "water"}
		"mushroom":
			return {"resist": "plant", "weak": "fire"}
		"rat":
			return {"resist": "earth", "weak": "lightning"}
		"tooth_walker":
			return {"resist": "dark", "weak": "holy"}
		"eyeball":
			return {"resist": "dark", "weak": "holy"}
		"trash_monster":
			return {"resist": "earth", "weak": "fire"}
		"sword":
			return {"resist": "arcane", "weak": "lightning"}
		_:
			return {}


func _default_grade_for_type(type_id: String) -> String:
	if type_id == "boss":
		return "boss"
	if type_id == "elite":
		return "elite"
	return "normal"


func _get_element_resist(element: String) -> float:
	if element == "none" or element.is_empty():
		return 0.0
	return float(element_resists.get(element, 0.0))


func _normalize_element(school: String) -> String:
	var normalized := school.to_lower()
	match normalized:
		"", "none":
			return "none"
		"void":
			return "dark"
		_:
			return normalized


func _get_effective_status_resist(effect_type: String) -> float:
	var base_resist := clampf(float(status_resists.get(effect_type, 0.0)), 0.0, 0.95)
	if not super_armor_active or not super_armor_enabled:
		return base_resist
	var bonus := 0.0
	if effect_type in ["root", "stun", "freeze", "silence"]:
		bonus = 0.80 if enemy_grade == "elite" else 0.90
	else:
		bonus = 0.60 if enemy_grade == "elite" else 0.70
	return clampf(base_resist + bonus, 0.0, 0.95)


func _tick_status_timers(delta: float) -> void:
	for status_type in STATUS_KEYS:
		var next_time := maxf(float(status_timers.get(status_type, 0.0)) - delta, 0.0)
		status_timers[status_type] = next_time
		if next_time <= 0.0:
			status_values[status_type] = 0.0


func _tick_runtime_timers(delta: float) -> void:
	var behavior_tempo := get_behavior_tempo_multiplier()
	attack_cooldown = maxf(attack_cooldown - (delta * behavior_tempo), 0.0)
	rat_combo_timer = maxf(rat_combo_timer - (delta * behavior_tempo), 0.0)
	sword_retreat_timer = maxf(sword_retreat_timer - (delta * behavior_tempo), 0.0)
	slow_timer = maxf(slow_timer - delta, 0.0)
	vulnerability_timer = maxf(vulnerability_timer - delta, 0.0)
	hit_flash_timer = maxf(hit_flash_timer - delta, 0.0)
	if slow_timer <= 0.0:
		slow_multiplier = 1.0
	_tick_status_timers(delta)
	_refresh_super_armor_state()


func _is_rooted() -> bool:
	return float(status_timers.get("root", 0.0)) > 0.0


func get_behavior_tempo_multiplier() -> float:
	if slow_timer <= 0.0:
		return 1.0
	return clampf(slow_multiplier, 0.1, 1.0)


func get_behavior_delay_multiplier() -> float:
	return 1.0 / maxf(get_behavior_tempo_multiplier(), 0.1)


func _is_action_locked() -> bool:
	return (
		float(status_timers.get("stun", 0.0)) > 0.0
		or float(status_timers.get("freeze", 0.0)) > 0.0
	)


func _is_hard_cc_active() -> bool:
	return _is_action_locked()


func _refresh_super_armor_state() -> void:
	if vulnerability_timer > 0.0:
		super_armor_active = false
		return
	if enemy_grade == "boss" and super_armor_enabled:
		super_armor_active = true


func _break_super_armor() -> void:
	super_armor_active = false
	vulnerability_timer = super_armor_break_duration


func _refresh_visual_modulate() -> void:
	if enemy_grade == "elite" and enemy_type != "elite":
		visual_modulate = Color("#f1ccff")
	elif enemy_grade == "elite":
		visual_modulate = Color("#e7c4ff")
	elif enemy_grade == "boss":
		visual_modulate = Color("#ffe7c0")
	else:
		visual_modulate = Color(1, 1, 1, 1)


func _get_outgoing_attack_amount() -> int:
	if attack_damage_type == "magic" and magic_attack > 0:
		return magic_attack
	if physical_attack > 0:
		return physical_attack
	return contact_damage


func _get_outgoing_attack_school() -> String:
	return "" if attack_element == "none" else attack_element

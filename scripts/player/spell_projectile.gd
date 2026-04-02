extends Area2D

const WORLD_EFFECT_SPECS := {
	"dark_void_bolt_attack":
	{
		"dir_path": "res://assets/effects/dark_void_bolt_attack/",
		"frame_prefix": "dark_void_bolt_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#dfd4ff",
		"loop_animation": false
	},
	"dark_void_bolt_hit":
	{
		"dir_path": "res://assets/effects/dark_void_bolt_hit/",
		"frame_prefix": "dark_void_bolt_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#cfbeff",
		"loop_animation": false
	},
	"earth_tremor_attack":
	{
		"dir_path": "res://assets/effects/earth_tremor_attack/",
		"frame_prefix": "earth_tremor_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": true,
		"modulate_color": "#efe7d0",
		"loop_animation": false
	},
	"earth_tremor_hit":
	{
		"dir_path": "res://assets/effects/earth_tremor_hit/",
		"frame_prefix": "earth_tremor_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#e7dcc6",
		"loop_animation": false
	},
	"fire_bolt_attack":
	{
		"dir_path": "res://assets/effects/fire_bolt_attack/",
		"frame_prefix": "fire_bolt_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.72,
		"flip_by_velocity": true,
		"modulate_color": "#ffd39b",
		"loop_animation": false
	},
	"fire_bolt_hit":
	{
		"dir_path": "res://assets/effects/fire_bolt_hit/",
		"frame_prefix": "fire_bolt_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#ffb06f",
		"loop_animation": false
	},
	"holy_radiant_burst_attack":
	{
		"dir_path": "res://assets/effects/holy_radiant_burst_attack/",
		"frame_prefix": "holy_radiant_burst_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#fff2bb",
		"loop_animation": false
	},
	"holy_radiant_burst_hit":
	{
		"dir_path": "res://assets/effects/holy_radiant_burst_hit/",
		"frame_prefix": "holy_radiant_burst_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.82,
		"flip_by_velocity": false,
		"modulate_color": "#fff8d6",
		"loop_animation": false
	},
	"water_aqua_bullet_attack":
	{
		"dir_path": "res://assets/effects/water_aqua_bullet_attack/",
		"frame_prefix": "water_aqua_bullet_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.80,
		"flip_by_velocity": true,
		"modulate_color": "#d9f7ff",
		"loop_animation": false
	},
	"water_aqua_bullet_hit":
	{
		"dir_path": "res://assets/effects/water_aqua_bullet_hit/",
		"frame_prefix": "water_aqua_bullet_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#bdefff",
		"loop_animation": false
	},
	"wind_gale_cutter_attack":
	{
		"dir_path": "res://assets/effects/wind_gale_cutter_attack/",
		"frame_prefix": "wind_gale_cutter_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.84,
		"flip_by_velocity": true,
		"modulate_color": "#e5fff5",
		"loop_animation": false
	},
	"wind_gale_cutter_hit":
	{
		"dir_path": "res://assets/effects/wind_gale_cutter_hit/",
		"frame_prefix": "wind_gale_cutter_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": false,
		"modulate_color": "#d5fff0",
		"loop_animation": false
	},
	"volt_spear_attack":
	{
		"dir_path": "res://assets/effects/volt_spear_attack/",
		"frame_prefix": "volt_spear_attack",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 0.78,
		"flip_by_velocity": true,
		"modulate_color": "#dff8ff",
		"loop_animation": false
	},
	"volt_spear_hit":
	{
		"dir_path": "res://assets/effects/volt_spear_hit/",
		"frame_prefix": "volt_spear_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#b7f6ff",
		"loop_animation": false
	}
}

var velocity := Vector2.ZERO
var remaining_range := 0.0
var team := "player"
var damage := 0
var knockback := 0.0
var school := "fire"
var hit_targets: Dictionary = {}
var duration := 3.0
var pierce := 0
var radius := 10.0
var owner_ref: Node = null
var spell_id := ""
var utility_effects: Array = []
var is_marker := false
var horizontal_drag_per_second := 0.0
var min_horizontal_speed := 0.0
var gravity_per_second := 0.0
var attack_effect_id := ""
var hit_effect_id := ""
var terminal_effect_id := ""
var terminal_effect_played := false
var hitstop_mode := "default"
var tick_interval := 0.0
var tick_timer := 0.0
var max_targets_per_tick := 0
var tracked_bodies: Dictionary = {}


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	velocity = config.get("velocity", Vector2.ZERO)
	remaining_range = float(config.get("range", 100.0))
	team = str(config.get("team", "player"))
	damage = int(config.get("damage", 10))
	knockback = float(config.get("knockback", 100.0))
	school = str(config.get("school", "fire"))
	duration = float(config.get("duration", 3.0))
	pierce = int(config.get("pierce", 0))
	radius = float(config.get("size", 10.0))
	owner_ref = config.get("owner", null)
	spell_id = str(config.get("spell_id", ""))
	utility_effects = config.get("utility_effects", []).duplicate(true)
	is_marker = bool(config.get("marker", false))
	horizontal_drag_per_second = float(config.get("horizontal_drag_per_second", 0.0))
	min_horizontal_speed = float(config.get("min_horizontal_speed", 0.0))
	gravity_per_second = float(config.get("gravity_per_second", 0.0))
	attack_effect_id = str(config.get("attack_effect_id", ""))
	hit_effect_id = str(config.get("hit_effect_id", ""))
	terminal_effect_id = str(config.get("terminal_effect_id", ""))
	hitstop_mode = str(config.get("hitstop_mode", "default"))
	tick_interval = maxf(float(config.get("tick_interval", 0.0)), 0.0)
	tick_timer = 0.0
	max_targets_per_tick = int(config.get("target_count", 0))
	_build_visual(Color(config.get("color", "#ffffff")))


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var shape: CollisionShape2D
	if not has_node("CollisionShape2D"):
		shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		add_child(shape)
		shape.shape = CircleShape2D.new()
	else:
		shape = get_node("CollisionShape2D")
	shape.shape.radius = radius
	_play_attack_effect()


func _physics_process(delta: float) -> void:
	if terminal_effect_played:
		return
	_tick_hit_windows(delta)
	_tick_persistent_hits(delta)
	_apply_runtime_motion(delta)
	position += velocity * delta
	remaining_range -= velocity.length() * delta
	duration -= delta
	if remaining_range <= 0.0 or duration <= 0.0:
		_finish_projectile()


func _apply_runtime_motion(delta: float) -> void:
	if gravity_per_second != 0.0:
		velocity.y += gravity_per_second * delta
	if horizontal_drag_per_second > 0.0 and velocity.x != 0.0:
		var target_speed := 0.0
		if min_horizontal_speed > 0.0:
			target_speed = sign(velocity.x) * min_horizontal_speed
		velocity.x = move_toward(velocity.x, target_speed, horizontal_drag_per_second * delta)


func _on_body_entered(body: Node) -> void:
	if body == owner_ref:
		return
	tracked_bodies[body.get_instance_id()] = body
	if team == "player" and body.is_in_group("enemy"):
		_hit_enemy(body, not _is_persistent_area_effect())
	elif team == "enemy" and body.is_in_group("player"):
		_hit_player(body, not _is_persistent_area_effect())


func _on_body_exited(body: Node) -> void:
	tracked_bodies.erase(body.get_instance_id())


func _hit_enemy(body: Node, finish_on_hit: bool = true) -> bool:
	var body_id := body.get_instance_id()
	if not _can_hit_body(body_id):
		return false
	_register_body_hit(body_id)
	_spawn_hit_effect(global_position)
	var actual_damage := damage
	if body.has_method("receive_hit"):
		var hit_result = body.receive_hit(damage, global_position, knockback, school, utility_effects)
		if typeof(hit_result) == TYPE_INT:
			actual_damage = int(hit_result)
		if team == "player" and spell_id != "":
			GameState.register_skill_damage(spell_id, actual_damage)
		if team == "player":
			var hitstop_duration := _get_hitstop_duration(actual_damage)
			if hitstop_duration > 0.0:
				_trigger_hitstop(hitstop_duration)
	if not finish_on_hit:
		return true
	if pierce > 0:
		pierce -= 1
		_queue_pierce_resume()
	else:
		_finish_projectile()
	return true


func _hit_player(body: Node, finish_on_hit: bool = true) -> bool:
	var body_id := body.get_instance_id()
	if not _can_hit_body(body_id):
		return false
	_register_body_hit(body_id)
	if body.has_method("receive_hit"):
		body.receive_hit(damage, global_position, knockback, school, utility_effects)
	if finish_on_hit:
		_finish_projectile()
	return true


func _queue_pierce_resume() -> void:
	if not is_inside_tree():
		return
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if velocity.length() > 0.0:
		global_position += velocity.normalized() * max(radius * 1.5, 18.0)
	call_deferred("_resume_after_pierce")


func _resume_after_pierce() -> void:
	if not is_inside_tree():
		return
	await get_tree().physics_frame
	if not is_inside_tree():
		return
	monitoring = true
	monitorable = true


func _tick_persistent_hits(delta: float) -> void:
	if not _is_persistent_area_effect():
		return
	tick_timer = maxf(tick_timer - delta, 0.0)
	if tick_timer > 0.0:
		return
	tick_timer = tick_interval
	var hit_count := 0
	for body_id in tracked_bodies.keys():
		var body = tracked_bodies.get(body_id, null)
		if not is_instance_valid(body):
			tracked_bodies.erase(body_id)
			continue
		if body == owner_ref:
			continue
		var hit_applied := false
		if team == "player" and body.is_in_group("enemy"):
			hit_applied = _hit_enemy(body, false)
		elif team == "enemy" and body.is_in_group("player"):
			hit_applied = _hit_player(body, false)
		if hit_applied:
			hit_count += 1
			if max_targets_per_tick > 0 and hit_count >= max_targets_per_tick:
				break


func _tick_hit_windows(delta: float) -> void:
	if not _is_persistent_area_effect():
		return
	for body_id in hit_targets.keys():
		var remaining := maxf(float(hit_targets.get(body_id, 0.0)) - delta, 0.0)
		if remaining <= 0.0:
			hit_targets.erase(body_id)
		else:
			hit_targets[body_id] = remaining


func _can_hit_body(body_id: int) -> bool:
	if not _is_persistent_area_effect():
		return not hit_targets.get(body_id, false)
	return float(hit_targets.get(body_id, 0.0)) <= 0.0


func _register_body_hit(body_id: int) -> void:
	if _is_persistent_area_effect():
		hit_targets[body_id] = maxf(tick_interval, 0.01)
		return
	hit_targets[body_id] = true


func _is_persistent_area_effect() -> bool:
	return tick_interval > 0.0


func _finish_projectile() -> void:
	if _play_terminal_effect():
		return
	queue_free()


func _play_terminal_effect() -> bool:
	if terminal_effect_played or terminal_effect_id.is_empty():
		return false
	var sprite := _build_terminal_effect_visual()
	if sprite == null:
		return false
	terminal_effect_played = true
	velocity = Vector2.ZERO
	monitoring = false
	monitorable = false
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.disabled = true
	var visual_children: Array[Node] = []
	for child in get_children():
		if child == collision_shape:
			continue
		visual_children.append(child)
	for child in visual_children:
		remove_child(child)
		if child.is_inside_tree():
			child.queue_free()
		else:
			child.free()
	add_child(sprite)
	sprite.play("fly")
	sprite.animation_finished.connect(
		func() -> void:
			if is_instance_valid(self):
				queue_free(),
		CONNECT_ONE_SHOT
	)
	set_physics_process(false)
	return true


func _trigger_hitstop(duration: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	Engine.time_scale = 0.05
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.ignore_time_scale = true
	tree.root.add_child(timer)
	timer.timeout.connect(
		func() -> void:
			Engine.time_scale = 1.0
			if is_instance_valid(timer):
				timer.queue_free(),
		CONNECT_ONE_SHOT
	)
	timer.start()


func _get_hitstop_duration(actual_damage: int) -> float:
	if _is_persistent_area_effect():
		return 0.0
	match hitstop_mode:
		"none":
			return 0.0
		"area_burst":
			return clampf(0.02 + float(actual_damage) * 0.001, 0.02, 0.06)
		_:
			return clampf(0.03 + float(actual_damage) * 0.002, 0.03, 0.12)


func _play_attack_effect() -> void:
	if attack_effect_id.is_empty():
		return
	var effect_position := _get_attack_effect_position()
	_spawn_world_effect(attack_effect_id, effect_position, "attack")


func _spawn_hit_effect(world_position: Vector2) -> void:
	if hit_effect_id.is_empty():
		return
	_spawn_world_effect(hit_effect_id, world_position, "hit")


func _spawn_world_effect(effect_id: String, world_position: Vector2, effect_stage: String) -> void:
	var sprite := _create_world_effect_visual(effect_id)
	if sprite == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	sprite.name = "%s_sprite" % effect_id
	sprite.set_meta("effect_id", effect_id)
	sprite.set_meta("effect_stage", effect_stage)
	parent.add_child(sprite)
	sprite.global_position = world_position
	sprite.play("fly")
	sprite.animation_finished.connect(
		func() -> void:
			if is_instance_valid(sprite):
				sprite.queue_free(),
		CONNECT_ONE_SHOT
	)


func _get_attack_effect_position() -> Vector2:
	var travel_dir := _get_visual_facing_sign()
	return global_position + Vector2(-18.0 * travel_dir, -6.0)


func _get_visual_facing_sign() -> float:
	if velocity.x != 0.0:
		return sign(velocity.x)
	if owner_ref != null:
		return float(owner_ref.get("facing"))
	return 1.0


func has_world_effect_spec(effect_id: String) -> bool:
	return WORLD_EFFECT_SPECS.has(effect_id)


func get_world_effect_ids() -> Array[String]:
	var effect_ids: Array[String] = []
	for effect_id in WORLD_EFFECT_SPECS.keys():
		effect_ids.append(str(effect_id))
	effect_ids.sort()
	return effect_ids


func _create_world_effect_visual(effect_id: String) -> AnimatedSprite2D:
	var spec: Dictionary = WORLD_EFFECT_SPECS.get(effect_id, {})
	if spec.is_empty():
		return null
	return _create_sampled_effect_sprite(
		str(spec.get("dir_path", "")),
		str(spec.get("frame_prefix", "")),
		int(spec.get("frame_count", 0)),
		float(spec.get("fps", 18.0)),
		float(spec.get("scale", 1.0)),
		bool(spec.get("flip_by_velocity", true)),
		Color(str(spec.get("modulate_color", "#ffffff"))),
		bool(spec.get("loop_animation", false))
	)


func _build_visual(color: Color) -> void:
	if spell_id == "fire_bolt":
		if _build_fire_bolt_visual():
			return
	elif spell_id == "volt_spear":
		if _build_volt_spear_visual():
			return
	elif spell_id == "frost_nova":
		if _build_frost_nova_visual():
			return
	var polygon := Polygon2D.new()
	polygon.color = color
	if is_marker:
		# Flat ground-level diamond: wide horizontal, shallow vertical
		polygon.polygon = PackedVector2Array(
			[
				Vector2(-radius, 0.0),
				Vector2(-radius * 0.4, -radius * 0.25),
				Vector2(radius, 0.0),
				Vector2(-radius * 0.4, radius * 0.25)
			]
		)
		polygon.modulate.a = 0.65
	else:
		polygon.polygon = _build_school_polygon(school, radius)
	add_child(polygon)


func _build_school_polygon(p_school: String, r: float) -> PackedVector2Array:
	match p_school:
		"dark":
			# Inverted broad crescent-like pentagon — wide, menacing
			return PackedVector2Array(
				[
					Vector2(-r * 0.5, -r * 0.9),
					Vector2(r, 0.0),
					Vector2(-r * 0.5, r * 0.9),
					Vector2(-r * 1.1, r * 0.4),
					Vector2(-r * 1.1, -r * 0.4)
				]
			)
		"arcane":
			# Diamond (rotated square) — classic magic orb silhouette
			return PackedVector2Array(
				[Vector2(0.0, -r), Vector2(r * 0.7, 0.0), Vector2(0.0, r), Vector2(-r * 0.7, 0.0)]
			)
		"water":
			# Teardrop: wide front, narrow tail
			return PackedVector2Array(
				[
					Vector2(-r * 0.6, -r * 0.5),
					Vector2(r * 0.9, -r * 0.2),
					Vector2(r, 0.0),
					Vector2(r * 0.9, r * 0.2),
					Vector2(-r * 0.6, r * 0.5),
					Vector2(-r, 0.0)
				]
			)
		"wind":
			# Long thin slash — extreme horizontal blade
			return PackedVector2Array(
				[
					Vector2(-r * 1.4, -r * 0.2),
					Vector2(r * 0.6, -r * 0.5),
					Vector2(r * 1.0, 0.0),
					Vector2(r * 0.6, r * 0.5),
					Vector2(-r * 1.4, r * 0.2)
				]
			)
		"earth":
			# Chunky rectangle — heavy stone slab
			return PackedVector2Array(
				[
					Vector2(-r * 0.8, -r * 0.7),
					Vector2(r * 0.8, -r * 0.7),
					Vector2(r * 0.8, r * 0.7),
					Vector2(-r * 0.8, r * 0.7)
				]
			)
		"holy":
			# Wide cross-beam: broad forward, thin vertical
			return PackedVector2Array(
				[
					Vector2(-r * 0.3, -r * 0.3),
					Vector2(r * 0.8, -r * 0.3),
					Vector2(r * 0.8, r * 0.3),
					Vector2(-r * 0.3, r * 0.3)
				]
			)
		"ice":
			# Hexagon (snowflake base)
			return PackedVector2Array(
				[
					Vector2(0.0, -r),
					Vector2(r * 0.87, -r * 0.5),
					Vector2(r * 0.87, r * 0.5),
					Vector2(0.0, r),
					Vector2(-r * 0.87, r * 0.5),
					Vector2(-r * 0.87, -r * 0.5)
				]
			)
		"lightning":
			# Jagged bolt: forward-pointing zigzag
			return PackedVector2Array(
				[
					Vector2(-r * 0.2, -r * 0.8),
					Vector2(r * 0.5, -r * 0.1),
					Vector2(r, 0.0),
					Vector2(r * 0.5, r * 0.1),
					Vector2(-r * 0.2, r * 0.8),
					Vector2(-r * 0.6, r * 0.2),
					Vector2(-r * 0.6, -r * 0.2)
				]
			)
		_:
			# Default: forward-pointing triangle
			return PackedVector2Array(
				[Vector2(-r, -r * 0.6), Vector2(r, 0.0), Vector2(-r, r * 0.6)]
			)


func _build_sampled_effect_visual(
	dir_path: String,
	frame_prefix: String,
	frame_count: int,
	fps: float,
	scale_value: float,
	flip_by_velocity: bool = true,
	modulate_color: Color = Color.WHITE,
	loop_animation: bool = true
) -> bool:
	var sprite := _create_sampled_effect_sprite(
		dir_path,
		frame_prefix,
		frame_count,
		fps,
		scale_value,
		flip_by_velocity,
		modulate_color,
		loop_animation
	)
	if sprite == null:
		return false
	add_child(sprite)
	sprite.play("fly")
	return true


func _create_sampled_effect_sprite(
	dir_path: String,
	frame_prefix: String,
	frame_count: int,
	fps: float,
	scale_value: float,
	flip_by_velocity: bool = true,
	modulate_color: Color = Color.WHITE,
	loop_animation: bool = true
) -> AnimatedSprite2D:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("fly")
	frames.set_animation_loop("fly", loop_animation)
	frames.set_animation_speed("fly", fps)
	for i in range(frame_count):
		var tex := _load_texture_2d("%s%s_%d.png" % [dir_path, frame_prefix, i])
		if tex != null:
			frames.add_frame("fly", tex)
	if frames.get_frame_count("fly") == 0:
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var scale_x := scale_value
	if flip_by_velocity and _get_visual_facing_sign() < 0.0:
		scale_x *= -1.0
	sprite.scale = Vector2(scale_x, scale_value)
	sprite.modulate = modulate_color
	sprite.animation = "fly"
	return sprite


func _load_texture_2d(texture_path: String) -> Texture2D:
	var local_path := ProjectSettings.globalize_path(texture_path)
	if FileAccess.file_exists(local_path):
		var image := Image.load_from_file(local_path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	var texture: Texture2D = ResourceLoader.load(texture_path, "Texture2D")
	if texture != null:
		return texture
	var image := Image.load_from_file(local_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)


func _build_terminal_effect_visual() -> AnimatedSprite2D:
	match terminal_effect_id:
		"bomber_burst":
			return _create_sampled_effect_sprite(
				"res://assets/effects/bomber_burst/",
				"bomber_burst",
				6,
				18.0,
				0.92,
				false,
				Color("#ffca86"),
				false
			)
		_:
			return null


# SPRITE DIRECTION: native facing = RIGHT (content sits at x=15-61 in 100px canvas)
# scale.x = +0.5 → right,  scale.x = -0.5 → left (mirrored)
func _build_fire_bolt_visual() -> bool:
	return _build_sampled_effect_visual(
		"res://assets/effects/fire_bolt/", "fire_bolt", 15, 12.0, 0.5
	)


func _build_volt_spear_visual() -> bool:
	return _build_sampled_effect_visual(
		"res://assets/effects/volt_spear/", "volt_spear", 15, 26.0, 0.46
	)


func _build_frost_nova_visual() -> bool:
	return _build_sampled_effect_visual(
		"res://assets/effects/frost_nova/",
		"frost_nova",
		8,
		40.0,
		0.82,
		false,
		Color("#8cecff"),
		false
	)

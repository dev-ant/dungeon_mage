extends Area2D

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
	_build_visual(Color(config.get("color", "#ffffff")))

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var shape: CollisionShape2D
	if not has_node("CollisionShape2D"):
		shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		add_child(shape)
		shape.shape = CircleShape2D.new()
	else:
		shape = get_node("CollisionShape2D")
	shape.shape.radius = radius

func _physics_process(delta: float) -> void:
	position += velocity * delta
	remaining_range -= velocity.length() * delta
	duration -= delta
	if remaining_range <= 0.0 or duration <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == owner_ref:
		return
	if team == "player" and body.is_in_group("enemy"):
		_hit_enemy(body)
	elif team == "enemy" and body.is_in_group("player"):
		if body.has_method("receive_hit"):
			body.receive_hit(damage, global_position, knockback, school, utility_effects)
			queue_free()

func _hit_enemy(body: Node) -> void:
	if hit_targets.get(body, false):
		return
	hit_targets[body] = true
	if body.has_method("receive_hit"):
		body.receive_hit(damage, global_position, knockback, school, utility_effects)
		if team == "player" and spell_id != "":
			GameState.register_skill_damage(spell_id, damage)
		if team == "player":
			_trigger_hitstop(clampf(0.03 + float(damage) * 0.002, 0.03, 0.12))
	if pierce > 0:
		pierce -= 1
	else:
		queue_free()

func _trigger_hitstop(duration: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	Engine.time_scale = 0.05
	var timer := tree.create_timer(duration, true, false, true)
	timer.timeout.connect(func() -> void: Engine.time_scale = 1.0)

func _build_visual(color: Color) -> void:
	var polygon := Polygon2D.new()
	polygon.color = color
	if is_marker:
		# Flat ground-level diamond: wide horizontal, shallow vertical
		polygon.polygon = PackedVector2Array([
			Vector2(-radius, 0.0),
			Vector2(-radius * 0.4, -radius * 0.25),
			Vector2(radius, 0.0),
			Vector2(-radius * 0.4, radius * 0.25)
		])
		polygon.modulate.a = 0.65
	else:
		polygon.polygon = PackedVector2Array([
			Vector2(-radius, -radius * 0.6),
			Vector2(radius, 0.0),
			Vector2(-radius, radius * 0.6)
		])
	add_child(polygon)

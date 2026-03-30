extends Node2D

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const PROJECTILE_SCRIPT := preload("res://scripts/player/spell_projectile.gd")
const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")
const ENEMY_SCENE := preload("res://scenes/enemies/EnemyBase.tscn")
const REST_SCRIPT := preload("res://scripts/world/rest_point.gd")
const ECHO_SCRIPT := preload("res://scripts/world/echo_marker.gd")
const CORE_SCRIPT := preload("res://scripts/world/core_device.gd")
const ROPE_SCRIPT := preload("res://scripts/world/rope.gd")
const ADMIN_MENU_SCRIPT := preload("res://scripts/admin/admin_menu.gd")
const DAMAGE_LABEL_SCRIPT := preload("res://scripts/ui/damage_label.gd")

var room_order := ["entrance", "conduit", "deep_gate"]
var room_index := 0
var current_room: Dictionary = {}
var room_builder := preload("res://scripts/world/room_builder.gd").new()
var transitioning := false

@onready var room_layer: Node2D = $RoomLayer
@onready var object_layer: Node2D = $ObjectLayer
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var event_camera = $EventPhantomCamera2D
@onready var ui: Control = $CanvasLayer/GameUI
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var admin_menu: Control = null
var damage_layer: Node2D = null

func _ready() -> void:
	GameState.ensure_input_map()
	damage_layer = Node2D.new()
	damage_layer.name = "DamageLayer"
	add_child(damage_layer)
	_spawn_admin_menu()
	player.cast_spell.connect(_spawn_projectile)
	player.request_room_shift.connect(_attempt_room_shift)
	GameState.player_died.connect(_on_player_died)
	GameState.combo_effect_requested.connect(_on_combo_effect_requested)
	_load_room(GameState.current_room_id, GameState.save_spawn_position)

func _load_room(room_id: String, spawn_position: Vector2 = Vector2(-1, -1)) -> void:
	current_room = GameDatabase.get_room(room_id)
	if current_room.is_empty():
		return
	room_index = room_order.find(room_id)
	if room_index == -1:
		room_index = 0
	var variant := GameState.get_room_variant(room_id) if room_id != "entrance" else {"tint": Color("#ffffff"), "extra_spawns": [], "label": ""}
	room_builder.build(room_layer, current_room, variant)
	_clear_layer(object_layer)
	_clear_layer(enemy_layer)
	_clear_layer(projectile_layer)
	_spawn_objects(current_room)
	_spawn_enemies(current_room.get("spawns", []) + variant.get("extra_spawns", []))
	player.reset_at(spawn_position if spawn_position.x >= 0 else Vector2(current_room["spawn"][0], current_room["spawn"][1]))
	camera.limit_right = int(current_room.get("width", 1600))
	camera.limit_left = 0
	GameState.set_room(room_id)
	ui.set_room_title("%s  [%s]" % [current_room.get("title", room_id), variant.get("label", "")])
	if not GameState.has_seen_room_text(room_id):
		GameState.push_message(current_room.get("entry_text", ""), 3.5)
		GameState.mark_room_text_seen(room_id)

func _spawn_objects(room_data: Dictionary) -> void:
	var index := 0
	for object_data in room_data.get("objects", []):
		var node: Area2D = null
		match object_data.get("type", ""):
			"rest":
				node = REST_SCRIPT.new()
				node.setup({"position": Vector2(object_data["position"][0], object_data["position"][1]), "text": object_data.get("text", "")})
			"echo":
				node = ECHO_SCRIPT.new()
				node.setup({"position": Vector2(object_data["position"][0], object_data["position"][1]), "text": object_data.get("text", "")}, room_data["id"], index)
			"rope":
				node = ROPE_SCRIPT.new()
				node.setup({"position": Vector2(object_data["position"][0], object_data["position"][1]), "height": object_data.get("height", 200.0)})
		if node:
			object_layer.add_child(node)
		index += 1
	if room_data["id"] == "conduit":
		var core := CORE_SCRIPT.new()
		core.setup(Vector2(room_data["core_position"][0], room_data["core_position"][1]))
		core.activated.connect(_on_core_activated)
		object_layer.add_child(core)

func _spawn_enemies(spawn_list: Array) -> void:
	for spawn_data in spawn_list:
		if spawn_data.get("type") == "boss" and GameState.boss_defeated:
			continue
		_spawn_enemy(spawn_data["type"], Vector2(spawn_data["position"][0], spawn_data["position"][1]))

func _spawn_enemy(enemy_type: String, spawn_position: Vector2) -> void:
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate()
	enemy.configure({"type": enemy_type, "position": spawn_position}, player)
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.fire_projectile.connect(_spawn_projectile)
	enemy.damage_label_requested.connect(_spawn_damage_label)
	enemy_layer.add_child(enemy)

func _spawn_projectile(payload: Dictionary) -> void:
	var projectile := PROJECTILE_SCRIPT.new()
	projectile.setup(payload)
	projectile_layer.add_child(projectile)

func _attempt_room_shift(direction: int) -> void:
	if transitioning:
		return
	if direction > 0:
		if current_room["id"] == "entrance":
			if enemy_layer.get_child_count() == 0:
				_transition_to(room_order[min(room_index + 1, room_order.size() - 1)], Vector2(120, 480))
			else:
				GameState.push_message("The corridor ahead stays sealed until the room falls quiet.", 1.6)
		elif current_room["id"] == "conduit":
			if GameState.core_activated:
				_transition_to("deep_gate", Vector2(180, 520))
			else:
				GameState.push_message("A vertical current spins overhead, but the chamber still wants the floor core engaged.", 2.0)
	elif direction < 0 and room_index > 0:
		var previous: String = room_order[room_index - 1]
		_transition_to(previous, Vector2(GameDatabase.get_room(previous).get("width", 1600) - 120, 480))

func _transition_to(room_id: String, spawn_position: Vector2) -> void:
	transitioning = true
	GameState.push_message("The path folds, pretending to rise while the pressure sinks deeper.", 2.2)
	await get_tree().create_timer(0.35).timeout
	_load_room(room_id, spawn_position)
	transitioning = false

func _on_enemy_died(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	GameState.notify_enemy_killed()
	GameState.notify_deploy_kill()
	var enemy_data: Dictionary = GameDatabase.get_enemy_data(enemy.enemy_type)
	var drop_profile: String = str(enemy_data.get("drop_profile", "none"))
	var dropped_item: String = GameDatabase.get_drop_for_profile(drop_profile)
	if dropped_item != "":
		GameState.grant_equipment_item(dropped_item)
		GameState.record_item_drop(dropped_item)
		var item_data: Dictionary = GameDatabase.get_equipment(dropped_item)
		GameState.push_message("Item drop: %s" % str(item_data.get("display_name", dropped_item)), 2.5)
	if enemy.enemy_type == "boss":
		GameState.boss_defeated = true
		GameState.grant_progression_event("boss_conduit")
		GameState.save_to_disk()
		_focus_event(enemy.global_position + Vector2(0, -32), 1.1)
		GameState.push_message("The conduit guardian falls. The floor core is exposed.", 2.8)
	if enemy_layer.get_child_count() <= 1 and current_room["id"] == "entrance":
		GameState.push_message("The east corridor opens. The maze rewards momentum.", 2.0)

func _on_core_activated() -> void:
	_focus_event(Vector2(current_room["core_position"][0], current_room["core_position"][1]) + Vector2(0, -24), 1.0)
	await get_tree().create_timer(1.1).timeout
	_transition_to("deep_gate", Vector2(180, 520))

func _on_player_died() -> void:
	await _fade_screen(0.0, 1.0, 0.6)
	await get_tree().create_timer(0.3).timeout
	var restore := GameState.restore_after_death()
	_load_room(restore["room_id"], restore["spawn_position"])
	await _fade_screen(1.0, 0.0, 0.5)

func _fade_screen(from_alpha: float, to_alpha: float, duration: float) -> void:
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, from_alpha)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(fade_rect)
	var elapsed := 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		fade_rect.color.a = lerpf(from_alpha, to_alpha, elapsed / duration)
		await get_tree().process_frame
	fade_rect.color.a = to_alpha
	if to_alpha <= 0.0:
		fade_rect.queue_free()

func _clear_layer(layer: Node) -> void:
	for child in layer.get_children():
		child.queue_free()

func _focus_event(world_position: Vector2, duration: float) -> void:
	event_camera.global_position = world_position
	event_camera.priority = 40
	event_camera.zoom = Vector2(0.9, 0.9)
	await get_tree().create_timer(duration).timeout
	event_camera.priority = 0

func _on_combo_effect_requested(payload: Dictionary) -> void:
	if payload.is_empty():
		return
	var effect_id := str(payload.get("effect_id", "combo_effect"))
	var burst_payload := {
		"spell_id": effect_id,
		"position": player.global_position + Vector2(0, -8),
		"velocity": Vector2.ZERO,
		"range": 1.0,
		"team": "player",
		"damage": int(payload.get("damage", 20)),
		"knockback": 160.0,
		"school": str(payload.get("school", "fire")),
		"size": float(payload.get("radius", 56.0)),
		"duration": 0.16,
		"color": str(payload.get("color", "#ff8f45")),
		"owner": player
	}
	_spawn_projectile(burst_payload)
	if effect_id == "ash_detonation":
		_focus_event(player.global_position + Vector2(0, -8), 0.35)

func _spawn_damage_label(amount: int, position: Vector2, school: String) -> void:
	var label := DAMAGE_LABEL_SCRIPT.new()
	damage_layer.add_child(label)
	label.setup(amount, position, school)

func _spawn_admin_menu() -> void:
	admin_menu = ADMIN_MENU_SCRIPT.new()
	canvas_layer.add_child(admin_menu)
	admin_menu.spawn_enemy_requested.connect(_on_admin_spawn_enemy_requested)
	admin_menu.reset_cooldowns_requested.connect(_on_admin_reset_cooldowns_requested)
	admin_menu.heal_requested.connect(_on_admin_heal_requested)
	admin_menu.clear_enemies_requested.connect(_on_admin_clear_enemies_requested)
	admin_menu.freeze_ai_toggled.connect(_on_admin_freeze_ai_toggled)

func _on_admin_spawn_enemy_requested(enemy_type: String) -> void:
	var spawn_position := player.global_position + Vector2(260, 0)
	if enemy_type == "boss":
		spawn_position = player.global_position + Vector2(340, -20)
	elif enemy_type == "dummy":
		spawn_position = player.global_position + Vector2(220, 0)
	elif enemy_type == "dasher":
		spawn_position = player.global_position + Vector2(320, 0)
	elif enemy_type == "sentinel":
		spawn_position = player.global_position + Vector2(400, 0)
	_spawn_enemy(enemy_type, spawn_position)
	if enemy_type == "boss":
		_focus_event(spawn_position + Vector2(0, -24), 0.45)

func _on_admin_reset_cooldowns_requested() -> void:
	if player.has_method("debug_reset_spell_cooldowns"):
		player.debug_reset_spell_cooldowns()
	GameState.stats_changed.emit()

func _on_admin_heal_requested() -> void:
	GameState.heal_full()

func _on_admin_clear_enemies_requested() -> void:
	_clear_layer(enemy_layer)
	GameState.admin_freeze_ai = false

func _on_admin_freeze_ai_toggled(frozen: bool) -> void:
	if frozen:
		enemy_layer.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		enemy_layer.process_mode = Node.PROCESS_MODE_INHERIT

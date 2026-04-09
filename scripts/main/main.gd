extends Node2D

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const PROJECTILE_SCRIPT := preload("res://scripts/player/spell_projectile.gd")
const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")
const ENEMY_SCENE := preload("res://scenes/enemies/EnemyBase.tscn")
const REST_SCRIPT := preload("res://scripts/world/rest_point.gd")
const ECHO_SCRIPT := preload("res://scripts/world/echo_marker.gd")
const CORE_SCRIPT := preload("res://scripts/world/core_device.gd")
const ROPE_SCRIPT := preload("res://scripts/world/rope.gd")
const SEAL_STATUE_SCRIPT := preload("res://scripts/world/seal_statue.gd")
const MEMORY_PLINTH_SCRIPT := preload("res://scripts/world/memory_plinth.gd")
const COVENANT_ALTAR_SCRIPT := preload("res://scripts/world/covenant_altar.gd")
const REFUGE_NOTICE_SCRIPT := preload("res://scripts/world/refuge_notice.gd")
const ADMIN_MENU_SCRIPT := preload("res://scripts/admin/admin_menu.gd")
const DAMAGE_LABEL_SCRIPT := preload("res://scripts/ui/damage_label.gd")
const ELITE_VARIANT_CHANCE := 0.03
const ELITE_VARIANT_TYPES := ["brute", "sentinel", "mushroom", "charger", "worm", "trash_monster"]
const LEGACY_ROOM_ORDER: Array[String] = ["entrance", "conduit", "deep_gate"]
const COMBO_EFFECT_EVENT_FOCUS_DURATION := 0.35
const COMBO_EFFECT_MIN_DURATION := COMBO_EFFECT_EVENT_FOCUS_DURATION
const SOUL_RISK_RELEASE_BEAT_DURATION := 0.22
const SOUL_RISK_RELEASE_OVERLAY_START := Color(0.64, 0.76, 1.0, 0.14)
const SOUL_RISK_RELEASE_OVERLAY_END := Color(0.44, 0.58, 0.94, 0.0)
const SOUL_RISK_CAMERA_ACTIVE_ZOOM_FACTOR := 0.985
const SOUL_RISK_CAMERA_AFTERSHOCK_START_FACTOR := 0.989
const SOUL_RISK_CAMERA_AFTERSHOCK_END_FACTOR := 0.996
const SOUL_RISK_CAMERA_CLEAR_ZOOM_FACTOR := 1.006

var room_order: Array[String] = []
var room_index := 0
var current_room: Dictionary = {}
var room_builder := preload("res://scripts/world/room_builder.gd").new()
var transitioning := false
var _soul_risk_release_overlay: ColorRect = null
var _brightness_overlay: ColorRect = null
var _soul_risk_release_timer := 0.0
var _last_soul_risk_state := "none"
var _default_camera_zoom := Vector2.ONE

@onready var room_layer: Node2D = $RoomLayer
@onready var object_layer: Node2D = $ObjectLayer
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var event_camera = $EventPhantomCamera2D
@onready var ui: Control = $CanvasLayer/GameUI
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var window_layer: Control = $CanvasLayer/WindowLayer
@onready var modal_layer: Control = $CanvasLayer/ModalLayer
@onready var tooltip_layer: Control = $CanvasLayer/TooltipLayer
@onready var window_manager: Control = $CanvasLayer/WindowLayer/WindowManager

var admin_menu: Control = null
var damage_layer: Node2D = null


func _ready() -> void:
	GameState.ensure_input_map()
	room_order = _resolve_room_order(GameState.current_room_id)
	damage_layer = Node2D.new()
	damage_layer.name = "DamageLayer"
	add_child(damage_layer)
	_build_soul_risk_release_overlay()
	_build_brightness_overlay()
	if UiState != null:
		UiState.brightness_changed.connect(_on_brightness_changed)
		UiState.special_effects_enabled_changed.connect(_on_special_effects_setting_changed)
	_spawn_admin_menu()
	player.cast_spell.connect(_spawn_projectile)
	player.request_room_shift.connect(_attempt_room_shift)
	GameState.player_died.connect(_on_player_died)
	GameState.combo_effect_requested.connect(_on_combo_effect_requested)
	GameState.progression_event_granted.connect(_on_progression_event_granted)
	_load_room(GameState.current_room_id, GameState.save_spawn_position)
	_default_camera_zoom = camera.zoom


func _process(delta: float) -> void:
	_sync_soul_risk_release_feedback_state()
	if _get_current_soul_risk_state() == "none" and _soul_risk_release_timer > 0.0:
		_soul_risk_release_timer = maxf(_soul_risk_release_timer - delta, 0.0)
	_refresh_soul_risk_release_overlay()
	_refresh_soul_risk_camera_feedback()


func _load_room(room_id: String, spawn_position: Vector2 = Vector2(-1, -1)) -> void:
	current_room = GameDatabase.get_room(room_id)
	if current_room.is_empty():
		return
	if not room_order.has(room_id):
		room_order = _resolve_room_order(room_id)
	room_index = room_order.find(room_id)
	if room_index == -1:
		room_index = 0
	var variant := (
		GameState.get_room_variant(room_id)
		if room_id != "entrance"
		else {"tint": Color("#ffffff"), "extra_spawns": [], "label": ""}
	)
	room_builder.build(room_layer, current_room, variant)
	_clear_layer(object_layer)
	_clear_layer(enemy_layer)
	_clear_layer(projectile_layer)
	_spawn_objects(current_room)
	_spawn_enemies(current_room.get("spawns", []) + variant.get("extra_spawns", []))
	player.reset_at(
		(
			spawn_position
			if spawn_position.x >= 0
			else Vector2(current_room["spawn"][0], current_room["spawn"][1])
		)
	)
	camera.limit_right = int(current_room.get("width", 1600))
	camera.limit_left = 0
	GameState.set_room(room_id)
	var room_title := str(current_room.get("title", room_id))
	var variant_label := str(variant.get("label", ""))
	ui.set_room_title(room_title if variant_label == "" else "%s  [%s]" % [room_title, variant_label])
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
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"text": object_data.get("text", "")
					}
				)
			"echo":
				node = ECHO_SCRIPT.new()
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"text": object_data.get("text", "")
					},
					room_data["id"],
					index
				)
			"rope":
				node = ROPE_SCRIPT.new()
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"height": object_data.get("height", 200.0)
					}
				)
			"seal_statue":
				node = SEAL_STATUE_SCRIPT.new()
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"text": object_data.get("text", ""),
						"progression_event_id": object_data.get("progression_event_id", ""),
						"prompt_text": object_data.get("prompt_text", "")
					}
				)
			"memory_plinth":
				node = MEMORY_PLINTH_SCRIPT.new()
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"text": object_data.get("text", ""),
						"repeat_text": object_data.get("repeat_text", ""),
						"progression_event_id": object_data.get("progression_event_id", ""),
						"prompt_text": object_data.get("prompt_text", ""),
						"save_progress": object_data.get("save_progress", false)
					}
				)
			"covenant_altar":
				node = COVENANT_ALTAR_SCRIPT.new()
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"text": object_data.get("text", ""),
						"repeat_text": object_data.get("repeat_text", ""),
						"progression_event_id": object_data.get("progression_event_id", ""),
						"prompt_text": object_data.get("prompt_text", "")
					}
				)
			"refuge_notice":
				node = REFUGE_NOTICE_SCRIPT.new()
				node.setup(
					{
						"position": Vector2(object_data["position"][0], object_data["position"][1]),
						"text": object_data.get("text", ""),
						"prompt_text": object_data.get("prompt_text", ""),
						"stage_messages": object_data.get("stage_messages", [])
					}
				)
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
		_spawn_enemy(
			spawn_data["type"],
			Vector2(spawn_data["position"][0], spawn_data["position"][1]),
			bool(spawn_data.get("allow_elite_roll", true))
		)


func _spawn_enemy(enemy_type: String, spawn_position: Vector2, allow_elite_roll: bool = false) -> void:
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate()
	enemy.configure(_build_enemy_spawn_config(enemy_type, spawn_position, allow_elite_roll), player)
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.fire_projectile.connect(_spawn_projectile)
	enemy.damage_label_requested.connect(_spawn_damage_label)
	enemy_layer.add_child(enemy)


func _build_enemy_spawn_config(
	enemy_type: String, spawn_position: Vector2, allow_elite_roll: bool
) -> Dictionary:
	var config := {"type": enemy_type, "position": spawn_position}
	if _should_spawn_elite_variant(enemy_type, allow_elite_roll):
		config["grade"] = "elite"
		config["base_type"] = enemy_type
	return config


func _should_spawn_elite_variant(enemy_type: String, allow_elite_roll: bool) -> bool:
	if not allow_elite_roll:
		return false
	if enemy_type in ["elite", "boss", "dummy"]:
		return false
	if not ELITE_VARIANT_TYPES.has(enemy_type):
		return false
	return randf() < ELITE_VARIANT_CHANCE


func _spawn_projectile(payload: Dictionary) -> void:
	var projectile := PROJECTILE_SCRIPT.new()
	projectile.setup(payload)
	projectile_layer.add_child(projectile)


func _attempt_room_shift(direction: int) -> void:
	if transitioning:
		return
	if direction > 0:
		if room_index >= room_order.size() - 1:
			GameState.push_message(
				"더 깊은 길은 열리지 않는다. 앞에 남은 것은 계약뿐이다.", 1.8
			)
			return
		var next_room_id: String = room_order[room_index + 1]
		_transition_to(next_room_id, _get_default_room_spawn(next_room_id))
	elif direction < 0 and room_index > 0:
		var previous: String = room_order[room_index - 1]
		_transition_to(previous, _get_reverse_room_spawn(previous))


func _resolve_room_order(room_id: String) -> Array[String]:
	if room_id in ["conduit", "deep_gate"]:
		return LEGACY_ROOM_ORDER.duplicate()
	return GameState.get_prototype_room_order()


func _get_room_clear_blocked_message(room_id: String) -> String:
	match room_id:
		"gate_threshold":
			return "심판의 관문은 수호자들이 남아 있는 한 열리지 않는다."
		"inverted_spire":
			return _get_inverted_spire_warning_line()
		_:
			return "이 방이 잠잠해질 때까지 앞쪽 통로는 봉인된 채로 남아 있다."


func _get_inverted_spire_warning_line() -> String:
	return str(GameState.get_final_warning_preview_summary().get("gate_line", "계약의 바닥은 여전히 팽팽하다. 제단은 아직 응답을 끝내지 않았다."))


func _get_default_room_spawn(room_id: String) -> Vector2:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	var spawn_data: Array = room_data.get("spawn", [120, 480])
	return Vector2(float(spawn_data[0]), float(spawn_data[1]))


func _get_reverse_room_spawn(room_id: String) -> Vector2:
	var room_width := float(GameDatabase.get_room(room_id).get("width", 1600))
	return Vector2(room_width - 120.0, 480.0)


func _transition_to(room_id: String, spawn_position: Vector2) -> void:
	transitioning = true
	GameState.push_message(
		"길은 솟아오르는 척 접히지만, 압력은 더 깊은 곳으로 가라앉는다.", 2.2
	)
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
	if enemy.has_method("get_current_drop_profile"):
		drop_profile = str(enemy.get_current_drop_profile())
	var dropped_item: String = GameDatabase.get_drop_for_profile(drop_profile)
	if dropped_item != "":
		GameState.grant_equipment_item(dropped_item)
		GameState.record_item_drop(dropped_item)
		var item_data: Dictionary = GameDatabase.get_equipment(dropped_item)
		GameState.push_message(
			"아이템 획득: %s" % str(item_data.get("display_name", dropped_item)), 2.5
		)
	if enemy.enemy_type == "boss":
		GameState.boss_defeated = true
		if current_room["id"] == "conduit":
			GameState.grant_progression_event("boss_conduit")
		GameState.save_to_disk()
		_focus_event(enemy.global_position + Vector2(0, -32), 1.1)
		GameState.push_message(_get_boss_clear_message(current_room["id"]), 2.8)
	if not _has_blocking_enemies() and current_room["id"] == "entrance":
		GameState.push_message("동쪽 통로가 열린다. 미궁은 전진의 기세를 보상한다.", 2.0)
	if not _has_blocking_enemies() and player != null and player.has_method("rearm_room_shift_edge"):
		player.rearm_room_shift_edge()
		_retry_room_shift_if_player_waiting_at_edge()


func _has_blocking_enemies() -> bool:
	for child in enemy_layer.get_children():
		if not is_instance_valid(child) or child.is_queued_for_deletion():
			continue
		if child.has_method("is_room_transition_blocking"):
			if child.is_room_transition_blocking():
				return true
			continue
		return true
	return false


func _retry_room_shift_if_player_waiting_at_edge() -> void:
	if player == null:
		return
	var room_width := float(current_room.get("width", 1600.0))
	var right_edge_threshold := maxf(20.0, room_width - 60.0)
	if player.global_position.x > right_edge_threshold:
		_attempt_room_shift(1)
	elif player.global_position.x < 20.0:
		_attempt_room_shift(-1)


func _on_core_activated() -> void:
	_focus_event(
		(
			Vector2(current_room["core_position"][0], current_room["core_position"][1])
			+ Vector2(0, -24)
		),
		1.0
	)
	await get_tree().create_timer(1.1).timeout
	_transition_to("deep_gate", Vector2(180, 520))


func _get_boss_clear_message(room_id: String) -> String:
	match room_id:
		"conduit":
			return "도관의 수호자가 쓰러졌다. 바닥 코어가 드러난다."
		"inverted_spire":
			return "계약이 떨린다. 전도된 탑이 잠시나마 하늘을 향하던 시절을 떠올린다."
		_:
			return "방 안이 고요해진다."


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


func _build_soul_risk_release_overlay() -> void:
	if _soul_risk_release_overlay != null:
		return
	_soul_risk_release_overlay = ColorRect.new()
	_soul_risk_release_overlay.name = "SoulRiskReleaseOverlay"
	_soul_risk_release_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_soul_risk_release_overlay.visible = false
	_soul_risk_release_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_soul_risk_release_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(_soul_risk_release_overlay)
	canvas_layer.move_child(_soul_risk_release_overlay, 0)


func _build_brightness_overlay() -> void:
	if _brightness_overlay != null:
		return
	_brightness_overlay = ColorRect.new()
	_brightness_overlay.name = "BrightnessOverlay"
	_brightness_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_brightness_overlay.visible = false
	_brightness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_brightness_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(_brightness_overlay)
	canvas_layer.move_child(_brightness_overlay, 1)
	_apply_brightness_overlay()


func _get_current_soul_risk_state() -> String:
	if GameState.soul_dominion_active:
		return "active"
	if GameState.soul_dominion_aftershock_timer > 0.0:
		return "aftershock"
	return "none"


func _sync_soul_risk_release_feedback_state() -> void:
	var current_state := _get_current_soul_risk_state()
	if current_state != "none":
		_soul_risk_release_timer = 0.0
	elif _last_soul_risk_state == "aftershock":
		_soul_risk_release_timer = SOUL_RISK_RELEASE_BEAT_DURATION
	_last_soul_risk_state = current_state


func _refresh_soul_risk_release_overlay() -> void:
	if _soul_risk_release_overlay == null:
		return
	if UiState != null and not UiState.are_special_effects_enabled():
		_soul_risk_release_overlay.visible = false
		_soul_risk_release_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
		return
	if _soul_risk_release_timer <= 0.0:
		_soul_risk_release_overlay.visible = false
		_soul_risk_release_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
		return
	var progress := clampf(
		1.0 - (_soul_risk_release_timer / SOUL_RISK_RELEASE_BEAT_DURATION),
		0.0,
		1.0
	)
	_soul_risk_release_overlay.visible = true
	_soul_risk_release_overlay.color = SOUL_RISK_RELEASE_OVERLAY_START.lerp(
		SOUL_RISK_RELEASE_OVERLAY_END,
		progress
	)


func _apply_brightness_overlay() -> void:
	if _brightness_overlay == null:
		return
	var brightness_value := 1.0
	if UiState != null:
		brightness_value = UiState.get_brightness()
	var alpha := clampf(1.0 - brightness_value, 0.0, 0.4)
	_brightness_overlay.visible = alpha > 0.001
	_brightness_overlay.color = Color(0.0, 0.0, 0.0, alpha)


func _on_brightness_changed(_value: float) -> void:
	_apply_brightness_overlay()


func _on_special_effects_setting_changed(_enabled: bool) -> void:
	_refresh_soul_risk_release_overlay()


func _refresh_soul_risk_camera_feedback() -> void:
	if camera == null:
		return
	if GameState.soul_dominion_active:
		camera.zoom = _default_camera_zoom * SOUL_RISK_CAMERA_ACTIVE_ZOOM_FACTOR
		return
	if GameState.soul_dominion_aftershock_timer > 0.0:
		var duration := float(GameState.SOUL_DOMINION_AFTERSHOCK_DURATION)
		var progress := 0.0
		if duration > 0.0:
			progress = clampf(
				1.0 - (GameState.soul_dominion_aftershock_timer / duration),
				0.0,
				1.0
			)
		var factor := lerpf(
			SOUL_RISK_CAMERA_AFTERSHOCK_START_FACTOR,
			SOUL_RISK_CAMERA_AFTERSHOCK_END_FACTOR,
			progress
		)
		camera.zoom = _default_camera_zoom * factor
		return
	if _soul_risk_release_timer > 0.0:
		var clear_progress := clampf(
			1.0 - (_soul_risk_release_timer / SOUL_RISK_RELEASE_BEAT_DURATION),
			0.0,
			1.0
		)
		var factor := lerpf(
			SOUL_RISK_CAMERA_CLEAR_ZOOM_FACTOR,
			1.0,
			clear_progress
		)
		camera.zoom = _default_camera_zoom * factor
		return
	camera.zoom = _default_camera_zoom


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
	var burst_duration := maxf(float(payload.get("duration", 0.0)), COMBO_EFFECT_MIN_DURATION)
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
		"duration": burst_duration,
		"color": str(payload.get("color", "#ff8f45")),
		"owner": player
	}
	_spawn_projectile(burst_payload)
	if effect_id == "ash_detonation":
		_focus_event(player.global_position + Vector2(0, -8), COMBO_EFFECT_EVENT_FOCUS_DURATION)


func _on_progression_event_granted(event_id: String) -> void:
	if event_id != "inverted_spire_covenant":
		return
	if str(current_room.get("id", "")) != "inverted_spire":
		return
	var boss_target := _get_final_boss_focus_position()
	_focus_event(boss_target, 0.6)
	GameState.push_message(
		"제단이 응답한다. 단상 너머 어딘가에서 오래 기다린 시선이 당신을 향한다.",
		2.8
	)


func _get_final_boss_focus_position() -> Vector2:
	for child in enemy_layer.get_children():
		if not is_instance_valid(child):
			continue
		if str(child.get("enemy_type")) == "boss":
			return child.global_position + Vector2(0, -32)
	return Vector2(
		float(current_room.get("width", 2240)) * 0.5,
		480.0
	)


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
	admin_menu.room_jump_requested.connect(_on_admin_room_jump_requested)


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
	_spawn_enemy(enemy_type, spawn_position, false)
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


func _on_admin_room_jump_requested(room_id: String) -> void:
	if room_id == "":
		return
	GameState.push_message("관리자 이동: %s" % room_id, 1.2)
	_load_room(room_id, _get_default_room_spawn(room_id))

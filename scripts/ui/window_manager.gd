extends Control

class_name WindowManager

const INVENTORY_WINDOW_SCENE := preload("res://scenes/ui/windows/InventoryWindow.tscn")
const SKILL_WINDOW_SCENE := preload("res://scenes/ui/windows/SkillWindow.tscn")
const KEY_BINDINGS_WINDOW_SCENE := preload("res://scenes/ui/windows/KeyBindingsWindow.tscn")
const EQUIPMENT_WINDOW_SCENE := preload("res://scenes/ui/windows/EquipmentWindow.tscn")
const STAT_WINDOW_SCENE := preload("res://scenes/ui/windows/StatWindow.tscn")
const QUEST_WINDOW_SCENE := preload("res://scenes/ui/windows/QuestWindow.tscn")
const SETTINGS_WINDOW_SCENE := preload("res://scenes/ui/windows/SettingsWindow.tscn")

var _window_scenes := {
	"inventory": INVENTORY_WINDOW_SCENE,
	"skill": SKILL_WINDOW_SCENE,
	"key_bindings": KEY_BINDINGS_WINDOW_SCENE,
	"equipment": EQUIPMENT_WINDOW_SCENE,
	"stat": STAT_WINDOW_SCENE,
	"quest": QUEST_WINDOW_SCENE,
	"settings": SETTINGS_WINDOW_SCENE
}
var _window_nodes: Dictionary = {}
var _window_stack: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	if Engine.is_editor_hint():
		return
	if UiState != null:
		UiState.ui_opacity_changed.connect(_on_ui_opacity_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_settings"):
		if close_topmost_window():
			get_viewport().set_input_as_handled()
			return
		open_window("settings")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_inventory"):
		toggle_window("inventory")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_skill"):
		toggle_window("skill")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_equipment"):
		toggle_window("equipment")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_stats"):
		toggle_window("stat")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_quest"):
		toggle_window("quest")
		get_viewport().set_input_as_handled()


func debug_toggle_window(window_id: String) -> void:
	toggle_window(window_id)


func get_window_node(window_id: String) -> Control:
	if not _window_nodes.has(window_id):
		return null
	return _window_nodes[window_id]


func is_window_open(window_id: String) -> bool:
	var window := get_window_node(window_id)
	return window != null and window.visible


func get_open_window_ids() -> Array[String]:
	var open_window_ids: Array[String] = []
	for window_id in _window_stack:
		if is_window_open(window_id):
			open_window_ids.append(window_id)
	return open_window_ids


func get_topmost_window_id() -> String:
	var open_window_ids := get_open_window_ids()
	if open_window_ids.is_empty():
		return ""
	return open_window_ids[open_window_ids.size() - 1]


func toggle_window(window_id: String) -> void:
	if is_window_open(window_id):
		close_window(window_id)
		return
	open_window(window_id)


func open_window(window_id: String) -> void:
	var window := _ensure_window(window_id)
	if window == null:
		return
	window.visible = true
	_focus_window(window_id)
	_restore_window_position(window_id)
	_apply_window_opacity(window_id)
	_refresh_pause_state()


func close_window(window_id: String) -> void:
	var window := get_window_node(window_id)
	if window == null:
		return
	window.visible = false
	_window_stack.erase(window_id)
	_refresh_all_window_opacity()
	_refresh_pause_state()


func close_topmost_window() -> bool:
	var topmost_window_id := get_topmost_window_id()
	if topmost_window_id == "":
		return false
	close_window(topmost_window_id)
	return true


func _ensure_window(window_id: String) -> Control:
	if _window_nodes.has(window_id):
		return _window_nodes[window_id]
	if not _window_scenes.has(window_id):
		return null
	var scene: PackedScene = _window_scenes[window_id]
	var window := scene.instantiate() as Control
	if window == null:
		return null
	window.visible = false
	add_child(window)
	_window_nodes[window_id] = window
	if window.has_signal("close_requested"):
		window.close_requested.connect(_on_window_close_requested)
	if window.has_signal("focus_requested"):
		window.focus_requested.connect(_on_window_focus_requested)
	if window.has_signal("moved"):
		window.moved.connect(_on_window_moved)
	if window.has_signal("open_window_requested"):
		window.open_window_requested.connect(_on_open_window_requested)
	if window.has_signal("bind_skill_requested"):
		window.bind_skill_requested.connect(_on_bind_skill_requested)
	return window


func _focus_window(window_id: String) -> void:
	var window := get_window_node(window_id)
	if window == null:
		return
	if window.get_parent() == self:
		move_child(window, get_child_count() - 1)
	_window_stack.erase(window_id)
	_window_stack.append(window_id)
	_refresh_all_window_opacity()


func _restore_window_position(window_id: String) -> void:
	var window := get_window_node(window_id)
	if window == null:
		return
	var fallback := Vector2(80.0, 80.0)
	if window.has_method("get_default_window_position"):
		fallback = window.call("get_default_window_position")
	var stored_position := UiState.get_window_position(window_id, fallback)
	var clamped_position := _clamp_window_position(window, stored_position)
	window.position = clamped_position
	if clamped_position != stored_position:
		UiState.set_window_position(window_id, clamped_position)


func _clamp_window_position(window: Control, desired_position: Vector2) -> Vector2:
	var viewport_size := get_viewport_rect().size
	var safe_x := clampf(desired_position.x, 0.0, maxf(viewport_size.x - window.size.x, 0.0))
	var safe_y := clampf(desired_position.y, 0.0, maxf(viewport_size.y - window.size.y, 0.0))
	return Vector2(safe_x, safe_y)


func _refresh_pause_state() -> void:
	get_tree().paused = is_window_open("settings")


func _apply_window_opacity(window_id: String) -> void:
	var window := get_window_node(window_id)
	if window == null or not window.visible:
		return
	var opacity := UiState.get_ui_opacity()
	var is_focused := get_topmost_window_id() == window_id
	if window.has_method("set_window_opacity"):
		window.call("set_window_opacity", opacity, is_focused)
		return
	window.modulate = Color(1.0, 1.0, 1.0, opacity)


func _refresh_all_window_opacity() -> void:
	for window_id_value in _window_nodes.keys():
		_apply_window_opacity(str(window_id_value))


func _on_ui_opacity_changed(_value: float) -> void:
	_refresh_all_window_opacity()


func _on_window_close_requested(window_id: String) -> void:
	close_window(window_id)


func _on_window_focus_requested(window_id: String) -> void:
	_focus_window(window_id)


func _on_window_moved(window_id: String, desired_position: Vector2) -> void:
	var window := get_window_node(window_id)
	if window == null:
		return
	var clamped_position := _clamp_window_position(window, desired_position)
	window.position = clamped_position
	UiState.set_window_position(window_id, clamped_position)


func _on_open_window_requested(window_id: String) -> void:
	open_window(window_id)


func _on_bind_skill_requested(skill_id: String) -> void:
	open_window("key_bindings")
	var key_bindings_window := get_window_node("key_bindings")
	if key_bindings_window != null and key_bindings_window.has_method("set_pending_skill_id"):
		key_bindings_window.call("set_pending_skill_id", skill_id)

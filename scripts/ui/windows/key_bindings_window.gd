extends "res://scripts/ui/widgets/ui_window_frame.gd"

const SLOT_COLUMNS := 7
const HOTKEY_DROP_BUTTON_SCENE := preload("res://scripts/ui/widgets/hotkey_drop_button.gd")
const SKILL_VISUAL_HELPER := preload("res://scripts/ui/widgets/skill_visual_helper.gd")

var _pending_skill_id := ""
var _selected_action := "spell_fire"
var _hovered_action := ""
var _pending_label: Label = null
var _summary_label: Label = null
var _slot_grid: GridContainer = null
var _slot_buttons: Dictionary = {}


func _enter_tree() -> void:
	window_id = "key_bindings"
	window_title = "키 설정"
	placeholder_text = ""
	default_size = Vector2(620.0, 360.0)
	default_position = Vector2(240.0, 112.0)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_key_bindings_content()
	_connect_runtime_signals()
	_refresh_window()


func set_pending_skill_id(skill_id: String) -> void:
	_pending_skill_id = GameDatabase.get_runtime_castable_skill_id(skill_id)
	if _pending_skill_id == "":
		_pending_skill_id = skill_id
	_refresh_window()


func get_pending_skill_text() -> String:
	if _pending_label == null:
		return ""
	return _pending_label.text


func get_slot_button(action: String) -> Button:
	return _slot_buttons.get(action, null)


func get_selected_action() -> String:
	return _selected_action


func debug_bind_pending_to_action(action: String) -> bool:
	_selected_action = action
	return _assign_pending_to_selected_action()


func debug_clear_action(action: String) -> bool:
	_selected_action = action
	return _clear_selected_action()


func debug_drop_skill_payload_on_action(payload: Dictionary, action: String) -> bool:
	return _apply_dropped_skill_payload(action, payload)


func debug_handle_keycode(keycode: int) -> bool:
	return _handle_hotkey_keycode(keycode)


func debug_set_hovered_action(action: String) -> void:
	_hovered_action = action
	_refresh_slot_buttons()


func debug_get_slot_border_color(action: String, state_name: String = "normal") -> Color:
	var button := get_slot_button(action)
	if button == null:
		return Color.BLACK
	var style := button.get_theme_stylebox(state_name) as StyleBoxFlat
	if style == null:
		return Color.BLACK
	return style.border_color


func _build_key_bindings_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return

	var content := VBoxContainer.new()
	content.name = "KeyBindingsContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	content_root.add_child(content)

	_pending_label = Label.new()
	_pending_label.name = "PendingLabel"
	_pending_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_pending_label)

	_summary_label = Label.new()
	_summary_label.name = "SummaryLabel"
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.modulate = Color(0.82, 0.87, 0.96, 0.95)
	content.add_child(_summary_label)

	var panel := PanelContainer.new()
	panel.name = "SlotPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
	content.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	_slot_grid = GridContainer.new()
	_slot_grid.name = "SlotGrid"
	_slot_grid.columns = SLOT_COLUMNS
	_slot_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slot_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_slot_grid.add_theme_constant_override("h_separation", 8)
	_slot_grid.add_theme_constant_override("v_separation", 8)
	margin.add_child(_slot_grid)

	for entry_value in GameState.get_action_hotkey_registry():
		var entry: Dictionary = entry_value
		var action := str(entry.get("action", ""))
		var button := HOTKEY_DROP_BUTTON_SCENE.new()
		button.name = "%sButton" % action
		button.custom_minimum_size = Vector2(80.0, 62.0)
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.action_id = action
		button.pressed.connect(_on_slot_pressed.bind(action))
		button.gui_input.connect(_on_slot_gui_input.bind(action))
		button.mouse_entered.connect(_on_slot_mouse_entered.bind(action))
		button.mouse_exited.connect(_on_slot_mouse_exited.bind(action))
		button.skill_payload_dropped.connect(_on_slot_skill_payload_dropped)
		_apply_slot_button_skin(button)
		_slot_grid.add_child(button)
		_slot_buttons[action] = button

	var action_row := HBoxContainer.new()
	action_row.name = "ActionRow"
	action_row.add_theme_constant_override("separation", 6)
	content.add_child(action_row)

	var assign_button := Button.new()
	assign_button.name = "AssignButton"
	assign_button.text = "선택 슬롯에 등록"
	assign_button.focus_mode = Control.FOCUS_NONE
	assign_button.pressed.connect(_assign_pending_to_selected_action)
	_apply_asset_large_button_skin(assign_button)
	action_row.add_child(assign_button)

	var clear_button := Button.new()
	clear_button.name = "ClearButton"
	clear_button.text = "선택 슬롯 비우기"
	clear_button.focus_mode = Control.FOCUS_NONE
	clear_button.pressed.connect(_clear_selected_action)
	_apply_asset_large_button_skin(clear_button)
	action_row.add_child(clear_button)


func _connect_runtime_signals() -> void:
	if not GameState.stats_changed.is_connected(_refresh_window):
		GameState.stats_changed.connect(_refresh_window)


func _refresh_window() -> void:
	_refresh_pending_label()
	_refresh_summary_label()
	_refresh_slot_buttons()


func _refresh_pending_label() -> void:
	if _pending_label == null:
		return
	if _pending_skill_id == "":
		_pending_label.text = "등록 대기 중인 스킬: 없음"
		return
	var skill_data: Dictionary = GameDatabase.get_skill_data(_pending_skill_id)
	_pending_label.text = "등록 대기 중인 스킬: %s" % str(
		skill_data.get("display_name", _pending_skill_id)
	)


func _refresh_summary_label() -> void:
	if _summary_label == null:
		return
	_summary_label.text = "허용 키는 1~0, Z/X/C/V, A/S/D/F, Shift/Ctrl/Alt 로 고정됩니다. 우클릭으로 슬롯을 비우고, 왼쪽 클릭으로 대상 슬롯을 선택하거나 pending skill 상태에서 해당 키를 직접 눌러 등록합니다."


func _refresh_slot_buttons() -> void:
	for entry_value in GameState.get_action_hotkey_registry():
		var entry: Dictionary = entry_value
		var action := str(entry.get("action", ""))
		var button := get_slot_button(action)
		if button == null:
			continue
		var skill_id := str(entry.get("skill_id", ""))
		var skill_name := "[빈 슬롯]"
		if skill_id != "":
			skill_name = str(GameDatabase.get_skill_data(skill_id).get("display_name", skill_id))
		button.text = "%s\n%s" % [str(entry.get("label", "?")), skill_name]
		button.tooltip_text = "%s -> %s" % [str(entry.get("label", "?")), skill_name]
		SKILL_VISUAL_HELPER.apply_skill_icon(button, skill_id, 18)
		_apply_slot_button_visual_state(
			button,
			skill_id != "",
			action == _selected_action,
			action == _hovered_action
		)
		button.button_pressed = action == _selected_action


func _assign_pending_to_selected_action() -> bool:
	if _pending_skill_id == "" or _selected_action == "":
		return false
	var changed := GameState.set_action_hotkey_skill(_selected_action, _pending_skill_id)
	if changed:
		_pending_skill_id = ""
		_refresh_window()
	return changed


func _clear_selected_action() -> bool:
	if _selected_action == "":
		return false
	var changed := GameState.clear_action_hotkey_skill(_selected_action)
	if changed:
		_refresh_window()
	return changed


func _build_soft_panel_style() -> StyleBox:
	return _build_asset_compact_panel_style()


func _apply_slot_button_skin(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.97, 0.98, 1.0, 1.0)
	normal.border_color = Color(0.81, 0.86, 0.93, 1.0)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", normal)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.84, 0.92, 1.0, 1.0)
	pressed.border_color = Color(0.26, 0.58, 0.89, 1.0)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)


func _apply_slot_button_visual_state(
	button: Button,
	has_skill: bool,
	is_selected: bool,
	is_hovered: bool
) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.97, 0.98, 1.0, 1.0) if has_skill else Color(0.95, 0.96, 0.99, 0.92)
	normal.border_color = Color(0.68, 0.76, 0.88, 0.92) if has_skill else Color(0.80, 0.84, 0.90, 0.82)
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = normal.bg_color.lightened(0.03)
	hover.border_color = Color(0.98, 0.84, 0.34, 0.98)
	hover.border_width_left = 3
	hover.border_width_top = 3
	hover.border_width_right = 3
	hover.border_width_bottom = 3

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.84, 0.92, 1.0, 1.0) if has_skill else Color(0.88, 0.93, 1.0, 0.96)
	pressed.border_color = Color(0.26, 0.58, 0.89, 1.0)
	pressed.border_width_left = 3
	pressed.border_width_top = 3
	pressed.border_width_right = 3
	pressed.border_width_bottom = 3

	var hover_pressed := pressed.duplicate() as StyleBoxFlat
	hover_pressed.border_color = Color(0.18, 0.68, 0.98, 1.0)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("hover_pressed", hover_pressed)
	button.add_theme_color_override(
		"font_color",
		Color(0.16, 0.22, 0.34, 1.0) if has_skill else Color(0.42, 0.46, 0.56, 1.0)
	)
	button.add_theme_color_override("font_hover_color", Color(0.10, 0.18, 0.28, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.07, 0.12, 0.20, 1.0))


func _on_slot_pressed(action: String) -> void:
	_selected_action = action
	_refresh_slot_buttons()


func _on_slot_mouse_entered(action: String) -> void:
	_hovered_action = action
	_refresh_slot_buttons()


func _on_slot_mouse_exited(action: String) -> void:
	if _hovered_action == action:
		_hovered_action = ""
		_refresh_slot_buttons()


func _on_slot_gui_input(event: InputEvent, action: String) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_RIGHT or not mouse_event.pressed:
		return
	_selected_action = action
	_clear_selected_action()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if _handle_hotkey_keycode(_resolve_input_keycode(key_event)):
		get_viewport().set_input_as_handled()


func _on_slot_skill_payload_dropped(action: String, skill_id: String) -> void:
	var payload := {
		"type": "skill_hotkey_bind",
		"skill_id": skill_id
	}
	_apply_dropped_skill_payload(action, payload)


func _apply_dropped_skill_payload(action: String, payload: Dictionary) -> bool:
	var skill_id := str(payload.get("skill_id", ""))
	if str(payload.get("type", "")) != "skill_hotkey_bind" or skill_id == "":
		return false
	_selected_action = action
	_pending_skill_id = GameDatabase.get_runtime_castable_skill_id(skill_id)
	if _pending_skill_id == "":
		_pending_skill_id = skill_id
	return _assign_pending_to_selected_action()


func _handle_hotkey_keycode(keycode: int) -> bool:
	if keycode <= 0:
		return false
	var matched_action := _find_registry_action_by_keycode(keycode)
	if matched_action == "":
		return false
	_selected_action = matched_action
	if _pending_skill_id != "":
		return _assign_pending_to_selected_action()
	_refresh_slot_buttons()
	return true


func _find_registry_action_by_keycode(keycode: int) -> String:
	for entry_value in GameState.get_action_hotkey_registry():
		var entry: Dictionary = entry_value
		if int(entry.get("keycode", 0)) == keycode:
			return str(entry.get("action", ""))
	return ""


func _resolve_input_keycode(key_event: InputEventKey) -> int:
	if key_event.physical_keycode != 0:
		return int(key_event.physical_keycode)
	return int(key_event.keycode)

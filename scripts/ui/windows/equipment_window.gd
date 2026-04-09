extends "res://scripts/ui/widgets/ui_window_frame.gd"

const SLOT_ORDER := ["weapon", "offhand", "head", "body", "legs", "accessory_1", "accessory_2"]
const SLOT_LABELS := {
	"weapon": "무기",
	"offhand": "보조",
	"head": "머리",
	"body": "상의",
	"legs": "하의",
	"accessory_1": "반지 1",
	"accessory_2": "반지 2"
}
const STAT_LABELS := {
	"magic_attack": "마공",
	"max_hp": "최대 HP",
	"max_mp": "최대 MP",
	"mp_regen": "MP 재생",
	"cooldown_recovery": "재감",
	"cast_speed": "시전 속도"
}

var _slot_buttons: Dictionary = {}
var _selected_slot := "weapon"
var _selected_item_id := ""
var _summary_label: Label = null
var _equipped_label: Label = null
var _compare_label: Label = null
var _item_list_root: VBoxContainer = null
var _item_buttons: Array[Button] = []
var _owned_item_panel: Control = null
var _equip_button: Button = null
var _unequip_button: Button = null
var _drag_owned_item_id := ""
var _drag_equipped_slot := ""
var _hovered_slot := ""
var _hovered_item_id := ""


func _enter_tree() -> void:
	window_id = "equipment"
	window_title = "장비"
	placeholder_text = ""
	default_size = Vector2(520.0, 440.0)
	default_position = Vector2(156.0, 110.0)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_equipment_content()
	_connect_runtime_signals()
	_refresh_window()


func get_slot_button(slot_name: String) -> Button:
	return _slot_buttons.get(slot_name, null)


func get_owned_item_button_count() -> int:
	return _item_buttons.size()


func get_selected_slot() -> String:
	return _selected_slot


func get_selected_item_id() -> String:
	return _selected_item_id


func get_compare_text() -> String:
	return "" if _compare_label == null else _compare_label.text


func get_summary_text() -> String:
	return "" if _summary_label == null else _summary_label.text


func get_slot_tooltip_text(slot_name: String) -> String:
	var button := get_slot_button(slot_name)
	return "" if button == null else button.tooltip_text


func get_owned_item_tooltip_text(item_id: String) -> String:
	for button in _item_buttons:
		if button != null and button.name == "Owned_%s" % item_id:
			return button.tooltip_text
	return ""


func debug_select_slot(slot_name: String) -> void:
	_select_slot(slot_name)


func debug_select_owned_item(item_id: String) -> void:
	_selected_item_id = item_id
	_refresh_item_selection()
	_refresh_detail_panel()


func debug_equip_selected_item() -> bool:
	return _equip_selected_item()


func debug_unequip_selected_slot() -> bool:
	return _unequip_selected_slot()


func debug_double_click_slot(slot_name: String) -> bool:
	_select_slot(slot_name)
	return _unequip_selected_slot()


func debug_double_click_owned_item(item_id: String) -> bool:
	var slot_name := str(GameDatabase.get_equipment(item_id).get("slot_type", ""))
	if slot_name != "":
		_select_slot(slot_name)
	_selected_item_id = item_id
	return _equip_selected_item()


func debug_drag_owned_item_to_slot(item_id: String, slot_name: String) -> bool:
	_drag_owned_item_id = item_id
	_drag_equipped_slot = ""
	return _attempt_drag_equip(slot_name)


func debug_drag_equipped_slot_to_owned(slot_name: String) -> bool:
	_drag_owned_item_id = ""
	_drag_equipped_slot = slot_name
	return _attempt_drag_unequip()


func debug_hover_slot(slot_name: String) -> void:
	_on_slot_button_mouse_entered(slot_name)


func debug_clear_hover_slot(slot_name: String = "") -> void:
	_on_slot_button_mouse_exited(slot_name)


func debug_hover_owned_item(item_id: String) -> void:
	_on_owned_item_button_mouse_entered(item_id)


func debug_clear_hover_owned_item(item_id: String = "") -> void:
	_on_owned_item_button_mouse_exited(item_id)


func _build_equipment_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return

	var shell := HBoxContainer.new()
	shell.name = "EquipmentContent"
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_theme_constant_override("separation", 10)
	content_root.add_child(shell)

	var paper_doll_panel := PanelContainer.new()
	paper_doll_panel.name = "PaperDollPanel"
	paper_doll_panel.custom_minimum_size = Vector2(168.0, 0.0)
	paper_doll_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper_doll_panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
	shell.add_child(paper_doll_panel)

	var paper_margin := MarginContainer.new()
	paper_margin.add_theme_constant_override("margin_left", 10)
	paper_margin.add_theme_constant_override("margin_top", 12)
	paper_margin.add_theme_constant_override("margin_right", 10)
	paper_margin.add_theme_constant_override("margin_bottom", 12)
	paper_doll_panel.add_child(paper_margin)

	var paper_column := VBoxContainer.new()
	paper_column.name = "PaperDollColumn"
	paper_column.add_theme_constant_override("separation", 8)
	paper_margin.add_child(paper_column)

	var paper_title := Label.new()
	paper_title.name = "PaperDollTitle"
	paper_title.text = "장착 슬롯"
	paper_column.add_child(paper_title)

	for slot_name in SLOT_ORDER:
		var slot_button := Button.new()
		slot_button.name = "%sSlotButton" % slot_name.capitalize()
		slot_button.custom_minimum_size = Vector2(0.0, 42.0)
		slot_button.focus_mode = Control.FOCUS_NONE
		slot_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_button.pressed.connect(_on_slot_button_pressed.bind(slot_name))
		slot_button.gui_input.connect(_on_slot_button_gui_input.bind(slot_name))
		slot_button.mouse_entered.connect(_on_slot_button_mouse_entered.bind(slot_name))
		slot_button.mouse_exited.connect(_on_slot_button_mouse_exited.bind(slot_name))
		_apply_slot_button_skin(slot_button)
		paper_column.add_child(slot_button)
		_slot_buttons[slot_name] = slot_button

	var detail_column := VBoxContainer.new()
	detail_column.name = "DetailColumn"
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 8)
	shell.add_child(detail_column)

	_summary_label = Label.new()
	_summary_label.name = "SummaryLabel"
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_column.add_child(_summary_label)

	_equipped_label = Label.new()
	_equipped_label.name = "EquippedLabel"
	_equipped_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_column.add_child(_equipped_label)

	_compare_label = Label.new()
	_compare_label.name = "CompareLabel"
	_compare_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_compare_label.modulate = Color(0.86, 0.91, 1.0, 0.95)
	_compare_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_column.add_child(_compare_label)

	var inventory_panel := PanelContainer.new()
	inventory_panel.name = "OwnedItemPanel"
	inventory_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
	inventory_panel.gui_input.connect(_on_owned_panel_gui_input)
	detail_column.add_child(inventory_panel)
	_owned_item_panel = inventory_panel

	var inventory_margin := MarginContainer.new()
	inventory_margin.add_theme_constant_override("margin_left", 10)
	inventory_margin.add_theme_constant_override("margin_top", 10)
	inventory_margin.add_theme_constant_override("margin_right", 10)
	inventory_margin.add_theme_constant_override("margin_bottom", 10)
	inventory_panel.add_child(inventory_margin)

	var inventory_column := VBoxContainer.new()
	inventory_column.name = "OwnedItemColumn"
	inventory_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_column.add_theme_constant_override("separation", 6)
	inventory_margin.add_child(inventory_column)

	var inventory_title := Label.new()
	inventory_title.name = "OwnedItemTitle"
	inventory_title.text = "보유 후보"
	inventory_column.add_child(inventory_title)

	var item_scroll := ScrollContainer.new()
	item_scroll.name = "OwnedItemScroll"
	item_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_scroll.custom_minimum_size = Vector2(0.0, 150.0)
	inventory_column.add_child(item_scroll)

	_item_list_root = VBoxContainer.new()
	_item_list_root.name = "OwnedItemList"
	_item_list_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_list_root.add_theme_constant_override("separation", 4)
	item_scroll.add_child(_item_list_root)

	var action_row := HBoxContainer.new()
	action_row.name = "ActionRow"
	action_row.add_theme_constant_override("separation", 6)
	detail_column.add_child(action_row)

	_equip_button = Button.new()
	_equip_button.name = "EquipButton"
	_equip_button.text = "장착"
	_equip_button.focus_mode = Control.FOCUS_NONE
	_equip_button.pressed.connect(_equip_selected_item)
	action_row.add_child(_equip_button)

	_unequip_button = Button.new()
	_unequip_button.name = "UnequipButton"
	_unequip_button.text = "해제"
	_unequip_button.focus_mode = Control.FOCUS_NONE
	_unequip_button.pressed.connect(_unequip_selected_slot)
	action_row.add_child(_unequip_button)


func _connect_runtime_signals() -> void:
	if not GameState.stats_changed.is_connected(_refresh_window):
		GameState.stats_changed.connect(_refresh_window)


func _refresh_window() -> void:
	_refresh_slot_buttons()
	_refresh_owned_item_buttons()
	_refresh_item_selection()
	_refresh_detail_panel()


func _refresh_slot_buttons() -> void:
	var equipped_items := GameState.get_equipped_items()
	for slot_name in SLOT_ORDER:
		var button := get_slot_button(slot_name)
		if button == null:
			continue
		var item_id := str(equipped_items.get(slot_name, ""))
		var item_name := _get_equipment_name(item_id)
		button.text = "%s\n%s" % [str(SLOT_LABELS.get(slot_name, slot_name)), item_name]
		button.button_pressed = slot_name == _selected_slot
		button.tooltip_text = _build_slot_tooltip_text(slot_name, item_id)


func _refresh_owned_item_buttons() -> void:
	if _item_list_root == null:
		return
	for child in _item_list_root.get_children():
		child.queue_free()
	for button in _item_buttons:
		if button != null:
			button.queue_free()
	_item_buttons.clear()

	var inventory_items: Array = GameState.get_equipment_inventory_for_slot(_selected_slot)
	if _hovered_item_id != "" and not inventory_items.has(_hovered_item_id):
		_hovered_item_id = ""
	if inventory_items.is_empty():
		_selected_item_id = ""
		var empty_label := Label.new()
		empty_label.name = "EmptyStateLabel"
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "이 슬롯에 맞는 장비가 아직 없습니다."
		_item_list_root.add_child(empty_label)
		return

	for item_value in inventory_items:
		var item_id := str(item_value)
		var item_button := Button.new()
		item_button.name = "Owned_%s" % item_id
		item_button.toggle_mode = true
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.focus_mode = Control.FOCUS_NONE
		item_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_button.text = "%s\n%s" % [_get_equipment_name(item_id), _format_stat_lines(item_id)]
		item_button.tooltip_text = _build_owned_item_tooltip_text(item_id)
		item_button.pressed.connect(_on_owned_item_button_pressed.bind(item_id))
		item_button.gui_input.connect(_on_owned_item_button_gui_input.bind(item_id))
		item_button.mouse_entered.connect(_on_owned_item_button_mouse_entered.bind(item_id))
		item_button.mouse_exited.connect(_on_owned_item_button_mouse_exited.bind(item_id))
		_item_list_root.add_child(item_button)
		_item_buttons.append(item_button)

	if not inventory_items.has(_selected_item_id):
		_selected_item_id = str(inventory_items[0])


func _refresh_item_selection() -> void:
	for button_index in range(_item_buttons.size()):
		var button := _item_buttons[button_index]
		if button == null:
			continue
		button.button_pressed = button.name == "Owned_%s" % _selected_item_id


func _refresh_detail_panel() -> void:
	if _summary_label == null or _equipped_label == null or _compare_label == null:
		return
	var equipped_items := GameState.get_equipped_items()
	var active_slot := _get_active_slot_name()
	var active_item_id := _get_active_candidate_item_id()
	var equipped_item_id := str(equipped_items.get(active_slot, ""))
	var selected_equipped_item_id := str(equipped_items.get(_selected_slot, ""))
	var selected_slot_label := str(SLOT_LABELS.get(active_slot, active_slot))
	var hover_suffix := ""
	if _hovered_item_id != "":
		hover_suffix = " (hover 비교)"
	elif _hovered_slot != "":
		hover_suffix = " (hover)"
	_summary_label.text = "선택 슬롯: %s%s\n%s" % [
		selected_slot_label,
		hover_suffix,
		GameState.get_equipment_slot_inventory_summary(active_slot)
	]
	_equipped_label.text = "현재 장착: %s" % _get_equipment_name(equipped_item_id)

	var compare_lines: Array[String] = []
	if active_item_id == "":
		if _hovered_slot != "":
			compare_lines.append("슬롯 hover 중: %s" % _get_equipment_name(equipped_item_id))
			compare_lines.append("보유 후보를 hover 또는 선택하면 자동 비교가 표시됩니다.")
		else:
			compare_lines.append("후보 장비를 선택하면 자동 비교가 표시됩니다.")
	else:
		compare_lines.append("후보: %s" % _get_equipment_name(active_item_id))
		compare_lines.append(_format_compare_summary(active_item_id, equipped_item_id))
	_compare_label.text = "\n".join(compare_lines)
	_equip_button.disabled = _selected_item_id == ""
	_unequip_button.disabled = selected_equipped_item_id == ""


func _select_slot(slot_name: String) -> void:
	if not SLOT_LABELS.has(slot_name):
		return
	_selected_slot = slot_name
	_selected_item_id = ""
	_hovered_item_id = ""
	_refresh_window()


func _on_slot_button_pressed(slot_name: String) -> void:
	_select_slot(slot_name)


func _on_slot_button_mouse_entered(slot_name: String) -> void:
	_hovered_slot = slot_name
	_refresh_detail_panel()


func _on_slot_button_mouse_exited(slot_name: String) -> void:
	if slot_name != "" and _hovered_slot != slot_name:
		return
	_hovered_slot = ""
	_refresh_detail_panel()


func _on_slot_button_gui_input(event: InputEvent, slot_name: String) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and not mouse_event.double_click:
		var equipped_item_id := str(GameState.get_equipped_items().get(slot_name, ""))
		if equipped_item_id != "":
			_drag_equipped_slot = slot_name
			_drag_owned_item_id = ""
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.double_click:
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			if _drag_owned_item_id != "":
				_attempt_drag_equip(slot_name)
			_clear_drag_state()
		return
	if not mouse_event.pressed:
		return
	_clear_drag_state()
	_select_slot(slot_name)
	_unequip_selected_slot()


func _on_owned_item_button_pressed(item_id: String) -> void:
	_selected_item_id = item_id
	_refresh_item_selection()
	_refresh_detail_panel()


func _on_owned_item_button_mouse_entered(item_id: String) -> void:
	_hovered_item_id = item_id
	_refresh_detail_panel()


func _on_owned_item_button_mouse_exited(item_id: String) -> void:
	if item_id != "" and _hovered_item_id != item_id:
		return
	_hovered_item_id = ""
	_refresh_detail_panel()


func _on_owned_item_button_gui_input(event: InputEvent, item_id: String) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and not mouse_event.double_click:
		_drag_owned_item_id = item_id
		_drag_equipped_slot = ""
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.double_click:
		return
	if not mouse_event.pressed:
		return
	_clear_drag_state()
	_selected_item_id = item_id
	_refresh_item_selection()
	_refresh_detail_panel()
	_equip_selected_item()


func _on_owned_panel_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or mouse_event.pressed:
		return
	if _drag_equipped_slot != "":
		_attempt_drag_unequip()
	_clear_drag_state()


func _equip_selected_item() -> bool:
	if _selected_item_id == "":
		return false
	var changed := GameState.equip_inventory_item(_selected_slot, _selected_item_id)
	if changed:
		_selected_item_id = ""
		_clear_drag_state()
	return changed


func _unequip_selected_slot() -> bool:
	var changed := GameState.unequip_item_to_inventory(_selected_slot)
	if changed:
		_selected_item_id = ""
		_clear_drag_state()
	return changed


func _attempt_drag_equip(slot_name: String) -> bool:
	if _drag_owned_item_id == "":
		return false
	var item: Dictionary = GameDatabase.get_equipment(_drag_owned_item_id)
	if item.is_empty():
		return false
	if str(item.get("slot_type", "")) != slot_name:
		return false
	_select_slot(slot_name)
	_selected_item_id = _drag_owned_item_id
	_refresh_item_selection()
	_refresh_detail_panel()
	return _equip_selected_item()


func _attempt_drag_unequip() -> bool:
	if _drag_equipped_slot == "":
		return false
	_select_slot(_drag_equipped_slot)
	return _unequip_selected_slot()


func _clear_drag_state() -> void:
	_drag_owned_item_id = ""
	_drag_equipped_slot = ""


func _get_active_slot_name() -> String:
	if _hovered_item_id != "":
		var item: Dictionary = GameDatabase.get_equipment(_hovered_item_id)
		var hover_slot := str(item.get("slot_type", ""))
		if hover_slot != "":
			return hover_slot
	if _hovered_slot != "" and SLOT_LABELS.has(_hovered_slot):
		return _hovered_slot
	return _selected_slot


func _get_active_candidate_item_id() -> String:
	if _hovered_item_id != "":
		return _hovered_item_id
	if _get_active_slot_name() != _selected_slot:
		return ""
	return _selected_item_id


func _get_equipment_name(item_id: String) -> String:
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "(비어 있음)"
	return str(item.get("display_name", item_id))


func _build_slot_tooltip_text(slot_name: String, item_id: String) -> String:
	return "%s 슬롯\n현재 장착: %s" % [
		str(SLOT_LABELS.get(slot_name, slot_name)),
		_get_equipment_name(item_id)
	]


func _build_owned_item_tooltip_text(item_id: String) -> String:
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "알 수 없는 장비"
	var slot_name := str(item.get("slot_type", ""))
	var equipped_item_id := str(GameState.get_equipped_items().get(slot_name, ""))
	return "%s\n%s\n현재 장착 비교 대상: %s" % [
		_get_equipment_name(item_id),
		_format_stat_lines(item_id),
		_get_equipment_name(equipped_item_id)
	]


func _format_compare_summary(candidate_item_id: String, equipped_item_id: String) -> String:
	var candidate_stats := _get_stat_modifier_dictionary(candidate_item_id)
	var equipped_stats := _get_stat_modifier_dictionary(equipped_item_id)
	var compare_lines: Array[String] = []
	for stat_name in STAT_LABELS.keys():
		var candidate_value := float(candidate_stats.get(stat_name, 0.0))
		var equipped_value := float(equipped_stats.get(stat_name, 0.0))
		if is_zero_approx(candidate_value) and is_zero_approx(equipped_value):
			continue
		var delta := candidate_value - equipped_value
		var prefix := "+" if delta >= 0.0 else ""
		compare_lines.append(
			"%s %s%s" % [str(STAT_LABELS.get(stat_name, stat_name)), prefix, _format_stat_value(stat_name, delta)]
		)
	if compare_lines.is_empty():
		return "변화되는 핵심 스탯이 없습니다."
	return "\n".join(compare_lines)


func _format_stat_lines(item_id: String) -> String:
	var stat_lines: Array[String] = []
	var stats := _get_stat_modifier_dictionary(item_id)
	for stat_name in STAT_LABELS.keys():
		var value := float(stats.get(stat_name, 0.0))
		if is_zero_approx(value):
			continue
		stat_lines.append("%s %s" % [str(STAT_LABELS.get(stat_name, stat_name)), _format_stat_value(stat_name, value)])
	if stat_lines.is_empty():
		return "핵심 보정 없음"
	return ", ".join(stat_lines)


func _get_stat_modifier_dictionary(item_id: String) -> Dictionary:
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return {}
	return item.get("stat_modifiers", {})


func _format_stat_value(stat_name: String, value: float) -> String:
	if stat_name in ["cooldown_recovery", "cast_speed"]:
		return "%d%%" % int(round(value * 100.0))
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%.2f" % value


func _apply_slot_button_skin(button: Button) -> void:
	button.toggle_mode = true
	button.add_theme_stylebox_override("normal", _build_soft_slot_style(Color(0.93, 0.95, 0.99, 1.0), Color(0.73, 0.79, 0.90, 1.0)))
	button.add_theme_stylebox_override("hover", _build_soft_slot_style(Color(0.90, 0.96, 1.0, 1.0), Color(0.30, 0.65, 0.92, 1.0)))
	button.add_theme_stylebox_override("pressed", _build_soft_slot_style(Color(0.82, 0.91, 1.0, 1.0), Color(0.23, 0.56, 0.86, 1.0)))


func _build_soft_panel_style() -> StyleBox:
	return _build_textured_panel_style(
		Color(0.92, 0.95, 0.99, 0.97),
		Color(0.74, 0.80, 0.89, 1.0),
		10,
		2,
		0.13,
		0.03,
		0.08
	)


func _build_soft_slot_style(fill_color: Color, border_color: Color) -> StyleBox:
	return _build_textured_panel_style(fill_color, border_color, 8, 2, 0.16, 0.045, 0.10)

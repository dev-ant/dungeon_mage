extends "res://scripts/ui/widgets/ui_window_frame.gd"

signal open_window_requested(window_id: String)

const TAB_ORDER := ["장비", "소비", "기타"]
const SLOT_COUNT_PER_TAB := 20
const GRID_COLUMNS := 5
const TAB_TO_STACKABLE_KIND := {"소비": "consumable", "기타": "other"}
const SLOT_TYPE_LABELS := {
	"weapon": "무기",
	"offhand": "보조",
	"head": "머리",
	"body": "상의",
	"legs": "하의",
	"accessory_1": "반지 1",
	"accessory_2": "반지 2"
}
const RARITY_LABELS := {
	"common": "일반",
	"uncommon": "고급",
	"rare": "희귀",
	"epic": "영웅",
	"legendary": "전설"
}

var _tab_container: TabContainer = null
var _count_badge: PanelContainer = null
var _count_label: Label = null
var _tab_grids: Dictionary = {}
var _tab_slot_buttons: Dictionary = {}
var _summary_label: Label = null
var _detail_label: Label = null
var _organize_button: Button = null
var _equip_button: Button = null
var _open_equipment_button: Button = null
var _selected_tab := "장비"
var _selected_slot_index := -1
var _drag_source_index := -1


func _enter_tree() -> void:
	window_id = "inventory"
	window_title = "아이템"
	placeholder_text = ""
	default_size = Vector2(500.0, 468.0)
	default_position = Vector2(120.0, 120.0)
	window_accent_color = Color(0.46, 0.74, 0.96, 0.98)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_inventory_content()
	_connect_runtime_signals()
	_refresh_inventory_state()


func get_tab_slot_grid(tab_name: String) -> GridContainer:
	if not _tab_grids.has(tab_name):
		return null
	return _tab_grids[tab_name]


func get_slot_button(tab_name: String, slot_index: int) -> Button:
	if not _tab_slot_buttons.has(tab_name):
		return null
	var buttons: Array = _tab_slot_buttons[tab_name]
	if slot_index < 0 or slot_index >= buttons.size():
		return null
	return buttons[slot_index] as Button


func get_slot_item_id(tab_name: String, slot_index: int) -> String:
	if tab_name == "장비":
		return _get_equipment_item_at_slot(slot_index)
	var stackable_entry := _get_stackable_slot_entry(tab_name, slot_index)
	return str(stackable_entry.get("item_id", ""))


func get_slot_stack_count(tab_name: String, slot_index: int) -> int:
	if tab_name == "장비":
		return 1 if get_slot_item_id(tab_name, slot_index) != "" else 0
	return int(_get_stackable_slot_entry(tab_name, slot_index).get("count", 0))


func get_detail_text() -> String:
	if _detail_label == null:
		return ""
	return _detail_label.text


func debug_select_slot(tab_name: String, slot_index: int) -> void:
	_select_slot(tab_name, slot_index)


func debug_swap_equipment_slots(first_index: int, second_index: int) -> bool:
	var changed := GameState.swap_equipment_inventory_items(first_index, second_index)
	if changed:
		_selected_tab = "장비"
		_selected_slot_index = second_index
		_refresh_inventory_state()
	return changed


func debug_drag_equipment_slot(source_index: int, target_index: int) -> bool:
	return _apply_equipment_drag_drop(source_index, target_index)


func debug_drag_tab_slot(tab_name: String, source_index: int, target_index: int) -> bool:
	return _apply_tab_drag_drop(tab_name, source_index, target_index)


func debug_organize_equipment_tab() -> bool:
	return _organize_equipment_tab()


func debug_equip_selected_item() -> bool:
	return _activate_selected_item()


func debug_activate_selected_item() -> bool:
	return _activate_selected_item()


func debug_open_equipment_window() -> void:
	open_window_requested.emit("equipment")


func _build_inventory_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return
	var content := VBoxContainer.new()
	content.name = "InventoryContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	content_root.add_child(content)

	var header := HBoxContainer.new()
	header.name = "HeaderRow"
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(header)

	var title_label := Label.new()
	title_label.name = "InventorySummaryLabel"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text = "장비 / 소비 / 기타"
	title_label.add_theme_color_override("font_color", Color(0.90, 0.96, 1.0, 0.98))
	header.add_child(title_label)

	_count_badge = PanelContainer.new()
	_count_badge.name = "CountBadge"
	_apply_info_badge_skin(_count_badge, window_accent_color)
	header.add_child(_count_badge)

	var count_margin := MarginContainer.new()
	count_margin.name = "CountMargin"
	count_margin.add_theme_constant_override("margin_left", 12)
	count_margin.add_theme_constant_override("margin_top", 4)
	count_margin.add_theme_constant_override("margin_right", 12)
	count_margin.add_theme_constant_override("margin_bottom", 4)
	_count_badge.add_child(count_margin)

	_count_label = Label.new()
	_count_label.name = "CountLabel"
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	count_margin.add_child(_count_label)

	_tab_container = TabContainer.new()
	_tab_container.name = "InventoryTabs"
	_tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tab_container.tab_changed.connect(_on_tab_changed)
	_apply_tab_container_skin(_tab_container, Color(0.46, 0.74, 0.96, 0.98))
	content.add_child(_tab_container)

	for tab_name in TAB_ORDER:
		var page := VBoxContainer.new()
		page.name = tab_name
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		page.add_theme_constant_override("separation", 6)
		_tab_container.add_child(page)

		var grid_panel := PanelContainer.new()
		grid_panel.name = "%sPanel" % tab_name
		grid_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grid_panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
		page.add_child(grid_panel)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		grid_panel.add_child(margin)

		var grid := GridContainer.new()
		grid.name = "SlotGrid"
		grid.columns = GRID_COLUMNS
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		margin.add_child(grid)
		_tab_grids[tab_name] = grid

		var buttons: Array[Button] = []
		for slot_index in range(SLOT_COUNT_PER_TAB):
			var button := _create_slot_button(tab_name, slot_index)
			grid.add_child(button)
			buttons.append(button)
		_tab_slot_buttons[tab_name] = buttons

	_summary_label = Label.new()
	_summary_label.name = "SummaryLabel"
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_summary_label)

	_detail_label = Label.new()
	_detail_label.name = "DetailLabel"
	_detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.modulate = Color(0.82, 0.87, 0.96, 0.96)
	content.add_child(_detail_label)

	var action_row := HBoxContainer.new()
	action_row.name = "ActionRow"
	action_row.add_theme_constant_override("separation", 6)
	content.add_child(action_row)

	_organize_button = Button.new()
	_organize_button.name = "OrganizeButton"
	_organize_button.text = "정리"
	_organize_button.focus_mode = Control.FOCUS_NONE
	_apply_action_button_skin(_organize_button, Color(0.62, 0.82, 0.42, 0.98))
	_organize_button.pressed.connect(_organize_current_tab)
	action_row.add_child(_organize_button)

	_equip_button = Button.new()
	_equip_button.name = "EquipButton"
	_equip_button.text = "장착"
	_equip_button.focus_mode = Control.FOCUS_NONE
	_apply_action_button_skin(_equip_button, Color(0.42, 0.74, 0.98, 0.98))
	_equip_button.pressed.connect(_activate_selected_item)
	action_row.add_child(_equip_button)

	_open_equipment_button = Button.new()
	_open_equipment_button.name = "OpenEquipmentButton"
	_open_equipment_button.text = "장비창"
	_open_equipment_button.focus_mode = Control.FOCUS_NONE
	_apply_action_button_skin(_open_equipment_button, Color(0.90, 0.72, 0.36, 0.98), true)
	_open_equipment_button.pressed.connect(func() -> void: open_window_requested.emit("equipment"))
	action_row.add_child(_open_equipment_button)


func _create_slot_button(tab_name: String, slot_index: int) -> Button:
	var button := Button.new()
	button.name = "Slot_%02d" % slot_index
	button.custom_minimum_size = Vector2(74.0, 68.0)
	button.focus_mode = Control.FOCUS_NONE
	button.toggle_mode = true
	button.text = ""
	button.clip_text = true
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.pressed.connect(func() -> void: _select_slot(tab_name, slot_index))
	button.gui_input.connect(_on_slot_gui_input.bind(tab_name, slot_index))
	button.add_theme_stylebox_override("normal", _build_slot_style(false))
	button.add_theme_stylebox_override("hover", _build_slot_style(true))
	button.add_theme_stylebox_override("pressed", _build_slot_style(true))
	button.add_theme_stylebox_override("focus", _build_slot_style(true))
	return button


func _connect_runtime_signals() -> void:
	if not GameState.stats_changed.is_connected(_refresh_inventory_state):
		GameState.stats_changed.connect(_refresh_inventory_state)


func _refresh_inventory_state() -> void:
	_refresh_count_label()
	_refresh_slot_cells()
	_refresh_slot_selection()
	_refresh_summary_and_detail()
	_refresh_action_buttons()


func _refresh_count_label() -> void:
	if _count_label == null:
		return
	var current_count := _get_tab_item_count(_selected_tab)
	_count_label.text = "%d / %d" % [current_count, SLOT_COUNT_PER_TAB]


func _refresh_slot_cells() -> void:
	for tab_name_value in _tab_slot_buttons.keys():
		var tab_name := str(tab_name_value)
		var buttons: Array = _tab_slot_buttons[tab_name]
		for slot_index in range(buttons.size()):
			var button := buttons[slot_index] as Button
			if button == null:
				continue
			if tab_name == "장비":
				var item_id := _get_equipment_item_at_slot(slot_index)
				if item_id == "":
					button.text = ""
					button.tooltip_text = "빈 슬롯"
					continue
				var item: Dictionary = GameDatabase.get_equipment(item_id)
				var display_name := str(item.get("display_name", item_id))
				var rarity := str(item.get("rarity", "common"))
				button.text = "%s\n%s" % [_get_rarity_short_label(rarity), display_name]
				button.tooltip_text = "%s\n%s / %s" % [
					display_name,
					str(SLOT_TYPE_LABELS.get(str(item.get("slot_type", "")), "장비")),
					str(RARITY_LABELS.get(rarity, rarity))
				]
				continue
			var stackable_entry := _get_stackable_slot_entry(tab_name, slot_index)
			var item_id := str(stackable_entry.get("item_id", ""))
			if item_id == "":
				button.text = ""
				button.tooltip_text = "빈 슬롯"
				continue
			var item_data := _get_stackable_item_data(tab_name, item_id)
			var display_name := str(item_data.get("display_name", item_id))
			var count := int(stackable_entry.get("count", 0))
			button.text = "%s\nx%d" % [display_name, count]
			button.tooltip_text = "%s\n수량 x%d\n%s" % [
				display_name,
				count,
				str(item_data.get("description", "설명이 없습니다."))
			]


func _get_tab_item_count(tab_name: String) -> int:
	if tab_name == "장비":
		return mini(GameState.get_equipment_inventory_occupied_count(), SLOT_COUNT_PER_TAB)
	if tab_name == "소비":
		return mini(GameState.get_consumable_inventory_occupied_count(), SLOT_COUNT_PER_TAB)
	if tab_name == "기타":
		return mini(GameState.get_other_inventory_occupied_count(), SLOT_COUNT_PER_TAB)
	return 0


func _on_tab_changed(tab_index: int) -> void:
	if tab_index < 0 or tab_index >= TAB_ORDER.size():
		return
	_selected_tab = TAB_ORDER[tab_index]
	_selected_slot_index = -1
	_drag_source_index = -1
	_refresh_inventory_state()


func _select_slot(tab_name: String, slot_index: int) -> void:
	_selected_tab = tab_name
	_selected_slot_index = slot_index
	_refresh_slot_selection()
	_refresh_summary_and_detail()
	_refresh_action_buttons()


func _refresh_slot_selection() -> void:
	for tab_name_value in _tab_slot_buttons.keys():
		var tab_name := str(tab_name_value)
		var buttons: Array = _tab_slot_buttons[tab_name]
		for button_index in range(buttons.size()):
			var button := buttons[button_index] as Button
			if button == null:
				continue
			var is_selected := tab_name == _selected_tab and button_index == _selected_slot_index
			button.button_pressed = is_selected


func _refresh_summary_and_detail() -> void:
	if _summary_label == null or _detail_label == null:
		return
	if _selected_tab == "장비":
		var item_count := _get_tab_item_count("장비")
		_summary_label.text = "장비 탭  %d / %d칸  드래그로 순서를 바꾸고, 정리 버튼으로 slot/rarity 기준 정렬을 적용할 수 있습니다." % [
			item_count,
			SLOT_COUNT_PER_TAB
		]
		var selected_item_id := _get_selected_equipment_item_id()
		if selected_item_id == "":
			_detail_label.text = "아이템을 선택하면 상세 정보가 표시됩니다."
			return
		var item: Dictionary = GameDatabase.get_equipment(selected_item_id)
		var stat_lines := _format_stat_lines(selected_item_id)
		_detail_label.text = "%s\n슬롯: %s / 희귀도: %s\n\n%s" % [
			str(item.get("display_name", selected_item_id)),
			str(SLOT_TYPE_LABELS.get(str(item.get("slot_type", "")), str(item.get("slot_type", "")))),
			str(RARITY_LABELS.get(str(item.get("rarity", "common")), str(item.get("rarity", "common")))),
			stat_lines
		]
		return
	var item_count := _get_tab_item_count(_selected_tab)
	var behavior_text := (
		"같은 아이템끼리 드래그하면 스택이 합쳐지고, 더블클릭 또는 사용 버튼으로 즉시 소비됩니다."
		if _selected_tab == "소비"
		else "정리로 이름순 정렬이 가능하며, 기타 아이템은 상세 확인 전용입니다."
	)
	_summary_label.text = "%s 탭  %d / %d칸  %s" % [_selected_tab, item_count, SLOT_COUNT_PER_TAB, behavior_text]
	var selected_entry := _get_selected_stackable_entry()
	var item_id := str(selected_entry.get("item_id", ""))
	if item_id == "":
		_detail_label.text = "아이템을 선택하면 상세 정보가 표시됩니다."
		return
	var item_data := _get_stackable_item_data(_selected_tab, item_id)
	_detail_label.text = "%s\n수량: x%d / 최대 스택: %d\n\n%s" % [
		str(item_data.get("display_name", item_id)),
		int(selected_entry.get("count", 0)),
		int(item_data.get("max_stack", 9999)),
		str(item_data.get("description", "설명이 없습니다."))
	]


func _refresh_action_buttons() -> void:
	var is_equipment_tab := _selected_tab == "장비"
	var selected_item_id := _get_selected_equipment_item_id()
	if _organize_button != null:
		_organize_button.disabled = _get_tab_item_count(_selected_tab) <= 1
	if _equip_button != null:
		_equip_button.text = "장착" if is_equipment_tab else ("사용" if _selected_tab == "소비" else "상세")
		if is_equipment_tab:
			_equip_button.disabled = selected_item_id == ""
		elif _selected_tab == "소비":
			_equip_button.disabled = _get_selected_stackable_item_id() == ""
		else:
			_equip_button.disabled = true
	if _open_equipment_button != null:
		_open_equipment_button.disabled = not is_equipment_tab


func _on_slot_gui_input(event: InputEvent, tab_name: String, slot_index: int) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if mouse_event.pressed:
		if mouse_event.double_click:
			_select_slot(tab_name, slot_index)
			_activate_selected_item()
			return
		if get_slot_item_id(tab_name, slot_index) != "":
			_drag_source_index = slot_index
		return
	if _drag_source_index == -1:
		return
	var source_index := _drag_source_index
	_drag_source_index = -1
	if slot_index == source_index:
		return
	_apply_tab_drag_drop(tab_name, source_index, slot_index)


func _apply_equipment_drag_drop(source_index: int, target_index: int) -> bool:
	return _apply_tab_drag_drop("장비", source_index, target_index)


func _apply_tab_drag_drop(tab_name: String, source_index: int, target_index: int) -> bool:
	if source_index < 0 or source_index >= SLOT_COUNT_PER_TAB:
		return false
	if target_index < 0 or target_index >= SLOT_COUNT_PER_TAB:
		return false
	if get_slot_item_id(tab_name, source_index) == "":
		return false
	var changed := false
	if tab_name == "장비":
		if _get_equipment_item_at_slot(target_index) == "":
			changed = GameState.move_equipment_inventory_item(source_index, target_index)
		else:
			changed = GameState.swap_equipment_inventory_items(source_index, target_index)
	else:
		var stackable_kind := str(TAB_TO_STACKABLE_KIND.get(tab_name, ""))
		if stackable_kind == "":
			return false
		changed = GameState.apply_stackable_inventory_drag_drop(
			stackable_kind,
			source_index,
			target_index
		)
	if changed:
		_selected_slot_index = target_index
	_refresh_inventory_state()
	return changed


func _organize_equipment_tab() -> bool:
	_selected_tab = "장비"
	return _organize_current_tab()


func _organize_current_tab() -> bool:
	if _selected_tab == "장비":
		var selected_item_id := _get_selected_equipment_item_id()
		var changed := GameState.organize_equipment_inventory()
		if changed and selected_item_id != "":
			_selected_slot_index = GameState.find_equipment_inventory_slot_by_item(selected_item_id)
		_refresh_inventory_state()
		return changed
	var stackable_kind := str(TAB_TO_STACKABLE_KIND.get(_selected_tab, ""))
	if stackable_kind == "":
		return false
	var selected_item_id := _get_selected_stackable_item_id()
	var changed := GameState.organize_stackable_inventory(stackable_kind)
	if changed and selected_item_id != "":
		_selected_slot_index = _find_stackable_slot_by_item_id(_selected_tab, selected_item_id)
	_refresh_inventory_state()
	return changed


func _activate_selected_item() -> bool:
	if _selected_tab == "장비":
		return _equip_selected_item()
	if _selected_tab == "소비":
		var changed := GameState.use_consumable_inventory_item(_selected_slot_index)
		if changed and _get_selected_stackable_item_id() == "":
			_selected_slot_index = -1
		_refresh_inventory_state()
		return changed
	return false


func _equip_selected_item() -> bool:
	var previous_selected_slot := _selected_slot_index
	var selected_item_id := _get_selected_equipment_item_id()
	if selected_item_id == "":
		return false
	var item: Dictionary = GameDatabase.get_equipment(selected_item_id)
	var slot_name := str(item.get("slot_type", ""))
	if slot_name == "":
		return false
	var changed := GameState.equip_inventory_item(slot_name, selected_item_id)
	if changed:
		var slot_item_after_equip := _get_equipment_item_at_slot(previous_selected_slot)
		_selected_slot_index = previous_selected_slot if slot_item_after_equip != "" else -1
		_refresh_inventory_state()
	return changed


func _get_selected_equipment_item_id() -> String:
	if _selected_tab != "장비":
		return ""
	return _get_equipment_item_at_slot(_selected_slot_index)


func _get_selected_stackable_entry() -> Dictionary:
	if _selected_tab == "장비":
		return {}
	return _get_stackable_slot_entry(_selected_tab, _selected_slot_index)


func _get_selected_stackable_item_id() -> String:
	return str(_get_selected_stackable_entry().get("item_id", ""))


func _get_equipment_item_at_slot(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= SLOT_COUNT_PER_TAB:
		return ""
	return GameState.get_equipment_inventory_item_at(slot_index)


func _get_stackable_slot_entry(tab_name: String, slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= SLOT_COUNT_PER_TAB:
		return {}
	match tab_name:
		"소비":
			return GameState.get_consumable_inventory_item_at(slot_index)
		"기타":
			return GameState.get_other_inventory_item_at(slot_index)
		_:
			return {}


func _get_stackable_item_data(tab_name: String, item_id: String) -> Dictionary:
	match tab_name:
		"소비":
			return GameDatabase.get_consumable_item(item_id)
		"기타":
			return GameDatabase.get_other_item(item_id)
		_:
			return {}


func _find_stackable_slot_by_item_id(tab_name: String, item_id: String) -> int:
	if item_id == "":
		return -1
	for slot_index in range(SLOT_COUNT_PER_TAB):
		if get_slot_item_id(tab_name, slot_index) == item_id:
			return slot_index
	return -1


func _format_stat_lines(item_id: String) -> String:
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	var stats: Dictionary = item.get("stat_modifiers", {})
	if stats.is_empty():
		return "핵심 보정 없음"
	var lines: Array[String] = []
	for stat_name_value in stats.keys():
		var stat_name := str(stat_name_value)
		var value := float(stats.get(stat_name, 0.0))
		if is_zero_approx(value):
			continue
		lines.append("%s %s" % [_get_stat_label(stat_name), _format_stat_value(stat_name, value)])
	lines.sort()
	return "\n".join(lines)


func _get_stat_label(stat_name: String) -> String:
	match stat_name:
		"magic_attack":
			return "마공"
		"max_hp":
			return "최대 HP"
		"max_mp":
			return "최대 MP"
		"mp_regen":
			return "MP 재생"
		"cooldown_recovery":
			return "재감"
		"cast_speed":
			return "시전 속도"
		_:
			return stat_name


func _format_stat_value(stat_name: String, value: float) -> String:
	if stat_name in ["cooldown_recovery", "cast_speed"]:
		return "%d%%" % int(round(value * 100.0))
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%.2f" % value


func _get_rarity_short_label(rarity: String) -> String:
	match rarity:
		"legendary":
			return "전설"
		"epic":
			return "영웅"
		"rare":
			return "희귀"
		"uncommon":
			return "고급"
		_:
			return "일반"


func _build_soft_panel_style() -> StyleBox:
	return _build_asset_compact_panel_style()


func _build_slot_style(active: bool) -> StyleBox:
	return _build_asset_slot_style(active)

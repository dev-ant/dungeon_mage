extends "res://scripts/ui/widgets/ui_window_frame.gd"

const TAB_ORDER := ["진행 가능", "진행 중", "완료"]

var _search_line: LineEdit = null
var _current_area_toggle: CheckBox = null
var _tab_container: TabContainer = null
var _empty_state_labels: Dictionary = {}


func _enter_tree() -> void:
	window_id = "quest"
	window_title = "퀘스트"
	placeholder_text = ""
	default_size = Vector2(440.0, 420.0)
	default_position = Vector2(272.0, 96.0)
	window_accent_color = Color(0.94, 0.76, 0.42, 0.98)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_quest_content()
	_refresh_empty_states()


func get_tab_names() -> Array[String]:
	var tab_names: Array[String] = []
	for tab_name in TAB_ORDER:
		tab_names.append(str(tab_name))
	return tab_names


func get_empty_state_text(tab_name: String) -> String:
	var label := _empty_state_labels.get(tab_name, null) as Label
	return "" if label == null else label.text


func _build_quest_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return

	var content := VBoxContainer.new()
	content.name = "QuestContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	content_root.add_child(content)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 8)
	content.add_child(top_row)

	_search_line = LineEdit.new()
	_search_line.name = "SearchLine"
	_search_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_line.placeholder_text = "퀘스트 검색"
	top_row.add_child(_search_line)

	_current_area_toggle = CheckBox.new()
	_current_area_toggle.name = "CurrentAreaOnlyCheckBox"
	_current_area_toggle.text = "현재 지역만"
	top_row.add_child(_current_area_toggle)

	_tab_container = TabContainer.new()
	_tab_container.name = "QuestTabs"
	_tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_tab_container_skin(_tab_container, Color(0.94, 0.76, 0.42, 0.98))
	content.add_child(_tab_container)

	for tab_name in TAB_ORDER:
		var page := VBoxContainer.new()
		page.name = tab_name
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_tab_container.add_child(page)

		var panel := PanelContainer.new()
		panel.name = "%sPanel" % tab_name
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", _build_empty_panel_style())
		page.add_child(panel)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		panel.add_child(margin)

		var empty_label := Label.new()
		empty_label.name = "EmptyStateLabel"
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		margin.add_child(empty_label)
		_empty_state_labels[tab_name] = empty_label


func _refresh_empty_states() -> void:
	var room_id := str(GameState.current_room_id)
	var room_data := GameDatabase.get_room(room_id)
	var room_name := str(room_data.get("title", room_id))
	for tab_name in TAB_ORDER:
		var label := _empty_state_labels.get(tab_name, null) as Label
		if label == null:
			continue
		label.text = "%s 퀘스트 데이터는 아직 연결되지 않았습니다.\n현재 지역: %s\n이 창은 future quest runtime hook을 위한 shell입니다." % [tab_name, room_name]


func _build_empty_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.93, 0.95, 0.98, 0.97)
	style.border_color = Color(0.74, 0.80, 0.88, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

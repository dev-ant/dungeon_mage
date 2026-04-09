extends "res://scripts/ui/widgets/ui_window_frame.gd"

signal open_window_requested(window_id: String)
signal bind_skill_requested(skill_id: String)

const SCHOOL_ORDER := ["fire", "ice", "lightning", "wind", "water", "plant", "earth", "holy", "dark", "arcane"]
const SKILL_DRAG_BUTTON_SCENE := preload("res://scripts/ui/widgets/skill_bind_drag_button.gd")
const SKILL_VISUAL_HELPER := preload("res://scripts/ui/widgets/skill_visual_helper.gd")

var _category_list: VBoxContainer = null
var _skill_list_root: VBoxContainer = null
var _detail_label: Label = null
var _bind_label: Label = null
var _category_buttons: Dictionary = {}
var _skill_buttons: Dictionary = {}
var _selected_school := "fire"
var _selected_skill_id := ""


func _enter_tree() -> void:
	window_id = "skill"
	window_title = "스킬"
	placeholder_text = ""
	default_size = Vector2(640.0, 460.0)
	default_position = Vector2(180.0, 96.0)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_skill_content()
	_connect_runtime_signals()
	_select_initial_skill()
	_refresh_window()


func get_category_names() -> Array[String]:
	var names: Array[String] = []
	for school in SCHOOL_ORDER:
		names.append(GameState.get_school_display_name(school))
	return names


func get_selected_skill_id() -> String:
	return _selected_skill_id


func get_detail_text() -> String:
	if _detail_label == null:
		return ""
	return _detail_label.text


func get_bind_summary_text() -> String:
	if _bind_label == null:
		return ""
	return _bind_label.text


func debug_select_school(school: String) -> void:
	if SCHOOL_ORDER.has(school):
		_selected_school = school
		_refresh_window()


func debug_select_skill(skill_id: String) -> void:
	_selected_skill_id = skill_id
	_refresh_window()


func debug_request_bind_selected_skill() -> void:
	if _selected_skill_id == "":
		return
	bind_skill_requested.emit(_selected_skill_id)


func debug_get_selected_skill_drag_payload() -> Dictionary:
	return _build_skill_drag_payload(_selected_skill_id)


func _build_skill_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return

	var shell := HBoxContainer.new()
	shell.name = "SkillContent"
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_theme_constant_override("separation", 10)
	content_root.add_child(shell)

	var category_panel := PanelContainer.new()
	category_panel.name = "CategoryPanel"
	category_panel.custom_minimum_size = Vector2(132.0, 0.0)
	category_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	category_panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
	shell.add_child(category_panel)

	var category_margin := MarginContainer.new()
	category_margin.add_theme_constant_override("margin_left", 10)
	category_margin.add_theme_constant_override("margin_top", 10)
	category_margin.add_theme_constant_override("margin_right", 10)
	category_margin.add_theme_constant_override("margin_bottom", 10)
	category_panel.add_child(category_margin)

	_category_list = VBoxContainer.new()
	_category_list.name = "CategoryList"
	_category_list.add_theme_constant_override("separation", 6)
	category_margin.add_child(_category_list)

	for school in SCHOOL_ORDER:
		var button := Button.new()
		button.name = "%sButton" % school.capitalize()
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.text = GameState.get_school_display_name(school)
		button.pressed.connect(_on_school_pressed.bind(school))
		_apply_tab_button_skin(button)
		_category_list.add_child(button)
		_category_buttons[school] = button

	var list_panel := PanelContainer.new()
	list_panel.name = "SkillListPanel"
	list_panel.custom_minimum_size = Vector2(220.0, 0.0)
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
	shell.add_child(list_panel)

	var list_margin := MarginContainer.new()
	list_margin.add_theme_constant_override("margin_left", 10)
	list_margin.add_theme_constant_override("margin_top", 10)
	list_margin.add_theme_constant_override("margin_right", 10)
	list_margin.add_theme_constant_override("margin_bottom", 10)
	list_panel.add_child(list_margin)

	var list_column := VBoxContainer.new()
	list_column.name = "SkillListColumn"
	list_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_column.add_theme_constant_override("separation", 6)
	list_margin.add_child(list_column)

	var list_title := Label.new()
	list_title.name = "SkillListTitle"
	list_title.text = "스킬 목록"
	list_column.add_child(list_title)

	var skill_scroll := ScrollContainer.new()
	skill_scroll.name = "SkillScroll"
	skill_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skill_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_column.add_child(skill_scroll)

	_skill_list_root = VBoxContainer.new()
	_skill_list_root.name = "SkillListRoot"
	_skill_list_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_skill_list_root.add_theme_constant_override("separation", 4)
	skill_scroll.add_child(_skill_list_root)

	var detail_panel := PanelContainer.new()
	detail_panel.name = "SkillDetailPanel"
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override("panel", _build_soft_panel_style())
	shell.add_child(detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 12)
	detail_margin.add_theme_constant_override("margin_top", 12)
	detail_margin.add_theme_constant_override("margin_right", 12)
	detail_margin.add_theme_constant_override("margin_bottom", 12)
	detail_panel.add_child(detail_margin)

	var detail_column := VBoxContainer.new()
	detail_column.name = "DetailColumn"
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 8)
	detail_margin.add_child(detail_column)

	_detail_label = Label.new()
	_detail_label.name = "DetailLabel"
	_detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_column.add_child(_detail_label)

	_bind_label = Label.new()
	_bind_label.name = "BindLabel"
	_bind_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bind_label.modulate = Color(0.86, 0.91, 1.0, 0.95)
	detail_column.add_child(_bind_label)

	var action_row := HBoxContainer.new()
	action_row.name = "ActionRow"
	action_row.add_theme_constant_override("separation", 6)
	detail_column.add_child(action_row)

	var bind_button := Button.new()
	bind_button.name = "BindButton"
	bind_button.text = "키 등록"
	bind_button.focus_mode = Control.FOCUS_NONE
	bind_button.pressed.connect(_on_bind_button_pressed)
	_apply_asset_large_button_skin(bind_button)
	action_row.add_child(bind_button)

	var open_button := Button.new()
	open_button.name = "OpenKeyBindingsButton"
	open_button.text = "키 설정 보기"
	open_button.focus_mode = Control.FOCUS_NONE
	open_button.pressed.connect(func() -> void: open_window_requested.emit("key_bindings"))
	_apply_asset_large_button_skin(open_button)
	action_row.add_child(open_button)


func _connect_runtime_signals() -> void:
	if not GameState.stats_changed.is_connected(_refresh_window):
		GameState.stats_changed.connect(_refresh_window)


func _select_initial_skill() -> void:
	var school_skills := _get_skill_ids_for_school(_selected_school)
	if not school_skills.is_empty():
		_selected_skill_id = school_skills[0]


func _refresh_window() -> void:
	_refresh_category_buttons()
	_refresh_skill_list()
	_refresh_detail_panel()


func _refresh_category_buttons() -> void:
	for school_value in _category_buttons.keys():
		var school := str(school_value)
		var button := _category_buttons[school] as Button
		if button == null:
			continue
		button.button_pressed = school == _selected_school


func _refresh_skill_list() -> void:
	if _skill_list_root == null:
		return
	for child in _skill_list_root.get_children():
		child.queue_free()
	_skill_buttons.clear()

	var school_skills := _get_skill_ids_for_school(_selected_school)
	if school_skills.is_empty():
		var empty_label := Label.new()
		empty_label.name = "EmptyStateLabel"
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "현재 학교에 표시할 전투 스킬이 없습니다."
		_skill_list_root.add_child(empty_label)
		_selected_skill_id = ""
		return

	if not school_skills.has(_selected_skill_id):
		_selected_skill_id = school_skills[0]

	for skill_id in school_skills:
		var button := SKILL_DRAG_BUTTON_SCENE.new()
		button.name = "%sButton" % skill_id
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = _build_skill_button_text(skill_id)
		button.skill_id = skill_id
		button.tooltip_text = _build_skill_drag_tooltip(skill_id)
		SKILL_VISUAL_HELPER.apply_skill_icon(button, skill_id, 18)
		button.pressed.connect(_on_skill_pressed.bind(skill_id))
		_apply_skill_button_skin(button)
		button.button_pressed = skill_id == _selected_skill_id
		_skill_list_root.add_child(button)
		_skill_buttons[skill_id] = button


func _refresh_detail_panel() -> void:
	if _detail_label == null or _bind_label == null:
		return
	if _selected_skill_id == "":
		_detail_label.text = "스킬을 선택하면 상세 정보가 표시됩니다."
		_bind_label.text = "현재 등록 키: 없음"
		return
	var skill_data: Dictionary = GameDatabase.get_skill_data(_selected_skill_id)
	var runtime := _build_runtime_summary(_selected_skill_id, skill_data)
	var key_labels := GameState.get_action_hotkey_labels_for_skill(_selected_skill_id)
	var cooldown := float(runtime.get("cooldown", 0.0))
	var mana_cost := GameState.get_skill_mana_cost(_selected_skill_id)
	_detail_label.text = "%s\n레벨 %d / 숙련도 %d\n마나 %.1f / 쿨다운 %.1f초\n\n%s" % [
		str(skill_data.get("display_name", _selected_skill_id)),
		GameState.get_skill_level(_selected_skill_id),
		int(GameState.spell_mastery.get(_selected_skill_id, 0)),
		mana_cost,
		cooldown,
		str(skill_data.get("description", "설명이 아직 없습니다."))
	]
	_bind_label.text = "현재 등록 키: %s" % (
		"없음" if key_labels.is_empty() else ", ".join(key_labels)
	)


func _get_skill_ids_for_school(school: String) -> Array[String]:
	var skills: Array[String] = []
	for raw_skill in GameDatabase.get_all_skills():
		if typeof(raw_skill) != TYPE_DICTIONARY:
			continue
		var skill_data: Dictionary = raw_skill
		var skill_id := str(skill_data.get("skill_id", ""))
		if skill_id == "":
			continue
		var runtime_castable_id := GameDatabase.get_runtime_castable_skill_id(skill_id)
		if runtime_castable_id == "":
			continue
		var resolved_school := str(skill_data.get("element", skill_data.get("school", "")))
		if resolved_school == "":
			resolved_school = GameState.resolve_runtime_school(skill_id, runtime_castable_id)
		if resolved_school != school:
			continue
		if skills.has(runtime_castable_id):
			continue
		skills.append(runtime_castable_id)
	skills.sort_custom(func(a: String, b: String) -> bool:
		var a_name := str(GameDatabase.get_skill_data(a).get("display_name", a))
		var b_name := str(GameDatabase.get_skill_data(b).get("display_name", b))
		return a_name.naturalnocasecmp_to(b_name) < 0
	)
	return skills


func _build_skill_button_text(skill_id: String) -> String:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	return "%s\nLv.%d  MP %.1f" % [
		str(skill_data.get("display_name", skill_id)),
		GameState.get_skill_level(skill_id),
		GameState.get_skill_mana_cost(skill_id)
	]


func _build_runtime_summary(skill_id: String, skill_data: Dictionary) -> Dictionary:
	if not GameDatabase.get_spell(skill_id).is_empty():
		return GameState.get_spell_runtime(skill_id)
	return GameState.get_data_driven_skill_runtime(skill_id, skill_data)


func _build_skill_drag_payload(skill_id: String) -> Dictionary:
	if skill_id == "":
		return {}
	var resolved_skill_id := GameDatabase.get_runtime_castable_skill_id(skill_id)
	if resolved_skill_id == "":
		resolved_skill_id = skill_id
	var skill_data: Dictionary = GameDatabase.get_skill_data(resolved_skill_id)
	return {
		"type": "skill_hotkey_bind",
		"skill_id": resolved_skill_id,
		"display_name": str(skill_data.get("display_name", resolved_skill_id))
	}


func _build_skill_drag_tooltip(skill_id: String) -> String:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	return "%s\n드래그해서 키 설정 슬롯에 바로 등록할 수 있습니다." % str(
		skill_data.get("display_name", skill_id)
	)


func _build_soft_panel_style() -> StyleBox:
	return _build_asset_compact_panel_style()


func _apply_tab_button_skin(button: Button) -> void:
	_apply_asset_large_button_skin(button)


func _apply_skill_button_skin(button: Button) -> void:
	_apply_asset_large_button_skin(button)


func _on_school_pressed(school: String) -> void:
	_selected_school = school
	_refresh_window()


func _on_skill_pressed(skill_id: String) -> void:
	_selected_skill_id = skill_id
	_refresh_window()


func _on_bind_button_pressed() -> void:
	if _selected_skill_id == "":
		return
	bind_skill_requested.emit(_selected_skill_id)

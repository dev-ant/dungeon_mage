extends Control

const BUTTONS_TEX := "res://assets/ui/pixel_rpg/Buttons.png"
const ACTION_PANEL_TEX := "res://assets/ui/pixel_rpg/Action_panel.png"
const HOTBAR_SLOT_SIZE := Vector2(56, 56)
const HOTBAR_READY_MODULATE := Color(1.0, 1.0, 1.0, 1.0)
const HOTBAR_UNAVAILABLE_MODULATE := Color(0.55, 0.55, 0.6, 0.95)
const HOTBAR_EMPTY_MODULATE := Color(0.45, 0.45, 0.5, 0.75)
const TOOLTIP_BG_COLOR := Color(0.08, 0.10, 0.16, 0.94)
const TOOLTIP_BORDER_COLOR := Color(0.45, 0.60, 0.82, 0.95)

@onready var room_label: Label = $Margin/Top/RoomLabel
@onready var hp_label: Label = $Margin/Top/HpLabel
@onready var mastery_label: Label = $Margin/Top/MasteryLabel
@onready var resonance_label: Label = $Margin/Top/ResonanceLabel
@onready var buff_label: Label = $Margin/Top/BuffLabel
@onready var combo_label: Label = $Margin/Top/ComboLabel
@onready var admin_label: Label = $Margin/Top/AdminLabel
@onready var hint_label: Label = $Margin/Bottom/HintLabel

var _hotbar_container: PanelContainer = null
var _hotbar_button_bar: HBoxContainer = null
var _hotbar_button_nodes: Array[Button] = []
var _target_panel_container: PanelContainer = null
var _target_name_label: Label = null
var _target_hp_bar: ProgressBar = null
var _target_hp_value_label: Label = null
var _target_meta_label: Label = null
var _resource_cluster_container: PanelContainer = null
var _resource_cluster_info_label: Label = null
var _hp_bar: ProgressBar = null
var _mp_bar: ProgressBar = null
var _hp_value_label: Label = null
var _mp_value_label: Label = null
var _buff_chip_panel: PanelContainer = null
var _buff_chip_row: HBoxContainer = null
var _tooltip_panel: PanelContainer = null
var _tooltip_label: Label = null
var _hovered_slot_index := -1
var _drag_source_slot_index := -1
var _show_primary_action_row := true
var _show_active_buff_row := true

const SCHOOL_CHIP_COLORS := {
	"fire": Color(0.95, 0.38, 0.12),
	"ice": Color(0.30, 0.72, 0.95),
	"lightning": Color(0.95, 0.88, 0.15),
	"dark": Color(0.62, 0.22, 0.90),
	"plant": Color(0.28, 0.82, 0.30),
	"holy": Color(0.95, 0.93, 0.68),
	"arcane": Color(0.72, 0.58, 1.0),
	"earth": Color(0.72, 0.54, 0.32),
	"water": Color(0.26, 0.70, 0.98),
	"wind": Color(0.58, 0.92, 0.82),
	"": Color(0.70, 0.70, 0.70),
}


func _process(_delta: float) -> void:
	refresh("")


func _ready() -> void:
	GameState.stats_changed.connect(refresh.bind(""))
	GameState.ui_message_changed.connect(_on_message)
	_configure_debug_fallback_labels()
	_build_target_panel()
	_build_resource_cluster()
	_build_hotbar_buttons()
	_build_buff_chips()
	_build_tooltip_panel()
	refresh("")


func _configure_debug_fallback_labels() -> void:
	room_label.add_theme_font_size_override("font_size", 22)
	hp_label.add_theme_font_size_override("font_size", 13)
	mastery_label.add_theme_font_size_override("font_size", 13)
	resonance_label.add_theme_font_size_override("font_size", 13)
	buff_label.add_theme_font_size_override("font_size", 12)
	combo_label.add_theme_font_size_override("font_size", 12)
	admin_label.add_theme_font_size_override("font_size", 12)
	hp_label.modulate = Color(0.84, 0.86, 0.96, 0.72)
	mastery_label.modulate = Color(0.84, 0.86, 0.96, 0.72)
	resonance_label.modulate = Color(0.84, 0.86, 0.96, 0.72)
	buff_label.modulate = Color(0.84, 0.86, 0.96, 0.58)
	combo_label.modulate = Color(0.84, 0.86, 0.96, 0.58)
	admin_label.modulate = Color(0.95, 0.82, 0.52, 0.72)
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.modulate = Color(0.96, 0.92, 0.78)


func _build_resource_cluster() -> void:
	if not has_node("Margin/Bottom"):
		return
	var wrapper := CenterContainer.new()
	wrapper.name = "ResourceClusterWrap"
	$Margin/Bottom.add_child(wrapper)
	$Margin/Bottom.move_child(wrapper, 0)

	_resource_cluster_container = PanelContainer.new()
	var panel_style := _make_action_panel_style()
	if panel_style != null:
		_resource_cluster_container.add_theme_stylebox_override("panel", panel_style)
	wrapper.add_child(_resource_cluster_container)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	_resource_cluster_container.add_child(content)

	_resource_cluster_info_label = Label.new()
	_resource_cluster_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_resource_cluster_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resource_cluster_info_label.custom_minimum_size = Vector2(440, 0)
	_resource_cluster_info_label.add_theme_font_size_override("font_size", 12)
	_resource_cluster_info_label.modulate = Color(0.94, 0.94, 0.98)
	content.add_child(_resource_cluster_info_label)

	var bars := HBoxContainer.new()
	bars.alignment = BoxContainer.ALIGNMENT_CENTER
	bars.add_theme_constant_override("separation", 12)
	content.add_child(bars)

	var hp_box := VBoxContainer.new()
	hp_box.add_theme_constant_override("separation", 2)
	bars.add_child(hp_box)
	var hp_title := Label.new()
	hp_title.text = "HP"
	hp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_title.add_theme_font_size_override("font_size", 12)
	hp_box.add_child(hp_title)
	_hp_bar = ProgressBar.new()
	_hp_bar.min_value = 0.0
	_hp_bar.max_value = 1.0
	_hp_bar.value = 1.0
	_hp_bar.custom_minimum_size = Vector2(220, 16)
	_hp_bar.show_percentage = false
	_apply_bar_style(_hp_bar, Color(0.88, 0.22, 0.24), Color(0.22, 0.07, 0.08))
	hp_box.add_child(_hp_bar)
	_hp_value_label = Label.new()
	_hp_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_value_label.add_theme_font_size_override("font_size", 11)
	_hp_value_label.modulate = Color(1.0, 0.82, 0.82)
	hp_box.add_child(_hp_value_label)

	var mp_box := VBoxContainer.new()
	mp_box.add_theme_constant_override("separation", 2)
	bars.add_child(mp_box)
	var mp_title := Label.new()
	mp_title.text = "MP"
	mp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mp_title.add_theme_font_size_override("font_size", 12)
	mp_box.add_child(mp_title)
	_mp_bar = ProgressBar.new()
	_mp_bar.min_value = 0.0
	_mp_bar.max_value = 1.0
	_mp_bar.value = 1.0
	_mp_bar.custom_minimum_size = Vector2(220, 16)
	_mp_bar.show_percentage = false
	_apply_bar_style(_mp_bar, Color(0.18, 0.45, 0.88), Color(0.06, 0.12, 0.28))
	mp_box.add_child(_mp_bar)
	_mp_value_label = Label.new()
	_mp_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mp_value_label.add_theme_font_size_override("font_size", 11)
	_mp_value_label.modulate = Color(0.80, 0.85, 1.0)
	mp_box.add_child(_mp_value_label)


func _build_target_panel() -> void:
	if not has_node("Margin/Top"):
		return
	_target_panel_container = PanelContainer.new()
	_target_panel_container.name = "TargetPanel"
	var panel_style := _make_action_panel_style()
	if panel_style != null:
		_target_panel_container.add_theme_stylebox_override("panel", panel_style)
	$Margin/Top.add_child(_target_panel_container)
	$Margin/Top.move_child(_target_panel_container, 0)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	_target_panel_container.add_child(content)

	_target_name_label = Label.new()
	_target_name_label.custom_minimum_size = Vector2(300, 0)
	_target_name_label.add_theme_font_size_override("font_size", 14)
	_target_name_label.modulate = Color(0.98, 0.95, 0.86)
	content.add_child(_target_name_label)

	_target_hp_bar = ProgressBar.new()
	_target_hp_bar.min_value = 0.0
	_target_hp_bar.max_value = 1.0
	_target_hp_bar.value = 1.0
	_target_hp_bar.custom_minimum_size = Vector2(300, 14)
	_target_hp_bar.show_percentage = false
	_apply_bar_style(_target_hp_bar, Color(0.88, 0.22, 0.24), Color(0.22, 0.07, 0.08))
	content.add_child(_target_hp_bar)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	content.add_child(footer)

	_target_hp_value_label = Label.new()
	_target_hp_value_label.add_theme_font_size_override("font_size", 11)
	_target_hp_value_label.modulate = Color(1.0, 0.82, 0.82)
	footer.add_child(_target_hp_value_label)

	_target_meta_label = Label.new()
	_target_meta_label.add_theme_font_size_override("font_size", 11)
	_target_meta_label.modulate = Color(0.82, 0.88, 0.98)
	footer.add_child(_target_meta_label)


func _build_tooltip_panel() -> void:
	if not has_node("Margin/Bottom"):
		return
	var wrapper := CenterContainer.new()
	wrapper.name = "TooltipWrap"
	$Margin/Bottom.add_child(wrapper)
	$Margin/Bottom.move_child(wrapper, 0)

	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.visible = false
	_tooltip_panel.add_theme_stylebox_override(
		"panel", _make_flat_panel_style(TOOLTIP_BG_COLOR, TOOLTIP_BORDER_COLOR, 2)
	)
	wrapper.add_child(_tooltip_panel)

	_tooltip_label = Label.new()
	_tooltip_label.custom_minimum_size = Vector2(460, 0)
	_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_label.add_theme_font_size_override("font_size", 12)
	_tooltip_label.modulate = Color(0.95, 0.97, 1.0)
	_tooltip_panel.add_child(_tooltip_label)


func _build_buff_chips() -> void:
	if not has_node("Margin/Top"):
		return
	_buff_chip_panel = PanelContainer.new()
	_buff_chip_panel.name = "BuffChipPanel"
	_buff_chip_panel.add_theme_stylebox_override(
		"panel", _make_flat_panel_style(Color(0.07, 0.08, 0.12, 0.82), Color(0.28, 0.32, 0.44, 0.92), 2)
	)
	$Margin/Top.add_child(_buff_chip_panel)
	$Margin/Top.move_child(_buff_chip_panel, 1)

	_buff_chip_row = HBoxContainer.new()
	_buff_chip_row.name = "BuffChipRow"
	_buff_chip_row.add_theme_constant_override("separation", 6)
	_buff_chip_panel.add_child(_buff_chip_row)


func _build_hotbar_buttons() -> void:
	if not has_node("Margin/Bottom"):
		return
	var wrapper := CenterContainer.new()
	wrapper.name = "HotbarWrap"
	$Margin/Bottom.add_child(wrapper)
	$Margin/Bottom.move_child(wrapper, 2)

	_hotbar_container = PanelContainer.new()
	var panel_style := _make_action_panel_style()
	if panel_style != null:
		_hotbar_container.add_theme_stylebox_override("panel", panel_style)
	wrapper.add_child(_hotbar_container)

	_hotbar_button_bar = HBoxContainer.new()
	_hotbar_button_bar.name = "HotbarButtonBar"
	_hotbar_button_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_hotbar_button_bar.add_theme_constant_override("separation", 4)
	_hotbar_container.add_child(_hotbar_button_bar)

	for i in range(GameState.VISIBLE_HOTBAR_SLOT_COUNT):
		var btn := Button.new()
		btn.text = str(i + 1)
		btn.custom_minimum_size = HOTBAR_SLOT_SIZE
		btn.focus_mode = Control.FOCUS_NONE
		btn.clip_text = true
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.82))
		btn.add_theme_color_override("font_pressed_color", Color(0.84, 0.84, 0.84))
		_apply_hotbar_button_skin(btn)
		btn.gui_input.connect(_on_hud_hotbar_button_gui_input.bind(i))
		btn.mouse_entered.connect(_on_hud_hotbar_button_hovered.bind(i))
		btn.mouse_exited.connect(_on_hud_hotbar_button_unhovered.bind(i))
		_hotbar_button_bar.add_child(btn)
		_hotbar_button_nodes.append(btn)


func _apply_bar_style(bar: ProgressBar, fill_color: Color, bg_color: Color) -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 2
	fill.corner_radius_top_right = 2
	fill.corner_radius_bottom_left = 2
	fill.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = bg_color
	bg.corner_radius_top_left = 2
	bg.corner_radius_top_right = 2
	bg.corner_radius_bottom_left = 2
	bg.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg)


func _make_flat_panel_style(bg_color: Color, border_color: Color, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	return style


func _make_action_panel_style() -> StyleBoxTexture:
	var tex: Texture2D = load(ACTION_PANEL_TEX)
	if tex == null:
		return null
	var style := StyleBoxTexture.new()
	style.texture = tex
	style.region_rect = Rect2(8, 8, 176, 27)
	style.texture_margin_left = 5.0
	style.texture_margin_top = 5.0
	style.texture_margin_right = 5.0
	style.texture_margin_bottom = 5.0
	style.expand_margin_left = 4.0
	style.expand_margin_top = 4.0
	style.expand_margin_right = 4.0
	style.expand_margin_bottom = 4.0
	return style


func _apply_hotbar_button_skin(btn: Button) -> void:
	var tex: Texture2D = load(BUTTONS_TEX)
	if tex == null:
		return

	var style_normal := StyleBoxTexture.new()
	style_normal.texture = tex
	style_normal.region_rect = Rect2(13, 12, 22, 22)
	style_normal.texture_margin_left = 3.0
	style_normal.texture_margin_top = 3.0
	style_normal.texture_margin_right = 3.0
	style_normal.texture_margin_bottom = 3.0

	var style_hover := StyleBoxTexture.new()
	style_hover.texture = tex
	style_hover.region_rect = Rect2(109, 12, 22, 22)
	style_hover.texture_margin_left = 3.0
	style_hover.texture_margin_top = 3.0
	style_hover.texture_margin_right = 3.0
	style_hover.texture_margin_bottom = 3.0

	var style_pressed := StyleBoxTexture.new()
	style_pressed.texture = tex
	style_pressed.region_rect = Rect2(61, 12, 22, 22)
	style_pressed.texture_margin_left = 3.0
	style_pressed.texture_margin_top = 3.0
	style_pressed.texture_margin_right = 3.0
	style_pressed.texture_margin_bottom = 3.0

	var style_disabled := StyleBoxTexture.new()
	style_disabled.texture = tex
	style_disabled.region_rect = Rect2(157, 12, 22, 22)
	style_disabled.texture_margin_left = 3.0
	style_disabled.texture_margin_top = 3.0
	style_disabled.texture_margin_right = 3.0
	style_disabled.texture_margin_bottom = 3.0

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", style_hover)
	btn.add_theme_stylebox_override("disabled", style_disabled)
	btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _refresh_hotbar_buttons() -> void:
	if _hotbar_button_bar == null:
		return
	if not _show_primary_action_row:
		_hide_tooltip_panel()
		_hovered_slot_index = -1
		return
	var hotbar: Array = GameState.get_visible_spell_hotbar()
	for i in range(_hotbar_button_nodes.size()):
		var btn: Button = _hotbar_button_nodes[i]
		if i >= hotbar.size():
			btn.visible = false
			continue
		btn.visible = true
		var slot: Dictionary = hotbar[i]
		var tooltip: Dictionary = _get_hotbar_tooltip_data(i)
		var skill_id := str(slot.get("skill_id", ""))
		var slot_label := str(slot.get("label", str(i + 1)))
		if skill_id == "":
			btn.text = "%s\nEmpty" % slot_label
			btn.modulate = HOTBAR_EMPTY_MODULATE
			continue
		var short_name := _get_skill_short_name(skill_id)
		var cooldown := float(tooltip.get("cooldown", 0.0))
		var current_state := str(tooltip.get("current_state", "ready"))
		if cooldown > 0.0:
			btn.text = "%s\n%s\nCD %.1f" % [slot_label, short_name, cooldown]
		elif current_state == "ready":
			btn.text = "%s\n%s" % [slot_label, short_name]
		else:
			btn.text = "%s\n%s\n%s" % [slot_label, short_name, _get_compact_state_text(current_state)]
		btn.modulate = _get_hotbar_slot_modulate(tooltip)


func _refresh_buff_chips() -> void:
	if _buff_chip_row == null:
		return
	for child in _buff_chip_row.get_children():
		child.queue_free()
	if not _show_active_buff_row:
		return
	for buff_value in GameState.active_buffs:
		var buff: Dictionary = buff_value
		var skill_id := str(buff.get("skill_id", ""))
		var display_name := str(buff.get("display_name", skill_id))
		var remaining := float(buff.get("remaining", 0.0))
		var school := ""
		if skill_id != "":
			var skill_data := GameDatabase.get_skill_data(skill_id)
			school = str(skill_data.get("school", ""))
		var chip_color: Color = SCHOOL_CHIP_COLORS.get(school, SCHOOL_CHIP_COLORS[""])
		var cell := HBoxContainer.new()
		cell.add_theme_constant_override("separation", 3)
		var swatch := ColorRect.new()
		swatch.color = chip_color
		swatch.custom_minimum_size = Vector2(12, 12)
		cell.add_child(swatch)
		var lbl := Label.new()
		lbl.text = "%s %.0fs" % [display_name.left(10), remaining]
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.modulate = chip_color.lightened(0.25)
		cell.add_child(lbl)
		_buff_chip_row.add_child(cell)


func _refresh_resource_cluster() -> void:
	if _hp_bar != null and GameState.max_health > 0:
		_hp_bar.value = float(GameState.health) / float(GameState.max_health)
		if _hp_value_label != null:
			_hp_value_label.text = "%d/%d" % [GameState.health, GameState.max_health]
	if _mp_bar != null and GameState.max_mana > 0.0:
		_mp_bar.value = float(GameState.mana) / float(GameState.max_mana)
		if _mp_value_label != null:
			_mp_value_label.text = "%d/%d" % [int(GameState.mana), int(GameState.max_mana)]
		_refresh_mp_bar_color()
	if _resource_cluster_info_label != null:
		_resource_cluster_info_label.text = (
			"Circle %d   Score %.1f   %s"
			% [
				GameState.get_current_circle(),
				GameState.get_circle_progress_score(),
				GameState.get_combat_stats_summary()
			]
		)


func _refresh_target_panel() -> void:
	if _target_panel_container == null:
		return
	var target_enemy := _get_primary_target_enemy()
	if target_enemy == null:
		_target_panel_container.visible = false
		return
	_target_panel_container.visible = true
	var target_name := str(target_enemy.get("display_name"))
	if target_name.is_empty():
		target_name = str(target_enemy.name)
	var target_grade := str(target_enemy.get("enemy_grade"))
	if target_grade.is_empty():
		target_grade = "normal"
	var target_type := str(target_enemy.get("enemy_type"))
	if target_type.is_empty():
		target_type = "enemy"
	var target_hp := int(target_enemy.get("health"))
	var target_max_hp := maxi(1, int(target_enemy.get("max_health")))
	var health_ratio := clampf(float(target_hp) / float(target_max_hp), 0.0, 1.0)
	_target_name_label.text = target_name
	_target_hp_bar.value = health_ratio
	_target_hp_value_label.text = "%d/%d" % [target_hp, target_max_hp]
	_target_meta_label.text = "%s %s" % [target_grade.capitalize(), target_type.capitalize()]
	if health_ratio > 0.5:
		_apply_bar_style(_target_hp_bar, Color(0.35, 0.84, 0.46), Color(0.10, 0.18, 0.11))
	elif health_ratio > 0.2:
		_apply_bar_style(_target_hp_bar, Color(0.96, 0.58, 0.20), Color(0.26, 0.12, 0.05))
	else:
		_apply_bar_style(_target_hp_bar, Color(0.88, 0.22, 0.24), Color(0.22, 0.07, 0.08))


func _refresh_mp_bar_color() -> void:
	if _mp_bar == null:
		return
	if GameState.soul_dominion_active:
		_apply_bar_style(_mp_bar, Color(0.75, 0.12, 0.12), Color(0.28, 0.05, 0.05))
	elif GameState.soul_dominion_aftershock_timer > 0.0:
		_apply_bar_style(_mp_bar, Color(0.85, 0.45, 0.10), Color(0.28, 0.14, 0.04))
	else:
		_apply_bar_style(_mp_bar, Color(0.18, 0.45, 0.88), Color(0.06, 0.12, 0.28))


func _on_hud_hotbar_button_hovered(slot_index: int) -> void:
	if not _show_primary_action_row:
		return
	_hovered_slot_index = slot_index
	var tooltip: Dictionary = _get_hotbar_tooltip_data(slot_index)
	if tooltip.is_empty():
		_hide_tooltip_panel()
		return
	_show_tooltip_panel(_format_hotbar_tooltip(tooltip))


func _on_hud_hotbar_button_unhovered(slot_index: int) -> void:
	if _hovered_slot_index == slot_index:
		_hovered_slot_index = -1
	_hide_tooltip_panel()


func _on_hud_hotbar_button_gui_input(slot_index: int, event: InputEvent) -> void:
	if not _show_primary_action_row:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index == MOUSE_BUTTON_RIGHT and not mouse_event.pressed:
		_clear_hotbar_slot(slot_index)
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if mouse_event.pressed:
		_drag_source_slot_index = slot_index
		return
	if _drag_source_slot_index == -1:
		return
	var source_slot := _drag_source_slot_index
	_drag_source_slot_index = -1
	if source_slot != slot_index:
		_swap_hotbar_slots(source_slot, slot_index)
	else:
		_cast_hotbar_slot(slot_index)


func _cast_hotbar_slot(slot_index: int) -> void:
	var player := _get_player_node()
	if player != null and player.has_method("cast_hotbar_slot"):
		player.cast_hotbar_slot(slot_index)


func _clear_hotbar_slot(slot_index: int) -> void:
	var player := _get_player_node()
	if player != null and player.has_method("clear_hotbar_slot") and player.clear_hotbar_slot(slot_index):
		GameState.push_message("Slot %d cleared" % (slot_index + 1), 1.2)
		refresh("")


func _swap_hotbar_slots(first_slot: int, second_slot: int) -> void:
	var player := _get_player_node()
	if player != null and player.has_method("swap_hotbar_slots") and player.swap_hotbar_slots(first_slot, second_slot):
		GameState.push_message("Swapped %d <-> %d" % [first_slot + 1, second_slot + 1], 1.2)
		refresh("")


func _get_hotbar_tooltip_data(slot_index: int) -> Dictionary:
	var player := _get_player_node()
	if player != null and player.has_method("get_hotbar_slot_tooltip_data"):
		return player.get_hotbar_slot_tooltip_data(slot_index)
	return {}


func _get_hotbar_slot_modulate(tooltip: Dictionary) -> Color:
	if str(tooltip.get("current_state", "empty")) == "empty":
		return HOTBAR_EMPTY_MODULATE
	if bool(tooltip.get("can_use", false)):
		return HOTBAR_READY_MODULATE
	return HOTBAR_UNAVAILABLE_MODULATE


func _get_compact_state_text(current_state: String) -> String:
	match current_state:
		"cooldown":
			return "Cooling"
		"mana":
			return "No MP"
		"player_locked":
			return "Locked"
		"empty_slot":
			return "Empty"
		_:
			return current_state.capitalize()


func _format_hotbar_tooltip(tooltip: Dictionary) -> String:
	if str(tooltip.get("current_state", "")) == "empty":
		return "Empty slot\nAssign a skill, buff, toggle, deploy skill, or item."
	var state_text := _get_tooltip_state_text(tooltip)
	return (
		"%s [%s]\n쿨타임 %.1fs   비용 %.0f MP\n%s\n레벨 %d   마스터리 %d\n%s"
		% [
			str(tooltip.get("name", "Unknown")),
			str(tooltip.get("label", "")),
			float(tooltip.get("cooldown", 0.0)),
			float(tooltip.get("cost", 0.0)),
			state_text,
			int(tooltip.get("level", 0)),
			int(tooltip.get("mastery", 0)),
			str(tooltip.get("description", ""))
		]
	)


func _get_tooltip_state_text(tooltip: Dictionary) -> String:
	if bool(tooltip.get("can_use", false)):
		return "상태 Ready"
	var failure_reason := str(tooltip.get("failure_reason", ""))
	if failure_reason == "":
		failure_reason = str(tooltip.get("current_state", "unavailable"))
	return "상태 %s" % failure_reason.capitalize()


func _show_tooltip_panel(text: String) -> void:
	if _tooltip_panel == null or _tooltip_label == null:
		return
	_tooltip_label.text = text
	_tooltip_panel.visible = true


func _hide_tooltip_panel() -> void:
	if _tooltip_panel == null:
		return
	_tooltip_panel.visible = false


func _get_skill_short_name(skill_id: String) -> String:
	var skill_data := GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty():
		return str(skill_data.get("display_name", skill_id)).split(" ")[0].left(8)
	var spell_data := GameDatabase.get_spell(skill_id)
	if not spell_data.is_empty():
		return str(spell_data.get("name", skill_id)).split(" ")[0].left(8)
	return skill_id.left(8)


func _get_primary_target_enemy() -> Node2D:
	var player := _get_player_node() as Node2D
	if player == null:
		return null
	var best_enemy: Node2D = null
	var best_distance := INF
	for enemy_value in get_tree().get_nodes_in_group("enemy"):
		var enemy := enemy_value as Node2D
		if enemy == null or not is_instance_valid(enemy) or not enemy.is_inside_tree():
			continue
		var enemy_hp := int(enemy.get("health"))
		var enemy_max_hp := int(enemy.get("max_health"))
		if enemy_hp <= 0 or enemy_max_hp <= 0:
			continue
		var distance_to_player := player.global_position.distance_to(enemy.global_position)
		if distance_to_player < best_distance:
			best_distance = distance_to_player
			best_enemy = enemy
	return best_enemy


func _get_player_node() -> Node:
	var player_nodes := get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return null
	return player_nodes[0]


func set_room_title(title: String) -> void:
	room_label.text = (
		"%s  Circle %d  Score %.1f"
		% [title, GameState.get_current_circle(), GameState.get_circle_progress_score()]
	)


func refresh(_unused: String = "") -> void:
	_refresh_target_panel()
	_apply_row_visibility_state()
	_refresh_hotbar_buttons()
	_refresh_resource_cluster()
	_refresh_buff_chips()
	if _show_primary_action_row and _hovered_slot_index != -1:
		var tooltip: Dictionary = _get_hotbar_tooltip_data(_hovered_slot_index)
		if not tooltip.is_empty():
			_show_tooltip_panel(_format_hotbar_tooltip(tooltip))
	_refresh_debug_fallback_labels()


func set_show_primary_action_row(visible: bool) -> void:
	if _show_primary_action_row == visible:
		return
	_show_primary_action_row = visible
	if not visible:
		_drag_source_slot_index = -1
		_hovered_slot_index = -1
		_hide_tooltip_panel()
	refresh("")


func set_show_active_buff_row(visible: bool) -> void:
	if _show_active_buff_row == visible:
		return
	_show_active_buff_row = visible
	refresh("")


func is_primary_action_row_visible() -> bool:
	return _show_primary_action_row


func is_active_buff_row_visible() -> bool:
	return _show_active_buff_row


func _apply_row_visibility_state() -> void:
	if _hotbar_container != null:
		_hotbar_container.visible = _show_primary_action_row
	if _buff_chip_panel != null:
		_buff_chip_panel.visible = _show_active_buff_row


func _refresh_debug_fallback_labels() -> void:
	hp_label.text = GameState.get_resource_status_line()
	mastery_label.text = _get_player_hotbar_mastery_summary()
	resonance_label.text = (
		"Resonance  Fire:%d  Ice:%d  Lightning:%d  Dominant:%s"
		% [
			GameState.resonance["fire"],
			GameState.resonance["ice"],
			GameState.resonance["lightning"],
			GameState.get_dominant_school().capitalize()
		]
	)
	buff_label.text = "%s\n%s" % [GameState.get_active_buff_summary(), GameState.get_buff_cooldown_summary()]
	combo_label.text = "%s   %s" % [GameState.get_combo_summary(), GameState.get_combat_stats_summary()]
	admin_label.text = "%s  %s" % [GameState.get_admin_status_summary(), _get_admin_tab_summary()]


func _on_message(text: String, _duration: float) -> void:
	hint_label.text = text


func _get_player_hotbar_mastery_summary() -> String:
	var player := _get_player_node()
	if player != null and player.has_method("get_hotbar_mastery_summary"):
		return str(player.get_hotbar_mastery_summary())
	return "Skills  unavailable"


func _get_admin_tab_summary() -> String:
	var admin_nodes := get_tree().get_nodes_in_group("admin_menu")
	if admin_nodes.is_empty():
		return "Tab[closed]"
	var admin_menu := admin_nodes[0]
	if admin_menu != null and admin_menu.has_method("get_admin_tab_summary"):
		return str(admin_menu.get_admin_tab_summary())
	return "Tab[closed]"

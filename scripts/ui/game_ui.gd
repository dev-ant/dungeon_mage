extends Control

const ACTION_PANEL_TEX := "res://assets/ui/pixel_rpg/Action_panel.png"
const HOTBAR_DROP_BUTTON_SCENE := preload("res://scripts/ui/widgets/skill_hotbar_drop_button.gd")
const SKILL_VISUAL_HELPER := preload("res://scripts/ui/widgets/skill_visual_helper.gd")
const HOTBAR_SLOT_SIZE := Vector2(56, 56)
const ACTION_PANEL_FRAME_REGION := Rect2(13, 13, 166, 19)
const ACTION_PANEL_SLOT_NORMAL_REGION := Rect2(13, 77, 22, 19)
const ACTION_PANEL_SLOT_ACTIVE_REGION := Rect2(61, 77, 22, 19)
const HOTBAR_READY_MODULATE := Color(1.0, 1.0, 1.0, 1.0)
const HOTBAR_UNAVAILABLE_MODULATE := Color(0.55, 0.55, 0.6, 0.95)
const HOTBAR_EMPTY_MODULATE := Color(0.45, 0.45, 0.5, 0.75)
const TOOLTIP_BG_COLOR := Color(0.08, 0.10, 0.16, 0.94)
const TOOLTIP_BORDER_COLOR := Color(0.45, 0.60, 0.82, 0.95)
const TOOLTIP_EDGE_MARGIN := 12.0
const TOOLTIP_HOVER_OFFSET := Vector2(12.0, -8.0)
const HOTBAR_FILLED_OVERLAY_BORDER := Color(0.78, 0.88, 1.0, 0.30)
const HOTBAR_HOVER_OVERLAY_BORDER := Color(1.0, 0.92, 0.56, 0.86)
const HOTBAR_DRAG_OVERLAY_BORDER := Color(0.42, 0.78, 1.0, 0.96)
const HOTBAR_EMPTY_HOVER_OVERLAY_BORDER := Color(0.76, 0.84, 0.96, 0.52)
const WARNING_ROW_DEFAULT_MODULATE := Color(1.0, 0.82, 0.70, 0.92)
const WARNING_ROW_SOUL_ACTIVE_MODULATE := Color(0.98, 0.52, 0.48, 1.0)
const WARNING_ROW_SOUL_AFTERSHOCK_BASE := Color(0.96, 0.70, 0.34, 0.96)
const WARNING_ROW_SOUL_AFTERSHOCK_PEAK := Color(1.0, 0.90, 0.66, 1.0)
const SOUL_WARNING_PULSE_SPEED := 8.0
const SOUL_RISK_OVERLAY_ACTIVE_BORDER := Color(0.62, 0.10, 0.12, 0.34)
const SOUL_RISK_OVERLAY_AFTERSHOCK_BASE := Color(0.72, 0.32, 0.08, 0.20)
const SOUL_RISK_OVERLAY_AFTERSHOCK_PEAK := Color(0.98, 0.72, 0.30, 0.34)
const SOUL_RISK_OVERLAY_ACTIVE_WIDTH := 16
const SOUL_RISK_OVERLAY_AFTERSHOCK_BASE_WIDTH := 12
const SOUL_RISK_OVERLAY_AFTERSHOCK_PEAK_WIDTH := 18
const SOUL_RISK_CLEAR_BEAT_DURATION := 0.30
const SOUL_RISK_CLEAR_MP_FILL := Color(0.90, 0.58, 0.18)
const SOUL_RISK_CLEAR_MP_BG := Color(0.24, 0.14, 0.07)
const SOUL_RISK_CLEAR_OVERLAY_START := Color(0.94, 0.70, 0.28, 0.22)
const SOUL_RISK_CLEAR_OVERLAY_END := Color(0.56, 0.76, 1.0, 0.0)
const SOUL_RISK_CLEAR_OVERLAY_START_WIDTH := 10
const SOUL_RISK_CLEAR_OVERLAY_END_WIDTH := 2

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
var _hotbar_state_overlays: Array[PanelContainer] = []
var _target_panel_container: PanelContainer = null
var _target_name_label: Label = null
var _target_hp_bar: ProgressBar = null
var _target_hp_value_label: Label = null
var _target_meta_label: Label = null
var _bottom_hud_row: HBoxContainer = null
var _resource_cluster_container: PanelContainer = null
var _resource_cluster_info_label: Label = null
var _hp_bar: ProgressBar = null
var _mp_bar: ProgressBar = null
var _hp_value_label: Label = null
var _mp_value_label: Label = null
var _bottom_status_panel: PanelContainer = null
var _bottom_status_column: VBoxContainer = null
var _buff_chip_panel: PanelContainer = null
var _buff_chip_row: HBoxContainer = null
var _tooltip_host: Control = null
var _tooltip_panel: PanelContainer = null
var _tooltip_label: Label = null
var _last_tooltip_horizontal_side := "right"
var _last_tooltip_vertical_side := "above"
var _soul_risk_overlay: PanelContainer = null
var _soul_risk_clear_timer := 0.0
var _last_soul_risk_state := "none"
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


func _process(delta: float) -> void:
	_tick_soul_risk_clear_feedback(delta)
	refresh("")


func _ready() -> void:
	GameState.stats_changed.connect(refresh.bind(""))
	GameState.ui_message_changed.connect(_on_message)
	if UiState != null:
		UiState.special_effects_enabled_changed.connect(_on_special_effects_setting_changed)
		UiState.primary_action_row_visibility_changed.connect(_on_primary_action_row_visibility_changed)
		UiState.active_buff_row_visibility_changed.connect(_on_active_buff_row_visibility_changed)
	_configure_debug_fallback_labels()
	_build_soul_risk_overlay()
	_build_target_panel()
	_build_bottom_hud_row()
	_build_bottom_status_panel()
	_build_resource_cluster()
	_build_hotbar_buttons()
	_build_buff_chips()
	_build_tooltip_panel()
	_relocate_bottom_status_labels()
	_position_bottom_hud_row()
	if UiState != null:
		set_show_primary_action_row(UiState.get_show_primary_action_row())
		set_show_active_buff_row(UiState.get_show_active_buff_row())
	refresh("")


func _configure_debug_fallback_labels() -> void:
	room_label.add_theme_font_size_override("font_size", 22)
	hp_label.add_theme_font_size_override("font_size", 13)
	mastery_label.add_theme_font_size_override("font_size", 13)
	resonance_label.add_theme_font_size_override("font_size", 11)
	buff_label.add_theme_font_size_override("font_size", 10)
	combo_label.add_theme_font_size_override("font_size", 10)
	admin_label.add_theme_font_size_override("font_size", 12)
	hp_label.modulate = Color(0.84, 0.86, 0.96, 0.72)
	mastery_label.modulate = Color(0.84, 0.86, 0.96, 0.72)
	resonance_label.modulate = Color(0.84, 0.86, 0.96, 0.72)
	buff_label.modulate = Color(0.84, 0.86, 0.96, 0.58)
	combo_label.modulate = Color(0.84, 0.86, 0.96, 0.58)
	admin_label.modulate = Color(0.95, 0.82, 0.52, 0.72)
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.modulate = Color(0.96, 0.92, 0.78)
	hp_label.modulate = WARNING_ROW_DEFAULT_MODULATE
	resonance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	buff_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combo_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _build_bottom_hud_row() -> void:
	if not has_node("Margin/Bottom"):
		return
	_bottom_hud_row = HBoxContainer.new()
	_bottom_hud_row.name = "BottomHudRow"
	_bottom_hud_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bottom_hud_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	_bottom_hud_row.add_theme_constant_override("separation", 0)
	$Margin/Bottom.add_child(_bottom_hud_row)


func _build_bottom_status_panel() -> void:
	if _bottom_hud_row == null:
		return
	_bottom_status_panel = PanelContainer.new()
	_bottom_status_panel.name = "BottomStatusPanel"
	_bottom_status_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_bottom_status_panel.custom_minimum_size = Vector2(280, 0)
	_bottom_status_panel.clip_contents = true
	_bottom_status_panel.add_theme_stylebox_override(
		"panel", _make_flat_panel_style(Color(0.07, 0.08, 0.12, 0.82), Color(0.28, 0.32, 0.44, 0.92), 2)
	)
	_bottom_hud_row.add_child(_bottom_status_panel)

	_bottom_status_column = VBoxContainer.new()
	_bottom_status_column.name = "BottomStatusColumn"
	_bottom_status_column.custom_minimum_size = Vector2(280, 0)
	_bottom_status_column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_bottom_status_column.add_theme_constant_override("separation", 3)
	_bottom_status_panel.add_child(_bottom_status_column)


func _relocate_bottom_status_labels() -> void:
	if _bottom_status_column == null:
		return
	for label in [resonance_label, buff_label, combo_label]:
		if label == null:
			continue
		var current_parent: Node = label.get_parent()
		if current_parent != null:
			current_parent.remove_child(label)
		_bottom_status_column.add_child(label)
	if _buff_chip_panel != null:
		var current_parent: Node = _buff_chip_panel.get_parent()
		if current_parent != null:
			current_parent.remove_child(_buff_chip_panel)
		_bottom_status_column.add_child(_buff_chip_panel)
		_bottom_status_column.move_child(_buff_chip_panel, 0)


func _build_resource_cluster() -> void:
	if _bottom_hud_row == null:
		return

	var left_spacer := Control.new()
	left_spacer.name = "BottomHudLeftSpacer"
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bottom_hud_row.add_child(left_spacer)

	_resource_cluster_container = PanelContainer.new()
	_resource_cluster_container.name = "ResourceCluster"
	_resource_cluster_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resource_cluster_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_bottom_hud_row.add_child(_resource_cluster_container)

	var bars := VBoxContainer.new()
	bars.name = "ResourceBars"
	bars.alignment = BoxContainer.ALIGNMENT_CENTER
	bars.add_theme_constant_override("separation", 4)
	_resource_cluster_container.add_child(bars)

	_hp_bar = ProgressBar.new()
	_hp_bar.min_value = 0.0
	_hp_bar.max_value = 1.0
	_hp_bar.value = 1.0
	_hp_bar.custom_minimum_size = Vector2(180, 8)
	_hp_bar.show_percentage = false
	_apply_bar_style(_hp_bar, Color(0.88, 0.22, 0.24), Color(0.22, 0.07, 0.08))
	bars.add_child(_hp_bar)

	_mp_bar = ProgressBar.new()
	_mp_bar.min_value = 0.0
	_mp_bar.max_value = 1.0
	_mp_bar.value = 1.0
	_mp_bar.custom_minimum_size = Vector2(180, 8)
	_mp_bar.show_percentage = false
	_apply_bar_style(_mp_bar, Color(0.18, 0.45, 0.88), Color(0.06, 0.12, 0.28))
	bars.add_child(_mp_bar)

	var right_spacer := Control.new()
	right_spacer.name = "BottomHudRightSpacer"
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bottom_hud_row.add_child(right_spacer)

	var right_gutter := Control.new()
	right_gutter.name = "BottomHudRightGutter"
	right_gutter.custom_minimum_size = Vector2(280, 0)
	_bottom_hud_row.add_child(right_gutter)


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


func _build_soul_risk_overlay() -> void:
	if _soul_risk_overlay != null:
		return
	_soul_risk_overlay = PanelContainer.new()
	_soul_risk_overlay.name = "SoulRiskOverlay"
	_soul_risk_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_soul_risk_overlay.visible = false
	_soul_risk_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_soul_risk_overlay.offset_left = 0.0
	_soul_risk_overlay.offset_top = 0.0
	_soul_risk_overlay.offset_right = 0.0
	_soul_risk_overlay.offset_bottom = 0.0
	_soul_risk_overlay.add_theme_stylebox_override(
		"panel", _make_overlay_border_style(SOUL_RISK_OVERLAY_ACTIVE_BORDER, SOUL_RISK_OVERLAY_ACTIVE_WIDTH)
	)
	add_child(_soul_risk_overlay)
	move_child(_soul_risk_overlay, get_child_count() - 1)


func _build_tooltip_panel() -> void:
	if not has_node("Margin/Bottom"):
		return
	_tooltip_host = Control.new()
	_tooltip_host.name = "TooltipHost"
	_tooltip_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_host.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tooltip_host.offset_left = 0.0
	_tooltip_host.offset_top = 0.0
	_tooltip_host.offset_right = 0.0
	_tooltip_host.offset_bottom = 0.0
	$Margin/Bottom.add_child(_tooltip_host)
	$Margin/Bottom.move_child(_tooltip_host, 0)

	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.visible = false
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.add_theme_stylebox_override(
		"panel", _make_flat_panel_style(TOOLTIP_BG_COLOR, TOOLTIP_BORDER_COLOR, 2)
	)
	_tooltip_host.add_child(_tooltip_panel)

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
	_buff_chip_panel.custom_minimum_size = Vector2(280, 0)
	_buff_chip_panel.clip_contents = true
	_buff_chip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_chip_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	$Margin/Top.add_child(_buff_chip_panel)
	$Margin/Top.move_child(_buff_chip_panel, 1)

	_buff_chip_row = HBoxContainer.new()
	_buff_chip_row.name = "BuffChipRow"
	_buff_chip_row.add_theme_constant_override("separation", 4)
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
		var btn := HOTBAR_DROP_BUTTON_SCENE.new()
		btn.text = str(i + 1)
		btn.custom_minimum_size = HOTBAR_SLOT_SIZE
		btn.focus_mode = Control.FOCUS_NONE
		btn.clip_text = true
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.slot_index = i
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.82))
		btn.add_theme_color_override("font_pressed_color", Color(0.84, 0.84, 0.84))
		_apply_hotbar_button_skin(btn)
		var overlay := PanelContainer.new()
		overlay.name = "StateOverlay"
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.visible = false
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.offset_left = 0.0
		overlay.offset_top = 0.0
		overlay.offset_right = 0.0
		overlay.offset_bottom = 0.0
		btn.add_child(overlay)
		btn.gui_input.connect(_on_hud_hotbar_button_gui_input.bind(i))
		btn.mouse_entered.connect(_on_hud_hotbar_button_hovered.bind(i))
		btn.mouse_exited.connect(_on_hud_hotbar_button_unhovered.bind(i))
		btn.skill_payload_dropped.connect(_on_hud_hotbar_skill_payload_dropped)
		_hotbar_button_bar.add_child(btn)
		_hotbar_button_nodes.append(btn)
		_hotbar_state_overlays.append(overlay)


func _position_bottom_hud_row() -> void:
	if _bottom_hud_row == null or not has_node("Margin/Bottom"):
		return
	var bottom_container := $Margin/Bottom
	bottom_container.move_child(_bottom_hud_row, bottom_container.get_child_count() - 1)


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


func _make_overlay_border_style(border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


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
	return _build_atlas_stylebox(
		tex,
		ACTION_PANEL_FRAME_REGION,
		5,
		5,
		5,
		5,
		4.0,
		4.0,
		4.0,
		4.0
	)


func _apply_hotbar_button_skin(btn: Button) -> void:
	var tex: Texture2D = load(ACTION_PANEL_TEX)
	if tex == null:
		return

	var style_normal := _build_atlas_stylebox(tex, ACTION_PANEL_SLOT_NORMAL_REGION, 5, 5, 5, 5, 3.0, 3.0, 3.0, 3.0)
	var style_hover := _build_atlas_stylebox(tex, ACTION_PANEL_SLOT_ACTIVE_REGION, 5, 5, 5, 5, 3.0, 3.0, 3.0, 3.0)
	var style_pressed := _build_atlas_stylebox(tex, ACTION_PANEL_SLOT_ACTIVE_REGION, 5, 5, 5, 5, 3.0, 3.0, 3.0, 3.0)
	var style_disabled := _build_atlas_stylebox(tex, ACTION_PANEL_SLOT_NORMAL_REGION, 5, 5, 5, 5, 3.0, 3.0, 3.0, 3.0)

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_stylebox_override("focus", style_hover)
	btn.add_theme_stylebox_override("disabled", style_disabled)
	btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _build_atlas_stylebox(
	texture: Texture2D,
	region: Rect2,
	margin_left: int,
	margin_top: int,
	margin_right: int,
	margin_bottom: int,
	content_left: float = 0.0,
	content_top: float = 0.0,
	content_right: float = 0.0,
	content_bottom: float = 0.0
) -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	var style := StyleBoxTexture.new()
	style.texture = atlas
	style.texture_margin_left = margin_left
	style.texture_margin_top = margin_top
	style.texture_margin_right = margin_right
	style.texture_margin_bottom = margin_bottom
	style.content_margin_left = content_left
	style.content_margin_top = content_top
	style.content_margin_right = content_right
	style.content_margin_bottom = content_bottom
	return style


func _refresh_hotbar_buttons() -> void:
	if _hotbar_button_bar == null:
		return
	if not _show_primary_action_row:
		_refresh_hotbar_state_overlays()
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
			btn.text = "%s\n비어 있음" % slot_label
			btn.icon = null
			btn.modulate = HOTBAR_EMPTY_MODULATE
			continue
		var short_name := _get_skill_short_name(skill_id)
		var cooldown := float(tooltip.get("cooldown", 0.0))
		var current_state := str(tooltip.get("current_state", "ready"))
		if cooldown > 0.0:
			btn.text = "%s\n%s\n재사용 %.1f" % [slot_label, short_name, cooldown]
		elif current_state == "ready":
			btn.text = "%s\n%s" % [slot_label, short_name]
		else:
			btn.text = "%s\n%s\n%s" % [slot_label, short_name, _get_compact_state_text(current_state)]
		SKILL_VISUAL_HELPER.apply_skill_icon(btn, skill_id, 18)
		btn.modulate = _get_hotbar_slot_modulate(tooltip)
	_refresh_hotbar_state_overlays()


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
		cell.add_theme_constant_override("separation", 2)
		var swatch := ColorRect.new()
		swatch.color = chip_color
		swatch.custom_minimum_size = Vector2(8, 8)
		cell.add_child(swatch)
		var lbl := Label.new()
		lbl.text = "%s %.0fs" % [display_name.left(8), remaining]
		lbl.add_theme_font_size_override("font_size", 9)
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
			"서클 %d   점수 %.1f   %s"
			% [
				GameState.get_current_circle(),
				GameState.get_circle_progress_score(),
				GameState.get_combat_stats_summary()
			]
		)


func _refresh_target_panel() -> void:
	if _target_panel_container == null:
		return
	var target_enemy := _get_target_panel_enemy()
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
	_target_meta_label.text = "%s / %s" % [
		_get_enemy_grade_text(target_grade),
		_get_enemy_type_text(target_type)
	]
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
		var pulse := _get_soul_warning_pulse_strength()
		var fill := Color(0.85, 0.45, 0.10).lerp(Color(0.98, 0.72, 0.28), pulse)
		var bg := Color(0.28, 0.14, 0.04).lerp(Color(0.36, 0.18, 0.06), pulse)
		_apply_bar_style(_mp_bar, fill, bg)
	elif _soul_risk_clear_timer > 0.0:
		var clear_progress := _get_soul_risk_clear_progress()
		var fill := SOUL_RISK_CLEAR_MP_FILL.lerp(Color(0.18, 0.45, 0.88), clear_progress)
		var bg := SOUL_RISK_CLEAR_MP_BG.lerp(Color(0.06, 0.12, 0.28), clear_progress)
		_apply_bar_style(_mp_bar, fill, bg)
	else:
		_apply_bar_style(_mp_bar, Color(0.18, 0.45, 0.88), Color(0.06, 0.12, 0.28))


func _on_hud_hotbar_button_hovered(slot_index: int) -> void:
	if not _show_primary_action_row:
		return
	_hovered_slot_index = slot_index
	_refresh_hotbar_state_overlays()
	var tooltip: Dictionary = _get_hotbar_tooltip_data(slot_index)
	if tooltip.is_empty():
		_hide_tooltip_panel()
		return
	_show_tooltip_panel(_format_hotbar_tooltip(tooltip), _get_hotbar_button(slot_index))


func _on_hud_hotbar_button_unhovered(slot_index: int) -> void:
	if _hovered_slot_index == slot_index:
		_hovered_slot_index = -1
	_refresh_hotbar_state_overlays()
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
		_refresh_hotbar_state_overlays()
		return
	if _drag_source_slot_index == -1:
		return
	var source_slot := _drag_source_slot_index
	_drag_source_slot_index = -1
	_refresh_hotbar_state_overlays()
	if source_slot != slot_index:
		_swap_hotbar_slots(source_slot, slot_index)
	else:
		_cast_hotbar_slot(slot_index)


func debug_drop_skill_payload_on_hotbar_slot(payload: Dictionary, slot_index: int) -> bool:
	return _apply_hotbar_skill_payload(slot_index, payload)


func debug_get_hotbar_overlay_border_color(slot_index: int) -> Color:
	var overlay := _get_hotbar_state_overlay(slot_index)
	if overlay == null:
		return Color.BLACK
	var style := overlay.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return Color.BLACK
	return style.border_color


func debug_is_hotbar_overlay_visible(slot_index: int) -> bool:
	var overlay := _get_hotbar_state_overlay(slot_index)
	return overlay != null and overlay.visible


func _cast_hotbar_slot(slot_index: int) -> void:
	var player := _get_player_node()
	if player != null and player.has_method("cast_hotbar_slot"):
		player.cast_hotbar_slot(slot_index)


func _clear_hotbar_slot(slot_index: int) -> void:
	var player := _get_player_node()
	if player != null and player.has_method("clear_hotbar_slot") and player.clear_hotbar_slot(slot_index):
		GameState.push_message("%d번 슬롯을 비웠습니다." % (slot_index + 1), 1.2)
		refresh("")


func _swap_hotbar_slots(first_slot: int, second_slot: int) -> void:
	var player := _get_player_node()
	if player != null and player.has_method("swap_hotbar_slots") and player.swap_hotbar_slots(first_slot, second_slot):
		GameState.push_message("%d번과 %d번 슬롯을 교체했습니다." % [first_slot + 1, second_slot + 1], 1.2)
		refresh("")


func _on_hud_hotbar_skill_payload_dropped(slot_index: int, skill_id: String) -> void:
	var payload := {
		"type": "skill_hotkey_bind",
		"skill_id": skill_id
	}
	_apply_hotbar_skill_payload(slot_index, payload)


func _apply_hotbar_skill_payload(slot_index: int, payload: Dictionary) -> bool:
	if not _show_primary_action_row:
		return false
	if str(payload.get("type", "")) != "skill_hotkey_bind":
		return false
	var skill_id := str(payload.get("skill_id", ""))
	if skill_id == "":
		return false
	var player := _get_player_node()
	if player == null or not player.has_method("assign_hotbar_skill"):
		return false
	var assigned := bool(player.call("assign_hotbar_skill", slot_index, skill_id))
	if not assigned:
		return false
	var display_name := str(GameDatabase.get_skill_data(skill_id).get("display_name", skill_id))
	GameState.push_message("%d번 슬롯에 %s 등록" % [slot_index + 1, display_name], 1.2)
	refresh("")
	return true


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
	return _get_state_display_text(current_state)


func _format_hotbar_tooltip(tooltip: Dictionary) -> String:
	if str(tooltip.get("current_state", "")) == "empty":
		return "빈 슬롯\n스킬, 버프, 토글, 설치 스킬 또는 아이템을 배치하세요."
	var state_text := _get_tooltip_state_text(tooltip)
	return (
		"%s [%s]\n쿨타임 %.1fs   비용 %.0f MP\n%s\n레벨 %d   마스터리 %d\n%s"
		% [
			str(tooltip.get("name", "알 수 없음")),
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
		return "상태 사용 가능"
	var failure_reason := str(tooltip.get("failure_reason", ""))
	if failure_reason == "":
		failure_reason = str(tooltip.get("current_state", "unavailable"))
	return "상태 %s" % _get_state_display_text(failure_reason)


func _hide_tooltip_panel() -> void:
	if _tooltip_panel == null:
		return
	_tooltip_panel.visible = false


func debug_show_tooltip_for_anchor_rect(anchor_rect: Rect2, text: String) -> void:
	if _tooltip_panel == null or _tooltip_label == null:
		return
	_tooltip_label.text = text
	_tooltip_panel.visible = true
	_position_tooltip_panel(anchor_rect)


func debug_get_tooltip_horizontal_side() -> String:
	return _last_tooltip_horizontal_side


func debug_get_tooltip_vertical_side() -> String:
	return _last_tooltip_vertical_side


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


func _get_target_panel_enemy() -> Node2D:
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
		var should_show_target_bar := false
		if enemy.has_method("should_show_target_health_bar"):
			should_show_target_bar = bool(enemy.call("should_show_target_health_bar"))
		else:
			should_show_target_bar = str(enemy.get("enemy_grade")) == "boss"
		if not should_show_target_bar:
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
		"%s  서클 %d  점수 %.1f"
		% [title, GameState.get_current_circle(), GameState.get_circle_progress_score()]
	)


func refresh(_unused: String = "") -> void:
	_sync_soul_risk_feedback_state()
	_refresh_target_panel()
	_apply_row_visibility_state()
	_refresh_hotbar_buttons()
	_refresh_resource_cluster()
	_refresh_soul_risk_overlay()
	_refresh_buff_chips()
	if _show_primary_action_row and _hovered_slot_index != -1:
		var tooltip: Dictionary = _get_hotbar_tooltip_data(_hovered_slot_index)
		if not tooltip.is_empty():
			_show_tooltip_panel(_format_hotbar_tooltip(tooltip), _get_hotbar_button(_hovered_slot_index))
	_refresh_debug_fallback_labels()


func _show_tooltip_panel(text: String, anchor_control: Control = null) -> void:
	if _tooltip_panel == null or _tooltip_label == null:
		return
	_tooltip_label.text = text
	_tooltip_panel.visible = true
	_position_tooltip_panel(_get_anchor_rect(anchor_control))


func _position_tooltip_panel(anchor_rect_override: Variant = null) -> void:
	if _tooltip_panel == null or _tooltip_host == null or not _tooltip_panel.visible:
		return
	var anchor_rect: Rect2 = anchor_rect_override if anchor_rect_override is Rect2 else Rect2()
	if anchor_rect.size == Vector2.ZERO and _hovered_slot_index != -1:
		anchor_rect = _get_anchor_rect(_get_hotbar_button(_hovered_slot_index))
	if anchor_rect.size == Vector2.ZERO:
		var viewport_rect := get_viewport_rect()
		anchor_rect = Rect2(
			viewport_rect.size.x * 0.5,
			viewport_rect.size.y - 120.0,
			56.0,
			56.0
		)
	_tooltip_panel.reset_size()
	var panel_size := _tooltip_panel.get_combined_minimum_size()
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		panel_size = Vector2(460.0, 72.0)
	var viewport_size := get_viewport_rect().size
	var target_x := anchor_rect.position.x + anchor_rect.size.x + TOOLTIP_HOVER_OFFSET.x
	var target_y := anchor_rect.position.y - panel_size.y + TOOLTIP_HOVER_OFFSET.y
	_last_tooltip_horizontal_side = "right"
	_last_tooltip_vertical_side = "above"
	if target_x + panel_size.x > viewport_size.x - TOOLTIP_EDGE_MARGIN:
		target_x = anchor_rect.position.x - panel_size.x - TOOLTIP_HOVER_OFFSET.x
		_last_tooltip_horizontal_side = "left"
	if target_y < TOOLTIP_EDGE_MARGIN:
		target_y = anchor_rect.position.y + anchor_rect.size.y + absf(TOOLTIP_HOVER_OFFSET.y)
		_last_tooltip_vertical_side = "below"
	target_x = clampf(target_x, TOOLTIP_EDGE_MARGIN, viewport_size.x - panel_size.x - TOOLTIP_EDGE_MARGIN)
	target_y = clampf(target_y, TOOLTIP_EDGE_MARGIN, viewport_size.y - panel_size.y - TOOLTIP_EDGE_MARGIN)
	var host_origin := _tooltip_host.get_global_rect().position
	_tooltip_panel.position = Vector2(target_x, target_y) - host_origin


func _get_anchor_rect(anchor_control: Control) -> Rect2:
	if anchor_control == null or not is_instance_valid(anchor_control) or not anchor_control.is_inside_tree():
		return Rect2()
	return anchor_control.get_global_rect()


func _get_hotbar_button(slot_index: int) -> Control:
	if slot_index < 0 or slot_index >= _hotbar_button_nodes.size():
		return null
	return _hotbar_button_nodes[slot_index]


func _get_hotbar_state_overlay(slot_index: int) -> PanelContainer:
	if slot_index < 0 or slot_index >= _hotbar_state_overlays.size():
		return null
	return _hotbar_state_overlays[slot_index]


func _refresh_hotbar_state_overlays() -> void:
	for slot_index in range(_hotbar_state_overlays.size()):
		var overlay := _get_hotbar_state_overlay(slot_index)
		if overlay == null:
			continue
		var tooltip: Dictionary = _get_hotbar_tooltip_data(slot_index)
		var has_skill := str(tooltip.get("skill_id", "")) != ""
		var is_hovered := _show_primary_action_row and slot_index == _hovered_slot_index
		var is_drag_source := _show_primary_action_row and slot_index == _drag_source_slot_index
		var border_color := Color(0.0, 0.0, 0.0, 0.0)
		var border_width := 0
		if is_drag_source:
			border_color = HOTBAR_DRAG_OVERLAY_BORDER
			border_width = 3
		elif is_hovered and has_skill:
			border_color = HOTBAR_HOVER_OVERLAY_BORDER
			border_width = 3
		elif is_hovered:
			border_color = HOTBAR_EMPTY_HOVER_OVERLAY_BORDER
			border_width = 2
		elif has_skill:
			border_color = HOTBAR_FILLED_OVERLAY_BORDER
			border_width = 2
		overlay.visible = border_width > 0
		overlay.add_theme_stylebox_override("panel", _make_overlay_border_style(border_color, border_width))


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
	if _bottom_status_panel != null:
		_bottom_status_panel.visible = true


func _refresh_debug_fallback_labels() -> void:
	var warning_text := _get_top_warning_summary()
	hp_label.text = warning_text
	hp_label.visible = warning_text != ""
	_refresh_warning_row_visuals()
	mastery_label.text = ""
	mastery_label.visible = false
	resonance_label.text = (
		"공명  화염:%d  냉기:%d  전기:%d  우세:%s"
		% [
			GameState.resonance["fire"],
			GameState.resonance["ice"],
			GameState.resonance["lightning"],
			GameState.get_school_display_name(GameState.get_dominant_school())
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
	return "스킬 정보를 불러올 수 없음"


func _get_top_warning_summary() -> String:
	var warnings: Array[String] = []
	var recent_damage_text := _get_recent_damage_warning_text()
	if recent_damage_text != "":
		warnings.append(recent_damage_text)
	var soul_risk_text := GameState.get_soul_dominion_risk_summary()
	if soul_risk_text != "":
		warnings.append(soul_risk_text)
	if warnings.is_empty():
		return ""
	return "경고  %s" % "   ".join(warnings)


func _refresh_warning_row_visuals() -> void:
	if hp_label == null:
		return
	if not hp_label.visible:
		hp_label.modulate = WARNING_ROW_DEFAULT_MODULATE
		return
	if GameState.soul_dominion_active:
		hp_label.modulate = WARNING_ROW_SOUL_ACTIVE_MODULATE
		return
	if GameState.soul_dominion_aftershock_timer > 0.0:
		hp_label.modulate = WARNING_ROW_SOUL_AFTERSHOCK_BASE.lerp(
			WARNING_ROW_SOUL_AFTERSHOCK_PEAK,
			_get_soul_warning_pulse_strength()
		)
		return
	hp_label.modulate = WARNING_ROW_DEFAULT_MODULATE


func _refresh_soul_risk_overlay() -> void:
	if _soul_risk_overlay == null:
		return
	if UiState != null and not UiState.are_special_effects_enabled():
		_soul_risk_overlay.visible = false
		return
	if GameState.soul_dominion_active:
		_soul_risk_overlay.visible = true
		_soul_risk_overlay.add_theme_stylebox_override(
			"panel",
			_make_overlay_border_style(
				SOUL_RISK_OVERLAY_ACTIVE_BORDER,
				SOUL_RISK_OVERLAY_ACTIVE_WIDTH
			)
		)
		return
	if GameState.soul_dominion_aftershock_timer > 0.0:
		var pulse := _get_soul_warning_pulse_strength()
		var border_color := SOUL_RISK_OVERLAY_AFTERSHOCK_BASE.lerp(
			SOUL_RISK_OVERLAY_AFTERSHOCK_PEAK,
			pulse
		)
		var border_width := int(round(lerpf(
			float(SOUL_RISK_OVERLAY_AFTERSHOCK_BASE_WIDTH),
			float(SOUL_RISK_OVERLAY_AFTERSHOCK_PEAK_WIDTH),
			pulse
		)))
		_soul_risk_overlay.visible = true
		_soul_risk_overlay.add_theme_stylebox_override(
			"panel",
			_make_overlay_border_style(border_color, border_width)
		)
		return
	if _soul_risk_clear_timer > 0.0:
		var clear_progress := _get_soul_risk_clear_progress()
		var border_color := SOUL_RISK_CLEAR_OVERLAY_START.lerp(
			SOUL_RISK_CLEAR_OVERLAY_END,
			clear_progress
		)
		var border_width := int(round(lerpf(
			float(SOUL_RISK_CLEAR_OVERLAY_START_WIDTH),
			float(SOUL_RISK_CLEAR_OVERLAY_END_WIDTH),
			clear_progress
		)))
		_soul_risk_overlay.visible = true
		_soul_risk_overlay.add_theme_stylebox_override(
			"panel",
			_make_overlay_border_style(border_color, border_width)
		)
		return
	_soul_risk_overlay.visible = false


func _on_special_effects_setting_changed(_enabled: bool) -> void:
	_refresh_soul_risk_overlay()


func _on_primary_action_row_visibility_changed(enabled: bool) -> void:
	set_show_primary_action_row(enabled)


func _on_active_buff_row_visibility_changed(enabled: bool) -> void:
	set_show_active_buff_row(enabled)


func _get_soul_warning_pulse_strength() -> float:
	var duration := float(GameState.SOUL_DOMINION_AFTERSHOCK_DURATION)
	if duration <= 0.0:
		return 0.0
	var elapsed := maxf(duration - GameState.soul_dominion_aftershock_timer, 0.0)
	return clampf(0.5 + 0.5 * sin(elapsed * SOUL_WARNING_PULSE_SPEED), 0.0, 1.0)


func _get_current_soul_risk_state() -> String:
	if GameState.soul_dominion_active:
		return "active"
	if GameState.soul_dominion_aftershock_timer > 0.0:
		return "aftershock"
	return "none"


func _sync_soul_risk_feedback_state() -> void:
	var current_state := _get_current_soul_risk_state()
	if _last_soul_risk_state == "aftershock" and current_state == "none":
		_soul_risk_clear_timer = SOUL_RISK_CLEAR_BEAT_DURATION
	elif current_state != "none":
		_soul_risk_clear_timer = 0.0
	_last_soul_risk_state = current_state


func _tick_soul_risk_clear_feedback(delta: float) -> void:
	if _get_current_soul_risk_state() != "none":
		_soul_risk_clear_timer = 0.0
		return
	if _soul_risk_clear_timer <= 0.0:
		return
	_soul_risk_clear_timer = maxf(_soul_risk_clear_timer - delta, 0.0)


func _get_soul_risk_clear_progress() -> float:
	if SOUL_RISK_CLEAR_BEAT_DURATION <= 0.0:
		return 1.0
	return clampf(
		1.0 - (_soul_risk_clear_timer / SOUL_RISK_CLEAR_BEAT_DURATION),
		0.0,
		1.0
	)


func _get_recent_damage_warning_text() -> String:
	if GameState.last_damage_display_timer <= 0.0 or GameState.last_damage_amount <= 0:
		return ""
	if GameState.last_damage_school != "":
		return "최근 피해 %d (%s)" % [
			GameState.last_damage_amount,
			GameState.get_school_display_name(GameState.last_damage_school)
		]
	return "최근 피해 %d" % GameState.last_damage_amount


func _get_admin_tab_summary() -> String:
	var admin_nodes := get_tree().get_nodes_in_group("admin_menu")
	if admin_nodes.is_empty():
		return "탭[닫힘]"
	var admin_menu := admin_nodes[0]
	if admin_menu != null and admin_menu.has_method("get_admin_tab_summary"):
		return str(admin_menu.get_admin_tab_summary())
	return "탭[닫힘]"


func _get_state_display_text(state_code: String) -> String:
	match state_code:
		"ready":
			return "사용 가능"
		"cooldown":
			return "재사용 대기"
		"mana", "insufficient_mana":
			return "MP 부족"
		"player_locked", "locked":
			return "행동 불가"
		"empty_slot", "empty":
			return "빈 슬롯"
		"buff_slots_full":
			return "버프 슬롯 가득 참"
		"buff_rejected":
			return "버프 사용 불가"
		"blocked":
			return "사용 불가"
		"missing_player":
			return "플레이어 없음"
		"active_toggle":
			return "활성 유지 중"
		"unavailable":
			return "사용 불가"
		_:
			return state_code


func _get_enemy_grade_text(grade: String) -> String:
	match grade:
		"boss":
			return "보스"
		"elite":
			return "정예"
		"normal":
			return "일반"
		_:
			return grade


func _get_enemy_type_text(enemy_type: String) -> String:
	match enemy_type:
		"brute":
			return "근접형"
		"ranged":
			return "원거리형"
		"boss":
			return "보스형"
		"dummy":
			return "훈련 허수아비"
		"dasher":
			return "돌진형"
		"sentinel":
			return "감시형"
		"elite":
			return "정예형"
		"leaper":
			return "도약형"
		"bomber":
			return "폭탄형"
		"charger":
			return "돌격형"
		"bat":
			return "박쥐형"
		"worm":
			return "웜형"
		"mushroom":
			return "버섯형"
		"rat":
			return "쥐형"
		"tooth_walker":
			return "보행체"
		"eyeball":
			return "안구형"
		"trash_monster":
			return "폐기물형"
		"sword":
			return "검형"
		"enemy":
			return "적"
		_:
			return enemy_type

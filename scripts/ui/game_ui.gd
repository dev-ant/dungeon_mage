extends Control

const BUTTONS_TEX := "res://assets/ui/pixel_rpg/Buttons.png"
const ACTION_PANEL_TEX := "res://assets/ui/pixel_rpg/Action_panel.png"

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
var _hp_bar: ProgressBar = null
var _mp_bar: ProgressBar = null
var _hp_value_label: Label = null
var _mp_value_label: Label = null
var _buff_chip_row: HBoxContainer = null

const SCHOOL_CHIP_COLORS := {
	"fire": Color(0.95, 0.38, 0.12),
	"ice": Color(0.30, 0.72, 0.95),
	"lightning": Color(0.95, 0.88, 0.15),
	"dark": Color(0.62, 0.22, 0.90),
	"plant": Color(0.28, 0.82, 0.30),
	"": Color(0.70, 0.70, 0.70),
}


func _process(_delta: float) -> void:
	refresh("")


func _ready() -> void:
	GameState.stats_changed.connect(refresh.bind(""))
	GameState.ui_message_changed.connect(_on_message)
	_build_resource_bars()
	_build_hotbar_buttons()
	_build_buff_chips()
	refresh("")


func _build_resource_bars() -> void:
	if not has_node("Margin/Top"):
		return
	var bar_row := HBoxContainer.new()
	bar_row.add_theme_constant_override("separation", 8)
	var hp_label_node := Label.new()
	hp_label_node.text = "HP"
	hp_label_node.add_theme_font_size_override("font_size", 12)
	bar_row.add_child(hp_label_node)
	_hp_bar = ProgressBar.new()
	_hp_bar.min_value = 0.0
	_hp_bar.max_value = 1.0
	_hp_bar.value = 1.0
	_hp_bar.custom_minimum_size = Vector2(120, 14)
	_hp_bar.show_percentage = false
	_apply_bar_style(_hp_bar, Color(0.85, 0.18, 0.18), Color(0.25, 0.08, 0.08))
	bar_row.add_child(_hp_bar)
	_hp_value_label = Label.new()
	_hp_value_label.add_theme_font_size_override("font_size", 11)
	_hp_value_label.modulate = Color(1, 0.8, 0.8)
	bar_row.add_child(_hp_value_label)
	var mp_label_node := Label.new()
	mp_label_node.text = "MP"
	mp_label_node.add_theme_font_size_override("font_size", 12)
	bar_row.add_child(mp_label_node)
	_mp_bar = ProgressBar.new()
	_mp_bar.min_value = 0.0
	_mp_bar.max_value = 1.0
	_mp_bar.value = 1.0
	_mp_bar.custom_minimum_size = Vector2(120, 14)
	_mp_bar.show_percentage = false
	_apply_bar_style(_mp_bar, Color(0.18, 0.45, 0.88), Color(0.06, 0.12, 0.28))
	bar_row.add_child(_mp_bar)
	_mp_value_label = Label.new()
	_mp_value_label.add_theme_font_size_override("font_size", 11)
	_mp_value_label.modulate = Color(0.8, 0.85, 1.0)
	bar_row.add_child(_mp_value_label)
	$Margin/Top.add_child(bar_row)
	$Margin/Top.move_child(bar_row, 1)


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


func _refresh_resource_bars() -> void:
	if _hp_bar != null and GameState.max_health > 0:
		_hp_bar.value = float(GameState.health) / float(GameState.max_health)
		if _hp_value_label != null:
			_hp_value_label.text = "%d/%d" % [GameState.health, GameState.max_health]
	if _mp_bar != null and GameState.max_mana > 0.0:
		_mp_bar.value = float(GameState.mana) / float(GameState.max_mana)
		if _mp_value_label != null:
			_mp_value_label.text = "%d/%d" % [int(GameState.mana), int(GameState.max_mana)]
		_refresh_mp_bar_color()


func _build_buff_chips() -> void:
	if not has_node("Margin/Top"):
		return
	_buff_chip_row = HBoxContainer.new()
	_buff_chip_row.name = "BuffChipRow"
	_buff_chip_row.add_theme_constant_override("separation", 4)
	$Margin/Top.add_child(_buff_chip_row)


func _refresh_buff_chips() -> void:
	if _buff_chip_row == null:
		return
	for child in _buff_chip_row.get_children():
		child.queue_free()
	for buff in GameState.active_buffs:
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
		swatch.custom_minimum_size = Vector2(10, 10)
		cell.add_child(swatch)
		var lbl := Label.new()
		lbl.text = "%s %.0fs" % [display_name.left(7), remaining]
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.modulate = chip_color.lightened(0.3)
		cell.add_child(lbl)
		_buff_chip_row.add_child(cell)


func _refresh_mp_bar_color() -> void:
	if _mp_bar == null:
		return
	if GameState.soul_dominion_active:
		# MP locked: dark red fill, pulsing hint
		_apply_bar_style(_mp_bar, Color(0.75, 0.12, 0.12), Color(0.28, 0.05, 0.05))
	elif GameState.soul_dominion_aftershock_timer > 0.0:
		# Aftershock: orange warning
		_apply_bar_style(_mp_bar, Color(0.85, 0.45, 0.10), Color(0.28, 0.14, 0.04))
	else:
		# Normal: blue
		_apply_bar_style(_mp_bar, Color(0.18, 0.45, 0.88), Color(0.06, 0.12, 0.28))


func _build_hotbar_buttons() -> void:
	if not has_node("Margin/Bottom"):
		return
	_hotbar_container = PanelContainer.new()
	var panel_style := _make_action_panel_style()
	if panel_style != null:
		_hotbar_container.add_theme_stylebox_override("panel", panel_style)
	$Margin/Bottom.add_child(_hotbar_container)
	$Margin/Bottom.move_child(_hotbar_container, 0)

	_hotbar_button_bar = HBoxContainer.new()
	_hotbar_button_bar.add_theme_constant_override("separation", 4)
	_hotbar_container.add_child(_hotbar_button_bar)

	var hotbar := GameState.get_spell_hotbar()
	for i in range(hotbar.size()):
		var btn := Button.new()
		btn.text = str(i + 1)
		btn.custom_minimum_size = Vector2(44, 44)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.6))
		btn.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.8))
		_apply_hotbar_button_skin(btn)
		btn.pressed.connect(_on_hud_hotbar_button_pressed.bind(i))
		btn.mouse_entered.connect(_on_hud_hotbar_button_hovered.bind(i))
		btn.mouse_exited.connect(_on_hud_hotbar_button_unhovered)
		_hotbar_button_bar.add_child(btn)
		_hotbar_button_nodes.append(btn)


func _make_action_panel_style() -> StyleBoxTexture:
	var tex: Texture2D = load(ACTION_PANEL_TEX)
	if tex == null:
		return null
	var style := StyleBoxTexture.new()
	style.texture = tex
	# Use band 1 of Action_panel.png: the horizontal bar frame at y=8-35, x=8-184
	style.region_rect = Rect2(8, 8, 176, 27)
	# 9-patch margins: match the frame border width (~5px on each side)
	style.texture_margin_left = 5.0
	style.texture_margin_top = 5.0
	style.texture_margin_right = 5.0
	style.texture_margin_bottom = 5.0
	# Expand margins = internal padding for children
	style.expand_margin_left = 4.0
	style.expand_margin_top = 4.0
	style.expand_margin_right = 4.0
	style.expand_margin_bottom = 4.0
	return style


func _apply_hotbar_button_skin(btn: Button) -> void:
	var tex: Texture2D = load(BUTTONS_TEX)
	if tex == null:
		return
	# Buttons.png: 22x22 green square buttons at x=13/61/109/157, y=12
	# Column 1 (x=13): standard green — Normal state
	# Column 2 (x=61): slightly darker — Pressed state
	# Column 3 (x=109): brighter/highlighted — Hover/Focus state
	# Column 4 (x=157): another variant — Disabled state
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
	var hotbar := GameState.get_spell_hotbar()
	for i in range(_hotbar_button_nodes.size()):
		var btn: Button = _hotbar_button_nodes[i]
		if i >= hotbar.size():
			continue
		var skill_id := str(hotbar[i].get("skill_id", ""))
		var slot_label := str(hotbar[i].get("label", str(i + 1)))
		if skill_id == "":
			btn.text = "%s\n---" % slot_label
		else:
			var short_name := _get_skill_short_name(skill_id)
			var cd := float(GameState.buff_cooldowns.get(skill_id, 0.0))
			if cd > 0.0:
				btn.text = "%s\n%s\nCD%.0f" % [slot_label, short_name, cd]
			else:
				btn.text = "%s\n%s" % [slot_label, short_name]


func _on_hud_hotbar_button_hovered(slot_index: int) -> void:
	var hotbar := GameState.get_spell_hotbar()
	if slot_index >= hotbar.size():
		return
	var skill_id := str(hotbar[slot_index].get("skill_id", ""))
	if skill_id == "":
		hint_label.text = "[empty slot]"
		return
	var skill_data := GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty():
		hint_label.text = skill_id
		return
	var display_name := str(skill_data.get("display_name", skill_id))
	var mp_cost := int(skill_data.get("mana_cost_base", 0))
	var cd_base := float(skill_data.get("cooldown_base", 0.0))
	var cd_remaining := float(GameState.buff_cooldowns.get(skill_id, 0.0))
	var cd_text := "CD %.1fs" % cd_remaining if cd_remaining > 0.0 else "ready"
	hint_label.text = "%s  MP %d  %s  (base CD %.0fs)" % [display_name, mp_cost, cd_text, cd_base]


func _on_hud_hotbar_button_unhovered() -> void:
	hint_label.text = ""


func _on_hud_hotbar_button_pressed(slot_index: int) -> void:
	var player_nodes := get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return
	var player := player_nodes[0]
	if player != null and player.has_method("cast_hotbar_slot"):
		player.cast_hotbar_slot(slot_index)


func _get_skill_short_name(skill_id: String) -> String:
	var skill_data := GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty():
		return str(skill_data.get("display_name", skill_id)).split(" ")[0].left(8)
	var spell_data := GameDatabase.get_spell(skill_id)
	if not spell_data.is_empty():
		return str(spell_data.get("name", skill_id)).split(" ")[0].left(8)
	return skill_id.left(8)


func set_room_title(title: String) -> void:
	room_label.text = (
		"%s  Circle %d  Score %.1f"
		% [title, GameState.get_current_circle(), GameState.get_circle_progress_score()]
	)


func refresh(_unused: String = "") -> void:
	_refresh_hotbar_buttons()
	_refresh_resource_bars()
	_refresh_buff_chips()
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
	var hotbar_text := _get_player_hotbar_summary()
	var cast_feedback_text := _get_player_cast_feedback_summary()
	var toggle_text := _get_player_toggle_summary()
	room_label.text = (
		"%s  Circle %d  Score %.1f"
		% [
			room_label.text.split("  Circle")[0],
			GameState.get_current_circle(),
			GameState.get_circle_progress_score()
		]
	)
	buff_label.text = (
		"%s\n%s\n%s\n%s\n%s\n%s"
		% [
			hotbar_text,
			cast_feedback_text,
			toggle_text,
			GameState.get_equipment_summary(),
			GameState.get_active_buff_summary(),
			GameState.get_buff_cooldown_summary()
		]
	)
	combo_label.text = (
		"%s   %s   Keys  Q Veil / R Pyre / F Frost / T Aegis / G Tempest / B Surge / Y Compress / H Hourglass / J Pact / N Throne"
		% [GameState.get_combo_summary(), GameState.get_combat_stats_summary()]
	)
	admin_label.text = "%s  %s" % [GameState.get_admin_status_summary(), _get_admin_tab_summary()]


func _on_message(text: String, _duration: float) -> void:
	hint_label.text = text


func _get_player_hotbar_summary() -> String:
	var player_nodes := get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return "Hotbar  unavailable"
	var player := player_nodes[0]
	if player != null and player.has_method("get_hotbar_summary"):
		return str(player.get_hotbar_summary())
	return "Hotbar  unavailable"


func _get_player_hotbar_mastery_summary() -> String:
	var player_nodes := get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return "Skills  unavailable"
	var player := player_nodes[0]
	if player != null and player.has_method("get_hotbar_mastery_summary"):
		return str(player.get_hotbar_mastery_summary())
	return "Skills  unavailable"


func _get_player_cast_feedback_summary() -> String:
	var player_nodes := get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return "Cast  unavailable"
	var player := player_nodes[0]
	if player != null and player.has_method("get_cast_feedback_summary"):
		return str(player.get_cast_feedback_summary())
	return "Cast  unavailable"


func _get_player_toggle_summary() -> String:
	var player_nodes := get_tree().get_nodes_in_group("player")
	if player_nodes.is_empty():
		return "Toggles  unavailable"
	var player := player_nodes[0]
	if player != null and player.has_method("get_toggle_summary"):
		return str(player.get_toggle_summary())
	return "Toggles  unavailable"


func _get_admin_tab_summary() -> String:
	var admin_nodes := get_tree().get_nodes_in_group("admin_menu")
	if admin_nodes.is_empty():
		return "Tab[closed]"
	var admin_menu := admin_nodes[0]
	if admin_menu != null and admin_menu.has_method("get_admin_tab_summary"):
		return str(admin_menu.get_admin_tab_summary())
	return "Tab[closed]"

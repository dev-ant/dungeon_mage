extends PanelContainer

class_name UiWindowFrame

const SETTINGS_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/pixel_rpg/Settings.png")
const BUTTONS_TEXTURE: Texture2D = preload("res://assets/ui/pixel_rpg/Buttons.png")
const ACTION_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/pixel_rpg/Action_panel.png")
const SETTINGS_FRAME_REGION := Rect2(7, 0, 98, 149)
const BUTTON_CLOSE_NORMAL_REGION := Rect2(13, 12, 22, 23)
const BUTTON_CLOSE_HOVER_REGION := Rect2(61, 13, 22, 22)
const BUTTON_CLOSE_PRESSED_REGION := Rect2(109, 12, 22, 23)
const BUTTON_LARGE_NORMAL_REGION := Rect2(3, 96, 42, 32)
const BUTTON_LARGE_HOVER_REGION := Rect2(51, 96, 42, 32)
const BUTTON_LARGE_PRESSED_REGION := Rect2(147, 96, 42, 32)
const ACTION_PANEL_SLOT_NORMAL_REGION := Rect2(13, 77, 22, 19)
const ACTION_PANEL_SLOT_ACTIVE_REGION := Rect2(61, 77, 22, 19)

signal close_requested(window_id: String)
signal focus_requested(window_id: String)
signal moved(window_id: String, position: Vector2)

var window_id := "window"
var window_title := "Window"
var placeholder_text := ""
var default_size := Vector2(360.0, 280.0)
var default_position := Vector2(120.0, 96.0)
var window_accent_color := Color(0.46, 0.74, 0.96, 0.98)

var _title_accent: ColorRect = null
var _title_bar: HBoxContainer = null
var _title_label: Label = null
var _close_button: Button = null
var _content_root: MarginContainer = null
var _placeholder_label: Label = null
var _is_dragging := false
var _drag_offset := Vector2.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = default_size
	size = default_size
	_build_frame()
	_apply_window_style()
	_refresh_copy()


func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
		focus_requested.emit(window_id)


func _input(event: InputEvent) -> void:
	if not _is_dragging:
		return
	var motion_event := event as InputEventMouseMotion
	if motion_event != null:
		position = get_global_mouse_position() - _drag_offset
		moved.emit(window_id, position)
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event != null and mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
		_is_dragging = false
		moved.emit(window_id, position)


func set_window_opacity(opacity: float, focused: bool) -> void:
	var resolved_opacity := opacity if focused else maxf(opacity - 0.12, 0.60)
	modulate = Color(1.0, 1.0, 1.0, resolved_opacity)


func get_default_window_position() -> Vector2:
	return default_position


func get_content_root() -> MarginContainer:
	return _content_root


func clear_content_root() -> void:
	if _content_root == null:
		return
	for child in _content_root.get_children():
		_content_root.remove_child(child)
		child.queue_free()


func _build_frame() -> void:
	if _title_bar != null:
		return
	var root := VBoxContainer.new()
	root.name = "Root"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root)

	_title_accent = ColorRect.new()
	_title_accent.name = "TitleAccent"
	_title_accent.custom_minimum_size = Vector2(0.0, 4.0)
	_title_accent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_title_accent)

	_title_bar = HBoxContainer.new()
	_title_bar.name = "TitleBar"
	_title_bar.custom_minimum_size = Vector2(0.0, 28.0)
	_title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	_title_bar.add_theme_constant_override("separation", 8)
	_title_bar.add_theme_constant_override("margin_left", 2)
	_title_bar.add_theme_constant_override("margin_right", 2)
	_title_bar.gui_input.connect(_on_title_bar_gui_input)
	root.add_child(_title_bar)

	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 15)
	_title_bar.add_child(_title_label)

	_close_button = Button.new()
	_close_button.name = "CloseButton"
	_close_button.text = "X"
	_close_button.custom_minimum_size = Vector2(28.0, 22.0)
	_close_button.focus_mode = Control.FOCUS_NONE
	_close_button.pressed.connect(func() -> void: close_requested.emit(window_id))
	_title_bar.add_child(_close_button)

	_content_root = MarginContainer.new()
	_content_root.name = "ContentRoot"
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_root.add_theme_constant_override("margin_left", 12)
	_content_root.add_theme_constant_override("margin_top", 10)
	_content_root.add_theme_constant_override("margin_right", 12)
	_content_root.add_theme_constant_override("margin_bottom", 12)
	root.add_child(_content_root)

	_placeholder_label = Label.new()
	_placeholder_label.name = "Placeholder"
	_placeholder_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_placeholder_label.add_theme_font_size_override("font_size", 13)
	_content_root.add_child(_placeholder_label)


func _apply_window_style() -> void:
	var panel_style := _build_asset_window_panel_style()
	add_theme_stylebox_override("panel", panel_style)
	if _title_accent != null:
		_title_accent.color = window_accent_color
	if _title_label != null:
		_title_label.modulate = Color(0.96, 0.98, 1.0, 1.0)
		_title_label.add_theme_color_override("font_outline_color", window_accent_color.darkened(0.55))
		_title_label.add_theme_constant_override("outline_size", 1)
	if _close_button != null:
		_apply_close_button_skin(_close_button)


func _refresh_copy() -> void:
	if _title_label != null:
		_title_label.text = window_title
	if _placeholder_label != null:
		_placeholder_label.text = placeholder_text


func _apply_close_button_skin(button: Button) -> void:
	button.add_theme_stylebox_override(
		"normal",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_CLOSE_NORMAL_REGION, 6, 7, 6, 7)
	)
	button.add_theme_stylebox_override(
		"hover",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_CLOSE_HOVER_REGION, 6, 7, 6, 7)
	)
	button.add_theme_stylebox_override(
		"pressed",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_CLOSE_PRESSED_REGION, 6, 7, 6, 7)
	)
	button.add_theme_color_override("font_color", Color(0.14, 0.18, 0.21, 0.96))
	button.add_theme_color_override("font_hover_color", Color(0.08, 0.12, 0.14, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.08, 0.12, 0.14, 1.0))
	button.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.32))
	button.add_theme_constant_override("outline_size", 1)


func _apply_tab_container_skin(tab_container: TabContainer, accent_color: Color) -> void:
	if tab_container == null:
		return
	var panel := _build_button_style(Color(0.92, 0.95, 0.99, 0.98), Color(0.70, 0.78, 0.88, 0.96), 2, 10)
	var selected := _build_button_style(accent_color, accent_color.lightened(0.28), 2, 10)
	var unselected := _build_button_style(
		Color(0.82, 0.85, 0.91, 0.92),
		Color(0.60, 0.67, 0.76, 0.92),
		2,
		10
	)
	var hovered := _build_button_style(
		accent_color.lightened(0.12),
		accent_color.lightened(0.34),
		2,
		10
	)
	tab_container.add_theme_stylebox_override("panel", panel)
	tab_container.add_theme_stylebox_override("tab_selected", selected)
	tab_container.add_theme_stylebox_override("tab_unselected", unselected)
	tab_container.add_theme_stylebox_override("tab_hovered", hovered)
	tab_container.add_theme_stylebox_override("tab_disabled", unselected)
	tab_container.add_theme_color_override("font_selected_color", Color(0.08, 0.14, 0.22, 1.0))
	tab_container.add_theme_color_override("font_unselected_color", Color(0.90, 0.94, 1.0, 0.96))
	tab_container.add_theme_color_override("font_hovered_color", Color(0.05, 0.10, 0.18, 1.0))


func _apply_action_button_skin(
	button: Button,
	accent_color: Color,
	is_secondary: bool = false
) -> void:
	if button == null:
		return
	var normal_fill := Color(0.92, 0.95, 0.99, 0.98) if not is_secondary else Color(0.82, 0.86, 0.93, 0.94)
	var normal_border := accent_color.darkened(0.10) if not is_secondary else accent_color.darkened(0.28)
	button.add_theme_stylebox_override("normal", _build_button_style(normal_fill, normal_border, 2, 8))
	button.add_theme_stylebox_override(
		"hover",
		_build_button_style(accent_color.lightened(0.18), accent_color.lightened(0.30), 2, 8)
	)
	button.add_theme_stylebox_override(
		"pressed",
		_build_button_style(accent_color, accent_color.lightened(0.36), 2, 8)
	)
	button.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.08, 0.12, 0.18, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.06, 0.08, 0.14, 1.0))


func _apply_asset_large_button_skin(button: Button) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override(
		"normal",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_LARGE_NORMAL_REGION, 10, 9, 10, 9)
	)
	button.add_theme_stylebox_override(
		"hover",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_LARGE_HOVER_REGION, 10, 9, 10, 9)
	)
	button.add_theme_stylebox_override(
		"pressed",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_LARGE_PRESSED_REGION, 10, 9, 10, 9)
	)
	button.add_theme_stylebox_override(
		"focus",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_LARGE_HOVER_REGION, 10, 9, 10, 9)
	)
	button.add_theme_stylebox_override(
		"hover_pressed",
		_build_asset_button_style(BUTTONS_TEXTURE, BUTTON_LARGE_PRESSED_REGION, 10, 9, 10, 9)
	)
	button.add_theme_color_override("font_color", Color(0.06, 0.12, 0.10, 0.98))
	button.add_theme_color_override("font_hover_color", Color(0.04, 0.10, 0.08, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.02, 0.08, 0.06, 1.0))
	button.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.28))
	button.add_theme_constant_override("outline_size", 1)


func _apply_info_badge_skin(panel: PanelContainer, accent_color: Color) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override(
		"panel",
		_build_button_style(
			accent_color.darkened(0.18),
			accent_color.lightened(0.30),
			2,
			10
		)
	)


func _build_window_soft_panel_style(
	fill_color: Color = Color(0.92, 0.95, 0.99, 0.98),
	border_color: Color = Color(0.70, 0.77, 0.86, 1.0),
	corner_radius: int = 10
) -> StyleBoxFlat:
	return _build_button_style(fill_color, border_color, 2, corner_radius)


func _build_asset_window_panel_style() -> StyleBoxTexture:
	return _build_atlas_stylebox(
		SETTINGS_PANEL_TEXTURE,
		SETTINGS_FRAME_REGION,
		12,
		12,
		12,
		12,
		10.0,
		8.0,
		10.0,
		8.0
	)


func _build_asset_compact_panel_style() -> StyleBoxTexture:
	return _build_atlas_stylebox(
		SETTINGS_PANEL_TEXTURE,
		SETTINGS_FRAME_REGION,
		12,
		12,
		12,
		12,
		8.0,
		6.0,
		8.0,
		6.0
	)


func _build_asset_slot_style(active: bool = false) -> StyleBoxTexture:
	var region := ACTION_PANEL_SLOT_ACTIVE_REGION if active else ACTION_PANEL_SLOT_NORMAL_REGION
	return _build_atlas_stylebox(
		ACTION_PANEL_TEXTURE,
		region,
		5,
		5,
		5,
		5,
		4.0,
		4.0,
		4.0,
		4.0
	)


func _build_textured_panel_style(
	fill_color: Color,
	border_color: Color,
	corner_radius: int = 10,
	border_width: int = 2,
	gloss_strength: float = 0.12,
	stripe_strength: float = 0.035,
	shadow_strength: float = 0.07
) -> StyleBoxTexture:
	var texture_size := 48
	var image := _build_textured_box_image(
		texture_size,
		fill_color,
		border_color,
		corner_radius,
		border_width,
		gloss_strength,
		stripe_strength,
		shadow_strength
	)
	var style := StyleBoxTexture.new()
	style.texture = ImageTexture.create_from_image(image)
	style.texture_margin_left = corner_radius + border_width
	style.texture_margin_top = corner_radius + border_width
	style.texture_margin_right = corner_radius + border_width
	style.texture_margin_bottom = corner_radius + border_width
	return style


func _build_asset_button_style(
	texture: Texture2D,
	region: Rect2,
	margin_left: int = 8,
	margin_top: int = 6,
	margin_right: int = 8,
	margin_bottom: int = 6
) -> StyleBoxTexture:
	return _build_atlas_stylebox(
		texture,
		region,
		margin_left,
		margin_top,
		margin_right,
		margin_bottom,
		6.0,
		3.0,
		6.0,
		3.0
	)


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


func _apply_setting_row_skin(panel: PanelContainer, accent_color: Color, emphasized: bool = false) -> void:
	if panel == null:
		return
	var fill := Color(0.97, 0.985, 1.0, 0.99) if not emphasized else accent_color.lightened(0.72)
	var border := Color(0.78, 0.82, 0.89, 1.0) if not emphasized else accent_color.lightened(0.14)
	panel.add_theme_stylebox_override("panel", _build_textured_panel_style(fill, border, 10))


func _apply_slider_skin(slider: HSlider, accent_color: Color) -> void:
	if slider == null:
		return
	slider.custom_minimum_size = Vector2(0.0, 24.0)
	slider.add_theme_stylebox_override(
		"grabber_area",
		_build_button_style(Color(0.85, 0.88, 0.93, 0.92), Color(0.72, 0.78, 0.86, 0.98), 2, 7)
	)
	slider.add_theme_stylebox_override(
		"grabber_area_highlight",
		_build_button_style(accent_color.lightened(0.52), accent_color.lightened(0.16), 2, 7)
	)
	slider.add_theme_stylebox_override(
		"slider",
		_build_button_style(Color(0.96, 0.98, 1.0, 1.0), Color(0.82, 0.86, 0.92, 1.0), 1, 8)
	)
	slider.add_theme_icon_override("grabber", _build_circle_icon_texture(16, accent_color, accent_color.darkened(0.34)))
	slider.add_theme_icon_override(
		"grabber_highlight",
		_build_circle_icon_texture(16, accent_color.lightened(0.12), accent_color.darkened(0.20))
	)
	slider.add_theme_icon_override(
		"grabber_disabled",
		_build_circle_icon_texture(16, Color(0.78, 0.82, 0.88, 0.84), Color(0.62, 0.67, 0.74, 0.92))
	)


func _apply_checkbox_skin(checkbox: CheckBox, accent_color: Color) -> void:
	if checkbox == null:
		return
	checkbox.add_theme_constant_override("h_separation", 10)
	checkbox.add_theme_icon_override("checked", _build_checkbox_icon_texture(true, accent_color, false))
	checkbox.add_theme_icon_override("unchecked", _build_checkbox_icon_texture(false, accent_color, false))
	checkbox.add_theme_icon_override("checked_disabled", _build_checkbox_icon_texture(true, accent_color, true))
	checkbox.add_theme_icon_override("unchecked_disabled", _build_checkbox_icon_texture(false, accent_color, true))
	checkbox.add_theme_color_override("font_color", Color(0.12, 0.18, 0.26, 1.0))
	checkbox.add_theme_color_override("font_hover_color", Color(0.08, 0.12, 0.20, 1.0))
	checkbox.add_theme_color_override("font_pressed_color", Color(0.08, 0.12, 0.20, 1.0))
	checkbox.add_theme_color_override("font_focus_color", Color(0.08, 0.12, 0.20, 1.0))
	checkbox.add_theme_color_override("font_outline_color", accent_color.darkened(0.65))
	checkbox.add_theme_constant_override("outline_size", 1)


func _build_button_style(
	fill_color: Color,
	border_color: Color,
	border_width: int = 2,
	corner_radius: int = 8
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	return style


func _build_circle_icon_texture(size: int, fill_color: Color, border_color: Color) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	var center := (float(size) - 1.0) * 0.5
	var radius := center - 0.5
	var border_start := radius - 2.0
	for y in range(size):
		for x in range(size):
			var dx := float(x) - center
			var dy := float(y) - center
			var distance := sqrt(dx * dx + dy * dy)
			if distance > radius:
				continue
			if distance >= border_start:
				image.set_pixel(x, y, border_color)
			else:
				image.set_pixel(x, y, fill_color)
	return ImageTexture.create_from_image(image)


func _build_textured_box_image(
	size: int,
	fill_color: Color,
	border_color: Color,
	corner_radius: int,
	border_width: int,
	gloss_strength: float,
	stripe_strength: float,
	shadow_strength: float
) -> Image:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(size):
		for x in range(size):
			if not _is_point_in_rounded_rect(x, y, size, size, corner_radius):
				continue
			var is_border := not _is_point_in_rounded_rect(
				x - border_width,
				y - border_width,
				size - (border_width * 2),
				size - (border_width * 2),
				maxi(corner_radius - border_width, 0)
			)
			if is_border:
				image.set_pixel(x, y, border_color)
				continue
			var vertical_ratio := float(y) / maxf(float(size - 1), 1.0)
			var shaded := fill_color.lerp(fill_color.darkened(shadow_strength), vertical_ratio * 0.75)
			var gloss_mix := maxf(0.0, 1.0 - (vertical_ratio / 0.45)) * gloss_strength
			shaded = shaded.lerp(Color(1.0, 1.0, 1.0, fill_color.a), gloss_mix)
			var stripe_band := sin((float(x) + float(y * 2)) * 0.32) * 0.5 + 0.5
			shaded = shaded.lerp(Color(1.0, 1.0, 1.0, fill_color.a), stripe_band * stripe_strength)
			if y > size * 0.68:
				var footer_ratio := (float(y) - (size * 0.68)) / maxf(size * 0.32, 1.0)
				shaded = shaded.lerp(fill_color.darkened(shadow_strength * 1.35), footer_ratio * 0.55)
			image.set_pixel(x, y, shaded)
	return image


func _is_point_in_rounded_rect(px: int, py: int, width: int, height: int, radius: int) -> bool:
	if width <= 0 or height <= 0:
		return false
	if radius <= 0:
		return px >= 0 and py >= 0 and px < width and py < height
	if px < 0 or py < 0 or px >= width or py >= height:
		return false
	var max_radius := mini(radius, mini(width, height) / 2)
	if (px >= max_radius and px < width - max_radius) or (py >= max_radius and py < height - max_radius):
		return true
	var center_x := max_radius if px < max_radius else width - max_radius - 1
	var center_y := max_radius if py < max_radius else height - max_radius - 1
	var dx := float(px - center_x)
	var dy := float(py - center_y)
	return dx * dx + dy * dy <= float(max_radius * max_radius)


func _build_checkbox_icon_texture(checked: bool, accent_color: Color, disabled: bool) -> Texture2D:
	var size := 18
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	var border := accent_color.darkened(0.22) if not disabled else Color(0.60, 0.64, 0.70, 0.90)
	var fill := Color(0.97, 0.985, 1.0, 1.0) if not disabled else Color(0.90, 0.92, 0.96, 0.92)
	var checked_fill := accent_color.lightened(0.58) if not disabled else Color(0.78, 0.82, 0.88, 0.88)
	for y in range(size):
		for x in range(size):
			var is_border := x <= 1 or y <= 1 or x >= size - 2 or y >= size - 2
			var color := border if is_border else (checked_fill if checked else fill)
			image.set_pixel(x, y, color)
	if checked:
		var mark_color := border.darkened(0.18)
		for x in range(4, 8):
			image.set_pixel(x, 10 + (x - 4), mark_color)
			image.set_pixel(x, 11 + (x - 4), mark_color)
		for x in range(8, 14):
			image.set_pixel(x, 16 - x, mark_color)
			image.set_pixel(x, 15 - x, mark_color)
	return ImageTexture.create_from_image(image)


func _on_title_bar_gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if mouse_event.pressed:
		_is_dragging = true
		_drag_offset = get_global_mouse_position() - position
		focus_requested.emit(window_id)
		return
	_is_dragging = false
	moved.emit(window_id, position)
